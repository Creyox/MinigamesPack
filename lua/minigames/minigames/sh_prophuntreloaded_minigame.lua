if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

MINIGAME.conVarData = {
  ttt2_minigames_prophuntreloaded = {
    slider = true,
    min = 0,
    max = 1,
    decimal = 3, 
    desc = "ttt2_minigames_prophuntreloaded traitor pct (Def. 0.125)"
  }
}

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Prop Hunt Reloaded"
    },
    desc = {
      English = "One traitor against everyone else"
    }
  }
end

if SERVER then
  local ttt2_minigames_prophuntreloaded = CreateConVar("ttt2_minigames_prophuntreloaded", "0.125", {FCVAR_ARCHIVE}, "Determines how many traitors are selected")
  local oldFallback = GetConVar("ttt_traitor_shop_fallback")
  if oldFallback then
    oldFallback = oldFallback:GetString()
  else 
    oldFallback = "UNSET"
  end
  function MINIGAME:OnActivation()
    local selectedTraitors = 0
    local plys = util.GetAlivePlayers()
    local traitorAmount = ttt2_minigames_prophuntreloaded:GetFloat() * #plys
    if traitorAmount < 1 then 
      traitorAmount = 1
    else 
      traitorAmount = math.floor(traitorAmount)
    end
    local arg1 = "DISABLED"
    RunConsoleCommand("ttt_traitor_shop_fallback", arg1)

    for i = 1, #plys do
      plys[i]:SetRole(ROLE_INNOCENT, TEAM_INNOCENT)
    end

    repeat 
      local ply = selectRandomPlayer()
      if ply:GetSubRole() ~= ROLE_TRAITOR then 
        ply:SetRole(ROLE_TRAITOR, TEAM_TRAITOR)
        selectedTraitors = selectedTraitors + 1  
      end
    until selectedTraitors == traitorAmount

    for i = 1, #plys do 
      if plys[i]:GetSubRole() ~= ROLE_TRAITOR then
        local weps = plys[i]:GetWeapons()
        for j = 1, #weps do
          if weps[j].ClassName ~= "weapon_crowbar" and weps[j].ClassName ~= "weapon_zm_improvised" then
            plys[i]:StripWeapon(weps[j].ClassName)
          end
        end
        plys[i]:GiveEquipmentWeapon("weapon_ttt_prop_disguiser")
        plys[i]:GiveEquipmentItem("item_ttt_nopropdmg")
        plys[i]:SelectWeapon("weapon_ttt_prop_disguiser")
        plys[i]:ShouldDropWeapon(false)
        local wep = plys[i]:GetActiveWeapon()
        wep.AllowDrop = false
        wep.DisguiseTime = 600
      end
		end
    SendFullStateUpdate()
    hook.Add( "PlayerCanPickupWeapon", "PropHunt_Minigame_NoPickup", function (ply, weapon)
      if ply:GetSubRole() == ROLE_TRAITOR then
        return true
      else
        return false
      end
    end)
  end

  function MINIGAME:OnDeactivation()
    RunConsoleCommand("ttt_traitor_shop_fallback", oldFallback)
    hook.Remove("PlayerCanPickupWeapon", "PropHunt_Minigame_NoPickup")
  end

  function MINIGAME:IsSelectable()
    if not WEPS.IsInstalled("weapon_ttt_prop_disguiser") then
      return false
    else
      return true
    end
  end

  function selectRandomPlayer()
    local ply
    local plys = util.GetAlivePlayers()
    repeat
      if #plys <= 0 then return end
      local rnd = math.random(#plys)
      ply = plys[rnd]
      table.remove(plys, rnd)
    until IsValid(ply)
    return ply
  end
end
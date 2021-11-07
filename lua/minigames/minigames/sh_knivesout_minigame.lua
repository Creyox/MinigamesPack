if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Knives out"
    },
    desc = {
      English = "Stabb \'em in the head, before they hit you back"
    }
  }

end

if SERVER then
  local oldPreventWin = GetConVar("ttt_debug_preventwin")

  function MINIGAME:OnActivation()
    RunConsoleCommand("ttt_debug_preventwin", 1)
    local plys = util.GetAlivePlayers()
    for i = 1, #plys do 
      plys[i]:SetRole(ROLE_SERIALKILLER, TEAM_NONE)
      local weps = plys[i]:GetWeapons()
      for j = 1, #weps do
        if weps[j].ClassName ~= "weapon_crowbar" and weps[j].ClassName ~= "weapon_zm_improvised" then
          plys[i]:StripWeapon(weps[j].ClassName)
        end
      end
      plys[i]:GiveEquipmentWeapon("weapon_ttt_knife")
      plys[i]:SelectWeapon("weapon_ttt_knife")
    end
    hook.Add( "PlayerCanPickupWeapon", "knivesOut_Minigame_Pickup", function(ply, weapon)
      return ( weapon:GetClass() == "weapon_ttt_knife" )
    end)
    SendFullStateUpdate()

    hook.Add("PlayerDeath", "knivesOut_Minigame_PlayerDeath", function(victim, inflictor, attacker)
        local plys = util.GetAlivePlayers()
        if #plys <= 1 then
          RunConsoleCommand("ttt_debug_preventwin", 0)
        end
    end)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("PlayerCanPickupWeapon", "knivesOut_Minigame_Pickup")
    hook.Remove("PlayerDeath", "knivesOut_Minigame_PlayerDeath")
  end

  function MINIGAME:IsSelectable()
    if not WEPS.IsInstalled("weapon_ttt_knife") or not SERIALKILLER then
      return false
    else
      return true
    end
  end

end
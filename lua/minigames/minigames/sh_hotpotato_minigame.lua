if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis, Hot Potato addon by SkyDivingL"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Hot Potato"
    }
  }
end

if SERVER then
  function MINIGAME:OnActivation()
    local plys = util.GetAlivePlayers()
    local randomPlayer = plys[math.random(1,#plys)]
		randomPlayer:GiveEquipmentWeapon("weapon_ttt_hotpotato")
    randomPlayer:SelectWeapon("weapon_ttt_hotpotato")
    local wep = randomPlayer:GetActiveWeapon()
		if IsValid( wep ) and wep:GetClass() == "weapon_ttt_hotpotato" then
			wep:PotatoTime( randomPlayer, randomPlayer )
    end 
  end
  function MINIGAME:IsSelectable()
    if not WEPS.IsInstalled("weapon_ttt_hotpotato") then
      return false
    else
      return true
    end 
  end


end
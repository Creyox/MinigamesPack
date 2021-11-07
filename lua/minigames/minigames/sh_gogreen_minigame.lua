if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Go Green!"
    },
    desc = {
      English = "Vapes for everyone"
    }
  }
end

if SERVER then
  function MINIGAME:OnActivation()
    local plys = util.GetAlivePlayers()
		for i = 1, #plys do
		  local ply = plys[i]
		  ply:GiveEquipmentWeapon("weapon_vape_medicinal")
		end
  end

  function MINIGAME:OnDeactivation()
    return
  end
   
  function MINIGAME:IsSelectable()
    if not WEPS.IsInstalled("weapon_vape_medicinal") then
      return false
    else
      return true
    end
  end
end
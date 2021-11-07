if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Captain Obvious"
    },
    desc = {
      English = "Find out who the defectives are!"
    }
  }
end

if SERVER then
  local oldDeteImmunity = GetConVar("ttt2_defective_detective_immunity") 
  local oldDefectiveSee = GetConVar("ttt2_defective_can_see_defectives")
  function MINIGAME:OnActivation()
    local plys = util.GetAlivePlayers()
    if #plys < 2 then return end
    for i = 1, #plys do 
      if i % 2 == 0 then
        plys[i]:SetRole(ROLE_DETECTIVE, TEAM_DETECTIVE)
      else 
        plys[i]:SetRole(ROLE_DEFECTIVE, TEAM_TRAITOR)
      end
    end
    SendFullStateUpdate()
    RunConsoleCommand("ttt2_defective_detective_immunity", 0)
    RunConsoleCommand("ttt2_defective_can_see_defectives", 0)
  end

  function MINIGAME:OnDeactivation()
    RunConsoleCommand("ttt2_defective_detective_immunity", oldDeteImmunity)
    RunConsoleCommand("ttt2_defective_can_see_defectives", oldDefectiveSee)
  end 

  function MINIGAME:IsSelectabel()
    if DEFECTIVE then
      return true
    else 
      return false
    end
  end
end
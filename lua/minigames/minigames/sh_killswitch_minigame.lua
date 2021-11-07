if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

MINIGAME.conVarData = {
  ttt2_minigames_killswitch_assign_rdm = {
		checkbox = true,
		desc = "ttt2_minigames_killswitch_assign_rdm (Def. 1)"
	},
  ttt2_minigames_killswitch_killtimer = {
    slider = true,
    min = 0,
    max = 3,
    decimal = 3, 
    desc = "The time a traitor has got to get a kill (Def. 0.5s)"
  }
}

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Kill Switch"
    },
    desc = {
      English = "When the traitors miss a kill, they lose their role!"
    }
  }
else 
  util.AddNetworkString("killswitch_minigame_announcement")
end

if SERVER then
  local ttt2_minigames_killswitch_assign_rdm = CreateConVar("ttt2_minigames_killswitch_assign_rdm", "1", {FCVAR_ARCHIVE}, "Whether a lost role is assigned randomly or swapped")
  local ttt2_minigames_killswitch_killtimer = CreateConVar("ttt2_minigames_killswitch_assign_rdm", "0.5", {FCVAR_ARCHIVE}, "The time a traitor has to get a kill")

  function SwapRole(ply, attacker)
    local oldRole = ply:GetSubRole()
    local oldTeam = ply:GetTeam()
    ply:SetRole(attacker:GetSubRole(), attacker:GetTeam())
    attacker:SetRole(oldRole, oldTeam)
    AnnounceSwitch(ply, attacker)
    SendFullStateUpdate()
  end

  function SwapRoleRandom(attacker)
    local plys = util.GetAlivePlayers()
    if #plys <= 1 then return end
    local ply
    for i = 1, #plys do
      if i > #plys then return end
      if IsValid(plys[i]) and plys[i]:GetSubRole()  ~= ROLE_TRAITOR then 
        repeat
          ply = plys[math.random(1, #plys)]
        until IsValid(ply) and ply:GetSubRole() ~= ROLE_TRAITOR
        SwapRole(ply, attacker)
        break
      end
    end
  end

  function AnnounceSwitch(ply, attacker)
    local plys = util.GetAlivePlayers()
    net.Start("killswitch_minigame_announcement")
    for i = 1, #plys do
      if plys[i] ~= ply and plys[i] ~= attacker then
        net.WriteString("killswitch_minigame_others")
      elseif plys[i] == ply then
        net.WriteString("killswitch_minigame_gotrole")
      elseif plys[i] == attacker then
        net.WriteString("killswitch_minigame_lostrole")
      end
      net.Send(plys[i])
    end
  end

  function CheckForSwap(ply, attacker)
    if not (ply:Alive() and attacker:Alive()) then return end
    
    if ttt2_minigames_killswitch_assign_rdm:GetBool() then
      SwapRoleRandom(attacker)
    else 
      SwapRole(plplyayer, attacker)
    end
  end	

  function printa(String)
    print(String)
  end


  function MINIGAME:OnActivation()
    hook.Add("PostEntityTakeDamage", "killswitch_minigame", function(ply, dmginfo, took)
		if not took then return end
    if dmginfo:GetDamage() <= 0 then return end
      if IsValid(ply) and ply:IsPlayer() then 
        local attacker = dmginfo:GetAttacker() -- Fetch the attacker
        if (IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_TRAITOR and ply:GetSubRole() ~= ROLE_TRAITOR) then 
          timer.Create("killswitchKillTimer", ttt2_minigames_killswitch_killtimer:GetFloat(), 1, function() CheckForSwap(ply, attacker) end)
        end
      end
    end)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("PostEntityTakeDamage", "killswitch_minigame")
  end
end

if CLIENT then
  net.Receive("killswitch_minigame_announcement", function()
    local msg = net.ReadString()
    if msg == "killswitch_minigame_others" then
      EPOP:AddMessage({
        text = "A traitor lost his role!",
        color = Color(255, 25, 25, 255)},
        nil,
        5,
        nil,
        true
      )
    elseif msg == "killswitch_minigame_lostrole" then
      EPOP:AddMessage({
        text = "You lost your role!",
        color = Color(255, 25, 25, 255)},
        nil,
        5,
        nil,
        true
      )
    elseif msg == "killswitch_minigame_gotrole" then
      EPOP:AddMessage({
        text = "You became a traitor!",
        color = Color(255, 25, 25, 255)},
        nil,
        5,
        nil,
        true
      )
    end
  end)
end
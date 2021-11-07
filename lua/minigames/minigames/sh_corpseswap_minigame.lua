if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Corpse Swap"
    },
    desc = {
      English = "All players change their position when a body is found"
    }
  }
else
  util.AddNetworkString("corpseSwap_minigame_announcement")
end


if SERVER then
  function MINIGAME:OnActivation() 
    hook.Add("TTTBodyFound", "corpseSwap_minigame_bodyfound", function(ply, deadply, rag)
      local plys = util.GetAlivePlayers()
      if #plys <= 1 then return end
      for i = 1, #plys do
        if IsValid(plys[i]) then 
          SwapPlayerPos(plys[i], plys[math.random(1,#plys)])
        end
      end
      net.Start("corpseSwap_minigame_announcement")
      net.Broadcast()
    end)
  end 

  function SwapPlayerPos(ply1, ply2)
    if not ply1:Alive() then return end
    if not ply2:Alive() then return end
    if ply1:GetPos() == ply2:GetPos() then return end 
    local tempPos = ply1:GetPos()
    ply1:SetPos(ply2:GetPos(), false)
    ply2:SetPos(tempPos, false)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("TTTBodyFound", "corpseSwap_minigame_bodyfound")
  end
end

if CLIENT then
  net.Receive("corpseSwap_minigame_announcement", function()
    EPOP:AddMessage({
      text = "All players changed their position!",
      color = Color(255, 25, 25, 255)},
      nil,
      5,
      nil,
      true
    )
  end)
end
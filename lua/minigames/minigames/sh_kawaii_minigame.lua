if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Crysis"
MINIGAME.contact = "dark-humor.de on TeamSpeak"

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Kawaii"
    },
    desc = {
      English = " "
    }
  }
else
  util.AddNetworkString("kawaii_minigame_screenEffectAdd")
	util.AddNetworkString("kawaii_minigame_screenEffectRemove")
end

if SERVER then
	local kawaisounds = {
		"hentai.mp3",
		"hentai2.mp3",
		"hentai3.mp3",
		"hentai4.mp3",
		"hentaiM2.mp3",
	}
  function MINIGAME:OnActivation()
		hook.Add("PostEntityTakeDamage", "kawaii_minigame_moaning", function(ply, dmginfo, took)
			if not took then return end
				if IsValid(ply) and ply:IsPlayer() and ply:Alive() then 
					net.Start("kawaii_minigame_screenEffectAdd")
					net.Send(ply)
					ply:EmitSound( kawaisounds[1] )
					timer.Create("removeKawaiiScreenEffect", 1.2, 1, function()
						net.Start("kawaii_minigame_screenEffectRemove")
						net.Send(ply)
					end)
				end
		end)
		hook.Add("PlayerDeath", "kawaii_minigame_death", function(ply, inflictor, attacker)
			if IsValid(ply) then
				ply:EmitSound( kawaisounds[3] )
			end
		end)
  end

  function MINIGAME:OnDeactivation()
		hook.Remove("PostEntityTakeDamage", "kawaii_minigame_moaning")
		hook.Remove("PlayerDeath", "kawaii_minigame_death")
  end
end

if CLIENT then
  local color_tbl = {
    ["$pp_colour_addr"] = 1.00,
    ["$pp_colour_addg"] = 0.30,
    ["$pp_colour_addb"] = 1.00,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 1.00,
    ["$pp_colour_mulg"] = 1.00,
    ["$pp_colour_mulb"] = 1.00
  }
	net.Receive("kawaii_minigame_screenEffectAdd", function()
		hook.Add("RenderScreenspaceEffects", "KawaiiMiniGameEffect", function()
      local client = LocalPlayer()
      if not client:Alive() or client:IsSpec() then return end

      DrawColorModify(color_tbl)
      cam.Start3D(EyePos(), EyeAngles())

      render.SuppressEngineLighting(true)
      render.SetColorModulation(1, 1, 1)
      render.SuppressEngineLighting(false)

      cam.End3D()
    end)
	end)
	net.Receive("kawaii_minigame_screenEffectRemove", function()
		hook.Remove("RenderScreenspaceEffects", "KawaiiMiniGameEffect")
	end)
end
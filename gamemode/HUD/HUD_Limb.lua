

local Size = 200
local xPos = -50
local yPos = ScrH() - Size
local playerIcon = Material("icons/player.png")
local injuredIcon = Material("icons/notif_injury.png")
local bleedingIcon = Material("icons/notif_bleeding.png")
local playerAlpha = 235

local iconScaling = .10
 
--[[ hook.Add("HUDPaint", "DrawLimbs", function()
	surface.SetDrawColor(Color(255, 255, 255, playerAlpha))
	surface.SetMaterial(playerIcon)
	surface.DrawTexturedRect(xPos, yPos, Size, Size)
	
	for k,v in pairs(Limbs) do
		if _Limbs[k]["Bleeding"] then 
			surface.SetDrawColor(Color(255, 55, 55, playerAlpha))
			surface.SetMaterial(bleedingIcon)
			local iconSize = (Size * iconScaling)
			local x = (Size - iconSize)/2  - (xPos - v["Bleeding"].x/2)
			print(x) 
			surface.DrawTexturedRect(x, yPos + v["Bleeding"].y, iconSize, iconSize)
		end 
		if _Limbs[k]["Broken"] then
			surface.SetDrawColor(Color(255, 255, 255, playerAlpha))
			surface.SetMaterial(injuredIcon)
			local iconSize = (Size * iconScaling)
			local x = (Size - iconSize)/2  - (xPos - v["Broken"].x/2)
			
			surface.DrawTexturedRect(x, yPos + v["Broken"].y, iconSize, iconSize)
		end
	end
end) ]]
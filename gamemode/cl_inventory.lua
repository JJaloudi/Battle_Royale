surface.CreateFont( "Character", 
{
	font    = "Roboto-Light",
    size    = 18,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "GameMedium", 
{
	font    = "Roboto-Light",
    size    = 14,
    weight  = 1000,
    antialias = true,
    shadow = false
})

net.Receive("ClearInventory",function()
	Inventory = nil
	Inventory = {}
end)

Panel = false

function CalculateWeight()
	local weight = 0
	
	for k,v in pairs(Inventory) do
		if v[1] then
			local stack = v[2]
			local item_weight = GetItemByKey(v[1]).Weight
			
			weight = weight + (item_weight * stack)
		end
	end
	
	return weight
end

net.Receive("OpenContainer",function()
	local ent = net.ReadEntity()
	local inv = net.ReadTable()
	
	OpenInventory(true, ent, inv)
end)

local entContainer = false
net.Receive("UpdateContainerInventory", function()
	local slot = net.ReadUInt(16)
	local data = net.ReadTable()
	
	Panel.ContainerInventory.List:Clear()
	
	Panel.ContainerInventory.Inventory[slot] = data
	
	
	if entContainer then
		if Panel then
			if Panel:IsValid() then
				print("??")
			
				Panel.ContainerInventory:SetInventory(Panel.ContainerInventory.Inventory, entContainer)
			end
		end
	end	
end)

net.Receive("EquipItem", function()
	EquippedItem = net.ReadUInt(16)
	
	Panel.PlayerInventory:SetInventory(Inventory, LocalPlayer())
	
	print("EquippedItem")
end)

function OpenInventory(bPanel, Ent, Inv)
	if !Panel then
		
		if Ent then
			entContainer = Ent
		end
		
	
		local baseSize = 250
		local invSize = 175
		local height = 450

		Panel = vgui.Create("BRFrame")
		
		if bPanel then
			Panel:SetSize(baseSize + invSize * 2, height)
		else
			Panel:SetSize(baseSize + invSize, height)
		end
		
		Panel:Center()
		Panel:MakePopup()
		
		Panel.PlayerInventory = vgui.Create("Inventory", Panel)
		local pInv = Panel.PlayerInventory
		pInv:Title("My Inventory")
		pInv:SetSize(invSize, Panel:GetTall())
		pInv:SetPos(Panel:GetWide() - pInv:GetWide(), 0)
		pInv:SetInventory(Inventory, LocalPlayer())
		
		local pStatus = vgui.Create("BRFrame", Panel)
		pStatus:ShowCloseButton(false)
		pStatus:Title("Player Menu")
		
		if bPanel then
			pStatus:SetPos(invSize, 0)
		end
		
		pStatus:SetSize(baseSize + 1, Panel:GetTall())
		
		local statusIcon = Material("icons/player_icon.png")
		local iWidth, iHeight = pStatus:GetWide(), pStatus:GetTall() - 150
		
		pStatus.PaintOver = function(s)	
			surface.SetDrawColor(GAME_OUTLINE)
			surface.SetMaterial(statusIcon)
			surface.DrawTexturedRect(s:GetWide()/2 - iWidth/2, s:GetTall()/2 - iHeight/2, iWidth, iHeight)
			
			local xPos = 10
			local xSize = s:GetWide() - (xPos * 2)
			local ySize = 30
			local yPos = s:GetTall() - (ySize + 10)
			
			draw.RoundedBoxEx(1,xPos, yPos, xSize, ySize, Color(155, 155, 155, 255))
			
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawOutlinedRect(xPos, yPos, xSize, ySize)
			
			surface.SetFont("GameMedium")
			local width, height = surface.GetTextSize("Weight")
			local nPos = xPos + 10 + width
			
			draw.SimpleText("Weight", "GameMedium", xPos + 5, (yPos + ySize) - height - 8, GAME_OUTLINE)
			draw.RoundedBoxEx(1, nPos, yPos + 3, (xSize - width - 13), ySize - 6.5, GAME_COLOR)
			
			if CalculateWeight() > 0 then			
				draw.RoundedBoxEx(1, nPos, yPos + 3, (xSize - width - 13) * CalculateWeight() / Config.DefaultMaxWeight, ySize - 6.5, GAME_MAIN)
			end
			
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawOutlinedRect(nPos , yPos + 3, xSize - width - 13, ySize - 5.5)
		end
		
		local startPosX, startPosY = pStatus:GetWide()/2 - iWidth/2, pStatus:GetTall()/2 - iHeight/2
		
		local head = vgui.Create("Limb", pStatus)
		head:SetSize(35, 50)
		head:SetPos(startPosX + 108, startPosY - 5)
		head:SetLimb("Head")
		
		local torso = vgui.Create("Limb", pStatus)
		torso:SetPos(startPosX + 99, startPosY + 45)
		torso:SetSize(52, 115)
		torso:SetLimb("Torso")
		
		local leftarm = vgui.Create("Limb", pStatus)
		leftarm:SetPos(startPosX + 69, startPosY + 45)
		leftarm:SetSize(30, 132.5)
		leftarm:SetLimb("Left Arm")
		
		local rightarm = vgui.Create("Limb", pStatus)
		rightarm:SetPos(startPosX + 151, startPosY + 45)
		rightarm:SetSize(30, 132.5)
		rightarm:SetLimb("Right Arm")
		
		local leftleg = vgui.Create("Limb", pStatus)
		leftleg:SetPos(startPosX + 98, startPosY + 160)
		leftleg:SetSize(27.5, 145)
		leftleg:SetLimb("Left Leg")
		 
		local rightleg = vgui.Create("Limb", pStatus)
		rightleg:SetPos(startPosX + 125.5, startPosY + 160)
		rightleg:SetSize(27.5, 145)
		rightleg:SetLimb("Right Leg")
		
		if bPanel then
			Panel.ContainerInventory = vgui.Create("Inventory", Panel)
			
			local entInv = Panel.ContainerInventory
			entInv:SetSize(invSize + 1, height)
			entInv:SetInventory(Inv, Ent)
			entInv:Title(Ent:GetNWString("Name", "Container"))
		end
		
	else
		if Panel:IsValid() then
		
			Panel:Close()
			
			Panel = false
			
			if entContainer then
				net.Start("EndContainerAccess")
					net.WriteEntity(entContainer)
				net.SendToServer()
				
				entContainer = false
			end
			
		end
	end
end

hook.Add("SetupMove", "HandleInventory", function()
	if input.WasKeyPressed(KEY_Q) then
		if LPPlaying() then
			OpenInventory()
		else
			OpenMainMenu()
		end
	end
end)
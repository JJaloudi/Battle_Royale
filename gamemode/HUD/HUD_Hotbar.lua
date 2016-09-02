--[[ LastUse = CurTime()
hook.Add("KeyPress", "HandleSlotUse", function(pl, key)
	if !EquippedItem then return end
	
	if LastUse <= CurTime() then
		if key == IN_ATTACK && !pl:GetActiveWeapon():IsValid() then	
			if Inventory[EquippedItem] then
				if Inventory[EquippedItem][1] then
					if GetItemByKey(Inventory[EquippedItem][1]).SubType then
						print("yer")
					
						net.Start("UseItem")
							net.WriteEntity(LocalPlayer())
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(EquippedItem, 16)
						net.SendToServer()
					end
				else
					EquippedItem = false
				end

			end	
			LastUse = CurTime() + 1
		end
	end
end)
 ]]

function GM:HUDItemPickedUp(item)
	
end

local HUDInventory = {
	_Icons = {}
}

local width = ScrW() * 0.11
local height = 40
local padding = 5

local removeColor = Color(125, 55, 55)
local newColor = Color(55, 125, 55)

local pxIncrement = 15 // increase in pixels

local animationSpeed = 2 // In px per seconds.

for i = 1, 5 do

	HUDInventory._Icons[i] = {
		Width = width,
		Height = height,
		Active = false
	}
	
end


local xPos = ScrW() //starting x-axis position
local yPos = ScrH()  //starting y-axis positon
local yAdd = height + padding 


local ActiveSlot = false
concommand.Add("changeslot", function(pl, cmd, args)
	ActiveSlot = tonumber(args[1]) or 1
end)

surface.CreateFont( "ItemHeader", 
{
	font    = "Roboto-Light",
    size    = ScreenScale(9),
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "ItemBody", 
{
	font    = "Roboto-Light",
    size    = ScreenScale(7.5),
    weight  = 1000,
    antialias = true,
    shadow = false
})

local lockedIcon = Material("icons/perklocked.png")
local handIcon = Material("icons/notify_grab.png")
hook.Add("HUDPaint", "DrawInventory", function(w, h)
	if !LPPlaying() then return end
	
	local ref = HUDInventory._Icons
	
	for i = 1, #ref do 
		local count = #ref + 1
		
		local mRef = ref[i]
		
		if !mRef.x then
			mRef.x = xPos -  (padding + mRef.Width)
			mRef.y = yPos - (yAdd * (count - i) - 1)
		end
		
		if !ActiveSlot then 
			mRef.x = xPos -  (padding + mRef.Width)	
			mRef.y = yPos - (yAdd * (count - i) - 1) 
		else
			if ActiveSlot == i then
				mRef.Width = math.Approach(mRef.Width, width + pxIncrement, animationSpeed)
				mRef.Height = math.Approach(mRef.Height, height + pxIncrement, animationSpeed)
				
				mRef.x = math.Approach(mRef.x, xPos -  (padding + mRef.Width), animationSpeed)
				mRef.y = math.Approach(mRef.y, (yPos - pxIncrement) - (yAdd * (count - i) - 1), animationSpeed)
			else
				mRef.Width = math.Approach(mRef.Width, width, animationSpeed)
				mRef.Height = math.Approach(mRef.Height, height, animationSpeed)
				
				if ActiveSlot > i then
					mRef.x = math.Approach(mRef.x, xPos - (padding + mRef.Width), animationSpeed)	
					mRef.y = math.Approach(mRef.y, (yPos - pxIncrement) - (yAdd * (count - i) - 1), animationSpeed)
				else
					mRef.x = math.Approach(mRef.x, xPos -  (padding + mRef.Width), animationSpeed)
					mRef.y = math.Approach(mRef.y, (yPos + pxIncrement) - (yAdd * (count - i) - 1) - pxIncrement, animationSpeed)
				end
			end
		end
		
		draw.RoundedBoxEx(1, mRef.x, mRef.y, mRef.Width, mRef.Height, GAME_COLOR)
		
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(mRef.x, mRef.y, mRef.Width, mRef.Height)
		
		draw.SimpleText(i, "Default", mRef.x + 3, mRef.y + 3, color_white)
		
		if Inventory[i] then
			if Inventory[i].Item then
				local ref = Items:GetItemByKey(Inventory[i].Item)
				if ref then 
					surface.SetMaterial(ref.Icon)
					surface.SetDrawColor(GAME_OUTLINE)
					surface.DrawTexturedRect(mRef.x + padding * 2, mRef.y, mRef.Height - padding/2, mRef.Height - padding/2)
					
					if ref.Type != "Firearm" then
						draw.SimpleText(ref.Name, "ItemHeader", (mRef.x + mRef.Width) - padding, mRef.y + mRef.Height/2 - padding/2, GAME_OUTLINE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText(ref.Name, "ItemHeader", (mRef.x + mRef.Width) - padding, mRef.y, GAME_OUTLINE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
						
						draw.SimpleText("Ammo: "..Inventory[i].Data.Clip .. "/" .. weapons.Get(ref.Entity).Primary.ClipSize, "ItemBody", (mRef.x + mRef.Width) - padding, mRef.y + mRef.Height - padding/2, GAME_OUTLINE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
					end
				end
			else
				surface.SetMaterial(handIcon)
				surface.SetDrawColor(GAME_OUTLINE)
				surface.DrawTexturedRect(mRef.x + padding, mRef.y + padding, mRef.Height - padding*2, mRef.Height - padding*2)
			
				draw.SimpleText("Empty", "ItemHeader", (mRef.x + mRef.Width) - padding, mRef.y + mRef.Height/2 - padding/2, GAME_OUTLINE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
		else
			surface.SetMaterial(lockedIcon)
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawTexturedRect(mRef.x + padding, mRef.y + padding, mRef.Height - padding*2, mRef.Height - padding*2)
		
			draw.SimpleText("Locked", "ItemHeader", (mRef.x + mRef.Width) - padding, mRef.y + mRef.Height/2 - padding/2, GAME_OUTLINE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end
end)

local slots = {
	[1] = KEY_1,
	[2] = KEY_2,
	[3] = KEY_3,
	[4] = KEY_4,
	[5] = KEY_5,
	[6] = KEY_6,
	[7] = KEY_7
}

local lastSwitch = CurTime()
hook.Add("Move", "CheckForSlot", function()
	if !LPPlaying() then return end
	
	if CurTime() > lastSwitch then
		for k,v in pairs(Inventory) do
			if ActiveSlot != k then
				if input.WasKeyPressed(slots[k]) then
					ActiveSlot = k
						
					print("Slot pressed: "..k)
							
					net.Start("ChangeSlot")
						net.WriteEntity(LocalPlayer())
						net.WriteUInt(ActiveSlot, 8)
					net.SendToServer()
							
					lastSwitch = CurTime() + 0.2
				end
			end
		end
	end
end)

local fillWidth = 0
local progress = 0
local ent = false
net.Receive("SendProgress", function()
	ent = net.ReadEntity()
	progress = net.ReadUInt(16) + .7
	if progress <= 1 then
		fillWidth = 0
	end
end)

net.Receive("EndProgress", function()
	ent = false
	progress = false
	fillWidth = 0
end)

local width = ScrW() * .35
local height = 10

local bgColor = Color(55, 55, 55, 255)
local fillColor = color_white

hook.Add("HUDPaint", "DrawProgress", function()
	if !ent then return end
	if !progress then return end

	if IsValid(ent) then	
		fillWidth = math.Approach(fillWidth, width * progress / 100, 1)
		
		draw.RoundedBoxEx(1, ScrW()/2 - width/2, ScrH() - ScrH() * .33, width, height, bgColor)
		draw.RoundedBoxEx(1, ScrW()/2 - width/2 + 2, (ScrH() -  ScrH() * .33) + 2, fillWidth - 4, height - 4, GAME_MAIN)
			
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(ScrW()/2 - width/2, ScrH() - ScrH() * .33, width, height)
	else
		ent = false
		progress = 0
		fillWidth = 0
	end
end)
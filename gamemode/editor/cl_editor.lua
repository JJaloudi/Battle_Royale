surface.CreateFont( "Header", 
{
	font    = "Roboto-Light",
    size    = 20,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "Description", 
{
	font    = "Roboto-Light",
    size    = 12,
    weight  = 1000,
    antialias = true,
    shadow = false
})

--[[ Models: 

models/props_wasteland/cargo_container01.mdl
models/props_wasteland/controlroom_storagecloset001a.mdl
models/props_junk/TrashDumpster01a.mdl
models/props_c17/FurnitureFridge001a.mdl
models/props_c17/FurnitureDresser001a.mdl
models/props_c17/BriefCase001a.mdl
models/props_c17/SuitCase001a.mdl
 ]]
 
local DATA = {}

net.Receive("SendCompressedData", function()
	local str = net.ReadString()
	
	DATA = util.JSONToTable(str)
end)

local function SaveData()
	net.Start("SendCompressedData")
		net.WriteEntity(LocalPlayer())
		net.WriteString(util.TableToJSON(DATA))
	net.SendToServer()
end

local lastSelection = "Household Food"
local currentSelection = "Loot Spawn"

local numTbl = {}
for k,v in pairs(EDITOR_TYPES) do
	numTbl[#numTbl + 1] = k
end

local tempTbl = {}
for k,v in pairs(Config.Loot) do
	tempTbl[#tempTbl + 1] = k
end

PrintTable(tempTbl)

local recentModel = false
local deleteRadius = 7
local clientModels = {}
 
local lastAction = CurTime() + 1
hook.Add("SetupMove", "Open Settings", function()
	if !DevMode then return end

	if lastAction <= CurTime() then
		if input.WasKeyPressed(KEY_Z) then
			local panel = vgui.Create("DFrame")
			panel:SetSize(200, 100)
			panel:SetTitle("Config Settings")
			panel:MakePopup()
			panel:ShowCloseButton(false)
			panel:Center()
			
			local save = vgui.Create("DButton", panel)
			save:SetPos(0, 20)
			save:SetText("Save Config")
			save:SetSize(panel:GetWide(), 20)
			save.DoClick = function()
				SaveData()
			end
			
			local reload = vgui.Create("DButton", panel)
			local x, y = save:GetPos()
			reload:SetPos(x, y + save:GetTall())
			reload:SetSize(save:GetSize())
			reload:SetText("Reload Config")
			reload.DoClick = function()
				net.Start("RequestMapData")
					net.WriteEntity(LocalPlayer())
				net.SendToServer()
			end
			
			local clear = vgui.Create("DButton", panel)
			clear:SetPos(x, y + save:GetTall() * 2)
			clear:SetSize(reload:GetSize())
			clear:SetText("Clear Config (Won't set until you save.)")
			clear.DoClick = function()
				DATA = {}
			end
			
			local close = vgui.Create("DButton", panel)
			close:SetSize(panel:GetWide(), 20)
			close:SetPos(0, panel:GetTall() - close:GetTall())
			close:SetText("Close")
			close.DoClick = function()
				panel:Close()
			end
			
			lastAction = CurTime() + .1
		end
	end
end)

hook.Add("KeyPress", "Check for Press", function(pl, key)
	if !DevMode then return end

	if lastAction <= CurTime() then
		if key == IN_ATTACK then
			local tr = LocalPlayer():GetEyeTrace()
			if !tr.HitEnt then
				if !DATA[currentSelection] then
					DATA[currentSelection] = {}
				end
				local tbl = DATA[currentSelection]
				
				local canCreate = true
				for k,v in pairs(DATA[currentSelection]) do
					if v.Pos:Distance(tr.HitPos) <= 5 then
						canCreate = false
					end
				end
				
				if canCreate then
					local key = #tbl + 1			
					tbl[key] = {Pos = tr.HitPos}
				end
				
			end
			
			SaveData()
		elseif key == IN_ATTACK2 then
			if !DATA[currentSelection] then return end
		
			local tr = LocalPlayer():GetEyeTrace()
			
			local canDelete = false
			for k,v in pairs(DATA[currentSelection]) do
				if v.Pos:Distance(tr.HitPos) <= deleteRadius then
					canDelete = k
				end
			end
			
			if canDelete then
				if DATA[currentSelection][canDelete].Model then
					clientModels[canDelete].Ent:Remove()
					
					clientModels[canDelete] = nil
				end
			
				DATA[currentSelection][canDelete] = nil
			end
		
		
			SaveData()
		elseif key == IN_RELOAD then
		
			local nSel = "Loot Spawn"
			
			for k,v in pairs(numTbl) do
				if v == currentSelection then
					if k != #numTbl then
						nSel = numTbl[k + 1]
						
						break
					end
				end
			end
			
			currentSelection = nSel
			
			if DATA[nSel] then
				if currentSelection == "Container" then
					for k,v in pairs(DATA[currentSelection]) do
						clientModels[k] = {Ent = ClientsideModel(v.Model)}
						local ref = clientModels[k].Ent
						local pos = v.Pos
						if v.ObjPos then
							pos = v.ObjPos
						end
						ref:SetPos(pos)
						if v.Ang then
							ref:SetAngles(v.Ang)
						end
						
						ref:Spawn()
					end
				end
			end
			
			if nSel != "Container" then
				for k,v in pairs(clientModels) do
					v.Ent:Remove()
				end
			end
				
			surface.PlaySound("buttons/button9.wav")
			
		elseif key == IN_USE then
			if !DATA[currentSelection] then return end
			
				local tr = LocalPlayer():GetEyeTrace()
					
				local modID = false
				for k,v in pairs(DATA[currentSelection]) do
					if v.Pos:Distance(tr.HitPos) <= deleteRadius then
						modID = k
					end
				end
					
				if modID then
					if currentSelection == "Loot Spawn" then
						local curSel = DATA[currentSelection][modID].Type
						local nSel = tempTbl[1]
						
						
						for k,v in pairs(tempTbl) do
							if v == curSel then 
								if k != #tempTbl then 				
									nSel = tempTbl[k + 1]
									break
								end
							end
						end
						
						lastSelection = nSel
						
						DATA[currentSelection][modID].Type = nSel
						
						SaveData()
					elseif currentSelection == "Container" then
						local curModel = ""
						if DATA[currentSelection][modID].Model then
							curModel = DATA[currentSelection][modID].Model
						end
						
						local ref = clientModels[modID].Ent
						local dRef = DATA[currentSelection][modID]
						local angRef = ref:GetAngles()
						
						local panel = vgui.Create("DFrame")
						panel:SetSize(200, 400)
						panel:SetPos(ScrW() - panel:GetWide() - 100, ScrH()/2 - panel:GetTall()/2)
						panel:MakePopup()
						panel:ShowCloseButton(false)
						panel:SetTitle("Container Details")
						
						
						local oldAng = ref:GetAngles()
						local oldPos = ref:GetPos()
						
						local model = vgui.Create("DTextEntry", panel)
						model:SetPos(5, 45)
						model:SetText(curModel)
						model:SetSize(panel:GetWide() - 10, 20)
						
						local label = vgui.Create("DLabel", panel)
						local x,y = model:GetPos()
						label:SetPos(x + 1, y - label:GetTall() + 2.5)
						label:SetText("Model Path")
	
						local force = vgui.Create("DCheckBoxLabel", panel)
						force:SetPos(x, y + model:GetTall() + 7.5)
						force:SetSize(panel:GetWide() - 10, 15)
						force:SetText("Force Spawn?")
						force:SetChecked(DATA[currentSelection][modID].ForceSpawn)
						
						//Ang controls
						
						x,y = force:GetPos()
						local pitch = vgui.Create("DNumberWang", panel)
						pitch:SetSize(45, 25)
						pitch:SetPos(x, y + force:GetTall() + 30)
						pitch:SetMinMax(-180, 180)
						pitch:SetValue(angRef.p)
						
						local pLabel = vgui.Create("DLabel", panel)
						x, y = pitch:GetPos()
						pLabel:SetSize(50, 25)
						pLabel:SetPos(x, y - pitch:GetTall())
						pLabel:SetText("Pitch")
						
						local yaw = vgui.Create("DNumberWang", panel)
						yaw:SetSize(45, 25)
						yaw:SetPos(panel:GetWide()/2 - yaw:GetWide()/2, y)
						yaw:SetMinMax(-180, 180)
						yaw:SetValue(angRef.y)
						
						local yLabel = vgui.Create("DLabel", panel)
						x, y = yaw:GetPos()
						yLabel:SetSize(50, 25)
						yLabel:SetPos(x, y - pitch:GetTall())
						yLabel:SetText("Yaw")
						
						local roll = vgui.Create("DNumberWang", panel)
						roll:SetSize(45, 25)
						roll:SetPos(panel:GetWide() - roll:GetWide() - 5, y)
						roll:SetMinMax(-180, 180)
						roll:SetValue(angRef.r)
						
						local rLabel = vgui.Create("DLabel", panel)
						x, y = roll:GetPos()
						rLabel:SetSize(50, 25)
						rLabel:SetPos(x, y - pitch:GetTall())
						rLabel:SetText("Roll")
						
						roll.OnValueChanged = function()
							ref:SetAngles(Angle(pitch:GetValue(), yaw:GetValue(), roll:GetValue()))
							
							dRef.Ang = ref:GetAngles()
						end
						
						pitch.OnValueChanged = function()
							ref:SetAngles(Angle(pitch:GetValue(), yaw:GetValue(), roll:GetValue()))
							
							dRef.Ang = ref:GetAngles()
						end
						
						yaw.OnValueChanged = function()
							ref:SetAngles(Angle(pitch:GetValue(), yaw:GetValue(), roll:GetValue()))
							
							dRef.Ang = ref:GetAngles()
						end
						
						//Vec controls
						
						local vecRef = ref:GetPos()
						print(vecRef.y)
						
						x, y = pitch:GetPos()
						local xVec = vgui.Create("DNumberWang", panel)
						xVec:SetSize(60, 25)
						xVec:SetPos(x, y + pitch:GetTall() + 30)
						xVec:SetMinMax(-50000, 50000)
						xVec:SetValue(vecRef.x)

						
						local xLabel = vgui.Create("DLabel", panel)
						x, y = xVec:GetPos()
						xLabel:SetSize(65, 25)
						xLabel:SetPos(x, y - xVec:GetTall())
						xLabel:SetText("X Axis")
						
						local yVec = vgui.Create("DNumberWang", panel)
						yVec:SetSize(60, 25)
						yVec:SetPos(panel:GetWide()/2 - yVec:GetWide()/2, y)
						yVec:SetMinMax(-50000, 50000)
						yVec:SetValue(vecRef.y)
						
						local yVecLabel = vgui.Create("DLabel", panel)
						x, y = yVec:GetPos()
						yVecLabel:SetSize(50, 25)
						yVecLabel:SetPos(x, y - yVec:GetTall())
						yVecLabel:SetText("Y Axis")
						
						local zVec = vgui.Create("DNumberWang", panel)
						zVec:SetSize(60, 25)
						zVec:SetPos(panel:GetWide() - zVec:GetWide() - 5, y)
						zVec:SetMinMax(-50000, 50000)
						zVec:SetValue(vecRef.z)
						
						local zLabel = vgui.Create("DLabel", panel)
						x, y = zVec:GetPos()
						zLabel:SetSize(50, 25)
						zLabel:SetPos(x, y - zVec:GetTall())
						zLabel:SetText("Z Axis")
						
						xVec.OnValueChanged = function()
							ref:SetPos(Vector(xVec:GetValue(), yVec:GetValue(), zVec:GetValue()))
							
							dRef.ObjPos  = ref:GetPos()
						end
						
						yVec.OnValueChanged = function()
							ref:SetPos(Vector(xVec:GetValue(), yVec:GetValue(), zVec:GetValue()))
							
							dRef.ObjPos  = ref:GetPos()
						end
						
						zVec.OnValueChanged = function()
							ref:SetPos(Vector(xVec:GetValue(), yVec:GetValue(), zVec:GetValue()))
							
							dRef.ObjPos = ref:GetPos()
						end
						
						//Spawn controls
						
						local cspawn = vgui.Create("DNumberWang", panel)
						x, y = xVec:GetPos()
						cspawn:SetPos(x, y + zVec:GetTall() * 2)
						cspawn:SetSize(45, 25)
						cspawn:SetMinMax(1, 100)
						cspawn:SetValue(DATA[currentSelection][modID].SpawnChance || Config.ContainerSpawnChance)
						
						local clabel = vgui.Create("DLabel", panel)
						x, y = cspawn:GetPos()
						clabel:SetPos(x, y - cspawn:GetTall() + 5)
						clabel:SetText("Chance of Spawn %")
						clabel:SetSize(100, 15)
						
						local blbt = vgui.Create("DButton", panel)
						blbt:SetSize(panel:GetWide() - 10, 25)
						blbt:SetText("Set Container Type")
						blbt:SetPos(5, panel:GetTall() - 90)
						blbt.DoClick = function()
							local blist = DermaMenu()
							blist:SetPos(gui.MousePos())
							
							for k,v in pairs(Config.Containers) do
								blist:AddOption(k, function() dRef.ContainerType = k cspawn:SetValue(v.Chance) end)
							end
							
						end
						
						local slots = vgui.Create("DNumberWang", panel)
						x, y = cspawn:GetPos()
						slots:SetPos(x, y + cspawn:GetTall() * 2)
						slots:SetSize(45, 25)
						slots:SetMinMax(1, 100)
						slots:SetValue(DATA[currentSelection][modID].ForceSlots || Config.ContainerMaxItems)
						slots:SetMinMax(1, 50)
						
						local clabel = vgui.Create("DLabel", panel)
						x, y = slots:GetPos()
						clabel:SetPos(x, y - slots:GetTall() + 5)
						clabel:SetText("Num. of Slots (Bypasses config setting)")
						clabel:SetSize(panel:GetWide(), 15)
						
						local cancel = vgui.Create("DButton", panel)
						cancel:SetSize(panel:GetWide()/2 , 35)
						cancel:SetPos(0, panel:GetTall() - cancel:GetTall())
						cancel:SetText("Cancel")
						cancel.DoClick = function()
							ref:SetAngles(oldAng)
							ref:SetPos(oldPos)
						
							panel:Close()
						end
						
						local confirm = vgui.Create("DButton", panel)
						confirm:SetSize(panel:GetWide()/2 + 1.5 , 35)
						confirm:SetPos(panel:GetWide() - confirm:GetWide(), panel:GetTall() - confirm:GetTall())
						confirm:SetText("Confirm Changes")
						confirm.DoClick = function()
						
							local text = model:GetValue()	
							
							DATA[currentSelection][modID].Model = text						
							ref:SetModel(text)
							
							DATA[currentSelection][modID].ForceSpawn = force:GetChecked()
							DATA[currentSelection][modID].SpawnChance = cspawn:GetValue()				
							DATA[currentSelection][modID].ForceSlots = slots:GetValue()
						
							SaveData()
						
							panel:Close()
						end
						
--[[ 						Derma_StringRequest(currentSelection, "Set the model of this container.", curModel,
						function(text)
							if util.IsValidModel(text) then
								DATA[currentSelection][modID].Model = text
								
								clientModels[modID].Ent:SetModel(text)
							end
						end,
						function(text)
						 
						end) ]]
					
					elseif currentSelection == "Item" then
						local curItem = ""
						if DATA[currentSelection][modID].Item then
							curItem = DATA[currentSelection][modID].Item
						end
						
						Derma_StringRequest(currentSelection, "Set the item of this spawn.", curItem,
						function(text)
							if GetItem(text) || GetItemByKey(text) then
								DATA[currentSelection][modID].Item = text
							else
							
							end
						end,
						function(text)
						 
						end)
						
					end
				end
			end
			
		lastAction = CurTime() + .01
	end
end)


local renderDistance = 4000
hook.Add("PlayerFootstep", "Render Client Models", function()
	
end)

local size = 0
local x = 5
local y = 5
local offset = 5
local headerFont = "Header"
local descFont = "Description"
local selectedItem = false

local hudLineSize = 15
hook.Add("HUDPaint", "Draw Selection and Spawns", function()
	if !DevMode then return end
	
	draw.SimpleText("DEV MODE", "Header", ScrW()/2, 0, Color(155, 55, 55, 255), TEXT_ALIGN_CENTER)
	draw.SimpleText("Editing Map ".. game.GetMap() .." map configuration file.", descFont, ScrW()/2, 20, GAME_OUTLINE, TEXT_ALIGN_CENTER)


	local descText = EDITOR_TYPES[currentSelection].Desc

	surface.SetFont(headerFont)
	local hWidth, hHeight = surface.GetTextSize("Selected Type: " .. currentSelection)
	
	surface.SetFont(descFont)
	local dWidth, dHeight = surface.GetTextSize("Click to create a point. " .. descText)
	
	local width = dWidth
	if dWidth < hWidth then
		width = hWidth
	end
	
	local xSize = width + offset*2
	local ySize = hHeight + dHeight + (offset)
	
	draw.RoundedBoxEx(1, x, y, xSize, ySize, GAME_COLOR)
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(x, y, xSize, ySize)
	
	size = xSize
	
	draw.SimpleText("Selected Type: " .. currentSelection, headerFont, x + width/2 + offset, y, GAME_MAIN, TEXT_ALIGN_CENTER)
	draw.SimpleText("Click to create a point. " .. descText, descFont, x + width/2 + offset, y + ySize - (dHeight + offset), GAME_OUTLINE, TEXT_ALIGN_CENTER)
	
	if DATA[currentSelection] then
		for k,v in pairs(DATA[currentSelection]) do
			if v.Pos:Distance(LocalPlayer():GetPos()) <= 600 then
				local pos = v.Pos:ToScreen()
				local tr = LocalPlayer():GetEyeTrace()
				if tr.HitPos:Distance(v.Pos) <= deleteRadius then
					selectedItem = k
				else
					selectedItem = false
				end
				
				local dispText = currentSelection
				if v.Type then
					dispText = v.Type .. " Spawn"
				end
				
				if selectedItem == k then
					draw.SimpleText("[#" .. k .. "] ".. dispText, descFont, pos.x, pos.y, GAME_OUTLINE)
				else
					draw.SimpleText("[#" .. k .. "] ".. dispText, descFont, pos.x, pos.y, GAME_COLOR)
				end
			end
		end
	end
	
end)
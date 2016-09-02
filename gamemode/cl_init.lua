include("shared.lua")
include("gametypes.lua")
include("config.lua")
include("apparel_system.lua")

include("cl_network.lua")
include("cl_inventory.lua")
include("cl_mainmenu.lua")
include("cl_gm_data.lua")

include("items.lua")
include("item_config.lua")
include("buffs.lua")

include("perk_system.lua")

include("vgui/inventory.lua")
include("vgui/item.lua")
include("vgui/button.lua")
include("vgui/limb.lua")
include("vgui/brframe.lua")
include("vgui/perk.lua")
include("vgui/mButton.lua")
include("vgui/apparel.lua")
include("vgui/player.lua")

include("HUD/HUD_Notifications.lua")
include("HUD/HUD_Limb.lua")
include("HUD/HUD_Hotbar.lua")

include("editor/sh_editor.lua")
include("editor/cl_editor.lua")


local path = GM.FolderName 
files, dir = file.Find(path.."/gamemode/gametypes/*","LUA")
for k,v in pairs(files) do
	include("gametypes/"..v)
end
	
files, dir = file.Find(path.."/gamemode/perks/*","LUA")
for k,v in pairs(files) do
	include("perks/"..v)
end	
	
files, dir = file.Find(path.."/gamemode/apparel/*","LUA")
for k,v in pairs(files) do
	include("apparel/"..v)
end	

files, dir = file.Find(path.."/gamemode/items/*","LUA")
for k,v in pairs(files) do
	include("items/"..v)
end

GAME_MAIN =  Color(55, 125, 55, 255)
GAME_COLOR = Color(75, 75, 75, 255)
GAME_SECOND = Color(125, 125, 125, 255)
GAME_OUTLINE = Color( 255, 255, 255, 255 )

local rEle = {"CHudHealth","CHudBattery","CHudSuitPower","CHudAmmo","CHudCrosshair","CHudSecondaryAmmo","CHudWeaponSelection"}
hook.Add("HUDShouldDraw","Remove Elements",function(ele)
	if table.HasValue(rEle,ele) then
		return false
	end
end)

Tooltip = false

function draw.FillPanel(pnl, color)
	draw.RoundedBoxEx(1,0,0, pnl:GetWide(), pnl:GetTall(), color)
end

local sin,cos,rad = math.sin,math.cos,math.rad;
function surface.CreatePoly(x,y,radius,quality)
    local circle = {};
    for i=1,quality do
        circle[i] = {};
        circle[i].x = x + cos(rad(i*360)/quality)*radius;
        circle[i].y = y + sin(rad(i*360)/quality)*radius;
    end
	
    return circle;
end

surface.CreateFont( "Placement", 
{
	font    = "Roboto-Light",
    size    = 35,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "BRTitle", 
{
	font    = "Roboto-Light",
    size    = 55,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "Player", 
{
	font    = "Roboto-Light",
    size    = 30,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "Rewards", 
{
	font    = "Roboto-Light",
    size    = 20,
    weight  = 1000,
    antialias = true,
    shadow = false
})

local placementDesign = {
	[1] = {"1st Place", Color(255,215,0)},
	[2] = {"2nd Place", Color(192, 192, 192)},
	[3] = {"3rd Place", Color(205, 127, 50)}
}

local GameOver

local perkScale = 0.055
local Size = ScrH() * perkScale
local Spacing = 5
local startX = Spacing * 2
local startY = ScrH() - Spacing/2
hook.Add("HUDPaint", "Draw Info", function()
	if PlayersRemaining && LPPlaying() then
		draw.SimpleText(PlayersRemaining .. " players remaining.", "Default", ScrW()/2, 5, color_white, TEXT_ALIGN_CENTER)
	end
	
	if GameOver then
		draw.SimpleText("BATTLE ROYALE", "BRTitle", ScrW()/2, 5, color_white, TEXT_ALIGN_CENTER)
		draw.SimpleText("Round Finished", "Placement", ScrW()/2, 55, Color(95, 25, 25, 255), TEXT_ALIGN_CENTER)
	end
	
	if bPerks then
		if table.Count(bPerks) > 0 then
		
			local count = -1
			for k,v in pairs(bPerks) do
				
				if v.CurTime then
					if v.CurTime <= CurTime() then
						v.Alpha = v.Alpha - 4
						
						if v.Alpha <= 4 then
							bPerks[k] = nil
						end
					end
				else
					v.CurTime = CurTime() + 5
				end
			
				
			
				local flatColor = Color(GetPerk(k).Color.r, GetPerk(k).Color.g, GetPerk(k).Color.b, v.Alpha )
				local gradientColor = Color(GetPerk(k).Color.r + 25, GetPerk(k).Color.g + 25, GetPerk(k).Color.b + 25, v.Alpha )
				local iconColor = Color(GAME_OUTLINE.r, GAME_OUTLINE.g, GAME_OUTLINE.b, v.Alpha )
				local outlineColor = Color(GetPerk(k).Color.r + 55, GetPerk(k).Color.g + 55, GetPerk(k).Color.b + 55,v.Alpha)
				
				local xPos, yPos = startX, (startY - (v.Count * Size) - Spacing ) - ((v.Count - 1) * Spacing)		
				
				draw.RoundedBoxEx(1, xPos, yPos, Size/2 - 1, Size - 2, flatColor)			
				draw.RoundedBoxEx(1, xPos + Size/2 - 1, yPos, Size/2 - 1, Size - 2, gradientColor)				
				
				
				draw.SimpleText(GetPerk(k).Name, "Default", xPos + Size + Spacing, yPos, iconColor)
				
				surface.SetMaterial(GetPerk(k).Icon)
				surface.SetDrawColor(iconColor)
				surface.DrawTexturedRect(xPos + 5, yPos + 5, Size - 10, Size - 10)
	 
				surface.SetDrawColor(outlineColor)
				surface.DrawOutlinedRect(xPos, yPos, Size, Size)
			end
		end
	end
end)

//maxWidth * value / maxValue

local healthIcon = Material("icons/player_icon.png")
local hpSizeX, hpSizeY = 125, 125
local hpX, hpY = ScrW() - hpSizeX, ScrH() - hpSizeY - 10

local hungerIcon = Material("icons/hunger.png")
local hnSizeX, hnSizeY = 65, 75
local hnX, hnY = ScrW() - hnSizeX - 30, ScrH() - hnSizeY * 2 - 75
hook.Add("HUDPaint", "DrawHUD", function()
	if false then
		surface.SetDrawColor(color_black)
		surface.SetMaterial(healthIcon)
		surface.DrawTexturedRect(hpX+.5, hpY, hpSizeX , hpSizeY)
		
		surface.SetDrawColor(color_black)
		surface.SetMaterial(hungerIcon)
		surface.DrawTexturedRect(hnX+.5, hnY, hnSizeX , hnSizeY)
		

		render.ClearStencil();
			render.SetStencilEnable(true);

				--------------------------------------------------------
				--- Setup the stencil & draw the circle mask onto it ---
				--------------------------------------------------------

				render.SetStencilWriteMask(1);
				render.SetStencilTestMask(1);

				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER);
				render.SetStencilFailOperation(STENCILOPERATION_REPLACE);
				render.SetStencilZFailOperation(STENCILOPERATION_KEEP);
				render.SetStencilPassOperation(STENCILOPERATION_KEEP);
				render.SetStencilReferenceValue(1);

				surface.SetDrawColor(1, 0, 0)
				draw.NoTexture();
				
				draw.RoundedBoxEx(1, hpX, (hpY + hpSizeY) - hpSizeY * LocalPlayer():Health() / 100, hpSizeX - 20,  hpSizeY * 5, Color(255, 0,0,255))
				
				draw.RoundedBoxEx(1, hnX, (hnY + hnSizeY) - hnSizeY * Hunger / 100, hnSizeX, hnSizeY * Hunger / 100, color_white)
				

				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL);
				render.SetStencilReferenceValue(1)
				render.SetStencilFailOperation(STENCILOPERATION_ZERO);
				render.SetStencilZFailOperation(STENCILOPERATION_ZERO);
				render.SetStencilPassOperation(STENCILOPERATION_KEEP);
				
				surface.SetDrawColor(Color(55, 155, 55, 255))
				surface.SetMaterial(healthIcon)
				surface.DrawTexturedRect(hpX, hpY, hpSizeX, hpSizeY)
				
				surface.SetDrawColor(Color(55, 55, 155, 255))
				surface.SetMaterial(hungerIcon)
				surface.DrawTexturedRect(hnX+.5, hnY, hnSizeX , hnSizeY)
				
			
			render.SetStencilEnable(false)
		render.ClearStencil()
	end
end)

local LastClose = false
net.Receive("EndGame", function()
	BR:ResetTables()

	local PlacementTbl = net.ReadTable()
	
	GameOver = vgui.Create("DFrame")
	
	local pnl = GameOver
	pnl:SetSize(ScrW() - 100, ScrH() - 200)
	pnl:SetPos(50, 100)
	pnl.Paint = function()
	
	end
	pnl:SetTitle("")
	pnl:MakePopup()
	pnl:ShowCloseButton(false)
	
	local pList = vgui.Create("DPanelList", pnl)
	
	surface.SetFont("Placement")
	
	pList:SetSize(pnl:GetWide(), pnl:GetTall() - 10)
	pList:SetPos(0, 0)
	
	
	local fragIcon = Material("icons/kills.png")
	for i = 1, #placementDesign do
		local width, height = surface.GetTextSize(placementDesign[i][1])
		local minSize = height + 5
		local playerSize = 90
		local playerCount = 0
		
		
		if PlacementTbl[i] then
			playerCount = #PlacementTbl[i]
		end
		
	
		local bPanel = vgui.Create("DPanel")
		bPanel:SetSize(pList:GetWide(), minSize + (playerSize * playerCount))
		bPanel.Paint = function() end
	
		local plPnl = vgui.Create("DPanel", bPanel)
		plPnl:SetSize(pList:GetWide(), minSize)
		plPnl.Paint = function(s)
			draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), placementDesign[i][2])
			draw.SimpleText(placementDesign[i][1], "Placement", s:GetWide()/2, s:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local plList = vgui.Create("DPanelList", bPanel)
		plList:SetPos(0, plPnl:GetTall())
		plList:SetSize(bPanel:GetWide(), (playerSize * playerCount))
		
		if PlacementTbl[i] then
			for k,v in pairs(PlacementTbl[i]) do
			
				local pl = vgui.Create("DButton")
				pl:SetSize(plList:GetWide(), playerSize)
				pl:SetText("")
				pl.Paint = function(s)
					draw.RoundedBoxEx(1, 0, 0, s:GetWide(), s:GetTall(), GAME_COLOR)
					draw.SimpleText(v.Player:Name(), "Player", 5, s:GetTall()/2, placementDesign[i][2], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText("Rewards", "Rewards", s:GetWide()/2, 10, placementDesign[i][2], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
					surface.SetFont("Player")
					local width, height = surface.GetTextSize(v.Player:Frags())
					local startPos = s:GetWide()
					local heightPos = s:GetTall()/2
				
					draw.SimpleText(v.Player:Frags(), "Player", s:GetWide() - 3, s:GetTall()/2, placementDesign[i][2], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				
					surface.SetDrawColor(placementDesign[i][2])
					
					surface.SetMaterial(fragIcon)
					surface.DrawTexturedRect(startPos - height - width - 4, s:GetTall()/2 - height/2, height, height)
				
					surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())
				end
				
				local rewardList = vgui.Create("DPanelList", pl)
				local wSize = pl:GetTall() - 30
				
				rewardList:SetSize((wSize + 4) * table.Count(v.Rewards) , wSize)
				rewardList:SetPos(pl:GetWide()/2 - rewardList:GetWide()/2 + 2, 25)
				rewardList:SetSpacing(4)
				
				rewardList:EnableHorizontal(true)
				for key, reward in pairs(v.Rewards) do
					if reward[1] == "PERK" then
						PrintTable(reward)
					
						local icon = vgui.Create("Perk")
						icon:SetPerk(reward[2])
						icon:SetSize(rewardList:GetTall(), rewardList:GetTall())
						
						rewardList:AddItem(icon)
					elseif reward[1] == "Money" then
						local icon = vgui.Create("DButton")
						icon:SetSize(rewardList:GetTall(), rewardList:GetTall())
						icon:SetText("")
						
						local moneyIcon = Material("icons/money.png")
						function icon:Paint()
							local flatColor = Color(55, 165, 55, 255 )
							local gradientColor = Color(62.5, 182.5, 52.5, 255)
									
							draw.RoundedBoxEx(1, 0, 0, self:GetWide()/2, self:GetTall(), flatColor)			
							draw.RoundedBoxEx(1, self:GetWide()/2, 0, self:GetWide()/2, self:GetTall(), gradientColor)	
							
							surface.SetMaterial(moneyIcon)
							surface.SetDrawColor(GAME_OUTLINE)
							surface.DrawTexturedRect(5.5, 5, self:GetWide() - 10, self:GetTall() - 10)
							
							draw.SimpleText(reward[2] .. " cred.", "Default", self:GetWide()/2, self:GetTall(), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
							
							surface.SetDrawColor(Color(95, 195, 95, 255))
							surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
						end
						
						rewardList:AddItem(icon)
					end
				end
				
				plList:AddItem(pl)
			end
		end
		
		
		pList:AddItem(bPanel)
	end
end)

hook.Add("SetupMove", "Remove", function()
	if !GameOver then return end
	
	if LastClose then
		if LastClose <= CurTime() then
			if input.WasKeyPressed(KEY_SPACE) || input.WasMousePressed(MOUSE_LEFT) || input.WasMousePressed(MOUSE_RIGHT) || input.WasMousePressed(MOUSE_MIDDLE) then
				if GameOver:Valid() then
					GameOver:Remove()
					
					GameOver = false
				else
					GameOver = false
				end
				
				LastClose = false
			end
		end
	else
		LastClose = CurTime() + 2
	end
end)

Apparel = {}

	net.Receive("EquipApparel",function()
		local pl = net.ReadEntity()
		local aType = net.ReadUInt(16)
		
		local item = GetApparel(aType)
		if !Apparel[pl] then
			Apparel[pl] = {}
		end
		
		Apparel[pl][item.Category] = {ID = aType}
	end)

	net.Receive("RemoveApparel", function()
		local pl = net.ReadEntity()
		local aLoc = net.ReadString()
		
		if !Apparel[pl] then
			Apparel[pl] = {}
		end
		
		Apparel[pl][aLoc] = nil
		
	end)

	//Render side of things
	function refreshApparel(pl)
		for k, v in pairs(Apparel[pl]) do
			if v.RenderModel then
				if !IsValid(pl) then
					SafeRemoveEntity(v.RenderModel)
					Apparel[pl] = nil
				end
			else
				if v.ID then
					v.RenderModel = ClientsideModel(GetApparel(v.ID).Model, RENDERMODE_TRANSALPHA)
					if GetApparel(v.ID).ApparelData.Col then
						v.RenderModel:SetColor(GetApparel(v.ID).ApparelData.Col)
					end
					
					v.RenderModel:SetNoDraw(true)
				--	v.RenderModel:SetParent(pl, APPAREL_TYPES[GetApparel(v.ID).ApparelData.Type])
				end
			end
		end
	end

hook.Add("PostDrawOpaqueRenderables", "RenderApparel", function()

		for k, v in pairs(Apparel) do
			if !IsValid(k) then
				Apparel[k] = nil
			end	
		end

		for id, pl in pairs(player.GetAll()) do
			if pl != LocalPlayer() || !pl:Alive() then
					if Apparel[pl] then
						
							refreshApparel(pl)
							for apparelType, appTbl in pairs(Apparel[pl]) do
								local id = appTbl.ID 
								local item = GetApparel(id)
								local appData = item.ApparelData
								
								local renderMdl = appTbl.RenderModel
								
								local parent = pl
							
								if not pl:Alive() && IsValid(renderMdl) then
									parent = pl:GetRagdollEntity()
								end 
									
								if IsValid(parent) then
									local pos, ang = parent:GetBonePosition(parent:LookupBone(APPAREL_TYPES[item.Category]))

									local newPos = pos + (renderMdl:GetForward() * appData.vecOffset.y) + (renderMdl:GetUp() * appData.vecOffset.z) + (renderMdl:GetRight() * appData.vecOffset.x)
									
									local rot = appData.angOffset
									ang:RotateAroundAxis(ang:Right(), 	rot.x)
									ang:RotateAroundAxis(ang:Up(), 		rot.y)
									ang:RotateAroundAxis(ang:Forward(), rot.z)

									renderMdl:SetPos(newPos)
									renderMdl:SetAngles(ang)
									
									if appData.Mat then
										renderMdl:SetMaterial(appData.Mat)
									end									
									
									if appData.Col then
										renderMdl:SetColor(appData.Col)
									end
									
									
									if appData.Scale then
										renderMdl:SetModelScale(appData.Scale, 0)
									end
									
									renderMdl:DrawModel()
								end
							end
					end
		//	end
		end
	end
end)
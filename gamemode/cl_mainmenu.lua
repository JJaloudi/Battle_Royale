surface.CreateFont( "TabFont", 
{
	font    = "annapolis",
    size    = ScreenScale(6),
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "DescFont", 
{
	font    = "annapolis",
    size    = 29,
    weight  = 1000,
    antialias = true,
    shadow = false
})

MenuTabs = {}

function AddMenuTab(name, col, func)
	MenuTabs[name] = {Color = col, Func = func}
end

AddMenuTab("Perks", Color(155, 155, 155, 255), function(pnl) 
	local pWidth, pHeight = pnl:GetWide()/2, pnl:GetTall() - 70
	local yPos =  45
	
	local PerkPanel = vgui.Create("DFrame")
	PerkPanel:SetParent(pnl)
	PerkPanel:SetPos(0, 0)
	PerkPanel:SetSize(pnl:GetWide(), pnl:GetTall())
	PerkPanel:ShowCloseButton(false)
	PerkPanel:SetTitle("")
	PerkPanel:SetDraggable(false)
	PerkPanel.Paint = function(s)
	end
	PerkPanel.PaintOver = function(s)
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())
	end
	
	-- local PerkDescription = vgui.Create("RichText", pnl)
	-- PerkDescription:SetSize(pWidth, pHeight)
	-- local x,y = PerkPanel:GetPos()
	-- PerkDescription:SetPos(x * 3 + pWidth, 45)
	-- PerkDescription:SetVerticalScrollbarEnabled(false)
	
	-- function PerkDescription:PerformLayout()
		-- self:SetFontInternal("DescFont")
	-- end
	
	-- PerkDescription:InsertColorChange(55, 195, 75, 255)
	-- PerkDescription:AppendText([[Perks play a huge role in Battle Royale.
	-- ]])
	
	-- PerkDescription:InsertColorChange(255, 255, 255, 255)
	-- PerkDescription:AppendText([[
			
-- Our attempt is to not have any overpowered players by keeping perks somewhat simple.
	
-- The perks that aren't simple to get on the other hand, require you to either have a lot of money or a lot of luck when the rewards come around. 
	
-- Play around with loadouts but be careful, a lot of perks are one time use BUT can be stacked if they are won/bought multiple times. 

-- If you think something is too overpowered, or unfair then let us know and we'll consider changes.
	
-- Enjoy!
	-- ]])
	
	local maxSlots = 3
	
	local CategoryList = vgui.Create("DPanelList", PerkPanel)
	CategoryList:SetPos(0, 0)
	CategoryList:SetSize(PerkPanel:GetWide(), 50)
	CategoryList:EnableHorizontal(true)
	
	CategoryList.PaintOver = function(s)
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawLine(0, s:GetTall() - 1, s:GetWide(), s:GetTall() - 1)
	end
	
	local PerkList = vgui.Create("DPanelList", PerkPanel)
	local x, y = CategoryList:GetPos()
	PerkList:SetSize(PerkPanel:GetWide(), PerkPanel:GetTall() - (y + CategoryList:GetTall()))
	PerkList:SetPos(0, y + CategoryList:GetTall())
	PerkList:EnableVerticalScrollbar(true)
	PerkList:EnableHorizontal(true)
	PerkList:SetSpacing(5); PerkList:SetPadding(5)
	PerkList.ActivePerk = 1
	
	PerkList.Paint = function(s)
		if #s:GetItems() < 1 then
			draw.SimpleText("You have no perks unlocked for this slot!", "Character", s:GetWide()/2, s:GetTall()/2, GAME_OUTLINE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	function PerkList:PopulateList(perkSlot)
		self:Clear()
		
		local tbl = {}
		for k,v in pairs(PERKS) do
			if v.Slot == perkSlot then
				table.insert(tbl, k)
			end
		end
		
		for k,v in pairs(tbl) do
			local perk = vgui.Create("Perk")
			perk:SetPerk(v)
			perk:SetSize((PerkList:GetWide() - 50) / 10, (PerkList:GetWide() - 50) / 10)
			
			if !unlockedPerks[v] then
				perk:ToggleLocked(true)
			else
				perk:SetStack(unlockedPerks[v])
				
				if activePerks[GetPerk(v).Slot] == v then
					perk.Active = true
				end
			end
			
			if !perk.Locked then
				perk.DoClick = function()
					net.Start("SelectPerk")
						net.WriteEntity(LocalPlayer())
						net.WriteUInt(v, 16)
					net.SendToServer()
					
					for key, obj in pairs(PerkList:GetItems()) do
						if obj.Active then
							obj.Active = false
						end
					end
					
					activePerks[GetPerk(v).Slot] = v				
					perk.Active = true
				end
			end
			
			self:AddItem(perk)
		end
		
		self.ActivePerk = perkSlot
	end
	
	PerkList:PopulateList(PerkList.ActivePerk)
	
	for i = 1, maxSlots do
		local CategoryButton = vgui.Create("mButton")
		CategoryButton:SetSize(CategoryList:GetWide()/maxSlots, CategoryList:GetTall())
		CategoryButton:Text("Slot "..i)
		CategoryButton:SetMainColor(Color(55, 55, 55, 255))
		if i == PerkList.ActivePerk then
			CategoryButton.Active = true
		end
		
		CategoryButton.DoClick = function(s)
		
			if i != PerkList.ActivePerk then
				for k,v in pairs(CategoryList:GetItems()) do
					if v.Active then
						v.Active = false
						
						v:OnCursorExited()
					end
				end
				
				s.Active = true
				PerkList:PopulateList(i)
			end
		end
		
		CategoryList:AddItem(CategoryButton)
	end
end)


AddMenuTab("Character", Color(155, 155, 155, 255), function(pnl) 
	local CategoryList = vgui.Create("DPanelList", pnl)
	CategoryList:SetPos(0, 0)
	CategoryList:SetSize(pnl:GetWide(), 50)
	CategoryList:EnableHorizontal(true)
	CategoryList.ActiveCat = "Backpacks"
	function CategoryList:Paint(w, h)
		draw.FillPanel(self, GAME_COLOR)
	end
	
	function CategoryList:PaintOver(w, h)
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(0, h - 1, w, h - 1)
	end
	
	local ApparelList = vgui.Create("DPanelList", pnl)
	ApparelList:SetPos(0, CategoryList:GetTall())
	ApparelList:SetSize(pnl:GetWide()/4, pnl:GetTall())
	ApparelList:EnableVerticalScrollbar(true)
	ApparelList:SetSpacing(10)
	ApparelList:SetPadding(10)
	function ApparelList:Paint(w, h)
		draw.FillPanel(self, Color(25, 25, 25, 255))
		
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawLine(w - 1, 1.5, w - 1, h)
		
		if #self:GetItems() < 1 then
			draw.SimpleText("You don't own any "..string.lower(CategoryList.ActiveCat).."!", "Default", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		for k,v in pairs(self:GetItems()) do
			if v.Active then
			
				local x, y = v:GetPos()
				draw.RoundedBoxEx(1, x, y, v:GetWide(), v:GetTall(), Color(155, 155, 155, 255))
				
			end
		end
	end
	
	local PlayerPreview = vgui.Create("PlayerPanel", pnl)
	PlayerPreview:SetPos(ApparelList:GetWide(), CategoryList:GetTall())
	PlayerPreview:SetSize(pnl:GetWide() - ApparelList:GetWide(), pnl:GetTall() - CategoryList:GetTall())
	PlayerPreview:SetPlayer(LocalPlayer())
	
	function ApparelList:Populate(cat)
		self:Clear()
	
		for k,v in pairs(unlockedApparel) do
			if GetApparel(k).Category == cat then
			
				local app = vgui.Create("Apparel")
				app:SetShop(false)
				app:SetID(k)
				app:SetSize(self:GetWide(), self:GetTall() / 5 - 50)
				app.DoClick = function()
					if !app.Active then
						net.Start("EquipApparel")
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(k, 16)
						net.SendToServer()
						
						app.Active = true
					else
						net.Start("UnequipApparel")
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(k, 16)
						net.SendToServer()
						Apparel[LocalPlayer()][GetApparel(k).Category] = nil
						
						app.Active = false
					end
				end
				
				if Apparel[LocalPlayer()] then
					if Apparel[LocalPlayer()][GetApparel(k).Category] then
						if Apparel[LocalPlayer()][GetApparel(k).Category].ID == k then
							app.Active = true
						end
					end
				end
				
				self:AddItem(app)
			end
		end
		
		
	end
	ApparelList:Populate(CategoryList.ActiveCat)
	
		
	for k,v in pairs(APPAREL_TYPES) do
		local CategoryButton = vgui.Create("mButton")
		CategoryButton:Text(k)
		CategoryButton:SetSize(CategoryList:GetWide()/table.Count(APPAREL_TYPES), CategoryList:GetTall())
		CategoryButton:SetMainColor(Color(195, 195, 195, 255))
		
		if k == CategoryList.ActiveCat then
			CategoryButton.Active = true
		end
		
		function CategoryButton:DoClick()
			CategoryList.ActiveCat = k
		
			for k,v in pairs(CategoryList:GetItems()) do
				if v.Active then
					v.Active = false
					
					v:OnCursorExited()
				end
			end
			
			self.Active = true
			ApparelList:Populate(k)
		end
		
		CategoryList:AddItem(CategoryButton)
	end
	
end)


AddMenuTab("Shop", Color(55, 155, 95, 255), function(pnl) 
	local ShopPanel = vgui.Create("DPanel", pnl)
	ShopPanel:SetSize(pnl:GetWide(), pnl:GetTall())
	ShopPanel:SetPos(0, 0)
	ShopPanel.Paint = function() end
	ShopPanel.PaintOver = function(s)
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())
	end
	
	local categories = {}
	local ShopCategories = vgui.Create("DPanelList", ShopPanel)
	ShopCategories:SetSize(ShopPanel:GetWide(), ShopPanel:GetTall() * 0.09)
	ShopCategories:EnableHorizontal(true)
	ShopCategories.ActiveShop = false
	
	local ShopDisplay = vgui.Create("DPanel", ShopPanel)
	ShopDisplay:SetSize(ShopPanel:GetWide(), ShopPanel:GetTall() - ShopCategories:GetTall())
	ShopDisplay:SetPos(0, ShopCategories:GetTall())
	ShopDisplay.Paint = function() end
	
	local categories = {}
	local function CreateShopCategory(id, name, func)
		categories[id] = {Name = name, Func = func}
	end
	
	CreateShopCategory(1, "Perks", function(pnl)
		local CategoryList = vgui.Create("DPanelList", pnl)
		CategoryList:SetPos(0, 0)
		CategoryList:SetSize(pnl:GetWide(), 50)
		CategoryList:EnableHorizontal(true)
		
		CategoryList.PaintOver = function(s)
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawLine(0, s:GetTall() - 1, s:GetWide(), s:GetTall() - 1)
		end
		
		local PerkList = vgui.Create("DPanelList", pnl)
		PerkList:SetSize(pnl:GetWide(), pnl:GetTall() - CategoryList:GetTall())
		PerkList:SetPos(0, CategoryList:GetTall())
		PerkList:EnableVerticalScrollbar(true)
		PerkList:EnableHorizontal(true)
		PerkList:SetSpacing(5); PerkList:SetPadding(5)
		PerkList.ActivePerk = 1
		
		function PerkList:PopulateList(perkSlot)
			self:Clear()
			
			local tbl = {}
			for k,v in pairs(PERKS) do
				if v.Slot == perkSlot then
					table.insert(tbl, k)
				end
			end
			
			for k,v in pairs(tbl) do
				if GetPerk(v).Price then
					local perk = vgui.Create("Perk")
					perk:SetPerk(v)
					perk:SetSize((PerkList:GetWide() - 50) / 10, (PerkList:GetWide() - 50) / 10)
					
					perk:SetShop(true)
					
					perk.DoClick = function()
						if Money >= GetPerk(v).Price then
							net.Start("BuyPerk")
								net.WriteEntity(LocalPlayer())
								net.WriteUInt(v, 16)
							net.SendToServer()
							surface.PlaySound("buttons/button9.wav")
						else
							surface.PlaySound("buttons/button6.wav")
						end
					end

					
					self:AddItem(perk)
				end
			end
			
			self.ActivePerk = perkSlot
		end
		
		PerkList:PopulateList(PerkList.ActivePerk)
		
		local maxSlots = 3
		for i = 1, maxSlots do
			local CategoryButton = vgui.Create("mButton")
			CategoryButton:SetSize(CategoryList:GetWide()/maxSlots, CategoryList:GetTall())
			CategoryButton:Text("Slot "..i)
			CategoryButton:SetMainColor(Color(55, 55, 55, 255))
			if i == PerkList.ActivePerk then
				CategoryButton.Active = true
			end
			
			CategoryButton.DoClick = function(s)
			
				if i != PerkList.ActivePerk then
					for k,v in pairs(CategoryList:GetItems()) do
						if v.Active then
							v.Active = false
							
							v:OnCursorExited()
						end
					end
					
					s.Active = true
					PerkList:PopulateList(i)
				end
			end
			
			CategoryList:AddItem(CategoryButton)
		end
	end)
	
	CreateShopCategory(2, "Apparel", function(pnl)
		local CategoryList = vgui.Create("DPanelList", pnl)
		CategoryList:SetPos(0, 0)
		CategoryList:SetSize(pnl:GetWide(), 50)
		CategoryList:EnableHorizontal(true)
		
		CategoryList.PaintOver = function(s)
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawLine(0, s:GetTall() - 1, s:GetWide(), s:GetTall() - 1)
		end
		
		local ApparelList = vgui.Create("DPanelList", pnl)
		ApparelList:SetSize(pnl:GetWide(), pnl:GetTall() - CategoryList:GetTall())
		ApparelList:SetPos(0, CategoryList:GetTall())
		ApparelList:EnableVerticalScrollbar(true)
		ApparelList:EnableHorizontal(true)
		ApparelList:SetSpacing(5); ApparelList:SetPadding(5)
		ApparelList.ActiveApparel = "Backpacks"
		
		function ApparelList:PopulateList(apparelType)
			self:Clear()
			
			local tbl = {}
			for k,v in pairs(APPAREL) do
				if v.Category == apparelType then
					table.insert(tbl, k)
				end
			end
			
			for k,v in pairs(tbl) do
				if !unlockedApparel[v] then
 					if GetApparel(v).Price then
					
						local apparel = vgui.Create("Apparel")
						apparel:SetID(v)
						apparel:SetSize((ApparelList:GetWide() - 20) / 4, (ApparelList:GetWide() - 35) / 7)
						
						apparel:SetShop(true)
						
						apparel.DoClick = function()
							if Money >= GetApparel(v).Price then
								net.Start("BuyApparel")
									net.WriteEntity(LocalPlayer())
									net.WriteUInt(v, 16)
								net.SendToServer()
								
								apparel:Remove()
								
								surface.PlaySound("buttons/button9.wav")
							else
								surface.PlaySound("buttons/button6.wav")
							end
						end

						
						self:AddItem(apparel)
					end
				end
			end
			
			self.ActiveApparel = apparelType
		end
		
		ApparelList:PopulateList(ApparelList.ActiveApparel)
		
		for k,v in pairs(APPAREL_TYPES) do
			local CategoryButton = vgui.Create("mButton")
			CategoryButton:SetSize(CategoryList:GetWide()/table.Count(APPAREL_TYPES), CategoryList:GetTall())
			CategoryButton:Text(k)
			CategoryButton:SetMainColor(Color(55, 55, 55, 255))
			if k == ApparelList.ActiveApparel then
				CategoryButton.Active = true
			end
			
			CategoryButton.DoClick = function(s)
			
				if k != ApparelList.ActiveApparel then
					for k,v in pairs(CategoryList:GetItems()) do
						if v.Active then
							v.Active = false
							
							v:OnCursorExited()
						end
					end
					
					s.Active = true
					ApparelList:PopulateList(k)
				end
				
			end
			
			CategoryList:AddItem(CategoryButton)
		end
	end)
	
	CreateShopCategory(3, "Models", function(pnl)
		local CategoryList = vgui.Create("DPanelList", pnl)
		CategoryList:SetPos(0, 0)
		CategoryList:SetSize(pnl:GetWide(), 50)
		CategoryList:EnableHorizontal(true)
		
		CategoryList.PaintOver = function(s)
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawLine(0, s:GetTall() - 1, s:GetWide(), s:GetTall() - 1)
		end
		
		local ModelList = vgui.Create("DPanelList", pnl)
		ModelList:SetSize(pnl:GetWide(), pnl:GetTall() - CategoryList:GetTall())
		ModelList:SetPos(0, CategoryList:GetTall())
		ModelList:EnableVerticalScrollbar(true)
		ModelList:EnableHorizontal(true)
		ModelList:SetSpacing(5); ModelList:SetPadding(5)
		ModelList.ActiveModel = "Civilian"
		
		function ModelList:PopulateList(modelType)
			self:Clear()
			
			local tbl = {}
			for k,v in pairs(MODELS) do
				if v.Category == modelType then
					table.insert(tbl, k)
				end
			end
			
			for k,v in pairs(tbl) do
				if string.lower(GetModel(v).Model) != string.lower(LocalPlayer():GetModel()) then
				
 					if GetModel(v).Price then
									
						local apparel = vgui.Create("PlayerPanel")
						apparel:SetModel(GetModel(v).Model)
						apparel:SetSize((ModelList:GetWide() - 10) / 2, (ModelList:GetWide() - 20) / 3)
						
						local PrevMins, PrevMaxs = apparel.Entity:GetRenderBounds()
						apparel:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.75, 0.75, 0.75))
						apparel:SetLookAt((PrevMaxs + PrevMins) / 2.5)
						
						local text = GetModel(v).Price .. "c"
						
						surface.SetFont("Default")
						local width, height = surface.GetTextSize(text)
						height = height + 5
						
						function apparel:PaintOver(w, h)
							draw.RoundedBoxEx(1, 0, h - height, w, height, Color(0, 0, 0, 195))
							
							if Money > GetModel(v).Price then
								draw.SimpleText(text, "Default", w/2, h - height/2 + 5, Color(55, 155, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
							else
								draw.SimpleText(text, "Default", w/2, h - height/2 + 5, Color(155, 55, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
							end
						
							surface.SetDrawColor(GAME_OUTLINE)
							surface.DrawOutlinedRect(0, 0, w, h)
						end
						
						apparel.DoClick = function()
							if Money >= GetModel(v).Price then
								net.Start("BuyModel")
									net.WriteEntity(LocalPlayer())
									net.WriteUInt(v, 16)
								net.SendToServer()
								
								apparel:Remove()
								
								surface.PlaySound("buttons/button9.wav")
							else
								surface.PlaySound("buttons/button6.wav")
							end
						end
						
						self:AddItem(apparel)
					end
				end
			end
			
			self.ActiveModel = modelType
		end
		
		ModelList:PopulateList(ModelList.ActiveModel)
		
		for k,v in pairs(MODEL_CATEGORIES) do
			local CategoryButton = vgui.Create("mButton")
			CategoryButton:SetSize(CategoryList:GetWide()/table.Count(MODEL_CATEGORIES), CategoryList:GetTall())
			CategoryButton:Text(v)
			CategoryButton:SetMainColor(Color(55, 55, 55, 255))
			if v == ModelList.ActiveModel then
				CategoryButton.Active = true
			end
			
			CategoryButton.DoClick = function(s)
			
				if v != ModelList.ActiveModel then
					for k,v in pairs(CategoryList:GetItems()) do
						if v.Active then
							v.Active = false
							
							v:OnCursorExited()
						end
					end
					
					s.Active = true
					ModelList:PopulateList(v)
					
					print(v)
				end
				
			end
			
			CategoryList:AddItem(CategoryButton)
		end	
	end)
	
	for k,v in pairs(categories) do
		local ShopCatButton = vgui.Create("mButton")
		ShopCatButton:Text(v.Name)
		ShopCatButton:SetSize(ShopCategories:GetWide() / table.Count(categories), ShopCategories:GetTall())
		ShopCatButton:SetMainColor(Color(55, 155, 95, 255))
		
		ShopCatButton.DoClick = function()
			if ShopCategories.ActiveShop != k then
				ShopDisplay:Clear()
			
				for k,v in pairs(ShopCategories:GetItems()) do
					if v.Active then
						v.Active = false
						v:OnCursorExited()
					end
				end
				
				ShopCatButton.Active = true
				v.Func(ShopDisplay)
			end
		end
		
		if k == 1 then
			ShopCatButton:DoClick()
		end
		
		ShopCategories:AddItem(ShopCatButton)
	end
	
end)

surface.CreateFont( "TitleHub", 
{
	font    = "annapolis",
    size    = ScreenScale(22),
    weight  = 1000,
    antialias = true, 
    shadow = false
})

surface.CreateFont( "HubText", 
{
	font    = "Roboto-Light",
    size    = ScreenScale(8.5),
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont("HubBody",
{
	font    = "Roboto-Light",
    size    = ScreenScale(6),
    weight  = 1000,
    antialias = true,
    shadow = false
})


local brIcon = Material("icons/deathmatch.png")
local readyIcon = Material("icons/readyup.png")
AddMenuTab("Hub", Color(55, 125, 55, 255), function(pnl) 
	local IconPanel = vgui.Create("DButton", pnl)
	IconPanel:SetPos(20, 20)
	IconPanel:SetText("")
	IconPanel:SetSize(pnl:GetWide() - 40, pnl:GetTall()/2 - 20)
	IconPanel.Paint = function(s, w, h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(brIcon)
		surface.DrawTexturedRect(0, 0, w, h)
		
		local title = "Beta Testing!"
		surface.SetFont("TitleHub")
		local width, height = surface.GetTextSize(title)
		
		local desc = "Welcome to Battle Royale testing. I know this panel looks like shit but it's only until I actually finish it. Enjoy :)"
		surface.SetFont("HubBody")
		local bWidth, bHeight = surface.GetTextSize(desc)
		
		draw.RoundedBoxEx(1, 0, h - (height + bHeight), w, height + bHeight, Color(0, 0, 0, 195))
		draw.SimpleText(title, "TitleHub", 5, h - (bHeight + height), color_white)
		draw.SimpleText(desc, "HubBody",  5, h - 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	
	local HubList = vgui.Create("DPanelList", pnl)
	local x, y = HubList:GetPos()
	HubList:SetPos(20, IconPanel:GetTall() + y + 40)
	HubList:SetSize(pnl:GetWide(), pnl:GetTall() - (IconPanel:GetTall() + y) - 40)
	HubList:EnableHorizontal(true)
	HubList:EnableVerticalScrollbar(true)
	HubList:SetPadding(0); HubList:SetSpacing(10)
	
	local hubFont = "HubText"
	function AddHubButton(text, icon, color, click, iconColor)
		local HubButton = vgui.Create("DButton")
		HubButton:SetText("")
		HubButton:SetSize(HubList:GetWide() / 4 - 17.5, HubList:GetTall()/2 - 20)
		HubButton.ActiveColor = color
		HubButton.Col = color
		HubButton.Text = text
		HubButton.Icon = icon
		HubButton.IconColor = iconColor || color_white
		function HubButton:OnCursorEntered()
			self.ActiveColor = Color(self.Col.r + 25, self.Col.g + 25, self.Col.b + 25, self.Col.a)
		end
		
		function HubButton:OnCursorExited()
			self.ActiveColor = self.Col
		end
		
		surface.SetFont(hubFont)
		local width, height = surface.GetTextSize(HubButton.Text)
		
		function HubButton:Paint(w, h)

			local tHeight = HubButton:GetTall() - height
			local iconSize = tHeight * 0.5
		
			draw.FillPanel(self, self.ActiveColor)
			draw.RoundedBoxEx(1, w/2, 0, w/2, h, Color(self.ActiveColor.r + 7, self.ActiveColor.g + 7, self.ActiveColor.b + 7, self.ActiveColor.a))
			draw.RoundedBoxEx(1, 0, h - height - 2, w, height + 2, Color(0, 0, 0, 195))
			draw.SimpleText(self.Text, "HubText", w/2, h - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			surface.SetMaterial(self.Icon)
			surface.SetDrawColor(self.IconColor)
			surface.DrawTexturedRect(w/2 - iconSize/2, tHeight/2 - iconSize/2, iconSize, iconSize)
			
			surface.SetDrawColor(GAME_OUTLINE) 
			surface.DrawOutlinedRect(0, 0, w, h)
		end
		
		function HubButton:DoClick()
			click(self)
			
			InitializeButtons()
		end
		
		HubList:AddItem(HubButton)
	end
	
	local starIcon = Material("icon16/user.png" )
	function InitializeButtons()
		HubList:Clear()
		
			local HubButton = vgui.Create("DButton")
		HubButton:SetText("")
		HubButton:SetSize(HubList:GetWide() / 4 - 17.5, HubList:GetTall()/2 - 20)
		HubButton.ActiveColor = Color(75, 75, 75, 255)
		HubButton.Col = Color(75, 75, 75, 255)
		
		if BR:IsPlayerQueued(LocalPlayer()) then
			HubButton.Text = "Exit Queue"
		else
			HubButton.Text  = "Enter Queue"
		end
		
		HubButton.Icon = readyIcon
		HubButton.IconColor = iconColor || color_white
		
		function HubButton:OnCursorEntered()
			self.ActiveColor = Color(self.Col.r + 25, self.Col.g + 25, self.Col.b + 25, self.Col.a)
		end
		
		function HubButton:OnCursorExited()
			self.ActiveColor = self.Col
		end
		
		surface.SetFont(hubFont)
		local width, height = surface.GetTextSize(HubButton.Text)
		
		function HubButton:Paint(w, h)

			local tHeight = HubButton:GetTall() - height
			local iconSize = tHeight * 0.5
		
			draw.FillPanel(self, self.ActiveColor)
			draw.RoundedBoxEx(1, w/2, 0, w/2, h, Color(self.ActiveColor.r + 7, self.ActiveColor.g + 7, self.ActiveColor.b + 7, self.ActiveColor.a))
			draw.RoundedBoxEx(1, 0, h - height - 2, w, height + 2, Color(0, 0, 0, 195))
			draw.SimpleText(self.Text, "HubText", w/2, h - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			surface.SetMaterial(self.Icon)
			surface.SetDrawColor(self.IconColor)
			surface.DrawTexturedRect(w/2 - iconSize/2, tHeight/2 - iconSize/2, iconSize, iconSize)
			
			surface.SetDrawColor(GAME_OUTLINE) 
			surface.DrawOutlinedRect(0, 0, w, h)
		end
		
		function HubButton:DoClick()		
			if !BR:IsPlayerQueued(LocalPlayer()) then
				BR:QueuePlayer(LocalPlayer())
				
				net.Start("QueuePlayer")
					net.WriteEntity(LocalPlayer())
				net.SendToServer()
			else
				BR:RemoveQueuedPlayer(LocalPlayer())
				
				net.Start("RemoveQueuedPlayer")
					net.WriteEntity(LocalPlayer())
				net.SendToServer()
			end	
			
			InitializeButtons()
		end
		
		local QueueList = vgui.Create("DPanelList", HubButton)
		QueueList:SetPos(0, 0)
		QueueList:SetSize(HubButton:GetWide(), HubButton:GetTall() - 30)
		QueueList:SetVerticalScrollbarEnabled(true)
		QueueList:EnableHorizontal(true)
		QueueList:SetPadding(2); QueueList:SetSpacing(2)
				
		QueueList.OnMouseReleased = function()
			HubButton:DoClick()
		end
			
		QueueList.OnCursorEntered = function()
			HubButton:OnCursorEntered()
		end
			
		QueueList.OnCursorExited = function()
			HubButton:OnCursorExited()
		end		
		
		for k,v in pairs(BR.QueuedPlayers) do
					
			local icon = vgui.Create("DButton")
			icon:SetSize(QueueList:GetWide()/5 - 12, QueueList:GetWide()/5 - 12)
			icon:SetText("")
			icon:SetTooltip(v:Name() .. " is ready!")
						
			function icon:Paint(w, h)
				surface.SetMaterial(starIcon)
				surface.SetDrawColor(color_white)
				surface.DrawTexturedRect(0, 0, w, h)
			end
					
			QueueList:AddItem(icon)
		end
		
		HubList:AddItem(HubButton)
		
		AddHubButton("Invite a Partner!", Material("icons/partner.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Rock The Vote", Material("icons/map.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Leaderboards", Material("icons/leaderboards.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Check our site!", Material("icons/website.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Tutorial", Material("icons/tutorial.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Make a Suggestion!", Material("icons/suggestion.png"), Color(75, 75, 75, 255), function() 
		
		end)
		
		AddHubButton("Donate", Material("icons/donate.png"), Color(75, 75, 75, 255), function() 
		
		end, Color(255, 255, 0))

	end
	
	InitializeButtons()
end)

MainMenu = false
function OpenMainMenu()
	if !MainMenu then
	
	
		MainMenu = vgui.Create("DFrame")
		
		local ScreenPanel = MainMenu
		ScreenPanel:SetSize(ScrW()/2, ScrH())
		ScreenPanel:SetPos(-ScreenPanel:GetWide(), 0)
		ScreenPanel:MoveTo(0, ScrH()/2 - ScreenPanel:GetTall()/2, 0.5)
		ScreenPanel:SetTitle("")
		ScreenPanel:MakePopup()
		ScreenPanel:SetDraggable(false)
		ScreenPanel:ShowCloseButton(false)
		ScreenPanel.Paint = function(s)
			draw.FillPanel(s, GAME_COLOR)
		end
		ScreenPanel.PaintOver = function(s)
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())
		end
		
		local TabList = vgui.Create("DPanelList", ScreenPanel)
		TabList:SetSize(ScreenPanel:GetWide(), ScrH() * .08)
		TabList:EnableHorizontal(true)
		TabList:SetSpacing(0)
		
		local bgMat = Material("icons/background.png")
		local DisplayPanel = vgui.Create("DPanel", ScreenPanel)
		DisplayPanel:SetPos(0, TabList:GetTall())
		DisplayPanel:SetSize(ScreenPanel:GetWide(), ScreenPanel:GetTall() - TabList:GetTall())
		
--[[ 		local dustImg = Material("icons/dust.png")
		local dustParticles = {}
		for i = 1, 125 do
			dustParticles[i] = {x = math.random(1, DisplayPanel:GetWide()), y = math.random(1, DisplayPanel:GetTall()), alpha = math.random(1, 95)}
		end ]]
		
		DisplayPanel.Paint = function(s)
		
			surface.SetDrawColor(color_white)
			surface.SetMaterial(bgMat)
			surface.DrawTexturedRect(0, 0, s:GetWide(), s:GetTall())
			
			draw.SimpleText(Money .. " Credits", "TabFont", ScrW() - 20, ScrH() - 80, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			
--[[ 			for k,v in pairs(dustParticles) do
				v.alpha = v.alpha * math.sin(CurTime()*math.abs(1)) 
			
				surface.SetMaterial(dustImg)
				surface.SetDrawColor(Color(255, 255, 255, v.alpha))
				surface.DrawTexturedRect(v.x, v.y, ScrH() * 0.009, ScrH() * 0.009)
			end ]]
			
		end
		
		local tabSize = TabList:GetWide()/(table.Count(MenuTabs) + 1)
		for k,v in pairs(MenuTabs) do			
		
			local Tab = vgui.Create("mButton")
			Tab:SetSize(tabSize, TabList:GetTall())
			Tab:Text(k)
			Tab:SetMainColor(v.Color)
			
			if k == "Hub" then
				TabList.ActiveTab = Tab
				
				Tab.Active = true
				v.Func(DisplayPanel)
			end
			
			Tab.DoClick = function()
				
				if TabList.ActiveTab != Tab then
				
					for key,val in pairs(TabList:GetItems()) do
						print(val)
					
						if val.Active then
							val.Active = false
							
							val:OnCursorExited()
						end
					end
					
					Tab.Active = true
					DisplayPanel:Clear()
					
					TabList.ActiveTab = Tab
					
					v.Func(DisplayPanel)
				end
				
			end
			
			TabList:AddItem(Tab)
		end
		
		
		
		local CloseButton = vgui.Create("mButton")
		CloseButton:SetSize(tabSize, TabList:GetTall())
		CloseButton:Text("Close")
		CloseButton:SetMainColor(Color(155, 55, 55, 255))
		CloseButton.DoClick = function()
			MainMenu:MoveTo(-ScreenPanel:GetWide(), ScrH()/2 - ScreenPanel:GetTall()/2, 0.75, 0, -1, function()
				MainMenu:Close()
				MainMenu = false
				
				PanelOpen = false
			end)
		end
		
		TabList:AddItem(CloseButton)
		
	else
	
		if MainMenu:Valid() then
			MainMenu:MoveTo(-MainMenu:GetWide(), ScrH()/2 - MainMenu:GetTall()/2, 0.5, 0, -1, function()
				if MainMenu then
					if MainMenu:IsValid() then
						MainMenu:Close()
						MainMenu = false
						
						PanelOpen = false
					end
				end
			end)
		else
		
			PanelOpen = false
			MainMenu = false
		end
	end
end


hook.Add("HUDPaint", "QueueHUD", function()
	if InMatch then return end
	
	
end)
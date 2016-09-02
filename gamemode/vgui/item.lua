local ITEM = {}

function ITEM:Init()
	self.Item = false
	self.Stack = 0
	self:SetText("")
	
	self.HighlightColor = GAME_SECOND
	self.IdleColor = GAME_COLOR
	
	self.CurColor = self.IdleColor
	
	self.ItemIcon = vgui.Create("SpawnIcon", self)
end

function ITEM:OnCursorEntered()
	self.CurColor = self.HighlightColor
end

function ITEM:OnCursorExited()
	self.CurColor = self.IdleColor
end

function ITEM:SetItem(it, stack)
	self.Item = it
	self.Stack = stack
	
	self.ItemIcon:SetSize(self:GetTall(), self:GetTall())
	self.ItemIcon:SetPos(2, 0)
	self.ItemIcon.OnMousePressed = function() end
	self.ItemIcon.OnCursorEntered = self.OnCursorEntered
	self.ItemIcon.PaintOver = function() end
	
	local ref = GetItemByKey(it)
	if ref.Type == "Weapon" then
 		self.ItemIcon:SetModel(weapons.Get(ref.Entity).WorldModel)
	else
		self.ItemIcon:SetModel(ref.Model)
	end
	
	self.ItemIcon:SetTooltip(nil)
end

function ITEM:Paint()
	draw.FillPanel(self, self.CurColor)
end

local equippedIcon = Material("icons/equipped.png")
function ITEM:PaintOver(w, h)
	local x,y = self.ItemIcon:GetPos()
	local str = GetItemByKey(self.Item).Name
	if self.Stack > 1 then
		str = self.Stack .. "x " .. str
	end
	draw.SimpleText(str, "Default", x + self.ItemIcon:GetWide() + 2, self:GetTall()/2, color_white, 0, TEXT_ALIGN_CENTER)
	
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
	
	if EquippedItem == self.Slot && self.Ent == LocalPlayer() then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(equippedIcon)
		surface.DrawTexturedRect(w - h - 5, 2.5, h, h - 5)
	end
end

vgui.Register("Item", ITEM, "DButton")
local mButton = {}


function mButton:Init()
	self.MainColor = GAME_COLOR
	self.IdleColor = Color(25, 25, 25, 255)
	
	self.Active = false
	
	self.ActiveColor = self.IdleColor
	self:SetText("")
end

function mButton:SetIcon(icon)
	self.Icon = Material(icon)
end

function mButton:SetMainColor(col)
	self.MainColor = col
end

function mButton:Text(text)
	self.Text = text
end

function mButton:OnCursorEntered()
	if !self.Active then
		self.ActiveColor = Color(self.MainColor.r + 25, self.MainColor.g + 25, self.MainColor.b + 25, self.MainColor.a + 25)
	end
end

function mButton:OnCursorExited()
	if !self.Active then
		print("YEET")
	
		self.ActiveColor = self.IdleColor
	end
end

function mButton:OnMousePressed()

end

function mButton:DoClick()

end

function mButton:DoRightClick()

end

function mButton:OnMouseReleased(code)
	surface.PlaySound("UI/buttonclick.wav")
	if code == 107 then
		self:DoClick()

	else
		self:DoRightClick()
	end
end

function mButton:Paint()
	if self.Active then
		self.ActiveColor = self.MainColor
	end

	draw.FillPanel(self, self.ActiveColor)
	draw.RoundedBoxEx(1, 0, 0, self:GetWide(), 5, Color(self.ActiveColor.r + 25, self.ActiveColor.g + 25, self.ActiveColor.b + 25, self.ActiveColor.a + 25))
	
	if self.Text then
		draw.SimpleTextOutlined(self.Text, "TabFont", self:GetWide()/2, self:GetTall()/2, GAME_OUTLINE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(self.ActiveColor.r + 25, self.ActiveColor.g + 25, self.ActiveColor.b + 25, self.ActiveColor.a + 25))
	end
	
	if self.Icon then
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(GAME_OUTLINE)
		
		surface.DrawTexturedRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)
	end
end

concommand.Add("testmenu", function()
	local pnl = vgui.Create("DFrame")
	pnl:SetSize(100, 100)
	pnl:Center()
	pnl:MakePopup()
	
	local bt = vgui.Create("mButton", pnl)
	
	bt:SetSize(50, 50)
	bt:SetPos(25, 35)
	
	bt:SetMainColor(Color(155, 55, 55, 255))
	bt:SetIcon("perks/shield.png")
	
end)

vgui.Register("mButton",mButton,"DButton")
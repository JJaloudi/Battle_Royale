local APPAREL = {}

function APPAREL:Init()
	self.ID = false
end

function APPAREL:SetID(id)
	if GetApparel(id) then
		self.ID = id
		self:SetModel(GetApparel(id).Model)
		
		local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
		self:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.75, 0.75, 0.5))
		self:SetLookAt((PrevMaxs + PrevMins) / 2)
		
		local ref = GetApparel(id)
		if ref.ApparelData.Col then	
			self:SetColor(ref.ApparelData.Col)
		end
	end
end

function APPAREL:OnCursorEntered()
	if self.ID then
		if !self.Locked then
			if Tooltip then
				if Tooltip:IsValid() then
					Tooltip:Close()
				end
			end

			Tooltip = vgui.Create("DFrame")
			
			surface.SetFont("PerkTitle")
			local width, height = surface.GetTextSize(GetApparel(self.ID).Name)
			
			Tooltip:ShowCloseButton(false)
			Tooltip:MakePopup()
			Tooltip:SetTitle("")
			Tooltip:SetSize(math.Clamp(width * 1.5, 150, 500), 150)
			
			Tooltip.Owner = self
			
			Tooltip.Label = vgui.Create("RichText", Tooltip)
			local lbl = Tooltip.Label
			
			surface.SetFont("Default")
			local lWidth, lHeight = surface.GetTextSize(GetApparel(self.ID).Description)
			
			lbl:SetPos(0, height + lHeight + 5)
			lbl:SetSize(Tooltip:GetWide() + 6, Tooltip:GetTall() - height - 6)
			lbl:InsertColorChange(255, 255, 255, 255)
			lbl:AppendText(GetApparel(self.ID).Description)
			lbl:SetVerticalScrollbarEnabled(false)
			

			
			lbl.numLines = 0
			function lbl:PerformLayout()
				self.numLines = self.numLines + 1 
			end
			
			
			function Tooltip.Paint(s)
				draw.RoundedBoxEx(1, 0, 0, s:GetWide(), s:GetTall(), GAME_COLOR)	
				
				draw.SimpleText(GetApparel(self.ID).Name, "PerkTitle", s:GetWide()/2, 2.5, GAME_OUTLINE, TEXT_ALIGN_CENTER)
				draw.SimpleText(GetApparel(self.ID).Category .. " Accessory", "Default", s:GetWide()/2, height, Color(255,215,0), TEXT_ALIGN_CENTER)
				
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())
				
			end
			
			Tooltip.Think = function(s)
				s:MoveToFront()
				
				Tooltip:SetTall( height + 25 + (lbl:GetNumLines() * lHeight) )
					
				local x,y = gui.MousePos()
				local offsetX = x + 15
				local offsetY = y - s:GetTall()
				if offsetY < 0 then
					offsetY = y + 30
				end
							
				s:SetPos(offsetX, offsetY)
				if !self then
					s:Remove()
				end
				if !Tooltip.Owner:IsValid() then
					s:Remove()
				end
			end
		end
	end 
end

function APPAREL:SetShop(b)
	self.Shop = b
end

function APPAREL:OnCursorExited()
	if Tooltip then
		if Tooltip:IsValid() then
			Tooltip:Close()
		end
	end
end

local activeIcon = Material("icons/active.png")
local lockedIcon = Material("icons/perklocked.png")
local unknownIcon = Material("icons/unknown.png")
function APPAREL:PaintOver()
	if self.Locked then
		draw.RoundedBoxEx(1, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 205))
			
		surface.SetMaterial(lockedIcon)
		surface.SetDrawColor(Color(195, 195, 195, 255))
		surface.DrawTexturedRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)
	else
		if self.Shop then
			draw.RoundedBoxEx(1, 0, self:GetTall()-15, self:GetWide(), 15, Color(0, 0, 0, 195))
			
			if Money > GetApparel(self.ID).Price then
				draw.SimpleText(GetApparel(self.ID).Price .. "c", "Default", self:GetWide()/2, self:GetTall() - 2, Color(55, 155, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			else
				draw.SimpleText(GetApparel(self.ID).Price .. "c", "Default", self:GetWide()/2, self:GetTall() - 2, Color(155, 55, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
		end
	end
	

	
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
end

vgui.Register("Apparel", APPAREL, "DModelPanel")

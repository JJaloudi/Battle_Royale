surface.CreateFont( "PerkTitle", 
{
	font    = "Roboto-Light",
    size    = 22,
    weight  = 1000,
    antialias = true,
    shadow = false
})

local PERK = {}

function PERK:Init()
	self.ID = false
	self.Stack = false
	self:SetText("")
end

function PERK:SetPerk(id)
	self.ID = id
end

function PERK:SetStack(amt)
	self.Stack = amt
end	

function PERK:ToggleLocked(b)
	self.Locked = b || !self.Locked
end

function PERK:OnCursorEntered()
	if self.ID then
		if !self.Locked then
			if Tooltip then
				if Tooltip:IsValid() then
					Tooltip:Close()
				end
			end

			Tooltip = vgui.Create("DFrame")
			
			surface.SetFont("PerkTitle")
			local width, height = surface.GetTextSize(GetPerk(self.ID).Name)
			
			Tooltip:ShowCloseButton(false)
			Tooltip:MakePopup()
			Tooltip:SetTitle("")
			Tooltip:SetSize(math.Clamp(width * 1.5, 150, 500), 150)
			
			Tooltip.Owner = self
			
			Tooltip.Label = vgui.Create("RichText", Tooltip)
			local lbl = Tooltip.Label
			
			surface.SetFont("Default")
			local lWidth, lHeight = surface.GetTextSize(GetPerk(self.ID).Desc)
			
			lbl:SetPos(0, height + lHeight)
			lbl:SetSize(Tooltip:GetWide() + 6, Tooltip:GetTall() - height - 6)
			lbl:InsertColorChange(255, 255, 255, 255)
			lbl:AppendText(GetPerk(self.ID).Desc)
			lbl:SetVerticalScrollbarEnabled(false)
			

			
			lbl.numLines = 0
			function lbl:PerformLayout()
				self.numLines = self.numLines + 1 
			end
			
			
			function Tooltip.Paint(s)
				draw.RoundedBoxEx(1, 0, 0, s:GetWide(), s:GetTall(), GAME_COLOR)	
				
				draw.SimpleText(GetPerk(self.ID).Name, "PerkTitle", s:GetWide()/2, 2.5, GAME_OUTLINE, TEXT_ALIGN_CENTER)
				draw.SimpleText("This perk uses slot "..GetPerk(self.ID).Slot.. ".", "Default", s:GetWide()/2, height, Color(GetPerk(self.ID).Color.r + 55, GetPerk(self.ID).Color.g + 55, GetPerk(self.ID).Color.b + 55, 255), TEXT_ALIGN_CENTER)
				
				surface.SetDrawColor(Color(GetPerk(self.ID).Color.r + 55, GetPerk(self.ID).Color.g + 55, GetPerk(self.ID).Color.b + 55, 255))
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

function PERK:SetShop(b)
	self.Shop = b
end

function PERK:OnCursorExited()
	if Tooltip then
		if Tooltip:IsValid() then
			Tooltip:Close()
		end
	end
end

local unknownIcon = Material("icons/unknown.png")
local activeIcon = Material("icons/active.png")
local outlineIcon = Material("icons/outline.png")
local lockedIcon = Material("icons/perklocked.png")
function PERK:Paint(w, h)

	render.ClearStencil() --Clear stencil
		render.SetStencilEnable( true ) --Enable stencil
		
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilFailOperation(STENCILOPERATION_DECR)
		render.SetStencilZFailOperation(STENCILOPERATION_DECR )
		render.SetStencilPassOperation( STENCILOPERATION_DECR ) 
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		
--[[ 		local outlineColor = Color(GetPerk(self.ID).Color.r + 55, GetPerk(self.ID).Color.g + 55, GetPerk(self.ID).Color.b + 55, 255)
		surface.SetDrawColor(outlineColor)	
		surface.DrawPoly(surface.CreatePoly(w/2, h/2, h/2, 100)) ]]
		
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )	
		surface.DrawPoly(surface.CreatePoly(w/2, h/2, h/2, 1000))
					
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilReferenceValue(1)
        render.SetStencilFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)	
			
		local flatColor = Color(GetPerk(self.ID).Color.r, GetPerk(self.ID).Color.g, GetPerk(self.ID).Color.b, 255 )
		local gradientColor = Color(GetPerk(self.ID).Color.r + 10, GetPerk(self.ID).Color.g + 10, GetPerk(self.ID).Color.b + 10, 255 )		
	
		draw.RoundedBoxEx(1, 0, 0, self:GetWide()/2, self:GetTall(), flatColor)			
		draw.RoundedBoxEx(1, self:GetWide()/2, 0, self:GetWide()/2, self:GetTall(), gradientColor)	
		
		surface.SetMaterial(GetPerk(self.ID).Icon)
		surface.SetDrawColor(GAME_OUTLINE)
		local iconSize = self:GetTall()/1.5
		
		surface.DrawTexturedRect(self:GetWide()/2-iconSize/2 + 1, self:GetTall()/2 - iconSize/2, iconSize, iconSize)
		 if self.ID then
			
			if self.Locked then	
				draw.RoundedBoxEx(1, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 205))
			
				surface.SetMaterial(lockedIcon)
				surface.SetDrawColor(Color(195, 195, 195, 255))
				surface.DrawTexturedRect(7.5, 7.5, self:GetWide() - 15, self:GetTall() - 20)
			else
			
				surface.SetFont("Default")
							
				if self.Stack && !self.Shop then
					if self.Stack > 1 then
						local text = "x"..self.Stack
						local width, height = surface.GetTextSize(text)
						width = width + 1
						
						draw.RoundedBoxEx(1, 0, self:GetTall() - height - 5, self:GetWide(), height + 5, Color(0, 0, 0, 205))
						draw.SimpleText(text, "Default", self:GetWide()/2, self:GetTall() - 1, GAME_OUTLINE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					end
				end
				
				if self.Shop then
					local text = GetPerk(self.ID).Price .. "c"
					local width, height = surface.GetTextSize(text)
					width = width + 1
				
					draw.RoundedBoxEx(1, 0, self:GetTall() - height - 5, self:GetWide(), height + 5, Color(0, 0, 0, 245))
					if Money >= GetPerk(self.ID).Price then
						draw.SimpleText(text, "Default", self:GetWide()/2, self:GetTall() - 4, Color(55, 155, 95, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					else
						draw.SimpleText(text, "Default", self:GetWide()/2, self:GetTall() - 4, Color(155, 55, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					end
				end
			end
		else
			surface.SetMaterial(unknownIcon)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)
		
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
		
		if self.Active then
			surface.SetMaterial(activeIcon)
			surface.SetDrawColor(Color(55, 255, 55, 255))
			surface.DrawTexturedRect(self:GetWide()/2, self:GetTall()/2, self:GetWide()/2, self:GetTall()/2)
					
			//surface.DrawCircle(w/2, h/2, h/2, Color(55, 255, 55, 255))
		else
--[[ 			local outlineColor = Color(GetPerk(self.ID).Color.r + 55, GetPerk(self.ID).Color.g + 55, GetPerk(self.ID).Color.b + 55, 255)
				
			surface.DrawCircle(w/2 + .5, h/2 +, h/2 + 1, outlineColor) ]]
		end
		
		render.SetStencilEnable(false)
	render.ClearStencil()
end

vgui.Register("Perk", PERK, "DButton")

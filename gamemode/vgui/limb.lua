local LIMB = {}

function LIMB:Init()
	self:SetText("")
	self.Limb = false
end

function LIMB:SetLimb(limb)
	self.Limb = limb
	
	self:Receiver("Slot",function(rcv, pDropped, bDrop)
		if !bDrop then return end
		
		local pnl = pDropped[1]
		local item = GetItemByKey(pnl.Item)
		if item then
			if CONSUME_TYPES[item.Type].Medical then
				net.Start("UseItemLimb")
					net.WriteEntity(LocalPlayer())
					net.WriteEntity(pnl.Ent)
					net.WriteUInt(pnl.Slot, 16)
					net.WriteString(self.Limb)
				net.SendToServer()
			end
		end
	end)
end

local function IsLimbHealthy(limb)
	local limb = _Limbs[limb]
	if limb["Broken"] || limb["Bleeding"] then
		return false
	else
		return true
	end
end

function LIMB:OnCursorEntered()
	if Tooltip then
		if Tooltip:IsValid() then
			Tooltip:Close()
		end
	end

	Tooltip = vgui.Create("DFrame")
	
	Tooltip:ShowCloseButton(false)
	Tooltip:MakePopup()
	Tooltip:SetTitle("")
	
	local height = 20
	local offset = 19.5
	local buffdisp = {}
	
	for k,v in pairs(_Limbs[self.Limb]) do
		height = height + offset
		
		buffdisp[#buffdisp + 1] = k
	end
	
	if height == 20 then
		height = height + offset
	end
	
	Tooltip:SetSize(100, height)
	
	Tooltip.Owner = self
	
	
	
	Tooltip.Paint = function(s)
		draw.FillPanel(s, Color(55, 55, 55, 255))
		draw.RoundedBox(3,0,0, s:GetWide(), 17, GAME_COLOR)
		draw.SimpleText(self.Limb, "Default", s:GetWide()/2, 2.5, GAME_OUTLINE, TEXT_ALIGN_CENTER)
	
		if IsLimbHealthy(self.Limb) then
			draw.SimpleText("Healthy", "Default", s:GetWide()/2, offset, Color(55, 155, 55, 255), TEXT_ALIGN_CENTER)
		else
			for k,v in pairs(buffdisp) do
				surface.SetDrawColor(BUFFS[v].Color)
				surface.SetMaterial(BUFFS[v].Icon)
				surface.DrawTexturedRect(1,offset * k + 1, offset - 2, offset - 2)
				
				draw.SimpleText(v, "Default", s:GetWide()/2, offset * k + 2, BUFFS[v].Color, TEXT_ALIGN_CENTER)
			end
		end
	
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall())	
	end
	
	Tooltip.Think = function(s)
		s:MoveToFront()
			
		local x,y = gui.MousePos()
		local offsetX = x + 30
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

function LIMB:OnCursorExited()
	if Tooltip then
		if Tooltip:IsValid() then
			Tooltip:Close()
		end
	end
end

function LIMB:Paint()

end

vgui.Register("Limb", LIMB, "DButton")
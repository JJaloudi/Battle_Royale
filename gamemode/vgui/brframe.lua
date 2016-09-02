surface.CreateFont( "Title", 
{
	font    = "Roboto-Light",
    size    = 14,
    weight  = 1000,
    antialias = true,
    shadow = false
})

local BRFrame = {}

function BRFrame:Init()
	self.pTitle = ""
	self:SetTitle("")
end

function BRFrame:Title(text)
	self.pTitle = text
end

function BRFrame:Paint()
	draw.FillPanel(self, GAME_COLOR)
	
	 
	surface.SetFont("Title")
	local width, height = surface.GetTextSize(self.pTitle)
	
	height = height * 1.5
	
	draw.RoundedBoxEx(1,0,0, self:GetWide(), height, GAME_MAIN)
	draw.SimpleText(self.pTitle, "Title", self:GetWide()/2, height/2 - height / 2.5, GAME_OUTLINE, TEXT_ALIGN_CENTER)
	
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), height)
	surface.DrawOutlinedRect(0,0, self:GetWide(), self:GetTall())
end


vgui.Register("BRFrame", BRFrame, "DFrame")
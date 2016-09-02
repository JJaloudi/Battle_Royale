surface.CreateFont( "Notification", 
{
	font    = "Roboto-Light",
    size    = 16,
    weight  = 1000,
    antialias = true,
    shadow = false
})

surface.CreateFont( "NotificationHeader", 
{
	font    = "Roboto-Light",
    size    = 13,
    weight  = 1000,
    antialias = true,
    shadow = false
})

local xPos = ScrW() - 20
local indentOffset = 5
local yPos = ScrH() - 70


local IconTypes = {
	[NOTIFY_WARNING] = Material("icons/notif_warning.png"),
	[NOTIFY_INJURY] = Material("icons/notif_injury.png"),
	[NOTIFY_BLEEDING] = Material("icons/notif_bleeding.png"),
	[NOTIFY_KILLED] = Material("icons/notif_killed.png"),
	[NOTIFY_PICKEDUP] = Material("icons/notify_grab.png")
} 

notification = {Queue = {}}

function notification.Create(nType,  headerText, bodyText, headerColor, bodyColor, dispTime)
	if !dispTime then dispTime = 5 end

	local settings = {}
	settings.Header = headerText
	settings.Body = bodyText
	settings.HeaderColor = headerColor || COLOR_DEFAULT
	settings.BodyColor = bodyColor || COLOR_OUTLINE
	settings.DisplayTime = CurTime() + dispTime
	settings.Type = nType || NOTIFY_WARNING
	settings.x = xPos
	settings.y = 0
	local ind = table.insert(notification.Queue, settings)
	
	
	for k,v in pairs(notification.Queue) do
		v.queue = (k + 1) - 1
	end
end

function notification.Remove(index)
	table.remove(notification.Queue, index)
	
	for k,v in pairs(notification.Queue) do
		if v.queue - 1 >= 1 then
			v.queue = v.queue - 1
		end
	end
end

notification.Settled = true

hook.Add("HUDPaint", "Render notifications", function()
	if #notification.Queue <= 0 then return end
	  
	
	for k,v in pairs( notification.Queue ) do
		surface.SetFont( "Notification" ) 
	
	
		local wpx, hpx = surface.GetTextSize( v.Body )	
		
		surface.SetFont("NotificationHeader")
		local cWidth, cHeight = surface.GetTextSize( v.Header )
		
		if cWidth > wpx then
			wpx = cWidth
		end
		
		local width, height = wpx + indentOffset * 2, hpx * 2.4
		width = width + height
		
		
		if v.DisplayTime <= CurTime() then 
			
			if v.x >= ScrW() + width then
			
				notification.Settled = true
			
				if notification.Settled then
				
					notification.Remove( k )
					
					notification.Settled = false
						
				end
				
			else
				v.x = v.x + 10
					
				notification.Settled = false 
			end
			
		else
		
			local destinedX = xPos - width + 5
			v.x = math.Approach(v.x, destinedX, 10)
			
			v.y = yPos - (height * v.queue * 1.2 ) 
			
		end
		
		surface.SetFont("NotificationHeader")
		local dwpx, dhpx = surface.GetTextSize( v.Header )
		
		
		local col = GAME_COLOR
		col.a = 255
		draw.RoundedBoxEx( 1, v.x, v.y, width, height, col )
		draw.SimpleText(v.Header, "NotificationHeader", v.x + height - 2 + indentOffset, v.y + 6, v.HeaderColor)
		draw.SimpleText(v.Body, "Notification", v.x + indentOffset + height - 2,  v.y + height - hpx - 4, v.BodyColor)
		
		surface.SetDrawColor(v.HeaderColor)
		surface.SetMaterial(IconTypes[v.Type])
		surface.DrawTexturedRect( v.x + 2.5, v.y + 2.5, height - 5, height - 5 )
		
		//surface.SetDrawColor(V.h)
		surface.DrawOutlinedRect( v.x, v.y, width + 1, height + 1 )
		
		
	end
end)

net.Receive("SendNotification", function()

	notification.Create(net.ReadUInt(8), net.ReadString(), net.ReadString(), net.ReadColor(), net.ReadColor(), net.ReadUInt(8))

end)

concommand.Add("testnotif", function()
	notification.Create(NOTIFY_KILLED, "Juju killed Bot 01!", "Only 5 players remain.", Color(55, 75, 195, 255), color_white, 3)
	notification.Create(NOTIFY_INJURY, "You got injured!", "You've broken your leg.", color_black, color_white, 6)
	notification.Create(NOTIFY_BLEEDING, "Your left arm is bleeding!", "Apply a bandage to your limb before you bleed out!", Color(255, 75, 105, 255), color_white, 5)
	notification.Create(NOTIFY_WARNING, "SERVER", "Thank you for playing!", Color(55, 255, 105, 255), color_white, 2)
end)
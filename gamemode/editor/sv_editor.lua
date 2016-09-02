util.AddNetworkString("SendCompressedData")
net.Receive("SendCompressedData", function()
	local pl = net.ReadEntity()
	local json = net.ReadString()
	
	if pl:GetDevMode() then
		file.Write(game.GetMap() .. ".txt", json)
		print("Saved new configuration file for map "..game.GetMap())
		
		
		local data = file.Read(game.GetMap() .. ".txt", "DATA")
		if data then
			net.Start("SendCompressedData")
				net.WriteString(data)
			net.Send(pl) 
		end
	else
		pl:Kick("Gtfo")
	end
end)

util.AddNetworkString("RequestMapData")
net.Receive("RequestMapData", function()
	local pl = net.ReadEntity()
	
	local data = file.Read(game.GetMap() .. ".txt", "DATA")
	if data then
		net.Start("SendCompressedData")
			net.WriteString(data)
		net.Send(pl)
	end
end)

local P = FindMetaTable("Player")

util.AddNetworkString("ToggleDevMode")
function P:ToggleDevMode(b)
	self.DevMode = b
	
	net.Start("ToggleDevMode")
		net.WriteBool(self.DevMode)
	net.Send(self)
end

function P:GetDevMode()
	return self.DevMode || false
end

hook.Add( "PlayerNoClip", "AllowDevNoClip", function(pl)
	return pl.DevMode
end) 
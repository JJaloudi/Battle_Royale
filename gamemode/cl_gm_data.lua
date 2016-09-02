BR = {
	QueuedPlayers = {},
	ActivePlayers = {}
}

function BR:SetGameStatus(b)
	self.GameStatus = b
end

net.Receive("SetGameType", function()
	BR:SetGameType(net.ReadTable()[1])
end)

function BR:SetGameType(type)
	self.GameType = type
	
	if !type then
		self.ActivePlayers = {}
		self.QueuedPlayers = {}
		
		self:SetGameStatus(type)
	end
end

function BR:ResetTables()
	self:SetGameType(false)
end

function BR:GetGameStatus()
	return self.GameStatus or false
end

function BR:IsPlayerQueued(pl)
	return table.HasValue(self.QueuedPlayers, pl)
end

net.Receive("QueuePlayer", function()
	BR:QueuePlayer(net.ReadEntity())
end)

function BR:QueuePlayer(pl)
	if !self:IsPlayerQueued(pl) then
		table.insert(self.QueuedPlayers, pl)
	
	end
end

net.Receive("RemoveQueuedPlayer", function()
	BR:RemoveQueuedPlayer(net.ReadEntity())
end)

function BR:RemoveQueuedPlayer(pl)
	if self:IsPlayerQueued(pl) then
		table.RemoveByValue(self.QueuedPlayers, pl)	
	end
end

function BR:IsPlayerActive(pl)
	return table.HasValue(self.ActivePlayers, pl)
end

net.Receive("EliminatePlayer", function()
	BR:EliminatePlayer(net.ReadEntity())
end)

function BR:EliminatePlayer(pl)
	if self:IsPlayerActive(pl) then
		table.RemoveByValue(self.ActivePlayers, pl)
	end
end

function LPPlaying()
	return BR:IsPlayerActive(LocalPlayer())
end

net.Receive("SendMatchInfo",function()

	BR:SetGameType(net.ReadUInt(16))
	
	Teammates = net.ReadTable()
	
	BR.ActivePlayers = net.ReadTable()
	
	if Panel then
		if Panel:IsValid() then
			Panel:Close()
		
			Panel = false
		end
	end
	
	if MainMenu then
		if MainMenu:IsValid() then
			MainMenu:Close()
			
			MainMenu = false
		end
	end
	
	bPerks = {}
end)

net.Receive("SetTimer", function()
	BR:SetTimer(net.ReadUInt(8))
end)

function BR:SetTimer(val)
	if val <= 0 then
		self.Time = false
		
		surface.PlaySound("buttons/combine_button1.wav")
	else
		self.Time = val
		
		surface.PlaySound("buttons/blip1.wav")
	end
end

hook.Add("HUDPaint", "Time", function()
	if BR.Time then
		draw.SimpleText(BR.Time, "Default", ScrW()/2, 5, color_white, TEXT_ALIGN_CENTER)
	end
end)
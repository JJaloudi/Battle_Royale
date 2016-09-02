BattleRoyale = {
	QueuedPlayers = {},
	ActivePlayers = {}
}
local BR = BattleRoyale

util.AddNetworkString("SetGameType")
function BR:SetGameType(name)
	local id = GetGameType(name) || name
	if id || GameTypes[name] then
		self.GameType = id
	elseif name == false then
		self.GameType = false
		
		self.QueuedPlayers = {}
		self.ActivePlayers = {}
		
		net.Start("SetGameType")
			net.WriteTable({name})
		net.Broadcast()
	end
	
	local data = file.Read(game.GetMap() .. ".txt", "DATA")
	if data then
		self.Config = util.JSONToTable(file.Read(game.GetMap() .. ".txt", "DATA"))
	end
end 

function BR:GetGameType()
	return self.GameType || false
end

function BR:SetPlayerPlacement(pl, place)
	if !self.Placement then
		self.Placement = {}
	end
	
	if !self.Placement[place] then
		self.Placement[place] = {}
	end
	
	
	local tbl = {Player = pl}
	table.insert(self.Placement[place], tbl)
end

hook.Add("PlayerDisconnected", "HandleQueue", function(pl)
	local ref = BattleRoyale

	if ref:GetGameType() == false then
		if ref:PlayerIsQueued(pl) then
			ref:RemoveQueuedPlayer(pl)
		end
	else
		if ref:IsPlayerActive(pl) then
			ref:EliminatePlayer(pl)
		end
		
		if ref.Placement then
		
			for k,v in pairs(ref.Placement) do
			
				for place, tbl in pairs(ref.Placement[k]) do
				
					if tbl.Player == pl then
						tbl = nil
					end
					
				end
				
			end
			
		end
		
		if #player.GetAll() < 2 then
		
			game.CleanUpMap()
	
			ref:SetGameType(false)
			
		end
	end
end)

function BR:PlayerIsQueued(pl)
	return table.HasValue(self:GetQueuedPlayers(), pl) or false
end

util.AddNetworkString("QueuePlayer")
net.Receive("QueuePlayer", function()
	BR:QueuePlayer(net.ReadEntity())
end)

function BR:QueuePlayer(pl)
	if !self:PlayerIsQueued(pl) then
		table.insert(self.QueuedPlayers, pl)
		
		net.Start("QueuePlayer")
			net.WriteEntity(pl)
		net.Broadcast()
		
		if #self.QueuedPlayers >= math.Round(#player.GetAll()/2) then
			self:SetGameType(GetGameType("Deathmatch"))
			self:StartGameTimer()
		end
		
	end
end

util.AddNetworkString("RemoveQueuedPlayer")
net.Receive("RemoveQueuedPlayer", function()
	BR:RemoveQueuedPlayer(net.ReadEntity())
end)

function BR:RemoveQueuedPlayer(pl)
	if self:PlayerIsQueued(pl) then
		table.RemoveByValue(self.QueuedPlayers, pl)
		
		net.Start("RemoveQueuedPlayer")
			net.WriteEntity(pl)
		net.Broadcast()
	end
end

function BR:GetQueuedPlayers()
	return self.QueuedPlayers || {}
end

function BR:IsPlayerActive(pl)
	return table.HasValue(self.ActivePlayers, pl)
end

util.AddNetworkString("EliminatePlayer")
function BR:EliminatePlayer(pl)
	if self:IsPlayerActive(pl) then
		table.RemoveByValue(self.ActivePlayers, pl)
		
		net.Start("EliminatePlayer")
			net.WriteEntity(pl)
		net.Broadcast()
	end
end

function BR:GetRemainingPlayers()
	return #self.ActivePlayers
end

util.AddNetworkString("SetTimer")
function BR:StartGameTimer()
	if self.Time then
		timer.Remove("BRGameTime")
	end
	
	self.Time = 10
	timer.Create("BRGameTime", 1, 0, function()
		if self.Time - 1 > 0 then
			self.Time = self.Time - 1
		else
			self:StartGame()
			
			self.Time = false
			timer.Remove("BRGameTime")
		end
	
		net.Start("SetTimer")
			net.WriteUInt(self.Time or 0, 8)
		net.Broadcast()
	end)
end

function BR:StartGame()
	for key, pos in pairs(self.Config["Player Spawn"]) do
		pos.Occupied = false
	end

	game.CleanUpMap()
	self:SpawnLoot()
	if self.Config["Player Spawn"] then
	
		for k,v in pairs(player.GetAll()) do
			//if self:PlayerIsQueued(v) then
			
				table.insert(self.ActivePlayers, v)
			
				local tbl = {}
				for key, pos in pairs(self.Config["Player Spawn"]) do
				
					if !pos.Occupied then
						table.insert(tbl, key)
					end
					
				end
				
				local ref = table.Random(tbl)
				local pRef = self.Config["Player Spawn"][ref]
				
				v:StripWeapons()
				v:Spawn()
				
				v:SetHunger(100)
				v:SetStamina(100)
				
				if self:GetGameType() then
					v:SetWalkSpeed(Config.DefaultWalkSpeed)
					v:SetRunSpeed(Config.DefaultRunSpeed)
					v:SetJumpPower(160)
				end
					
				v:SetPos(pRef.Pos)		
				v:SendMatchInfo({v}, self:GetQueuedPlayers())
				pRef.Occupied = true
				
				for i = 1, Config.DefaultSlots do
					v.Inventory[i] = {}
					
					v:SetSlot(i, false)
				end
				
				hook.Call("RoundStart", GAMEMODE, v, self:GetGameType()) 
				
				for slot, id in pairs(v.ActivePerks) do
					local ref = v:HasPerk(id)
					
					if ref then
					
						if ref - 1 <= 0 then
						
							print("Set perk to 0")
						
							v:SetPerk(id, 0)
							
						else
						
							v:AddPerk(id, -1)
							
						end
						
					end
				end
		//	end
			
		end
		
		self.QueuedPlayers = nil
	else
		print("CRITICAL ERROR! Your server cannot run without a proper map configuration file! You're missing spawn points.")
	end
end

util.AddNetworkString("EndGame")
function BR:EndGame(winner)

	game.CleanUpMap()
	
	self:SetGameType(false)

	for k,v in pairs(player.GetAll()) do
		v:ClearHotbar()

		v:ClearInventory()
	end
	
	for k,v in pairs(self.Placement) do
	
		if v[1] then
		
			for key, pl in pairs(self.Placement[k]) do	
			
				pl.Rewards = {}
				
				local multiplier = 4 - k
				local pay = {"Money", multiplier * 150}
				
				table.insert(pl.Rewards, pay)
				
				if pl.Player then
					if pl.Player:IsValid() then
						pl.Player:AddMoney(multiplier * 150)
			
						for i = 1, 4 - k do
						
							local chance = math.random(1, 100)
						
							local pTbl = {}
							for id, tbl in pairs(PERKS) do
								if chance <= tbl.Rarity then
									pTbl[#pTbl + 1] = tbl.ID
								end
							end
							
							local perkID = table.Random(pTbl)
							
							if GetPerk(perkID) then
								local perk = {"PERK", perkID, 1}
								
								table.insert(pl.Rewards, perk)
							end
						end

						for key,val in pairs(pl.Rewards) do
						
							if val[1] == "PERK" then					
								pl.Player:AddPerk(val[2], val[3])
							end
							
						end
					else
						self.Placement[k] = nil
					end
				else				
					self.Placement[k] = nil
				end
			end
		end
	end
	
	for k,v in pairs(player.GetAll()) do
		
		net.Start("EndGame")
			net.WriteTable(self.Placement)
		net.Send(v)
		
		v:Spawn()
		v:StripWeapons()
		
	end
	
	self.Placement = nil
	
	self.QueuedPlayers = {}
	self.ActivePlayers = {}
end

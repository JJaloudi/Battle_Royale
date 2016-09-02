hook.Add("Initialize", "SetDefaultGameType", function()
	//if check for votes then
	
	//else
		BattleRoyale:SetGameType(Config.DefaultGameType)
	//end
end)

util.AddNetworkString("UpdatePlayerCount")
util.AddNetworkString("RemovePlayer") 
hook.Add("PlayerDeath", "HandleGameTypeDeath", function(victim, weapon, killer)
	local gtype = BattleRoyale:GetGameType()
	if gtype then
		GameTypes[gtype].OnPlayerKilled(victim, weapon, killer)

		net.Start("RemovePlayer")
		net.Send(victim)
		
		net.Start("UpdatePlayerCount")
			net.WriteUInt(BattleRoyale:GetRemainingPlayers(), 16)
		net.Broadcast()
		
		victim:ClearHotbar()

		victim:ClearInventory()
	end
end)

hook.Add("PlayerDeathThink", "RejectSpawn", function(pl)
	local gtype = BattleRoyale:GetGameType()
	if gtype then
		return false
	end
end)

hook.Add("ScalePlayerDamage", "Limb Damage", function(pl, hg, dmginfo)
	for k,v in pairs(Limbs) do
		if table.HasValue(v.Hitgroup, hg) then	
			dmginfo:SetDamage(dmginfo:GetDamage() * v.Scale)
			if !table.HasValue({DMG_CLUB, DMG_FALL}, dmginfo:GetDamageType()) then
				if !pl:LimbHasBuff(k, "Bleeding") then
				
					pl:Notify(NOTIFY_BLEEDING, "Injured", "Your ".. string.lower(k) .. " is bleeding.", Color(155, 55, 55, 255), color_white, 5)
					pl:SetLimbBuff(k, "Bleeding", true)
					
					if dmginfo:GetInflictor() then
					
						if dmginfo:GetInflictor():IsValid() then
						
							pl.bInflictor = dmginfo:GetInflictor()
							
						end
						
					end
					
				end
			end
		end
	end
end)

hook.Add("PlayerFootstep", "BrokenLeg", function(pl, pos, foot)
	local leg = {
		[0] = {"Left Leg", -1},
		[1] = {"Right Leg", 1}
	}

	if pl.Limbs[leg[foot][1]]["Broken"] then
		pl:ViewPunch( Angle( 0, leg[foot][2], leg[foot][2] ) )
	end
end)

util.AddNetworkString("OnSlotSwap")
net.Receive("OnSlotSwap", function()
	local ent = net.ReadEntity()
	local slot1 = net.ReadUInt(16)
	local slot2 = net.ReadUInt(16)
	
	ent:SwapSlots(slot1, slot2)
end)

util.AddNetworkString("InventoryInteract")
net.Receive("InventoryInteract", function()
	local ent = net.ReadEntity()
	local dropEnt = net.ReadEntity()
	local dropSlot = net.ReadUInt(16)
	
	local ref = dropEnt.Inventory[dropSlot]
	if ref[3] then
		ent:GiveItem(ref[1], 1, ref[3])
	else
		ent:GiveItem(ref[1], 1)
	end
	
	dropEnt:GiveItem(ref[1], -1, false, dropSlot)
end)

timer.Create("ServerMessages", Config.MessageTime, 0, function()
	local message = table.Random(Config.ServerMessages)

	for k, v in pairs(player.GetAll()) do
		v:Notify(NOTIFY_WARNING, "Battle Royale", message, Color(55, 155, 55, 255), color_white, 6)
	end
end)
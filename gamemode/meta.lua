local P = FindMetaTable("Player")

hook.Add("PlayerInitialSpawn", "HandleConfig", function(pl)
	db:Query("SELECT * FROM player where steamid='"..pl:SteamID().."'",function(r,s,e)
		if #r[1].data > 0 then
			local ref = r[1].data[1]

			pl:SetMoney(tonumber(ref.money), true)
			pl:SetModel(GetModel(ref.model).Model)
			
			for k,v in pairs(util.JSONToTable(ref.perks)) do
				pl:SetPerk(tonumber(k), tonumber(v), true)
			end
			
			for k,v in pairs(util.JSONToTable(ref.apparel)) do
				pl:UnlockApparel(tonumber(k), true)
			end
			
			timer.Simple(2, function()
				if ref.eapparel then			
					for k,v in pairs(util.JSONToTable(ref.eapparel)) do
						pl:EquipApparel(tonumber(v), true)
					end
				end
			end)
			
 		else
			db:Query("INSERT INTO player (steamid, money, model, perks, apparel, eapparel) VALUES('"..pl:SteamID().."', 500, 1, '"..util.TableToJSON({}).."', '"..util.TableToJSON({}).."', '"..util.TableToJSON({}).."')")
			pl:SetMoney(500, true)
		end
	end)

	if Config.LimbSystem then
		pl.Limbs = {}
		for k,v in pairs(Limbs) do
			pl.Limbs[k] = {}
		end
	end
	
	pl:SetRunSpeed(Config.DefaultRunSpeed)
	pl:SetWalkSpeed(Config.DefaultWalkSpeed)
	
	pl.Perks = {}
	pl.ActivePerks = {}
	pl.Inventory = {}
	
	pl.UnlockedApparel = {}
	pl.Apparel = {}
end)

util.AddNetworkString("SendLimbData")
function P:SetLimbBuff(limb, buff, amt)
	self.Limbs[limb][buff] = amt
	
	net.Start("SendLimbData")
		net.WriteString(limb)
		net.WriteTable(self.Limbs[limb])
	net.Send(self)
end

function P:LimbHasBuff(limb, buff)
	return self.Limbs[limb][buff] || false
end

function P:RemoveLimbBuff(limb, buff)
	self:SetLimbBuff(limb, buff, false)
end

function P:GetLimbs(buff)
	local tbl = {}
	
	for k,v in pairs(self.Limbs) do
		if v[buff] then
			table.insert(tbl, k)
		end
	end	
	
	return tbl
end

function P:IsImpaired()
	local impaired = false
	local legs = {"Left Leg", "Right Leg"}
	
	for k,v in pairs(self.Limbs) do
		if table.HasValue(legs, k) then
			if v["Broken"] then
				impaired = true
				
				break
			end
		end
	end
	
	return impaired
end

function P:IsBleeding()
	local bTbl = {}
	for k,v in pairs(self.Limbs) do
		if v["Bleeding"] then
			bTbl[k] = true
		end
	end
	
	return bTbl
end

util.AddNetworkString("SendStamina")
function P:SetStamina(amt)
	self.Stamina = amt 
	net.Start("SendStamina")
		net.WriteUInt(amt,8)
	net.Send(self)
end

function P:GetStamina()
	return self.Stamina or 100
end

function P:AddStamina(amt)
	self:SetStamina(self:GetStamina() + amt)
end

util.AddNetworkString("SendHunger")
function P:SetHunger(amt)
	self.Hunger = amt
	net.Start("SendHunger")
		net.WriteUInt(amt,8)
	net.Send(self)
end

function P:GetHunger()
	return self.Hunger or 100
end

function P:AddHunger(amt)
	self:SetHunger(self:GetHunger() + amt)
end

util.AddNetworkString("SendNotification")
function P:Notify(nType, header, body, hcolor, bcolor, time)
	net.Start("SendNotification")
		net.WriteUInt(nType, 8)
		net.WriteString(header)
		net.WriteString(body)
		net.WriteColor(hcolor)
		net.WriteColor(bcolor)
		net.WriteUInt(time, 8)
	net.Send(self)
end

local E = FindMetaTable("Entity")

util.AddNetworkString("AddItem")
util.AddNetworkString("RemoveItem")
function E:SetSlot(slot, id, data)
	if self.Inventory[slot] then
		if id != false then			
			local ref = Items:GetItemByKey(id)
			if ref then
			
				self.Inventory[slot] = {Item = id}
				
				if data then
					self.Inventory[slot].Data = data
				elseif ref.Type == "Firearm" then
				
					self.Inventory[slot].Data = {Clip = weapons.Get(ref.Entity).Primary.ClipSize}
				
				end
				
				
				net.Start("AddItem")
					net.WriteUInt(slot, 16)
					net.WriteTable(self.Inventory[slot])
				net.Send(self)
			end
			
		else
			self.Inventory[slot] = {}
			
			net.Start("RemoveItem")
				net.WriteUInt(slot, 16)
			net.Send(self)
		end
	else
		print("?")
	end
end

util.AddNetworkString("ChangeSlot")
net.Receive("ChangeSlot", function()
	local pl = net.ReadEntity()
	local slot = net.ReadUInt(8)
	
	pl.ActiveSlot = slot
	
	local ref = pl.Inventory[slot]
	if ref then
		if ref.Item != false || ref.Item != nil then
			local iRef = Items:GetItemByKey(ref.Item)
		
			if iRef then
				if iRef.Type == "Firearm" then
					
					if pl:GetActiveWeapon():IsValid() then
						if pl:GetActiveWeapon():GetClass() == iRef.Entity then
							pl:StripWeapon(iRef.Entity)
						end
					end
				
					if pl:HasWeapon(iRef.Entity) then
						pl:SelectWeapon(iRef.Entity)
					else
						pl:Give(iRef.Entity)
					end
					
					local wepEnt = pl:GetWeapon(iRef.Entity)
					wepEnt:SetClip1(ref.Data.Clip)
				end
			else
				pl:SetActiveWeapon("gmod_hands")
			end
		else
			pl:SetActiveWeapon("gmod_hands")
		end
	end
end)

util.AddNetworkString("ClearInventory")
function P:ClearInventory()
	self.Inventory = nil
	self.Inventory = {}
	
	net.Start("ClearInventory")
	net.Send(self)
end

util.AddNetworkString("SendMoney")
function P:SetMoney(amt, b)
	self.Money = amt
	
	net.Start("SendMoney")
		net.WriteUInt(amt, 16)
	net.Send(self)
	
	if !b then
		db:Query("UPDATE player set money="..amt.." where steamid='"..self:SteamID().."'")
	end
end

function P:GetMoney()
	return self.Money or 0
end

function P:AddMoney(amt)
	self:SetMoney(self:GetMoney() + amt)
end

util.AddNetworkString("EquipItem")
function P:EquipItem(slot)
	local invRef = self.Inventory[slot]
	local ref = GetItemByKey(invRef[1])
	
	if ref then
		if self.EquippedItem then
			self:UnequipItem()
		end
		
		if ref.Type == "Weapon" then
			local wep = self:Give(ref.Entity)
			
			wep:SetClip1(self.Inventory[slot][3].Clip)
			wep.InvSlot = slot
		end
		
		self.EquippedItem = slot		
		net.Start("EquipItem")
			net.WriteUInt(slot, 16)
		net.Send(self)
	end
end

net.Receive("EquipItem", function()
	local pl = net.ReadEntity()
	local dropEnt = net.ReadEntity()
	local dropSlot = net.ReadUInt(16)
	
	local nSlot = dropSlot
	if pl != container then
		local ref = dropEnt.Inventory[dropSlot]
		if ref[3] then
			nSlot = pl:GiveItem(ref[1], 1, ref[3])
		else
			nSlot = pl:GiveItem(ref[1], 1)
		end
		
		dropEnt:GiveItem(ref[1], -1, false, dropSlot)
	end
	
	//print(nSlot)
	
	pl:EquipItem(nSlot)
end)	

util.AddNetworkString("UnequipItem")
function P:UnequipItem()
	if self.EquippedItem then	
		self:StripWeapons()
		self.EquippedItem = false
		
		net.Start("UnequipItem")
		net.Send(self)
	end
end

net.Receive("UnequipItem", function()
	net.ReadEntity():UnequipItem()
end)

util.AddNetworkString("BuyPerk")
net.Receive("BuyPerk", function()
	local pl = net.ReadEntity()
	local perk = net.ReadUInt(16)
	
	local ref = GetPerk(perk)
	if ref.Price then
	
		if pl:GetMoney() >= ref.Price then
			pl:AddPerk(perk, 1)
			pl:AddMoney(-ref.Price)
		end
	end
end)

function P:CalculateWeight()
	local weight = 0
	
	for k,v in pairs(self.Inventory) do
		if v[1] then
			local stack = v[2]
			local item_weight = GetItemByKey(v[1]).Weight
			
			weight = weight + (item_weight * stack)
		end
	end
	
	return weight
end
	
util.AddNetworkString("UseItem")
net.Receive("UseItem",function()
	local pl = net.ReadEntity()
	local container = net.ReadEntity()
	local slot = net.ReadUInt(16)
		
	if pl.Inventory[slot] then
		local item = pl.Inventory[slot][1]
		local ref = GetItemByKey(item)
	
		if ref.Type == "Weapon" then
			
			local wep = pl:Give(ref.Entity)
			wep:SetClip1(pl.Inventory[slot][3].Clip)
			wep.InvSlot = slot
			
		else
			
			local bUse = CONSUME_TYPES[ref.SubType].OnUse(pl, item, slot)
			
			if bUse then
				container:GiveItem(item, -1)
			end
		end
	end
end)

function P:UnequipWeapon()
	local wep = self:GetActiveWeapon()
	if wep then
		if self.Inventory[wep.InvSlot] then
			self.Inventory[wep.InvSlot][3].Clip = wep:Clip1()
			
			self:StripWeapon(wep:GetClass())
		end
	end
end

util.AddNetworkString("ClearHotbar") 
function P:ClearHotbar()
	net.Start("ClearHotbar")
	net.Send(self)
end

function P:GetGender()
	local Gender = "Male"
	
	if string.find(string.lower(self:GetModel()), "female") then
		Gender = "Female"
	end
	
	return Gender
end

util.AddNetworkString("SendUnlockedPerkTable")
util.AddNetworkString("SendUnlockedPerk")
function P:SetPerk(perk, amt, b)
	self.Perks[perk] = amt
	 
	net.Start("SendUnlockedPerk")
		net.WriteUInt(perk, 16)
		net.WriteUInt(amt, 16)
	net.Send(self)
	
	if !b then
		db:Query("UPDATE player set perks='"..util.TableToJSON(self.Perks).."' where steamid='"..self:SteamID().."'")
	end
end

function P:HasPerk(perk)
	if self.Perks[perk] then
		return self.Perks[perk]
	else
		return false
	end
end

function P:AddPerk(perk, amt)
	local pAmt = self:HasPerk(perk)
	if pAmt	then
		self:SetPerk(perk, pAmt + amt)
	else
		self:SetPerk(perk, amt)
	end
end

util.AddNetworkString("SendActivePerk")
function P:SetPerkActive(id)
	local perk = GetPerk(id)

	if perk then
		self.ActivePerks[perk.Slot] = id
		
		net.Start("SendActivePerk")
			net.WriteUInt(id, 16)
		net.Send(self)
	end
end

util.AddNetworkString("SelectPerk")
net.Receive("SelectPerk", function()
	local pl = net.ReadEntity()
	local perk = net.ReadUInt(16)
	
	if pl:HasPerk(perk) then
		pl:SetPerkActive(perk)
	end
end)

function P:HasActivePerk(perk)
	return self.ActivePerks[GetPerk(perk).Slot] == perk
end

util.AddNetworkString("TogglePerk")
function P:TogglePerk(perk)
	net.Start("TogglePerk")
		net.WriteUInt(perk, 16)
	net.Send(self)
end

util.AddNetworkString("EquipApparel")
util.AddNetworkString("RemoveApparel")
function P:EquipApparel(id, b)
	if GetApparel(id) then
		local it = GetApparel(id)
		self.Apparel[it.Category] = id
				
		net.Start("EquipApparel")
			net.WriteEntity(self)
			net.WriteUInt(id, 16)
		net.Broadcast()
		
		if !b then
			db:Query("UPDATE player set eapparel='"..util.TableToJSON(self.Apparel).."' where steamid='"..self:SteamID().."'")
		end
	end
end

net.Receive("EquipApparel", function()
	local pl = net.ReadEntity()
	local id = net.ReadUInt(16)
	
	if pl:ApparelUnlocked(id) then
		pl:EquipApparel(id)
	end
end)

function P:RemoveApparel(loc, b)
	if APPAREL_TYPES[loc] then
		if self.Apparel[loc] then
			self.Apparel[loc] = nil
			
			net.Start("RemoveApparel")
				net.WriteEntity(self)
				net.WriteString(loc)
			net.Broadcast()
			
			if !b then
				db:Query("UPDATE player set eapparel='"..util.TableToJSON(self.Apparel).."' where steamid='"..self:SteamID().."'")
			end
		end
	end
end

function P:ApparelEquipped(id)
	local app = GetApparel(id)
	if self.Apparel[app.Category] then
		if self.Apparel[app.Category] == id then
			return true
		else
			return false
		end
	else
		return false
	end
end

util.AddNetworkString("UnequipApparel")
net.Receive("UnequipApparel", function()
	local pl = net.ReadEntity()
	local id = net.ReadUInt(16)
	
	if pl:ApparelEquipped(id) then
		pl:RemoveApparel(GetApparel(id).Category)
	end
end)
	
util.AddNetworkString("UnlockApparel")
function P:UnlockApparel(id, b)
	self.UnlockedApparel[id] = true
		
	net.Start("UnlockApparel")
		net.WriteUInt(id, 16)
	net.Send(self)
	
	if !b then
		db:Query("UPDATE player set apparel='"..util.TableToJSON(self.UnlockedApparel).."' where steamid='"..self:SteamID().."'")
	end
end

util.AddNetworkString("BuyApparel")
net.Receive("BuyApparel", function()
	local pl = net.ReadEntity()
	local id = net.ReadUInt(16)

	local apparel = GetApparel(id)
	if pl:GetMoney() > apparel.Price then
		pl:AddMoney(-apparel.Price)
	
		pl:UnlockApparel(id)
		pl:EquipApparel(id)
	end
end)

function P:ApparelUnlocked(id)
	return self.UnlockedApparel[id] || false
end

util.AddNetworkString("BuyModel")
net.Receive("BuyModel", function()
	local pl = net.ReadEntity()
	local model = net.ReadUInt(16)
	
	local ref = GetModel(model)
	if ref then
		if pl:GetMoney() > ref.Price then
			pl:SetModel(ref.Model)
			
			db:Query("UPDATE player set model="..model.." where steamid='"..pl:SteamID().."'")
		end
	end
end)

util.AddNetworkString("UnequipWeapon")
net.Receive("UnequipWeapon",function()
	local pl = net.ReadEntity()
		
	pl:UnequipWeapon()
end)

util.AddNetworkString("SendMatchInfo")
function P:SendMatchInfo(teammates, qPlayers)
	net.Start("SendMatchInfo")
		net.WriteUInt(BattleRoyale.GameType, 16)
		net.WriteTable(teammates)
		net.WriteTable(BattleRoyale.ActivePlayers)
	net.Send(self)
end

util.AddNetworkString("UseItemLimb")
net.Receive("UseItemLimb", function()
	local pl = net.ReadEntity()
	local containerEnt = net.ReadEntity()
	local slot = net.ReadUInt(16)
	local limb = net.ReadString()
	
	local ref = containerEnt.Inventory[slot]
	if ref then
		ref = GetItemByKey(containerEnt.Inventory[slot][1])
		if ref.SubType then
			local bUse = CONSUME_TYPES[ref.SubType].OnUse(pl, containerEnt.Inventory[slot][1], slot, limb)
			
			if bUse then
				pl:GiveItem(containerEnt.Inventory[slot][1], -1)
			end
			
		end
	end
end)

util.AddNetworkString("EndContainerAccess")
net.Receive("EndContainerAccess", function()
	local containerEnt = net.ReadEntity()
	
	containerEnt.bUsed = false
end)


local legs = {"Left Leg", "Right Leg"}
hook.Add("GetFallDamage", "HandleBrokenLegs", function(pl, speed)
	local bBreak = hook.Call("PlayerBreakLegs", GAMEMODE, pl)

	
	print("YEET")
	if !bBreak then
		for k,v in pairs(legs) do
			if !pl:LimbHasBuff(v, "Broken") then
				pl:SetLimbBuff(v, "Broken", true)
			end
			
			pl:Notify(NOTIFY_INJURY, "Ah, my legs!", "You've broken both of your legs. Use a splint on the limbs to heal them.", color_black, color_white, 6)
			break
		end
	end
end)

hook.Add("Think", "HandleBuffs", function()
	for k,v in pairs(player.GetAll()) do
		if v:Alive() && v.bPlaying then
			for bone, buffs in pairs(v.Limbs) do
				if string.find(bone, "Leg") then
					if buffs["Broken"] then
						if v:GetRunSpeed() != Config.BrokenLegSpeed then
							v:SetRunSpeed( Config.BrokenLegSpeed )
						end
						if v:GetWalkSpeed() != Config.BrokenLegSpeed then
							v:SetWalkSpeed( Config.BrokenLegSpeed )
						end
					end
				end
				
				if buffs["Bleeding"] then
					if v.LastTake then
						if v.LastTake <= CurTime() then
							local ent = nil
							if v.bInflictor then
								ent = v.bInflictor 
							end
						
							v:TakeDamage(#v:GetLimbs("Bleeding") * Config.BleedDamage, ent)
							
							local bIgnoreBleed = hook.Call("PlayerShouldBleedEffect", GAMEMODE, v)
							
							if !bIgnoreBleed then
								local blood = ents.Create("env_blood")
								blood:SetKeyValue("targetname", "carlbloodfx")
								blood:SetKeyValue("parentname", "prop_ragdoll")
								blood:SetKeyValue("spawnflags", 8)
								blood:SetKeyValue("spraydir", math.random(25) .. " " .. math.random(25) .. " " .. math.random(25))
								blood:SetKeyValue("amount", 5000.0)
								blood:SetCollisionGroup( COLLISION_GROUP_WORLD )
								blood:SetPos( v:GetPos() )
								blood:Spawn()
								blood:Fire("EmitBlood")
							end
							
							v.LastTake = CurTime() + Config.BleedRate
							
							local ch = math.random(1, 100)
							
							if ch <= 40 then
								v:EmitSound(table.Random(Config.HurtSoundList[v:GetGender()]), 100)
							end
						end
					else
						v.LastTake = CurTime() + Config.BleedRate
					end
				end
			end
			
			if v:GetHunger() > 0 then
			
				if v.LastHunger then
					if v.LastHunger < CurTime() then
						v:AddHunger(-0.3)
						v.LastHunger = CurTime() + 3
					end
				else
					v.LastHunger = CurTime() + 3
				end
				
			else
			
				local bIgnore = hook.Call("PlayerShouldStarve", GAMEMODE, v)
				if !bIgnore then
					v:Kill()
				end
				
			end
		end
	end
end)

hook.Add("PlayerSpawn", "ResetStats", function(pl)
	if Config.LimbSystem then
		for ind, limb in pairs(Limbs) do
			for k,v in pairs(pl.Limbs[ind]) do
				pl:RemoveLimbBuff(ind, k)
			end
		end
	end
	
	pl:SetModel("models/player/group01/male_01.mdl")
		
end)
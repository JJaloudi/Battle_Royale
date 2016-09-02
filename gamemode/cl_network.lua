_Limbs = {}
for k,v in pairs(Limbs) do
	_Limbs[k] = {}
end

net.Receive("SendLimbData", function()
	_Limbs[net.ReadString()] = net.ReadTable()
end)

Inventory = {}
HUDInventory = {}

net.Receive("AddItem", function()
	local slot = net.ReadUInt(16)
	
	Inventory[slot] = net.ReadTable()
	
	HUDInventory[slot] = {
		Active = true,
		NewItem = true
	}
end)

net.Receive("RemoveItem", function()
	local slot = net.ReadUInt(16)

	Inventory[slot] = {}
	
	PrintTable(Inventory)
	
	HUDInventory[slot] = {
		Active = true,
		RemoveItem = true
	}
end)

DevMode = false
net.Receive("ToggleDevMode", function()
	DevMode = net.ReadBool()
end)

net.Receive("RemovePlayer", function()
	InMatch = false
	Teammates = false
	
	if Panel then
		if Panel:IsValid() then
			Panel:Close()
		
			Panel = false
		end
	end
end)

Money = 0
net.Receive("SendMoney", function()
	Money = net.ReadUInt(16)
end)

Hunger = 0
net.Receive("SetHunger", function()
	Hunger = net.ReadUInt(16)
end)

activePerks = {}
net.Receive("SendActivePerk", function()
	local PerkID = net.ReadUInt(16)

	activePerks[GetPerk(PerkID).Slot] = PerkID
end)

unlockedPerks = {}
net.Receive("SendUnlockedPerkTable", function()
	unlockedPerks = net.ReadTable()
end)

net.Receive("SendUnlockedPerk", function()
	local perkID = net.ReadUInt(16)
	local amt = net.ReadUInt(16)
	
	if amt <= 0 then
		unlockedPerks[perkID] = nil
	else
		unlockedPerks[perkID] = amt
	end
end)

bPerks = {}
net.Receive("TogglePerk", function()
	local pID = net.ReadUInt(16)

	if bPerks[pID] then
		table.remove(bPerks, pID)
	end
	
	bPerks[pID] = {true, lifeTime = CurTime(), Alpha = 255, Count = table.Count(bPerks) + 1}
end)

unlockedApparel = {}
net.Receive("UnlockApparel", function()
	unlockedApparel[net.ReadUInt(16)] = true
end)

unlockedModels = {}
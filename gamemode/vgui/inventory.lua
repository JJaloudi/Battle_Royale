local INV = {}

function INV:Init()
	self:SetSize(170, 170/3)
	self:ShowCloseButton(false)
	self:Title("Inventory")
	
	self.Inventory = {}
end

function INV:HasItem(item)
	local bool = false
	
	for k,v in pairs(self.Inventory) do
		if v[1] == item then
			bool = true
			
			break
		end
	end
	
	return bool
end

function INV:GetOpenSlot()
	local slot = #self.Inventory + 1
	
	for k,v in pairs(self.Inventory) do
		if v == false then
			slot = k
			
			break
		end
	end

	return slot
end

function INV:GetOpenStack(item)
	local slot = self:GetOpenSlot()
	local isStack = false
	
	for k,v in pairs(self.Inventory) do
		if v[1] == item then
			slot = k
			isStack = true
			
			break
		end
	end
	
	return slot, isStack
end

function INV:SetInventory(tbl, ent)
	print("Set Inv")

	self.Inventory = tbl
	self.Ent = ent

	local slots = #tbl

	if self.List then
		self.List:Clear()
		
		print("Clear")
	else	
		self.Ent = ent
		
		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar(true)	
		self.List:SetSize(self:GetWide(), self:GetTall() - 20)
		self.List:SetPos(0, 20)
		self.List:SetSpacing(-1); self.List:SetPadding(0)
	end
	
	self:Receiver("Slot", function(rcv, pDropped, bDrop)
		if !bDrop then return end

		local drop = pDropped[1]
		if drop.Ent != rcv.Ent then
			if drop.Slot then
			
				net.Start("InventoryInteract")
					net.WriteEntity(rcv.Ent)
					net.WriteEntity(drop.Ent)
					net.WriteUInt(drop.Slot, 16)
				net.SendToServer()
				
			end
		end
	end)
	
	self.BList = {}
	for k,v in pairs(tbl) do
		if v[1] then
			self.BList[k] = vgui.Create("Item")
			
			local item = self.BList[k]
			item.Slot = k
			item.Ent = ent
			
			item:Droppable("Slot")
				
			item:SetItem(v[1], v[2])
			item:SetSize(self.List:GetWide(), 25)
			
			function item:DoRightClick()
				local menu = DermaMenu()
				menu:MakePopup()
				
				menu:SetPos(gui.MousePos())
				
				if EquippedItem != k || ent != LocalPlayer() then
					if GetItemByKey(v[1]).SubType || GetItemByKey(v[1]).Type == "Weapon" then
						menu:AddOption("Equip", function()
							net.Start("EquipItem")
								net.WriteEntity(LocalPlayer())
								net.WriteEntity(ent)
								net.WriteUInt(item.Slot, 16)
							net.SendToServer()
							
							EquippedItem  = item.Slot
						end)
					end
				else
					menu:AddOption("Unequip", function()
						net.Start("UnequipItem")
							net.WriteEntity(LocalPlayer())
						net.SendToServer()
							
						EquippedItem = false
					end)
				end
			end
			
			item.Panel = self
			
				
			self.List:AddItem(self.BList[k])
		end
	end
end

vgui.Register("Inventory", INV, "BRFrame")
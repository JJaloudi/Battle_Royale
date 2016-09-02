include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self:SetModel("models/items/item_item_crate.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SetItem(item, stack)
	if item then
	
		self.Stack = stack || 1
		self.Item = item
		
		local ref = GetItemByKey(item)
		
		if ref.Type == "Weapon" then
			self:SetModel(weapons.Get(ref.Entity).WorldModel)
		else
			self:SetModel(ref.Model)
		end
		
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		local phys = self:GetPhysicsObject()
		
		if phys and phys:IsValid() then
			phys:Wake()
		end
		
	else
		self:Remove()
	end
end
		
function ENT:Think()

end

function ENT:Use(pl, ent)
	local str = GetItemByKey(self.Item).Name
	
	if self.Stack > 1 then
		str = self.Stack .. "x " .. str
	end

	pl:Notify(NOTIFY_PICKEDUP, "Item picked up", str, Color(55, 155, 125, 255), color_white, 5)

	pl:GiveItem(self.Item, self.Stack)
	
	self:Remove()
end
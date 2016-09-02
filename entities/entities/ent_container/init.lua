include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self:SetModel("models/items/item_item_crate.mdl")
	self:SetUseType(CONTINUOUS_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self.OpenProgress = 0
	
	self.LastUse = CurTime()
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end


local types = {
	"blue",
	"green",
	"red"
}

local colors = {
	["blue"] = Color(55, 55, 155),
	["green"] = Color(55, 155, 55),
	["red"] = Color(155, 55, 55)
}

function ENT:SCType(type)
	type = string.lower(type)

	if type == "random" then
		self.Type = table.Random(types)
	elseif table.HasValue(types, type) then
		self.Type = type
	end
	
	if self.Type then
		local tbl = {}
	
		for k,v in pairs(Items:GetTable()) do
			if v.Rarity[self.Type] then
				tbl[#tbl + 1] = v.ID
			end
		end
		
		local chance = math.random(1, 100)
		for k,v in pairs(tbl) do
			if Items:GetTable()[k].Rarity[self.Type] >= chance then
				tbl[k] = nil
			end
		end
		
		self:SetColor(colors[self.Type])
		
		self.Item = table.Random(tbl)
	end
end	
		
util.AddNetworkString("EndProgress")
function ENT:Think()
	if !self.LastUse then return end
	
	if self.LastUse <= CurTime() then
		self.OpenProgress = 0
		self.LastUse = false
		
		if IsValid(self.Opener) then
			net.Start("EndProgress")
			net.Send(self.Opener)
		end
	end
end

util.AddNetworkString("SendProgress")
function ENT:Use(pl, ent)
	if !self.Item then return self:Remove(); end
	
	if self.OpenProgress + .35 < 100 && !self.Open then
		self.OpenProgress = self.OpenProgress + .35
		self.Opener = pl
		self.LastUse = CurTime() + 0.05
		
		net.Start("SendProgress")
			net.WriteEntity(self)
			net.WriteUInt(self.OpenProgress, 16)
		net.Send(pl)
	else
		if !self.Open then
			self.Open = true
			
			self:SetUseType(SIMPLE_USE)
			
			if IsValid(self.Opener) then
				net.Start("EndProgress")
				net.Send(self.Opener)
			end
			
			self.Opener = nil
		end
		
		self:SetColor(color_white)
		pl:SetSlot(pl.ActiveSlot || 1, self.Item)
		
		self.Item = false
		self:Remove();
	end
end
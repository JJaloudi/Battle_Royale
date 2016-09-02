AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	
end

function SWEP:Think()

end
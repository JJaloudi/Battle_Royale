SWEP.PrintName				= "Melee Base"
SWEP.Author					= "Jayzor"
SWEP.Purpose				= ""

SWEP.Slot					= 0
SWEP.SlotPos				= 4

SWEP.ViewModel				= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel				= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV			= 90

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.BlockVec 				= Vector(-8.04, -7.84, -2.01)
SWEP.BlockAng 				= Vector(9.145, 30.954, -49.951)

SWEP.HoldType = "melee"
SWEP.DrawAmmo				= false

SWEP.SwingSound = Sound("npc/vort/claw_swing1.wav")
SWEP.HitSound = Sound("physics/flesh/flesh_impact_bullet1.wav")
SWEP.SwingDelay = 1
SWEP.Range = 75
SWEP.Damage = 15 

function SWEP:Initialize()
	self:SetClip1(-1)
	self:SetClip2(-1)
	self:SetHoldType( self.HoldType )
	self.NextSwing = CurTime()
	
	self.NextSecondaryAttack = CurTime()
end	

function SWEP:PrimaryAttack()
	if self.Owner:IsSprinting() then return end

	if CurTime() >= self.NextSwing && !self:GetNetworkedBool("Blocking") then
	
		print("Swing")
	
		self:EmitSound(self.SwingSound)
			
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self:SendWeaponAnim( ACT_VM_HITCENTER )
				
		local tr = self.Owner:GetEyeTrace()
			
		if tr.HitPos:Distance(self.Owner:GetPos()) <= 80 then 
				
			local ent = tr.Entity
			self:EmitSound(self.HitSound)
			
			if SERVER then
				if ent:IsPlayer() then
					local bSend = true
					local dmgInfo = DamageInfo()
						
					if ent:GetAimVector():DotProduct(self.Owner:GetAimVector()) > 0  then
						
						local bMultiply, multiplier = hook.Call("OnPlayerBackstab", GAMEMODE, self.Owner, self, ent) or 2
						if bMultiply then
							dmgInfo:SetDamage(self.Damage * multiplier)
						end	
					else
						local ref = ent:GetActiveWeapon()
						if ref then
							if ref:GetNetworkedBool("Blocking", false) then
								bSend = false
								
								ent:SetVelocity(ent:GetForward() * - 100)
								self.Owner:SetVelocity(self.Owner:GetForward() * -400)
							end
						end
						dmgInfo:SetDamage(self.Damage)
					end
						
					dmgInfo:SetInflictor(self)
					dmgInfo:SetAttacker(self.Owner)
					dmgInfo:SetDamageType(DMG_SLASH)
									
					if bSend then			
						ent:TakeDamageInfo(dmgInfo)
					end
				end
			end
		end		
		
		self.NextSwing = CurTime() + self.SwingDelay
	end
end

function SWEP:SecondaryAttack()
	return
end

local BLOCKING_TIME = 0.25

function SWEP:SetBlocking(b)
	self:SetNetworkedBool("Blocking", b)
end

function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.BlockVec ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Blocking" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - BLOCKING_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - BLOCKING_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / BLOCKING_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.BlockVec
	
	if ( self.BlockAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.BlockAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.BlockAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.BlockAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

function SWEP:Think()

	if self.Owner:KeyDown(IN_ATTACK2) && !self.Owner:KeyDown(IN_ATTACK) && !self.Owner:IsSprinting() then	
		if ( !self.BlockVec ) then return end
		if self:GetNetworkedBool("Blocking") == true then return end
		if self.NextSwing > CurTime() then self:SetBlocking(false) return end
		
		self:SetBlocking( true )
	else
		if ( !self.BlockVec ) then return end
		if !self:GetNetworkedBool("Blocking") then return end

		self:SetBlocking( false )
	end
end
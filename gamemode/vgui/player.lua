local Player = {}

function Player:Init()
	PanelOpen = true
end

function Player:SetPlayer(pl)

	self.Player = pl
	
	self:SetModel(pl:GetModel())
	
	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
	self:SetLookAt((PrevMaxs + PrevMins) / 2)
	
end

function Player:Paint()
	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end

	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end

	self:LayoutEntity( self.Entity )
	self.Entity:DrawModel()

	self:DrawApparel()
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function Player:DrawApparel()
	if self:GetPlayer() then
		if Apparel[self.Player] then
			for k,v in pairs(Apparel[self.Player]) do
				if v.RenderModel then
					local parent = self.Entity
					
					local renderMdl = v.RenderModel
					local ref = GetApparel(v.ID)
					local appData = ref.ApparelData
					local pos, ang = parent:GetBonePosition(parent:LookupBone(APPAREL_TYPES[ref.Category]))

					local newPos = pos + (renderMdl:GetForward() * appData.vecOffset.y) + (renderMdl:GetUp() * appData.vecOffset.z) + (renderMdl:GetRight() * appData.vecOffset.x)
					
					print(pos)
					
					local rot = appData.angOffset
					ang:RotateAroundAxis(ang:Right(), 	rot.x)
					ang:RotateAroundAxis(ang:Up(), 		rot.y)
					ang:RotateAroundAxis(ang:Forward(), rot.z)

					renderMdl:SetPos(newPos)
					renderMdl:SetAngles(ang)
										
					if appData.Col then
						renderMdl:SetColor(appData.Col)
					end
										
					if appData.Scale then
						renderMdl:SetModelScale(appData.Scale, 0)
					end
										
					renderMdl:DrawModel()
				else
					refreshApparel(self.Player)
				end
			end
		end
	end
end

function Player:GetPlayer()
	return self.Player or false
end	

vgui.Register("PlayerPanel", Player, "DModelPanel")
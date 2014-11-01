ENT.Type = "brush"

function ENT:Initialize()
	-- ParticleEffectAttach("portal_cleanser",PATTACH_ABSORIGIN,self,1)
	
	self:SetTrigger(true)
end

function ENT:Touch( ent )
end

function ENT:StartTouch( ent )
	if ent:IsPlayer() and ent:Alive() then
		plyweap = ent:GetActiveWeapon()
		if IsValid( plyweap ) and plyweap:GetClass() == "weapon_portalgun" and plyweap.CleanPortals then
			plyweap:CleanPortals()
		end
	elseif ent and ent:IsValid() then
		if ent:GetClass()=="projectile_portal_ball" then
			//portal ball projectile.
			local ang = ent:GetAngles()
			ang:RotateAroundAxis(ent:GetForward(),90)
			ang.y = self:GetAngles().y+90
			ParticleEffect("portal_"..ent:GetNWInt("Kind",TYPE_BLUE).."_cleanser",ent:GetPos(),ang)
			ent:Remove()
			
		else 
			if ent:GetName() != "dissolveme" then
			
				local vel = ent:GetVelocity()
			
				local fakebox = ents.Create( "prop_physics" )
				fakebox:SetModel(ent:GetModel())
				fakebox:SetPos(ent:GetPos())
				fakebox:SetAngles(ent:GetAngles())
				fakebox:Spawn()
				fakebox:Activate()
				fakebox:SetSkin(ent:GetSkin())
				fakebox:SetName("dissolveme")
				local phys = fakebox:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableGravity(false)
					phys:Wake()
					phys:SetVelocity(vel/10)
				end
				
				ent:Remove()
				
				local dissolver = ents.Create( "env_entity_dissolver" )
				dissolver:SetKeyValue( "dissolvetype", 0 )
				dissolver:SetKeyValue( "magnitude", 0 )
				dissolver:Spawn()
				dissolver:Activate()
				dissolver:Fire("Dissolve","dissolveme",0)
				dissolver:Fire("kill","",0.1)
			end
			
			
		end
	end
end

function ENT:EndTouch( ent )
end

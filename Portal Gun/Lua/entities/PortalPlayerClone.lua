
if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Portal" );
	self:NetworkVar( "Entity", 1, "Ent" );

end

function ENT:Initialize(  )
	if CLIENT then
		self:SetRenderClipPlaneEnabled(true)
	end
	
	self:AddEffects( bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES) )
	
end

-- function ENT:BuildBonePositions(numbones,numphys)
	-- for i=0, numbones-1 do
		-- self:SetBonePosition(i,self.ent:GetBonePosition(i))
	-- end
-- end

function ENT:Think( )
	
	self.ent = self:GetEnt()
	self.Portal = self:GetPortal()
	
	if CLIENT then return end
	
	local portal = self.Portal
	
	if not self.ent.InPortal then
		self:Remove()
		return
	end
	if not IsValid(self.ent.InPortal) then
		self:Remove()
		return
	end
	if self.ent.InPortal != portal then 
		self:Remove()
		return
	end
	
	//Adjust Pos
	local origin = portal:GetPortalPosOffsets(portal:GetOther(),self.ent)
	local angs = portal:GetPortalAngleOffsets(portal:GetOther(),self.ent)
	origin.z = origin.z - 64
	angs.p = 0
	angs.r = 0
	
	self:SetPos(origin)
	self:SetAngles(angs)
	
end

function ENT:Draw()
	if not self:IsValid() then return false end
	if not self.Portal then return false end
	if not self.Portal:IsValid() and self.Portal:GetOther():IsValid() then return false end
	
	if !RENDERING_PORTAL then
	
		local portal = self.Portal
		
		-- local origin = portal:GetPortalPosOffsets(portal:GetOther(),self.ent)
		-- local angs = portal:GetPortalAngleOffsets(portal:GetOther(),self.ent)
		-- origin.z = origin.z - 64
		-- angs.p = 0
		-- -- angs.y = 0
		-- angs.r = 0
		
		-- self:SetPos(origin)
		-- self:SetAngles(angs)
		
		if self:GetBoneCount() != self.ent:GetBoneCount() then
			return false
		end
		
		self:SetupBones()
		
		//DEBUG:
		-- for i=0, self:GetBoneCount() - 1 do
			-- print("Bone: "..i.." is '"..self:GetBoneName(i).."'. The following is what happens when you move it:")
			-- self:SetBonePosition(i,Vector(100,100,100),Angle(0,0,0))
			-- print("")
		-- end
		
		for i=0,self:GetBoneCount()-1 do
			if self:GetBoneName(i) == "__INVALIDBONE__" then continue end
			
			-- local i = self:LookupBone(v)
			
			local bpos,bang = self.ent:GetBonePosition(i)
			
			local normal = portal:GetForward()
			local forward = bang:Forward()
			local up = bang:Up()
			
			// reflect forward
			local dot = forward:DotProduct( normal )
			forward = forward + ( -2 * dot ) * normal
			
			// reflect up		
			local dot = up:DotProduct( normal )
			up = up + ( -2 * dot ) * normal
			
			// convert to angles
			bang = math.VectorAngles( forward, up );
			
			local LocalAngles = portal:WorldToLocalAngles( bang );
			
			// repair
			LocalAngles.y = -LocalAngles.y;
			LocalAngles.r = -LocalAngles.r;
			
			bang = portal:GetOther():LocalToWorldAngles( LocalAngles )
			
			bpos = portal:WorldToLocal( bpos )
			bpos.x = -bpos.x;
			bpos.y = -bpos.y;
			
			bpos = portal:GetOther():LocalToWorld( bpos )
			self:SetBonePosition(i,bpos,bang)
		end
		
		local normal = portal:GetForward()
		local distance = normal:Dot( portal:GetRenderOrigin() )
		self:SetRenderClipPlane(normal,distance)
		
		self:DrawModel()
		
	end
end

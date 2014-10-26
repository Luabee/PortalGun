TYPE_BLUE = 1
TYPE_ORANGE = 2

ENT.Type = "anim";

ENT.PrintName = "Portal";
ENT.Author = "Fernando5567";
ENT.Contact = "";
ENT.Purpose = "un portal?";
ENT.Instructions = "Spawn portals. Look through portals.";

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:SetType( int )
	self:SetNWInt("Potal:PortalType",int)
	self.PortalType = int
	
	--[[umsg.Start("Portal:SetPortalType" )
	umsg.Entity( self )
	umsg.Long( int )
	umsg.End()]]
	
	if self.Activated == true then
		if SERVER then
			self:SetUpEffects(int)
		end
	end
end

function ENT:IsLinked()
	return self:GetNWBool("Potal:Linked", false)
end

function ENT:GetOther()
	return self:GetNWEntity("Potal:Other",NULL)
end

function ENT:SetUpEffects(int)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if int == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_edge")
	elseif int == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_edge")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	
	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(self:GetPos())
	ent:SetAngles(ang)
	if int == TYPE_BLUE then
		ent:SetKeyValue( "effect_name", "portal_1_vacuum")
	elseif int == TYPE_ORANGE then
		ent:SetKeyValue( "effect_name", "portal_2_vacuum")
	end
	ent:SetKeyValue( "start_active", "1")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
end


--checks if there is a floor in front of the portal or if a specific position is on top of a floor.
-- function ENT:FloorInFront(pos)
	-- if not pos then
		-- pos = self:GetPos() + self:GetForward()*40
		-- for i=-10,10,1 do
			-- local contents = util.PointContents(pos + self:GetUp()*(-56-i))
			-- -- debugoverlay.Cross(pos + self:GetUp()*(-56-i),5,5,Color(0,255,0),true)
			-- if contents == CONTENTS_SOLID then
				-- -- print("Found a floor. "..contents)
				-- return true
			-- end
		-- end
	-- else
		-- pos.z = pos.z-2
		-- local contents = util.PointContents(pos)
		-- if contents == CONTENTS_SOLID then
			-- -- print("Found a floor. "..contents)
			-- return true
		-- end
	-- end
	
	-- return false
	-- -- print("No Floor Found. "..contents)
-- end

function ENT:IsHorizontal()
	return self:GetAngles().p == 0
end
TYPE_BLUE = 1
TYPE_ORANGE = 2

ENT.Type = "anim";

ENT.PrintName = "Portal";
ENT.Author = "Fernando5567";
ENT.Contact = "";
ENT.Purpose = "un portal?";
ENT.Instructions = "Spawn portals. Look through portals.";

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

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
	
	local pos = self:GetPos()
	if self:OnFloor() then pos.z = pos.z - 20 end

	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(pos)
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
	self.EdgeEffect = ent
	
	local ent = ents.Create( "info_particle_system" )
	ent:SetPos(pos)
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
	self.VacuumEffect = ent
end


--Returns best point to offset the player to prevent stucks.
function ENT:GetFloorOffset(pos1)
	local offset = Vector(0,0,0)
	local pos = Vector(0,0,0)
	pos:Set(pos1) --stupid pointers...
	
	pos.z = pos.z-64
	pos = self:WorldToLocal(pos)
	pos.x = pos.x+30
	for i=0,54 do
		local openspace = util.IsInWorld(self:LocalToWorld(pos+Vector(0,0,i)))
		if openspace then
			-- print("Found no floor at -"..i)
			-- umsg.Start("DebugOverlay_Cross")
				-- umsg.Vector(self:LocalToWorld(pos+offset))
				-- umsg.Bool(true)
			-- umsg.End()
			offset.z = i
			break
		else
			-- print("Found a floor at -"..i)
			-- umsg.Start("DebugOverlay_Cross")
				-- umsg.Vector(self:LocalToWorld(pos+offset))
				-- umsg.Bool(false)
			-- umsg.End()
		end
	end
	return offset
end

function ENT:IsHorizontal()
	local p = math.Round(self:GetAngles().p)
	return p == 0
end
function ENT:OnFloor()
	local p = math.Round(self:GetAngles().p)
	return p == 270 or p == -90
end
function ENT:OnRoof()
	local p = math.Round(self:GetAngles().p)
	return p >= 90 and p <= 180
end

local function PlayerPickup( ply, ent )	
	if ent:GetClass() == "prop_portal" or ent:GetModel() == "models/blackops/portal_sides.mdl" then
		print("No Pickup.")
		return false
	end
end
hook.Add( "PhysgunPickup", "NoPickupPortals", PlayerPickup )
hook.Add( "GravGunPickupAllowed", "NoPickupPortals", PlayerPickup )
hook.Add( "GravGunPunt", "NoPickupPortals", PlayerPickup )
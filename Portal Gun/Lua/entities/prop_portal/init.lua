AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "cl_init.lua" );
include( "shared.lua" );

ENT.Linked = nil
ENT.PortalType = TYPE_BLUE
ENT.Activated = false
ENT.KeyValues = {}

sound.Add({
	name = "portal_loop", 
	channel = CHAN_STATIC, 
	volume = .8, 
	level = 45, 
	pitch = {95, 110}, 
	sound = "weapons/portalgun/portal_ambient_loop1.wav"
})


function ENT:SpawnFunction( ply, tr ) --unused.
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "prop_portal" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

--I think this is from sassilization..
local function IsBehind( posA, posB, normal )

	local Vec1 = ( posB - posA ):GetNormalized()

	return ( normal:Dot( Vec1 ) < 0 )

end

function ENT:Initialize( )
	self:SetModel( "models/blackops/portal.mdl" )
	-- self:SetModel( "models/portals/portal1_renderfix.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMoveType( MOVETYPE_NONE )
	self:PhysWake()
	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetNWBool("Potal:Activated",false)
	self:SetNWBool("Potal:Linked",false)
	self:SetNWInt("Potal:PortalType",self.PortalType)
	
	self.Sides = ents.Create( "prop_physics" )
	self.Sides:SetModel( "models/blackops/portal_sides.mdl" )
	self.Sides:SetPos( self:GetPos() + self:GetForward()*-0.1 )
	self.Sides:SetAngles( self:GetAngles() )
	self.Sides:Spawn()
	self.Sides:Activate()
	self.Sides:SetRenderMode( RENDERMODE_NONE )
	self.Sides:PhysicsInit(SOLID_VPHYSICS)
	self.Sides:SetSolid(SOLID_VPHYSICS)
	self.Sides:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	--self.Sides:SetMoveType( MOVETYPE_NONE ) --causes some weird shit to happen..
	self.Sides:DrawShadow(false)
	
	local phys = self.Sides:GetPhysicsObject()
	
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
	
	self:DeleteOnRemove(self.Sides)
	
	if self:OnFloor() then
		self:SetPos( self:GetPos() + Vector(0,0,20) )
	end
	
	self.portal_loop = CreateSound(self,"portal_loop")
	self.portal_loop:Play()
	
	for k,v in pairs(ents.FindInSphere(self:GetPos(),100))do
		if v == self then continue end
		if v == self.Sides then continue end
		if v:GetClass() != "prop_physics" and v:GetClass() != "npc_turret_Floor" then continue end
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			-- print(v)
			phys:Wake()
			phys:ApplyForceCenter(Vector(0,0,10))
		end
	end
end


function ENT:BootPlayer()
	--Kick players out of this portal.
	for k,p in pairs(player.GetAll()) do 
		if p.InPortal and (p.InPortal:EntIndex() == self:EntIndex()) then
		
			p:SetPos(self:GetPos() + self:GetForward()*25 + self:GetUp()*-40)
			
			p.InPortal = false
			p:SetMoveType(MOVETYPE_WALK)
			umsg.Start( "Portal:ObjectLeftPortal" )
			umsg.Entity( p )
			umsg.End()
		end
	end
end

function ENT:CleanMeUp()
	self.portal_loop:Stop("portal_loop")
	self:BootPlayer()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)
	
	PrecacheParticleSystem("portal_2_close_a")
	PrecacheParticleSystem("portal_1_close_a")
	PrecacheParticleSystem("portal_2_close")
	PrecacheParticleSystem("portal_1_close")
	
	
	local pos = self:GetPos()
	if self:OnFloor() then
		pos = pos-Vector(0,0,20)
	end
	
	if self.PortalType == TYPE_BLUE and GetConVarNumber("portal_beta_borders") >= 1 then
		ParticleEffect("portal_1_close_",pos,ang,nil)
		elseif self.PortalType == TYPE_BLUE then
		ParticleEffect("portal_1_close",pos,ang,nil)
		elseif self.PortalType == TYPE_ORANGE and GetConVarNumber("portal_beta_borders") >= 1 then
		ParticleEffect("portal_2_close_",pos,ang,nil)
		elseif self.PortalType == TYPE_ORANGE then
		ParticleEffect("portal_2_close",pos,ang,nil)
	end
	
	self:EmitSound("weapons/portalgun/portal_close"..math.random(1,2)..".wav",150)
	-- timer.Simple(5,function()
		-- if ent and ent:IsValid() then
			-- ent:Remove()
		-- end
	-- end)
	self:Remove()
end

function ENT:MoveToNewPos(pos,newang) --Called by the swep, used if a player already has a portal out.
	
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)
	
	self:SetAngles(newang)
	
	local effectpos = self:GetPos()
	if self:OnFloor() then
		effectpos = effectpos-Vector(0,0,20)
	end
	self.VacuumEffect:SetPos(effectpos)
	self.EdgeEffect:SetPos(effectpos)
	
	if self.PortalType == TYPE_BLUE and GetConVarNumber("portal_beta_borders") >= 1 then
	ParticleEffect("portal_1_close_",effectpos,ang,nil)
	elseif self.PortalType == TYPE_BLUE then
		ParticleEffect("portal_1_close",effectpos,ang,nil)
	elseif GetConVarNumber("portal_beta_borders") >= 1 then
		ParticleEffect("portal_2_close_",pos,ang,nil)
	else
		ParticleEffect("portal_2_close",effectpos,ang,nil)
	end
	
	self:BootPlayer()
	if IsValid(self:GetOther()) then
		self:GetOther():BootPlayer()
	end
	
	self:SetPos( pos )
	
	if IsValid( self.Sides ) then
		self.Sides:SetPos(pos)
		self.Sides:SetAngles(newang)
	end
	
	if self:OnFloor() then
		pos.z = pos.z + 20
		self:SetPos( pos )
	end
	
	umsg.Start("Portal:Moved" )
	umsg.Entity( self )
	umsg.Vector(pos)
	umsg.Angle(newang)
	umsg.End()
	
	
end

function ENT:GetOpposite() --Don't think this is being used..? Gets the portal type that it would need to be linked too
	if self.PortalType == TYPE_BLUE then
		return TYPE_ORANGE
	elseif self.PortalType == TYPE_ORANGE then
		return TYPE_BLUE
	end
end

function ENT:SuccessEffect()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)
	
	local pos = self:GetPos()
	if self:OnFloor() then
		pos = pos-Vector(0,0,20)
	end
	
	if GetConVarNumber("portal_beta_borders") >= 1 then
	ParticleEffect("portal_"..self.PortalType.."_success_",pos,ang,self)
	else
	ParticleEffect("portal_"..self.PortalType.."_success",pos,ang,self)
	end
	local int = math.random(1,2)
	if int==2 then int = 3 end
	self:EmitSound("weapons/portalgun/portal_open"..int..".wav",100 )
	
end


function ENT:LinkPortals( ent )
	self:SetNWBool("Potal:Linked",true)
	self:SetNWEntity("Potal:Other",ent)
	ent:SetNWBool("Potal:Linked",true)
	ent:SetNWEntity("Potal:Other",self)
end

function ENT:OnTakeDamage(dmginfo)
end

--Mahalis code
function ENT:CanPort(ent)
	local c = ent:GetClass()
	if ent:IsPlayer() or (ent != nil && ent:IsValid() && !ent.isClone && ent:GetPhysicsObject() && c != "noportal_pillar" && c != "prop_dynamic" && c != "rpg_missile" && string.sub(c,1,5) != "func_" && string.sub(c,1,9) != "prop_door") then
		return true
	else
		return false
	end
end

function ENT:MakeClone(ent)

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end	
	--if ent:GetClass() != "prop_physics" then return end
	
	local portal = self:GetNWEntity("Potal:Other")

	
	if ent.clone != nil then return end
	local clone = ents.Create("prop_physics")
	clone:SetSolid(SOLID_NONE)
	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
	clone.isClone = true
	clone.daddyEnt = ent
	clone:SetModel(ent:GetModel())
	clone:Spawn()
	clone:SetSkin(ent:GetSkin())
	clone:SetMaterial(ent:GetMaterial())
	ent:DeleteOnRemove(clone)
	local phy = clone:GetPhysicsObject()
	if phy:IsValid() then
		phy:EnableCollisions(false)
		phy:EnableGravity(false)
		phy:EnableDrag(false)
	end
	ent.clone = clone
	
	umsg.Start("Portal:ObjectInPortal" )
		umsg.Entity( portal )
		umsg.Entity( clone )
	umsg.End()
	clone.InPortal = portal
end


function ENT:SyncClone(ent)
	local clone = ent.clone
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end	
	if clone == nil then return end
	
	local portal = self:GetNWEntity("Potal:Other")

	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
end

function ENT:StartTouch(ent)
	--if ent:IsPlayer() then return end
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then return end
	
	if ent:GetClass() == "projectile_portal_ball" then ent:Remove() return end
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	if ent.InPortal then return end
	
	
	if self:CanPort(ent) and !ent:IsPlayer() then
		if ent:GetModel() != "models/blackops/portal_sides.mdl" and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" or ent:GetClass() == "npc_portal_turret_floor" or ent:GetClass() == "npc_security_camera" ) then
			if ent:GetClass() == "npc_security_camera" then
				ent:SetModel("models/props/Security_Camera_prop_reference.mdl")
			end
			local phys = ent:GetPhysicsObject()
			ent:SetGroundEntity( NULL )
			if phys:IsValid() then
				phys:EnableMotion( true )
				phys:Wake()
			end
		end
		umsg.Start( "Portal:ObjectInPortal" )
		umsg.Entity( self )
		umsg.Entity( ent )
		umsg.End()
		ent.InPortal = self
		constraint.AdvBallsocket( ent, game.GetWorld(), 0, 0, Vector(0,0,0), Vector(0,0,0), 0, 0,  -180, -180, -180, 180, 180, 180,  0, 0, 0, 1, 1 )
		self:MakeClone(ent)
	elseif ent:IsPlayer() then
		
		if not self:PlayerWithinBounds(ent) then return end
		
		ent.JustEntered = true
		self:PlayerEnterPortal(ent)
	end
end

function ENT:Touch( ent )
	if ent.InPortal != self then self:StartTouch(ent) end
	--if ent:IsPlayer() then return end
	if !self:CanPort(ent) then return end
	
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	local portal = self:GetNWEntity("Potal:Other")
	
	if portal and portal:IsValid() then
		
		if ent:IsPlayer() then
			-- if ent.JustPorted then ent.InPortal = self return end
			--If the player isn't actually in the portal
			if not ent.InPortal then
				if not self:PlayerWithinBounds(ent) then return end
				ent.JustEntered = true
				self:PlayerEnterPortal(ent)
				
			else
				ent:SetGroundEntity( self )
				local eyepos = ent:EyePos()
				if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then --if the players eyes are behind the portal, we do the end touch shit we need anyway
					self:DoPort(ent) --end the touch
					ent.AlreadyPorted = true
				end
			end
		else
			self:SyncClone(ent)
			ent:SetGroundEntity( NULL )
		end
		
	end
end

function ENT:PlayerEnterPortal(ent)
	umsg.Start( "Portal:ObjectInPortal" )
		umsg.Entity( self )
		umsg.Entity( ent )
	umsg.End()
	ent.InPortal = self
	
	ent:GetPhysicsObject():EnableDrag(false)
	
	local vel = ent:GetVelocity()
	ent:SetMoveType(MOVETYPE_NOCLIP)
	ent:SetGroundEntity( self )
	-- print("noclipping")

	if ent.JustEntered then
		ent:EmitSound("weapons/portalgun/portal_enter".. self.PortalType ..".wav",80,100 + (30 * (ent:GetVelocity():Length() - 100)/1000))
		ent.JustEntered = false
	end
end

function ENT:EndTouch(ent)
	if ent.AlreadyPorted then
		ent.AlreadyPorted = false
	else
		self:DoPort(ent)
	end
end

function ENT:DoPort(ent) --Shared so we can predict it.

	if !self:CanPort(ent) then return end
	if !ent or !ent:IsValid() then return end
	if SERVER then
		constraint.RemoveConstraints(ent, "AdvBallsocket")
	end
		
	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	
	if SERVER then
		umsg.Start( "Portal:ObjectLeftPortal" )
		umsg.Entity( ent )
		umsg.End()
	end

	local portal = self:GetNWEntity("Potal:Other")
	
	--Mahalis code
	local vel = ent:GetVelocity()
	if !vel then return end
	-- vel = vel - 2*vel:Dot(self:GetAngles():Up())*self:GetAngles():Up()
	local nuVel = self:TransformOffset(vel,self:GetAngles(),portal:GetAngles()) * -1
	
	local phys = ent:GetPhysicsObject()
	
	if portal and portal:IsValid() and phys:IsValid() and ent.clone and ent.clone:IsValid() and !ent:IsPlayer() then
		if !IsBehind( ent:GetPos(), self:GetPos(), self:GetForward() ) then
			ent:SetPos(ent.clone:GetPos())
			ent:SetAngles(ent.clone:GetAngles())
			phys:SetVelocity(nuVel)
		end
		ent.InPortal = nil
		
		ent.clone:Remove()
		ent.clone = nil
	elseif ent:IsPlayer() then
		local eyepos = ent:EyePos()
		
		if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then
			local newPos = self:GetPortalPosOffsets(portal,ent)
			
			ent:SetHeadPos(newPos)
			
			if portal:OnFloor() and self:OnFloor() then --pop players out of floor portals.
				if nuVel:Length() < 340 then
					nuVel = portal:GetForward() * 340
				end
			elseif portal:OnFloor() then
				if nuVel:Length() < 350 then
					nuVel = portal:GetForward() * 350
				end
			elseif (not portal:IsHorizontal()) and (not portal:OnRoof()) then --pop harder for diagonals.
				if nuVel:Length() < 450 then
					nuVel = portal:GetForward() * 450
				end
			end
			
			-- print("Old Velocity:", ent:GetVelocity())
			-- print("New Velocity:", nuVel)
			ent:SetLocalVelocity(nuVel)
			
			--local newang = math.VectorAngles(ent:GetForward(), ent:GetUp()) + Angle(0,180,0) + (portal:GetAngles() - self:GetAngles())
			local newang = self:GetPortalAngleOffsets(portal,ent)
			ent:SetEyeAngles(newang)
			
	
			ent.JustEntered = false
			ent.JustPorted = true
			portal:PlayerEnterPortal(ent)
		elseif ent.InPortal == self then
			ent.InPortal = nil
			ent:SetMoveType(MOVETYPE_WALK)
			if SERVER then
				ent:EmitSound("weapons/portalgun/portal_exit".. self.PortalType ..".wav",80,100 + (30 * (nuVel:Length() - 100)/1000))
			end
			--print("Walking")
		end
	end
end

local function BulletHook(ent,bullet)
	if ent.FiredBullet then return end
	--Test if the bullet hits the portal.
	for k,inport in pairs(ents.FindByClass("prop_portal")) do --fix fake portal positions.
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()-Vector(0,0,20))
		end
	end
	
	for i=1, bullet.Num do
		local tr = util.QuickTrace(bullet.Src, bullet.Dir*10000, ent)
		
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_portal" then
			local inport = tr.Entity
			
			if inport:GetNWBool("Potal:Linked",false) == false or inport:GetNWBool("Potal:Activated",false) == false then return end
			
			local outport = inport:GetNWEntity("Potal:Other")
			if !IsValid(outport) then return end
			
			--Create our new bullet and get the hit pos of the inportal.
			local newbullet = table.Copy(bullet)
			
			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() + Vector(0,0,20))
			end
			
			local offset = inport:WorldToLocal(tr.HitPos + bullet.Dir*20)
			
			offset.x = -offset.x;
			offset.y = -offset.y;
			
			--Correct bullet angles.
			local ang = bullet.Dir
			ang = inport:TransformOffset(ang,inport:GetAngles(),outport:GetAngles()) * -1
			newbullet.Dir = ang
			
			--Transfer to new portal.
			newbullet.Src = outport:LocalToWorld( offset ) + ang*10
			
			
			-- umsg.Start("DebugOverlay_LineTrace")
				-- umsg.Vector(bullet.Src)
				-- umsg.Vector(tr.HitPos)
				-- umsg.Bool(true)
			-- umsg.End()
			-- local p1 = util.QuickTrace(newbullet.Src,ang*10000,{outport,inport})
			-- umsg.Start("DebugOverlay_LineTrace")
				-- umsg.Vector(newbullet.Src)
				-- umsg.Vector(p1.HitPos)
				-- umsg.Bool(false)
			-- umsg.End()
			
			newbullet.Attacker = ent
			outport.FiredBullet = true --prevent infinite loop.
			outport:FireBullets(newbullet)		
			outport.FiredBullet = false
			
			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() - Vector(0,0,20))
			end
			
		end
	end
	for k,inport in pairs(ents.FindByClass("prop_portal")) do
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()+Vector(0,0,20))
		end
	end
end
hook.Add("EntityFireBullets", "BulletPorting", BulletHook)

function ENT:SetActivatedState(bool)
	self.Activated = bool
	self:SetNWBool("Potal:Activated",bool)
	
	local other = self:FindOpenPair()
	if other and other:IsValid() then
		self:LinkPortals(other)
	end
end

function ENT:FindOpenPair() --This is for singeplayer, it finds a portal that is of the same type.
	local portals = ents.FindByClass( "prop_portal" );
	local mycolor = self:GetNWInt("Potal:PortalType",nil)
	local othercolor
	for k, v in pairs( portals ) do
		othercolor = v:GetNWInt("Potal:PortalType",nil)
		if v:GetNWBool("Potal:Activated",false) == true and v != self and othercolor and mycolor and othercolor != mycolor then
			return v
		end
	end
	return nil
end

function ENT:AcceptInput(name) --Map inputs (Seems to work..)
 
	if (name == "Fizzle") then
		self.Activated = false
		self:SetNWBool("Potal:Activated",false)
		self:CleanMeUp()
	end
	
	if (name == "SetActivatedState") then
		self:SetActivatedState(true)
	end
 
end

function ENT:KeyValue( key, value ) --Map keyvalues

	self.KeyValues[key] = value
	
	if key == "LinkageGroupID" then --I don't think this does jack shit, but it was on the valve wiki..
		self:SetNWInt("Potal:LinkageGroupID",value)
	end
	
	if key == "Activated" then --Set if it should start activated or not..
		self.Activated = tobool(value)
		self:SetNWBool("Potal:Activated",tobool(value))
	end
	
	if key == "PortalTwo" then --Sets the portal type
		self:SetType( value+1 )
	end
	
end

--Jintos code..
function math.VectorAngles( forward, up )

	local angles = Angle( 0, 0, 0 );

	local left = up:Cross( forward );
	left:Normalize();
	
	local xydist = math.sqrt( forward.x * forward.x + forward.y * forward.y );
	
	// enough here to get angles?
	if( xydist > 0.001 ) then
	
		angles.y = math.deg( math.atan2( forward.y, forward.x ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = math.deg( math.atan2( left.z, ( left.y * forward.x ) - ( left.x * forward.y ) ) );

	else
	
		angles.y = math.deg( math.atan2( -left.x, left.y ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = 0;
	
	end

	return angles;
	
end

hook.Add("SetupPlayerVisibility", "Add portalPVS", function(ply,ve)
	for k,self in pairs(ents.FindByClass("prop_portal"))do
		if not IsValid(self) then continue end
		local other = self:GetNWEntity("Potal:Other")
		if (not other) or (not IsValid(other)) then continue end
		local origin = ply:EyePos()
		local angles = ply:EyeAngles()
		
		local normal = self:GetForward()
		local distance = normal:Dot( self:GetPos() )

		// quick access
		local forward = angles:Forward()
		local up = angles:Up()

		// reflect origin
		local dot = origin:DotProduct( normal ) - distance
		origin = origin + ( -2 * dot ) * normal

		// reflect forward
		local dot = forward:DotProduct( normal )
		forward = forward + ( -2 * dot ) * normal

		// reflect up          
		local dot = up:DotProduct( normal )
		up = up + ( -2 * dot ) * normal
		
		local ViewOrigin = self:WorldToLocal( origin )
	   
		// repair
		ViewOrigin.y = -ViewOrigin.y
		
		ViewOrigin = other:LocalToWorld( ViewOrigin )
		-- if self:GetNWInt("Potal:PortalType") == TYPE_ORANGE then
			-- umsg.Start("DebugOverlay_Cross")
				-- umsg.Vector(ViewOrigin)
				-- umsg.Bool(true)
			-- umsg.End()
		-- end
		-- AddOriginToPVS(ViewOrigin)
		
		AddOriginToPVS(self:GetPos()+self:GetForward()*20)
	end
end)

concommand.Add("CreateParticles", function(p,c,a)
	local name = a[1]
	local ang = p:GetAngles()
	ang:RotateAroundAxis(p:GetRight(),90)
	ang:RotateAroundAxis(p:GetForward(),90)
	ParticleEffect(name,p:EyePos()+p:GetForward()*100,ang, (a[2] == 1 and self or nil))
end)
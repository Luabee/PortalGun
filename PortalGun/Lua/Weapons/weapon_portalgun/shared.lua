

TYPE_BLUE = 1
TYPE_ORANGE = 2

PORTAL_HEIGHT = 110
PORTAL_WIDTH = 68

local limitPickups = CreateConVar("portal_limitcarry", 0, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE,FCVAR_REPLICATED}, "Whether to limit the Portalgun to pickup certain props from the Portal game.")

local ballSpeed, useNoBalls
if ( SERVER ) then
        AddCSLuaFile( "shared.lua" )
        SWEP.Weight                     = 4
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
		ballSpeed = CreateConVar("portal_projectile_speed", 3500, {FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE}, "The speed that portal projectiles travel.")
		--useNoBalls = CreateConVar("portal_instant", 0, {FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE}, "<0|1> Make portals create instantly and don't use the projectile.")
end

if ( CLIENT ) then
        SWEP.WepSelectIcon = surface.GetTextureID("weapons/portalgun_inventory")
        SWEP.PrintName          = "Portal Gun"
        SWEP.Author             = "Fernando5567"
        SWEP.Contact            = "Fergp1998@hotmail.com"
        SWEP.Purpose            = "Shoot Linked Portals"
        SWEP.ViewModelFOV       = "60"
        SWEP.Instructions       = ""
        SWEP.Slot = 0
        SWEP.Slotpos = 0
        SWEP.CSMuzzleFlashes    = false
		
		game.AddParticles("particles/wip_muzzle.pcf")
		PrecacheParticleSystem("portalgun_muzzleflash_FP")
       
        -- function SWEP:DrawWorldModel()
                -- if ( RENDERING_PORTAL or RENDERING_MIRROR or GetViewEntity() != LocalPlayer() ) then
                        -- self.Weapon:DrawModel()
                -- end
        -- end
end

SWEP.HoldType                   = "crossbow"

SWEP.EnableIdle				= false	

SWEP.BobScale = 0
SWEP.SwayScale = 0

SWEP.HoldenProp			= NULL
SWEP.NextAllowedPickup	= 0
SWEP.UseReleased		= true
SWEP.PickupSound		= nil
local pickable 			= {
	'models/props/metal_box.mdl',
	'models/props/futbol.mdl',
	'models/props/sphere.mdl',
	'models/props/metal_box_fx_fizzler.mdl',
	'models/props/turret_01.mdl',
	'models/props/reflection_cube.mdl',
	'npc_turret_floor',
	'npc_manhack',
	'models/props/radio_reference.mdl',
	'models/props/security_camera.mdl',
	'models/props/security_camera_prop_reference.mdl',
	'models/props_bts/bts_chair.mdl',
	'models/props_bts/bts_clipboard.mdl',
	'models/props_underground/underground_weighted_cube.mdl',
	'models/XQM/panel360.mdl',
	'models/props_bts/glados_ball_reference.mdl'
}

local BobTime = 0
local BobTimeLast = CurTime()

local SwayAng = nil
local SwayOldAng = Angle()
local SwayDelta = Angle()

--Holy shit more hold types (^_^)  <- That face is fucking gay, why do I use it..

local ActIndex = {}
	ActIndex[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL
	ActIndex[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1
	ActIndex[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE
	ActIndex[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2
	ActIndex[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN
	ActIndex[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG
	ActIndex[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN
	ActIndex[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW
	ActIndex[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE
	ActIndex[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM
	ActIndex[ "normal" ]		= ACT_HL2MP_IDLE
	ActIndex[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE
	ActIndex[ "fist" ]			= ACT_HL2MP_IDLE_FIST
	ActIndex[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE
	
	
-- /*---------------------------------------------------------
   -- Name: SetWeaponHoldType
   -- Desc: Sets up the translation table, to translate from normal 
			-- standing idle pose, to holding weapon pose.
-------------------------------------------------------*/
-- function SWEP:SetWeaponHoldType( t )

	-- local index = ActIndex[ t ]
	
	-- if (index == nil) then
		-- Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set!\n" )
		-- return
	-- end

	-- self.ActivityTranslate = {}
	-- self.ActivityTranslate [ ACT_HL2MP_IDLE ] 					= index
	-- self.ActivityTranslate [ ACT_HL2MP_WALK ] 					= index+1
	-- self.ActivityTranslate [ ACT_HL2MP_RUN ] 					= index+2
	-- self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 			= index+3
	-- self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 			= index+4
	-- self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index+5
	-- self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index+6
	-- self.ActivityTranslate [ ACT_HL2MP_JUMP ] 					= index+7
	-- self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	-- -- if SERVER then
		-- -- self:SetupWeaponHoldTypeForAI( t ) 
	-- -- end

-- end

// Default hold pos is the pistol
-- SWEP:SetWeaponHoldType( SWEP.HoldType )


SWEP.Category = "Aperture Science"

SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true


SWEP.ViewModel                  = "models/weapons/portalgun/v_portalgun.mdl"
SWEP.WorldModel                 = "models/weapons/portalgun/w_portalgun_hl2.mdl"

SWEP.ViewModelFlip              = false

SWEP.Drawammo = false
SWEP.DrawCrosshair = true

SWEP.ShootOrange        = Sound( "weapons/portalgun/portalgun_shoot_red1.wav" )
SWEP.ShootBlue        = Sound( "weapons/portalgun/portalgun_shoot_blue1.wav" )
-- SWEP.ShootOrange        = Sound( "Weapon_Portalgun.fire_red" )
-- SWEP.ShootBlue          = Sound( "Weapon_Portalgun.fire_blue" )
SWEP.Delay                      = .5

SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = true
SWEP.Primary.Ammo                       = "none"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo                     = "none"

SWEP.RunBob = 0.5
SWEP.RunSway = 2.0

SWEP.HasOrangePortal = false
SWEP.HasBluePortal = false

function SWEP:Initialize()
	if CLIENT then
		self.Weapon:SetNetworkedInt("LastPortal",0,true)
		self:SetWeaponHoldType( self.HoldType )


		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( VElements )
		self.WElements = table.FullCopy( WElements )
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		

	else
		
		self.Weapon:SetNetworkedInt("LastPortal",0,true)
        self:SetWeaponHoldType( self.HoldType )
       
	end
end

if SERVER then
	util.AddNetworkString( 'PORTALGUN_PICKUP_PROP' )

	hook.Add( 'AllowPlayerPickup', 'PortalPickup', function( ply, ent )
		if IsValid( ply:GetActiveWeapon() ) and IsValid( ent ) and ply:GetActiveWeapon():GetClass() == 'weapon_portalgun' then --and (table.HasValue( pickable, ent:GetModel() ) or table.HasValue( pickable, ent:GetClass() )) then
			return false
		end
	end )
end

hook.Add("Think", "Portalgun Holding Item", function()
	for k,v in pairs(player.GetAll())do
		if v:KeyDown(IN_USE) then
			if v:GetActiveWeapon().NextAllowedPickup and v:GetActiveWeapon().NextAllowedPickup < CurTime() then
				if v:GetActiveWeapon().UseReleased then
					v:GetActiveWeapon().UseReleased = false
					if IsValid( v:GetActiveWeapon().HoldenProp ) then
						v:GetActiveWeapon():OnDroppedProp()
					end
				end
			end
		else
			v:GetActiveWeapon().UseReleased = true
		end
	end
end)

function SWEP:Think()
	
	-- // HOLDING FUNC
	
	if SERVER then
		if IsValid(self.HoldenProp) and (!self.HoldenProp:IsPlayerHolding() or self.HoldenProp.Holder != self.Owner) then
			self:OnDroppedProp()
		elseif not IsValid(self.HoldenProp) then
			self:OnDroppedProp()
		end
		if self.Owner:KeyDown( IN_USE ) and self.UseReleased then
			self.UseReleased = false
			if self.NextAllowedPickup < CurTime() and !IsValid(self.HoldenProp) then
			
				local ply = self.Owner
				self.NextAllowedPickup = CurTime() + 0.4
				local tr = util.TraceLine( { 
					start = ply:EyePos(),
					endpos = ply:EyePos() + ply:GetForward() * 150,
					filter = ply
				} )
					
				//PICKUP FUNC
				if IsValid( tr.Entity ) then
					local entsize = ( tr.Entity:OBBMaxs() - tr.Entity:OBBMins() ):Length() / 2
					if entsize > 45 then return end
					if !IsValid( self.HoldenProp ) and tr.Entity:GetMoveType() != 2 then
						if !self:PickupProp( tr.Entity ) then
							self:EmitSound( 'player/object_use_failure_01.wav' )
							self:SendWeaponAnim( ACT_VM_DRYFIRE )
						end
					end
				end
				
				//PICKUP THROUGH PORTAL FUNC
				--TODO
				
			end
		end
	end
	
	if CLIENT and self.EnableIdle then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

end

function SWEP:PickupProp( ent )
	if !limitPickups:GetBool() or ( table.HasValue( pickable, ent:GetModel() ) or table.HasValue( pickable, ent:GetClass() ) )then
		if self.Owner:GetGroundEntity() == ent then return false end
		
		//Take it from other players.
		if ent:IsPlayerHolding() and ent.Holder and ent.Holder:IsValid() then
			ent.Holder:GetActiveWeapon():OnDroppedProp()
		end
		
		self.HoldenProp = ent
		ent.Holder = self.Owner
		
		//Rotate it first
		local angOffset = hook.Call("GetPreferredCarryAngles",GAMEMODE,ent) 
		if angOffset then
			ent:SetAngles(self.Owner:EyeAngles() + angOffset)
		end
		
		//Pick it up.
		self.Owner:PickupObject(ent)
		
		self:SendWeaponAnim( ACT_VM_DEPLOY )
		
		if SERVER then
			net.Start( 'PORTALGUN_PICKUP_PROP' )
				net.WriteEntity( self )
				net.WriteEntity( ent )
			net.Send( self.Owner )
		end
		return true
	end
	return false
end

function SWEP:OnDroppedProp()
	if not self.HoldenProp then return end
	self:SendWeaponAnim(ACT_VM_RELEASE)
	if SERVER then
		self.Owner:DropObject()
	end
	self.HoldenProp.Holder = nil
	self.HoldenProp = nil
	if SERVER then
		net.Start( 'PORTALGUN_PICKUP_PROP' )
			net.WriteEntity( self )
			net.WriteEntity( NULL )
		net.Send( self.Owner )
	end
end

function SWEP:GetViewModelPosition( pos, ang )

        self.SwayScale  = self.RunSway
        self.BobScale   = self.RunBob

        return pos, ang
end

local function VectorAngle( vec1, vec2 ) -- Returns the angle between two vectors

        local costheta = vec1:Dot( vec2 ) / ( vec1:Length() *  vec2:Length() )
        local theta = math.acos( costheta )
       
        return math.deg( theta )
       
end

function SWEP:MakeTrace( start, off, normAng )
        local trace = {}
        trace.start = start
        trace.endpos = start + off
        trace.filter = { self.Owner }
        trace.mask = MASK_SOLID_BRUSHONLY
       
        local tr = util.TraceLine( trace )
       
        if !tr.Hit then
       
                local trace = {}
                local newpos = start + off
                trace.start = newpos
                trace.endpos = newpos + normAng:Forward() * -2
                trace.filter = { self.Owner }
                trace.mask = MASK_SOLID_BRUSHONLY
                local tr2 = util.TraceLine( trace )
               
                if !tr2.Hit then
               
                        local trace = {}
                        trace.start = start + off + normAng:Forward() * -2
                        trace.endpos = start + normAng:Forward() * -2
                        trace.filter = { self.Owner }
                        trace.mask = MASK_SOLID_BRUSHONLY
                        local tr3 = util.TraceLine( trace )
                       
                        if tr3.Hit then
                       
                                tr.Hit = true
                                tr.Fraction = 1 - tr3.Fraction
                               
                        end
                       
                end
               
        end
       
        return tr
end

function SWEP:IsPosionValid( pos, normal, minwallhits, dosecondcheck )

        local owner = self.Owner
       
        local noPortal = false
        local normAng = normal:Angle()
        local BetterPos = pos
       
        local elevationangle = VectorAngle( vector_up, normal )
       
        if elevationangle <= 15 or ( elevationangle >= 175 and elevationangle <= 185 )  then --If the degree of elevation is less than 15 degrees, use the players yaw to place the portal
       
                normAng.y = owner:EyeAngles().y + 180
               
        end
       
        local VHits = 0
        local HHits = 0
       
        local tr = self:MakeTrace( pos, normAng:Up() * -PORTAL_HEIGHT * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * -PORTAL_HEIGHT * 0.5
                BetterPos = BetterPos + normAng:Up() * ( length + ( PORTAL_HEIGHT * 0.5 ) )
                VHits = VHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Up() * PORTAL_HEIGHT * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * PORTAL_HEIGHT * 0.5
                BetterPos = BetterPos + normAng:Up() * ( length - ( PORTAL_HEIGHT * 0.5 ) )
                VHits = VHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Right() * -PORTAL_WIDTH * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * -PORTAL_WIDTH * 0.5
                BetterPos = BetterPos + normAng:Right() * ( length + ( PORTAL_WIDTH * 0.5 ) )
                HHits = HHits + 1
       
        end
       
        local tr = self:MakeTrace( pos, normAng:Right() * PORTAL_WIDTH * 0.5, normAng )
       
        if tr.Hit then
       
                local length = tr.Fraction * PORTAL_WIDTH * 0.5
                BetterPos = BetterPos + normAng:Right() * ( length - ( PORTAL_WIDTH * 0.5 ) )
                HHits = HHits + 1
       
        end
       
        if dosecondcheck then
       
                return self:IsPosionValid( BetterPos, normal, 2, false )
               
        elseif ( HHits >= minwallhits or VHits >= minwallhits ) then
       
                return false, false
               
        else
       
                return BetterPos, normAng
       
        end


end

function SWEP:ShootBall(type,startpos,endpos,dir)
	local ball = ents.Create("projectile_portal_ball")
	local origin = startpos -Vector(0,0,10) +self.Owner:GetRight()*8 -- +dir*100
	
	ball:SetPos(origin)
	ball:SetAngles(dir:Angle())
	ball:SetEffects(type)
	ball:SetGun(self)
	ball:Spawn()
	ball:Activate()
	ball:SetOwner(self.Owner)
	
	local speed = ballSpeed:GetInt()
	local phy = ball:GetPhysicsObject()
	if phy:IsValid() then phy:ApplyForceCenter((endpos-origin):GetNormal() * speed) end
	
	return ball
end

function SWEP:ShootPortal( type )

        local weapon = self.Weapon
        local owner = self.Owner
       
        weapon:SetNextPrimaryFire( CurTime() + self.Delay )
        weapon:SetNextSecondaryFire( CurTime() + self.Delay )

        local OrangePortalEnt = owner:GetNWEntity( "Portal:Orange", nil )
        local BluePortalEnt = owner:GetNWEntity( "Portal:Blue", nil )
       
        local EntToUse = type == TYPE_BLUE and BluePortalEnt or OrangePortalEnt
        local OtherEnt = type == TYPE_BLUE and OrangePortalEnt or BluePortalEnt
       
        local tr = {}
        tr.start = owner:GetShootPos()
        tr.endpos = owner:GetShootPos() + ( owner:GetAimVector() * 2048 * 1000 )
       
        tr.filter = { owner, EntToUse, EntToUse.Sides }
       
        for k,v in pairs(ents.FindByClass( "prop_physics*" )) do
                table.insert( tr.filter, v )
        end
       
        for k,v in pairs( ents.FindByClass( "npc_turret_floor" ) ) do
                table.insert( tr.filter, v )
        end
       
        tr.mask = MASK_SHOT
       
        local trace = util.TraceLine( tr )
       
        if IsFirstTimePredicted() and owner:IsValid() then --Predict that motha' fucka'
				
				//shoot a ball.
				local ball = self:ShootBall(type,tr.start,tr.endpos,trace.Normal)
				
                if ( trace.Hit and trace.HitWorld ) then
						
                       
                        if SERVER then
                               
                                local validpos, validnormang = self:IsPosionValid( trace.HitPos, trace.HitNormal, 2, true )
                               
                                if !trace.HitNoDraw and !trace.HitSky and ( trace.MatType != MAT_METAL or ( trace.MatType == MAT_CONCRETE or trace.MatType == MAT_DIRT ) ) and validpos and validnormang then
                                      //Wait until our ball lands, if it's enabled.
									  hitDelay = ((trace.Fraction * 2048 * 1000)-100)/ballSpeed:GetInt()
									  
									  self:SetNextPrimaryFire(math.max(CurTime()+hitDelay+.2, CurTime() + self.Delay))
									  self:SetNextSecondaryFire(math.max(CurTime()+hitDelay+.2, CurTime() + self.Delay))
									  
									  timer.Simple( hitDelay - .05, function()
											if ball and ball:IsValid() then 
												ball:Remove()
												
												local OrangePortalEnt = owner:GetNWEntity( "Portal:Orange", nil )
												local BluePortalEnt = owner:GetNWEntity( "Portal:Blue", nil )
											   
												local EntToUse = type == TYPE_BLUE and BluePortalEnt or OrangePortalEnt
												local OtherEnt = type == TYPE_BLUE and OrangePortalEnt or BluePortalEnt
												if !IsValid( EntToUse ) then
											   
														local Portal = ents.Create( "prop_portal" )
														Portal:SetPos( validpos )
														Portal:SetAngles( validnormang )
														Portal:Spawn()
														Portal:Activate()
														Portal:SetMoveType( MOVETYPE_NONE )
														Portal:SetActivatedState(true)
														Portal:SetType( type )
														Portal:SuccessEffect()
													   
														if type == TYPE_BLUE then
													   
																owner:SetNWEntity( "Portal:Blue", Portal )
																Portal:SetNetworkedBool("blue",true,true)
															   
														else
													   
																owner:SetNWEntity( "Portal:Orange", Portal )
																Portal:SetNetworkedBool("blue",false,true)
															   
														end
													   
														EntToUse = Portal
													   
														if IsValid( OtherEnt ) then
													   
																EntToUse:LinkPortals( OtherEnt )
															   
														end
													   
												else
											   
														EntToUse:MoveToNewPos( validpos, validnormang )
														EntToUse:SuccessEffect()
													   
												end
											end
										end )
                                else
                               
                                        local ang = trace.HitNormal:Angle()
                               
                                        ang:RotateAroundAxis( ang:Right(), -90 )
                                        ang:RotateAroundAxis( ang:Forward(), 0 )
                                        ang:RotateAroundAxis( ang:Up(), 90 )
                                        local ent = ents.Create( "info_particle_system" )
                                        ent:SetPos( trace.HitPos + trace.HitNormal * 0.1 )
                                        ent:SetAngles( ang )
										--TODO: Different fail effects.
                                        ent:SetKeyValue( "effect_name", "portal_" .. type .. "_badsurface")
                                        ent:SetKeyValue( "start_active", "1")
                                        ent:Spawn()
                                        ent:Activate()
                                        timer.Simple( 5, function()
											if IsValid( ent ) then
												ent:Remove()
											end 
                                        end )
										
										ent:EmitSound(Sound("weapons/portalgun/portal_invalid_surface3.wav"))
										
                                       
                                end
                               
                        end
                       
                end
               
        end
       
end

function SWEP:SecondaryAttack()
        self:ShootPortal( TYPE_ORANGE )
		self.Weapon:SetNetworkedInt("LastPortal",2)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:EmitSound( self.ShootOrange, 70, 100, .7, CHAN_WEAPON )
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:IdleStuff()

end

function SWEP:PrimaryAttack()
       
        self:ShootPortal( TYPE_BLUE )
		self.Weapon:SetNetworkedInt("LastPortal",1)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:EmitSound( self.ShootBlue, 70, 100, .7, CHAN_WEAPON )
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:IdleStuff()

end

function SWEP:CleanPortals()

        local blueportal = self.Owner:GetNWEntity( "Portal:Blue" )
        local orangeportal = self.Owner:GetNWEntity( "Portal:Orange" )
        local cleaned = false
       
        for k,v in ipairs( ents.FindByClass( "prop_portal" ) ) do
       
                if v == blueportal or v == orangeportal and v.CleanMeUp then
               
                        if SERVER then
                            v:CleanMeUp()
                        end
                       
                        cleaned = true
                       
                end
               
        end
       
        if cleaned then

            self.Weapon:SendWeaponAnim( ACT_VM_FIZZLE )
			self.Weapon:SetNetworkedInt("LastPortal",0)
			self.Weapon:EmitSound( "weapons/portalgun/portal_fizzle"..math.random(1,2)..".wav", 45, 100, .5, CHAN_WEAPON )
        
		end
       
end

function SWEP:Reload()

        self:CleanPortals()
		self:IdleStuff()
        return
       
end

function SWEP:Deploy()
       
        self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		self:CheckExisting()
		self:IdleStuff()
        return true
       
end

function SWEP:OnRestore()
end

/*---------------------------------------------------------
   Name: IdleStuff
   Desc: Helpers for the Idle function.
---------------------------------------------------------*/
function SWEP:IdleStuff()
	if self.EnableIdle then return end
	self.idledelay = CurTime() +self:SequenceDuration()
end

function SWEP:CheckExisting()
	if blueportal != nil && blueportal != nil then return end
	for _,v in pairs(ents.FindByClass("prop_portal")) do
		local own = v.Ownr
		if v != nil && own == self.Owner then
			if v.type == TYPE_BLUE && self.blueportal == nil then
				self.blueportal = v
			elseif v.type == TYPE_ORANGE && self.orangeportal == nil then
				self.orangeportal = v
			end
		end
	end
end
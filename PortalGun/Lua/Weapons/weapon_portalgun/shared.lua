

TYPE_BLUE = 1
TYPE_ORANGE = 2

PORTAL_HEIGHT = 110
PORTAL_WIDTH = 68

if ( SERVER ) then
        AddCSLuaFile( "shared.lua" )
        SWEP.Weight                     = 4
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
		
end

if ( CLIENT ) then
        SWEP.WepSelectIcon = surface.GetTextureID("weapons/portalgun_inventory")
        SWEP.PrintName          = "A.S.H.P.D."
        SWEP.Author                     = "Fernando5567"
        SWEP.Contact            = "Fergp1998@hotmail.com"
        SWEP.Purpose            = "Shoot Linked Portals"
        SWEP.ViewModelFOV       = "60"
        SWEP.Instructions       = ""
        SWEP.Slot = 0
        SWEP.Slotpos = 0
        SWEP.CSMuzzleFlashes    = true
		
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

BobTime = 0
BobTimeLast = CurTime()

SwayAng = nil
SwayOldAng = Angle()
SwayDelta = Angle()

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


SWEP.ViewModel                  = "models/weapons/v_portalgun.mdl"
SWEP.WorldModel                 = "models/weapons/portalgun/w_portalgun_hl2.mdl"

SWEP.ViewModelFlip              = false

SWEP.Drawammo = false
SWEP.DrawCrosshair = true

SWEP.ShootOrange        = Sound( "Weapon_Portalgun.fire_red" )
SWEP.ShootBlue          = Sound( "Weapon_Portalgun.fire_blue" )
SWEP.Delay                      = 0.5

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

        self:SetWeaponHoldType( self.HoldType )
       
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

function SWEP:ImpactEffect( traceHit )
	local data = EffectData();
	data:SetOrigin(traceHit.HitPos)
	data:SetNormal(traceHit.HitNormal)
	data:SetScale(20)
	util.Effect( "StunstickImpact", data );
	local rand=math.random(1,1.5);
	self:CreateBlast(rand,traceHit.HitPos)
	self:CreateBlast(rand,traceHit.HitPos)											
	if SERVER && traceHit.Entity && IsValid(traceHit.Entity) && string.find(traceHit.Entity:GetClass(),"ragdoll") then
		traceHit.Entity:Fire("StartRagdollBoogie");
		/*
		local boog=ents.Create("env_ragdoll_boogie")
		boog:SetPos(traceHit.Entity:GetPos())
		boog:SetParent(traceHit.Entity)
		boog:Spawn()
		boog:SetParent(traceHit.Entity)
		*/
	end
end

function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "anim_attachment_rh" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end

function SWEP:DispatchEffect(EFFECTSTR)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer:GetViewModel(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end

function SWEP:CreateBlast(scale,pos)
	if CLIENT then return end
	local blastspr = ents.Create("env_sprite");			//took me hours to understand how this damn
	blastspr:SetPos( pos );								//entity works
	blastspr:SetKeyValue( "model", "sprites/vortring1.vmt")//the damn vortigaunt beam ring
	blastspr:SetKeyValue( "scale",tostring(scale))
	blastspr:SetKeyValue( "framerate",60)
	blastspr:SetKeyValue( "spawnflags","1")
	blastspr:SetKeyValue( "brightness","255")
	blastspr:SetKeyValue( "angles","0 0 0")
	blastspr:SetKeyValue( "rendermode","9")
	blastspr:SetKeyValue( "renderamt","255")
	blastspr:Spawn()
	blastspr:Fire("kill","",0.45)							//remove it after 0.45 seconds
end

function SWEP:ShootPortal( type )
		
		local Weapon = self.Weapon



        local weapon = self.Weapon
        local owner = self.Owner
       
        weapon:SetNextPrimaryFire( CurTime() + self.Delay )
        weapon:SetNextSecondaryFire( CurTime() + self.Delay )
		

       
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
       
                if ( trace.Hit and trace.HitWorld ) then

						owner:DoAnimationEvent(PLAYERANIMEVENT_ATTACK_PRIMARY) --doesn't work?
                       
                        if SERVER then
                               
                                local validpos, validnormang = self:IsPosionValid( trace.HitPos, trace.HitNormal, 2, true )
                               
                                if !trace.HitNoDraw and !trace.HitSky and ( trace.MatType != MAT_METAL or ( trace.MatType == MAT_CONCRETE or trace.MatType == MAT_DIRT ) ) and validpos and validnormang then
                                       
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
                                                       
                                                else
                                               
                                                        owner:SetNWEntity( "Portal:Orange", Portal )
                                                       
                                                end
                                               
                                                EntToUse = Portal
                                               
                                                if IsValid( OtherEnt ) then
                                               
                                                        EntToUse:LinkPortals( OtherEnt )
                                                       
                                                end
                                               
                                        else
                                       
                                                EntToUse:MoveToNewPos( validpos, validnormang )
                                                EntToUse:SuccessEffect()
                                               
                                        end
                                       
                                else
                               
                                        local ang = trace.HitNormal:Angle()
                               
                                        ang:RotateAroundAxis( ang:Right(), -90 )
                                        ang:RotateAroundAxis( ang:Forward(), 0 )
                                        ang:RotateAroundAxis( ang:Up(), 90 )
                                        local ent = ents.Create( "info_particle_system" )
                                        ent:SetPos( trace.HitPos + trace.HitNormal * 0.1 )
                                        ent:SetAngles( ang )
                                        ent:SetKeyValue( "effect_name", "portal_" .. type .. "_badsurface")
                                        ent:SetKeyValue( "start_active", "1")
                                        ent:Spawn()
                                        ent:Activate()
                                       
                                        timer.Simple( 5, function()
                                       
                                                if IsValid( ent ) then
                                               
                                                        ent:Remove()
                                                       
                                                end
                                               
                                        end )
                                       
                                end
                               
                        end
                       
                end
               
        end
       
end

function SWEP:SecondaryAttack()

        self:ShootPortal( TYPE_ORANGE )
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self:EmitSound( self.ShootOrange, 100, 100 )
		self.Owner:DoAnimationEvent(PLAYERANIMEVENT_ATTACK_PRIMARY)
		self:IdleStuff()

end

function SWEP:PrimaryAttack()
       
        self:ShootPortal( TYPE_BLUE )
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self:EmitSound( self.ShootBlue, 100, 100 )
		self.Owner:DoAnimationEvent(PLAYERANIMEVENT_ATTACK_PRIMARY)
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
				self.Weapon:EmitSound( "portal_fizzle"..math.random(1,2)..".wav" )
				
               
        end
       
end

function SWEP:Reload()

        self:CleanPortals()
		self:IdleStuff()
        return
       
end

function SWEP:Deploy()
       
        self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		self:IdleStuff()
        return true
       
end

function SWEP:OnRestore()
end

function SWEP:Think()

	if CLIENT and self.EnableIdle then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end


end

function SWEP:DrawHUD()
end

/*---------------------------------------------------------
   Name: IdleStuff
   Desc: Helpers for the Idle function.
---------------------------------------------------------*/
function SWEP:IdleStuff()
	if self.EnableIdle then return end
	self.idledelay = CurTime() +self:SequenceDuration()
end

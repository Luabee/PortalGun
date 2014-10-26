include( "shared.lua" )

local dlightenabled = CreateClientConVar("portal_dynamic_light", "0", true) --Kinda laggy, default it to off
local lightteleport = CreateClientConVar("portal_light_teleport", "0", true)
local bordersenabled = CreateClientConVar("portal_borders", "1", true)
local betabordersenabled = CreateClientConVar("portal_beta_borders", "1", true)

local texFSB = render.GetSuperFPTex() -- I'm really not sure if I should even be using these D:
local texFSB2 = render.GetSuperFPTex2()

 -- Make our own material to use, so we aren't messing with other effects.
local PortalMaterial = CreateMaterial(
                "PortalMaterial",
                "GMODScreenspace",
                -- "VertexLitGeneric",
                {
                        [ '$basetexture' ] = texFSB,
                        //[ '$basetexturetransform' ] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
                        [ '$texturealpha' ] = "0",
                        [ '$vertexalpha' ] = "1",
                }
        )

if CLIENT then
	game.AddParticles("particles/portal_projectile.pcf")
	game.AddParticles("particles/portals.pcf")
	game.AddParticles("particles/portalgun.pcf")
end

// rendergroup
ENT.RenderGroup = RENDERGROUP_BOTH

/*------------------------------------
        Initialize()
------------------------------------*/
function ENT:Initialize( )

        self:SetRenderBounds( self:OBBMins()*20, self:OBBMaxs()*20 )
       
        self.openpercent = 0
       
end

usermessage.Hook("Portal:Moved", function(umsg)
        local ent = umsg:ReadEntity()
        if ent and ent:IsValid() and ent.openpercent then
                ent.openpercent = 0
				
        end
end)

--I think this is from sassilization..
local function IsInFront( posA, posB, normal )

        -- local Vec1 = ( posB - posA ):GetNormalized()

        -- return ( normal:Dot( Vec1 ) < 0 )
		return true

end

function ENT:Think()

        if self:GetNWBool("Potal:Activated",false) == false then return end
       
        self.openpercent = math.Approach( self.openpercent, 1, FrameTime() * 5 * ( 1 - self.openpercent + 0.25 ) )

        if dlightenabled:GetBool() == false then return end
       
        local portaltype = self:GetNWInt("Potal:PortalType",TYPE_BLUE)

        local glowcolor = Color( 64, 144, 255, 255 )
       
        if portaltype == TYPE_ORANGE then
                glowcolor = Color( 255, 160, 32, 255 )
        end
       
        --[[if lightteleport:GetBool() then
       
                local portal = self:GetNWEntity( "Potal:Other", nil )
       
                if IsValid( portal ) then

                        glowvec = render.GetLightColor( portal:GetPos() ) * 255
                        glowcolor = Color( glowvec.x, glowvec.y, glowvec.z )
                       
                end
                       
        end]]
       
        local dlight = DynamicLight( self:EntIndex() )
        if dlight then
                local col = glowcolor
                dlight.Pos = self:GetPos() + self:GetAngles():Forward()
                dlight.r = col.r
                dlight.g = col.g
                dlight.b = col.b
                dlight.Brightness = 2
                dlight.Decay = 256
                dlight.Size = self.openpercent * 256
                dlight.DieTime = CurTime() + 0.1
        end
end

local nonlinkedblue = surface.GetTextureID( "sprites/noblue" )
local nonlinkedorange = surface.GetTextureID( "sprites/nored" )
local bluebordermat = surface.GetTextureID( "sprites/blborder" )
local orangebordermat = surface.GetTextureID( "sprites/ogborder" )
local bluebetabordermat = surface.GetTextureID( "sprites/blueborder" )
local orangebetabordermat = surface.GetTextureID( "sprites/redborder" )

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

function ENT:DrawPortalEffects( portaltype )

        local ang = self:GetAngles()
       
        local res = 0.1
       
        local percentopen = self.openpercent
       
        local width = ( percentopen ) * 105
        local height = ( percentopen ) * 114
       
        if betabordersenabled:GetBool() then
                height = ( percentopen ) * 112
        end
       
        ang:RotateAroundAxis( ang:Right(), -90 )
        ang:RotateAroundAxis( ang:Up(), 90 )
       
        local origin = self:GetPos() + ( self:GetForward() * 0.1 ) - ( self:GetUp() * height / -2 ) - ( self:GetRight() * width / -2 )
       
        cam.Start3D2D( origin, ang, res )
       
                surface.SetDrawColor( 255, 255, 255, 255 )
       
                if ( RENDERING_PORTAL or RENDERING_MIRROR or !self:GetNWBool( "Potal:Linked", false ) ) then
               
                        if portaltype == TYPE_BLUE then
                       
                                surface.SetTexture( nonlinkedblue )
                               
                        elseif portaltype == TYPE_ORANGE then
                       
                                surface.SetTexture( nonlinkedorange )
                               
                        end
                       
                        surface.DrawTexturedRect( 0, 0, width / res , height / res )
                       
                end
               
                if !self:GetNWBool( "Potal:Linked", false ) then
               
                        if portaltype == TYPE_BLUE then
                       
                                surface.SetTexture( nonlinkedblue )
                               
                        elseif portaltype == TYPE_ORANGE then
                       
                                surface.SetTexture( nonlinkedorange )
                               
                        end
                       
                        surface.DrawTexturedRect( 0, 0, width / res , height / res )
                       
                end
               
                if bordersenabled:GetBool() == true then
                        if portaltype == TYPE_BLUE then
                               
                                if betabordersenabled:GetBool() then
                               
                                        surface.SetTexture( bluebetabordermat )
                                       
                                else
                               
                                        surface.SetTexture( bluebordermat )
                                       
                                end
                               
                                surface.DrawTexturedRect( 0, 0, width / res , height / res )
                               
                        elseif portaltype == TYPE_ORANGE then
                               
                                if betabordersenabled:GetBool() then
                               
                                        surface.SetTexture( orangebetabordermat )
                                       
                                else
                               
                                        surface.SetTexture( orangebordermat )
                                       
                                end
                               
                                surface.DrawTexturedRect( 0, 0, width / res , height / res )
                               
                        end
                       
                end
               
        cam.End3D2D()
       
end

function ENT:Draw()

        local viewent = GetViewEntity()
        local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or EyePos()

        if IsInFront( pos, self:GetPos(), self:GetForward() ) and self:GetNWBool("Potal:Activated",false) then


                local portaltype = self:GetNWInt( "Potal:PortalType",TYPE_BLUE )

                render.ClearStencil() -- Make sure the stencil buffer is all zeroes before we begin
                render.SetStencilEnable( true )
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
                render.SetStencilFailOperation( STENCILOPERATION_KEEP )
                render.SetStencilZFailOperation( STENCILOPERATION_KEEP )  -- Don't change anything if the pixel is occoludded (so we don't see things thru walls)
                render.SetStencilPassOperation( STENCILOPERATION_REPLACE ) -- Replace the value of the buffer's pixel with the reference value
                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS ) -- Always replace regardless of whatever is in the stencil buffer currently

                render.SetStencilReferenceValue( 1 )
               
                local percentopen = self.openpercent
                self:SetModelScale( percentopen,0 )
                self:DrawModel()
               
                render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
                render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
               
                render.SetStencilReferenceValue( 1 )
               
                local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
       
                PortalMaterial:SetTexture( "$basetexture", ToRT )
                render.SetMaterial( PortalMaterial )
                render.DrawScreenQuad()
               
                render.SetStencilEnable( false )
               
                self:DrawPortalEffects( portaltype )
       
        end

end

function ENT:RenderPortal( origin, angles)

        local portal = self:GetNWEntity( "Potal:Other", nil )

        if IsValid( portal ) and self:GetNWBool( "Potal:Linked", false ) and self:GetNWBool( "Potal:Activated", false ) then
   
			local portaltype = self:GetNWInt( "Potal:PortalType", TYPE_BLUE )
		   
			local normal = self:GetForward()
			local distance = normal:Dot( self:GetPos() )
		   
			othernormal = portal:GetForward()
			otherdistance = othernormal:Dot( portal:GetPos() )
		   
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
		   
			// convert to angles
			angles = math.VectorAngles( forward, up )
		   
			local LocalOrigin = self:WorldToLocal( origin )
			local LocalAngles = self:WorldToLocalAngles( angles )
		   
			// repair
			LocalOrigin.y = -LocalOrigin.y
			LocalAngles.y = -LocalAngles.y
			LocalAngles.r = -LocalAngles.r
		   
			view = {}
			view.x = 0
			view.y = 0
			view.w = ScrW()
			view.h = ScrH()
			view.origin = portal:LocalToWorld( LocalOrigin )
			view.angles = portal:LocalToWorldAngles( LocalAngles )
			view.drawhud = false
			view.drawviewmodel = false
			
			local oldrt = render.GetRenderTarget()
		   
			local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
		   
			render.SetRenderTarget( ToRT )
				render.PushCustomClipPlane( othernormal, otherdistance )
				local b = render.EnableClipping(true)
					render.Clear( 0, 0, 0, 255 )
					render.ClearDepth()
					render.ClearStencil()
					portal:SetNoDraw( true )
						RENDERING_PORTAL = true
							render.RenderView( view )
							render.UpdateScreenEffectTexture()
						RENDERING_PORTAL = false
					portal:SetNoDraw( false )

				render.PopCustomClipPlane()
				render.EnableClipping(b)
			render.SetRenderTarget( oldrt )
			

				
               
        end

end

/*------------------------------------
        ShouldDrawLocalPlayer()
------------------------------------*/
--Draw yourself into the portal.. YES YOU CAN SEE YOURSELF! (Bug? Can't see your weapons)
hook.Add( "ShouldDrawLocalPlayer", "Portal.ShouldDrawLocalPlayer", function()
        if RENDERING_PORTAL then
			return true
        end
end )
hook.Add( 'PostDrawEffects', 'PortalSimulation_PlayerRenderFix', function()
	cam.Start3D( EyePos(), EyeAngles() )
	cam.End3D()
end)

hook.Add( "RenderScene", "Portal.RenderScene", function( Origin, Angles )
	// render each portal
	for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		local viewent = GetViewEntity()
		local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or Origin
		if IsInFront( pos, v:GetPos(), v:GetForward() ) then --if the player is in front of the portal, then render it..
			// call into it to render
			v:RenderPortal( Origin, Angles )
		end
	end
end )
CreateClientConVar("portal_debugmonitor", 0, false, false)
hook.Add( "HUDPaint", "Portal.BlueMonitor", function( w,h )
	if GetConVarNumber("portal_debugmonitor") == 1 then
		// render each portal
		for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		  // debug monitor
			if view and v:GetNWInt("Potal:PortalType", TYPE_BLUE) == TYPE_BLUE then
				
				surface.DrawLine(ScrW()/2-10,ScrH()/2,ScrW()/2+10,ScrH()/2)
				surface.DrawLine(ScrW()/2,ScrH()/2-10,ScrW()/2,ScrH()/2+10)
				
				render.EnableClipping(true)
				render.PushCustomClipPlane( othernormal, otherdistance )
					view.w = 500
					view.h = 280
					RENDERING_PORTAL = true
						render.RenderView( view )
					RENDERING_PORTAL = false
				render.PopCustomClipPlane( )
				render.EnableClipping(false)
			end

		end
	end
end )

/*------------------------------------
        GetMotionBlurValues()
------------------------------------*/
hook.Add( "GetMotionBlurValues", "Portal.GetMotionBlurValues", function( x, y, fwd, spin )
        if RENDERING_PORTAL then
                return 0, 0, 0, 0
        end
end )

hook.Add( "PostProcessPermitted", "Portal.PostProcessPermitted", function( element )
        if element == "bloom" and RENDERING_PORTAL then
                return false
        end
end )

usermessage.Hook( "Portal:ObjectInPortal", function(umsg)
        local portal = umsg:ReadEntity()
        local ent = umsg:ReadEntity()
        if IsValid( ent ) and IsValid( portal ) then
                ent.InPortal = portal
        end
end )

usermessage.Hook( "Portal:ObjectLeftPortal", function(umsg)
        local ent = umsg:ReadEntity()
        if IsValid( ent ) then
                ent.InPortal = false
                ent:SetRenderClipPlaneEnabled(false)
        end
end )

hook.Add( "RenderScreenspaceEffects", "Portal.RenderScreenspaceEffects", function()
        for k,v in pairs( ents.GetAll() ) do
                if IsValid( v.InPortal ) then
                        --local plane = Plane(v.InPortal:GetForward(),v.InPortal:GetPos())
                       
                        local normal = v.InPortal:GetForward()
                        local distance = normal:Dot( v.InPortal:GetPos() )
                       
                        v:SetRenderClipPlaneEnabled( true )
                        v:SetRenderClipPlane( normal, distance )
                end
        end
end )

/*------------------------------------
        VectorAngles()
------------------------------------*/
function math.VectorAngles( forward, up )

        local angles = Angle( 0, 0, 0 )

        local left = up:Cross( forward )
        left:Normalize()
       
        local xydist = math.sqrt( forward.x * forward.x + forward.y * forward.y )
       
        // enough here to get angles?
        if( xydist > 0.001 ) then
       
                angles.y = math.deg( math.atan2( forward.y, forward.x ) )
                angles.p = math.deg( math.atan2( -forward.z, xydist ) )
                angles.r = math.deg( math.atan2( left.z, ( left.y * forward.x ) - ( left.x * forward.y ) ) )

        else
       
                angles.y = math.deg( math.atan2( -left.x, left.y ) )
                angles.p = math.deg( math.atan2( -forward.z, xydist ) )
                angles.r = 0
       
        end


        return angles
       
end

--red = in blue = out
usermessage.Hook("DebugOverlay_LineTrace", function(umsg)
	local p1,p2,b = umsg:ReadVector(),umsg:ReadVector(),umsg:ReadBool()
	local col
	if b then col = Color(255,0,0,255) else col = Color(0,0,255,255) end
	debugoverlay.Line(p1,p2,5, col)
end)
local point = Vector(0,0,0)
local CAM_POS = Vector(0,0,0)
usermessage.Hook("DebugOverlay_Cross", function(umsg)
	point = umsg:ReadVector()
	local b = umsg:ReadBool()
	if b then 
		b = Color(255,0,0) 
	else 
		b = Color(0,0,255)
	end
	debugoverlay.Cross(point,5, 5, b)
	debugoverlay.Box(point, Vector(-5,-5,-5), Vector(5,5,5), FrameTime(), b)
	debugoverlay.Cross(CAM_POS, 10, FrameTime(), Color(0,255,0), true)
end)
concommand.Add("CamSave", function(p,c,a)
	if CAM_POS == Vector(0,0,0) then
		CAM_POS = point
	else
		CAM_POS = Vector(0,0,0)
	end
end)

hook.Add("Think", "Reset Camera Roll", function()
	local a = LocalPlayer():EyeAngles()
	if a.r != 0 then
		a.r = math.Approach(a.r, 0, FrameTime()*270)
		LocalPlayer():SetEyeAngles(a)
	end
end)
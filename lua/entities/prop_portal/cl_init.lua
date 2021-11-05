include( "shared.lua" )

local dlightenabled = CreateClientConVar("portal_dynamic_light", "0", true) --Pretty laggy, default it to off
-- local lightteleport = CreateClientConVar("portal_light_teleport", "0", true)
local bordersenabled = CreateClientConVar("portal_borders", "1", true)
local betabordersenabled = CreateClientConVar("portal_beta_borders", "1", true)
local renderportals = CreateClientConVar("portal_render", 1, true) --Some people can't handle portals at all.

local texFSB = render.GetSuperFPTex() -- I'm really not sure if I should even be using these D:
local texFSB2 = render.GetSuperFPTex2()

 -- Make our own material to use, so we aren't messing with other effects.
local PortalMaterial = CreateMaterial(
								"PortalMaterial",
								"UnlitGeneric",
								-- "GMODScreenspace",
								{
												[ '$basetexture' ] = texFSB,
												[ '$model' ] = "1",
												-- [ '$basetexturetransform' ] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
												[ '$alphatest' ] = "0",
												[ '$additive' ] = "0",
												[ '$translucent' ] = "0",
												[ '$ignorez' ] = "0"
								}
				)

if CLIENT then
	game.AddParticles("particles/portal_projectile.pcf")
	game.AddParticles("particles/portals.pcf")
	game.AddParticles("particles/portalgun.pcf")
	game.AddParticles("particles/portal_beta_particles.pcf")
	game.AddParticles("particles/portal_beta_particles2.pcf")
end

// rendergroup
ENT.RenderGroup = RENDERGROUP_BOTH

/*------------------------------------
				Initialize()
------------------------------------*/
function ENT:Initialize( )

				self:SetRenderBounds( self:OBBMins()*20, self:OBBMaxs()*20 )
			 
				self.openpercent = 0
		
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		
		if self:OnFloor() then
			self:SetRenderOrigin( self:GetPos() - Vector(0,0,20))
		else
			self:SetRenderOrigin( self:GetPos() )
		end
		
		-- self:SetRenderClipPlaneEnabled( true )
		-- self:SetRenderClipPlane( self:GetForward(), 5 )
			 
end

usermessage.Hook("Portal:Moved", function(umsg)
				local ent = umsg:ReadEntity()
		local pos = umsg:ReadVector()
		local ang = umsg:ReadAngle()
				if ent and ent:IsValid() and ent.openpercent then
								ent.openpercent = 0
				
				ent:SetAngles(ang)
				if ent:OnFloor() then
					ent:SetRenderOrigin( pos - Vector(0,0,20) )
				else
					ent:SetRenderOrigin(pos)
				end
				-- ent:SetRenderClipPlane( ent:GetForward(), 5 )
				end
end)

--I think this is from sassilization..
local function IsInFront( posA, posB, normal )

				local Vec1 = ( posB - posA ):GetNormalized()

				return ( normal:Dot( Vec1 ) < 0 )
		-- return true

end

function ENT:Think()

				if self:GetNWBool("Potal:Activated",false) == false then return end
			 
				self.openpercent = math.Approach( self.openpercent, 1, FrameTime() * 3 * ( 1 - self.openpercent + 0.1 ) )

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
			 -- if AvgFPS() > 60 then
				local dlight = DynamicLight( self:EntIndex() )
				if dlight then
			local col = glowcolor
			dlight.Pos = self:GetRenderOrigin() + self:GetAngles():Forward()
			dlight.r = col.r
			dlight.g = col.g
			dlight.b = col.b
			dlight.Brightness = 2
			dlight.Decay = 256
			dlight.Size = self.openpercent * 256
			dlight.DieTime = CurTime() + .9
			dlight.Style = 5
				end
	   -- end
end

local nonlinkedblue = surface.GetTextureID( "sprites/noblue" )
local nonlinkedorange = surface.GetTextureID( "sprites/nored" )
local bluebordermat = surface.GetTextureID( "sprites/blborder" )
local orangebordermat = surface.GetTextureID( "sprites/ogborder" )
local bluebetabordermat = surface.GetTextureID( "sprites/blueborder" )
local orangebetabordermat = surface.GetTextureID( "sprites/redborder" )
local nonlinkedbluebeta = surface.GetTextureID( "sprites/n0blue" )
local nonlinkedorangebeta = surface.GetTextureID( "sprites/n0red" )
local bluebetarefract = surface.GetTextureID( "sprites/refract_blue" )
local orangebetarefract = surface.GetTextureID( "sprites/refract_orange" )

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
			 
				local origin = self:GetRenderOrigin() + ( self:GetForward() * 0.1 ) - ( self:GetUp() * height / -2 ) - ( self:GetRight() * width / -2 )
			 
				cam.Start3D2D( origin, ang, res )
			 
								surface.SetDrawColor( 255, 255, 255, 255 )
			 
								if ( RENDERING_PORTAL or !self:GetNWBool( "Potal:Linked", false ) or !self:GetNWBool( "Potal:Activated", false )) then
							 
												if portaltype == TYPE_BLUE then
						
						if betabordersenabled:GetBool() then
															 
															 surface.SetTexture( nonlinkedbluebeta )
							   
							   else
											 
																surface.SetTexture( nonlinkedblue )
						
						end
															 
												elseif portaltype == TYPE_ORANGE then
						
						if betabordersenabled:GetBool() then
															 
															 surface.SetTexture( nonlinkedorangebeta )
							   
							   else
											 
																surface.SetTexture( nonlinkedorange )
															 
												end
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
	self:SetModelScale( self.openpercent,0 )
	self:DrawModel()
	self:SetColor(Color(255,255,255,0))
	
end
function ENT:DrawPortal()
	local viewent = GetViewEntity()
	local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or EyePos()

	if IsInFront( pos, self:GetRenderOrigin(), self:GetForward() ) and self:GetNWBool("Potal:Activated",false) then
		
		render.ClearStencil() -- Make sure the stencil buffer is all zeroes before we begin
		render.SetStencilEnable( true )
		
			cam.Start3D2D(self:GetRenderOrigin(),self:GetAngles(),1)
				
				render.SetStencilWriteMask(3)
				render.SetStencilTestMask(3)
				render.SetStencilFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilZFailOperation( STENCILOPERATION_KEEP )  -- Don't change anything if the pixel is occoludded (so we don't see things thru walls)
				render.SetStencilPassOperation( STENCILOPERATION_REPLACE ) -- Replace the value of the buffer's pixel with the reference value
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS) -- Always replace regardless of whatever is in the stencil buffer currently

				render.SetStencilReferenceValue( 1 )
			   
				local percentopen = self.openpercent
				self:SetModelScale( percentopen,0 )
				self:DrawModel()
				
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
				
				--Draw portal.
				local portaltype = self:GetNWInt( "Potal:PortalType",TYPE_BLUE )
				if renderportals:GetBool() then
					local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
					PortalMaterial:SetTexture( "$basetexture", ToRT )
					render.SetMaterial( PortalMaterial )
					render.DrawScreenQuad()
				end
				
				--Draw colored overlay.
				local color = Material("sprites/blueNoDraw.png", "unlitgeneric")
				if portaltype == TYPE_ORANGE then
					color = Material("sprites/orangeNoDraw.png", "unlitgeneric")
				end
				local other = self:GetNWEntity("Potal:Other")
				if other and other:IsValid() and other.openpercent then
					if renderportals:GetBool() then
						color:SetFloat("$alpha", 1-math.min(percentopen,other.openpercent))
					else
						color:SetFloat("$alpha", 1)
					end
					render.SetMaterial(color)
					render.DrawScreenQuad()
				end
				
			cam.End3D2D()
		
		render.SetStencilEnable( false )
		
		self:DrawPortalEffects( portaltype )
	end
end
hook.Add("PostDrawOpaqueRenderables","DrawPortals", function()
	for k,v in pairs(ents.FindByClass("prop_portal"))do
		v:DrawPortal()
	end
end)

function ENT:RenderPortal( origin, angles)
	if renderportals:GetBool() then
		local portal = self:GetNWEntity( "Potal:Other", nil )
		if IsValid( portal ) and self:GetNWBool( "Potal:Linked", false ) and self:GetNWBool( "Potal:Activated", false ) then
	 
			local portaltype = self:GetNWInt( "Potal:PortalType", TYPE_BLUE )
		   
			local normal = self:GetForward()
			local distance = normal:Dot( self:GetRenderOrigin() )
		   
			othernormal = portal:GetForward()
			otherdistance = othernormal:Dot( portal:GetRenderOrigin() )
		   
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
			if self:OnFloor() and not portal:OnFloor() then
				LocalOrigin.x = LocalOrigin.x + 20
			end
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
						RENDERING_PORTAL = self
							render.RenderView( view )
							render.UpdateScreenEffectTexture()
						RENDERING_PORTAL = false
					portal:SetNoDraw( false )
					
				render.PopCustomClipPlane()
				render.EnableClipping(b)
			render.SetRenderTarget( oldrt ) 
		end
	end
end


/*------------------------------------
				ShouldDrawLocalPlayer()
------------------------------------*/
--Draw yourself into the portal.. YES YOU CAN SEE YOURSELF! (Bug? Can't see your weapons)
hook.Add( "ShouldDrawLocalPlayer", "Portal.ShouldDrawLocalPlayer", function()
		local ply = LocalPlayer()
		local portal = ply.InPortal
				if RENDERING_PORTAL then
			return true
				-- elseif IsValid(portal) then
			-- local pos,ang = portal:GetPortalPosOffsets(portal:GetOther(),ply), portal:GetPortalAngleOffsets(portal:GetOther(),ply)
			-- pos.z = pos.z - 64
			
			-- ply:SetRenderOrigin(pos)
			-- ply:SetRenderAngles(ang)
			-- return true
			
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
		if IsInFront( Origin, v:GetRenderOrigin(), v:GetForward() ) then --if the player is in front of the portal, then render it..
			// call into it to render
			v:RenderPortal( Origin, Angles )
		end
	end
end )
CreateClientConVar("portal_debugmonitor", 0, false, false)
hook.Add( "HUDPaint", "Portal.BlueMonitor", function( w,h )
	if GetConVarNumber("portal_debugmonitor") == 1 and GetConVarNumber("sv_cheats") == 1 then
		// render each portal
		for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		  // debug monitor
			if view and v:GetNWInt("Potal:PortalType", TYPE_BLUE) == TYPE_BLUE then
				
				surface.DrawLine(ScrW()/2-10,ScrH()/2,ScrW()/2+10,ScrH()/2)
				surface.DrawLine(ScrW()/2,ScrH()/2-10,ScrW()/2,ScrH()/2+10)
				
				local b = render.EnableClipping(true)
				render.PushCustomClipPlane( othernormal, otherdistance )
					view.w = 500
					view.h = 280
					RENDERING_PORTAL = true
						render.RenderView( view )
					RENDERING_PORTAL = false
				render.PopCustomClipPlane( )
				render.EnableClipping(b)
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
			
			-- if ent:IsPlayer() then
				-- portal:SetupPlayerClone(ent)
			-- end
			
			ent:SetRenderClipPlaneEnabled( true )
			ent:SetGroundEntity( portal )
		end
end )

usermessage.Hook( "Portal:ObjectLeftPortal", function(umsg)
				local ent = umsg:ReadEntity()
				if IsValid( ent ) then
			-- if ent:IsPlayer() and IsValid(ent.PortalClone) then
				-- ent.PortalClone:Remove()
			-- end
			ent.InPortal = false
			ent:SetRenderClipPlaneEnabled(false)
				end
end )

hook.Add( "RenderScreenspaceEffects", "Portal.RenderScreenspaceEffects", function()
				for k,v in pairs( ents.GetAll() ) do
								if IsValid( v.InPortal ) then
												--local plane = Plane(v.InPortal:GetForward(),v.InPortal:GetPos())
											 
												local normal = v.InPortal:GetForward()
												local distance = normal:Dot( v.InPortal:GetRenderOrigin() )
											 
						v:SetRenderClipPlaneEnabled(true)
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
usermessage.Hook("DebugOverlay_Cross", function(umsg)
	local point = umsg:ReadVector()
	local b = umsg:ReadBool()
	if b then 
		b = Color(0,255,0)
	else 
		b = Color(255,0,0) 
	end
	debugoverlay.Cross(point,5, 5, b,true)
end)

hook.Add("Think", "Reset Camera Roll", function()
	if not LocalPlayer():InVehicle() then
		local a = LocalPlayer():EyeAngles()
		if a.r != 0 then
			a.r = math.ApproachAngle(a.r, 0, FrameTime()*160)
			LocalPlayer():SetEyeAngles(a)
		end
	end
end) 

-- local fps = {30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30}
-- function AvgFPS()
	-- table.remove(fps,1)
	-- table.insert(fps,1/FrameTime())
	-- local avg = 0
	-- for i=1,#fps do
		-- avg = avg+fps[i]
	-- end
	-- return avg/#fps
-- end
-- hook.Add("Tick","Calc AVG FPS",AvgFPS)

-- hook.Add("HUDPaint","PrintVelocity", function() 
	
	-- draw.SimpleText(LocalPlayer():GetVelocity():__tostring(),"DermaLarge",100,100,Color(100,255,100),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)

-- end)
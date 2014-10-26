if( SERVER ) then
        AddCSLuaFile( "portalmove.lua" );
end

if( CLIENT ) then
       
	/*------------------------------------
			CreateMove()
	------------------------------------*/
	local function CreateMove( cmd )
   
		local pl = LocalPlayer();
		if( IsValid( pl ) ) then
   
			if( pl.InPortal and pl.InPortal:IsValid() and pl:GetMoveType() == MOVETYPE_NOCLIP) then
				
				local right = 0;
				local forward = 0;
				local maxspeed = pl:GetMaxSpeed();
				if pl:Crouching() then
					maxspeed = pl:GetCrouchedWalkSpeed() * 100
				end
			   
				// forward/back
				if( cmd:KeyDown( IN_FORWARD ) ) then
					forward = forward + maxspeed;
				end
				if( cmd:KeyDown( IN_BACK ) ) then
					forward = forward - maxspeed;
				end
			   
				// left/right
				if( cmd:KeyDown( IN_MOVERIGHT ) ) then
					right = right + maxspeed;
				end
				if( cmd:KeyDown( IN_MOVELEFT ) ) then
					right = right - maxspeed;
				end
				
				cmd:SetForwardMove( forward );
				cmd:SetSideMove( right );
			end
	   
		end
   
	end
	hook.Add( "CreateMove", "Noclip.CreateMove", CreateMove );

end

function SubAxis( v, x )
        return v - ( v:Dot( x ) * x )
end

function ipMove( ply, mv )

        if IsValid( ply.InPortal ) and ply:GetMoveType() == MOVETYPE_NOCLIP then
                -- if ply:GetMoveType() != MOVETYPE_NOCLIP then
                        -- return
                -- end
				if ply.InPortal:GetPos():Distance(ply:GetPos()) > 80 and ply.InPortal:IsLinked() and ply.InPortal:GetOther():GetPos():Distance(ply:GetPos()) > 80 then
					ply.InPortal = nil
					ply:SetMoveType(MOVETYPE_WALK)
					return false
				end
				
       
                local deltaTime = FrameTime()
				
                // I hate having to get these by name like this.
                local noclipSpeed = 1.75
                local noclipAccelerate = 5
               
                // calculate acceleration for this frame.
                local ang = mv:GetMoveAngles()
                local acceleration = ( ang:Forward() * mv:GetForwardSpeed() ) + ( ang:Right() * mv:GetSideSpeed() )
               
                local pos = mv:GetOrigin() + Vector( 0, 0, 38 )
                local pOrg = ply.InPortal:GetPos()
                local pAng = ply.InPortal:GetAngles()
                local off = pos - pOrg
                local vOff = SubAxis( SubAxis( off,pAng:Right() ), pAng:Forward() )
				local pPos = ply.InPortal:WorldToLocal(ply:GetPos())
               
                -- if ply:GetPos().z > math.abs( ( ply.InPortal:GetUp() * -42 ).z ) then
                if mv:GetOrigin().z > ply.InPortal:GetPos().z -42 then
                       
                        acceleration.z = -100
                       
                else
               
                        acceleration.z = 0
                       
                end
               
                // clamp to our max speed, and take into account noclip speed
                local accelSpeed = math.min( acceleration:Length(), ply:GetMaxSpeed() );
                local accelDir = acceleration:GetNormal()
                acceleration = accelDir * accelSpeed * noclipSpeed
               
                // calculate final velocity with friction
                local getvel = mv:GetVelocity()
                local newVelocity = getvel + acceleration * deltaTime * noclipAccelerate;
                newVelocity.x = newVelocity.x * ( 0.98 - deltaTime * 5 )
                newVelocity.y = newVelocity.y * ( 0.98 - deltaTime * 5 )
				
				if pPos.x <= 16.5 or (not ply.InPortal:IsHorizontal())then
					
					if vOff:Length() > 20 then
				   
						off = SubAxis( off, pAng:Up() ) + vOff:GetNormal() *20
					   
					end
				   
					local hOff = SubAxis( SubAxis( off, pAng:Up() ), pAng:Forward() )
				   
					if hOff:Length() > 16 then
					
						off = SubAxis( off, pAng:Right() ) + hOff:GetNormal() * 16
					   
					end
					
				end
				

                // set velocity
                mv:SetVelocity( newVelocity * .99 )
               
                // move the player
                mv:SetOrigin( ( pOrg + off - Vector( 0, 0, 38 ) + newVelocity * deltaTime ) )
               
                return true;
        end
end
hook.Add("Move","hpdMoveHook",ipMove)

local function NoclipAnim(ply,vel)
	print("Changed anim")
	if IsValid( ply.InPortal ) then
		ply:SetAnimation(PLAYER_WALK)
		return true
	end
	return false
end
hook.Add("HandlePlayerDucking", "Portal: Pretend To Walk", NoclipAnim)


local CanMoveThrough = {
	CONTENTS_EMPTY,
	CONTENTS_DEBRIS,
	CONTENTS_WATER
}

--everytick:
local function CollisionBoxOutsideMap( ent, minBound, maxBound )
	local pPos = ent:LocalToWorld(ent:OBBCenter())
	if not util.IsInWorld( Vector( pPos.x+minBound.x, pPos.y+minBound.y, pPos.z+minBound.z ) ) then
		
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x-minBound.x, pPos.y+minBound.y, pPos.z+minBound.z ) ) then
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x-minBound.x, pPos.y-minBound.y, pPos.z+minBound.z ) ) then
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x+minBound.x, pPos.y-minBound.y, pPos.z+minBound.z ) ) then
		return true 
	end
	
	if not util.IsInWorld( Vector( pPos.x+maxBound.x, pPos.y+maxBound.y, pPos.z+maxBound.z ) ) then
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x-maxBound.x, pPos.y+maxBound.y, pPos.z+maxBound.z ) ) then
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x-maxBound.x, pPos.y-maxBound.y, pPos.z+maxBound.z ) ) then
		return true 
	end
	if not util.IsInWorld( Vector( pPos.x+maxBound.x, pPos.y-maxBound.y, pPos.z+maxBound.z ) ) then
		return true 
	end
	
	for i=0.2, 0.8, 0.2 do
		if not util.IsInWorld( Vector( pPos.x, pPos.y, pPos.z+(maxBound.z+minBound.z)*i ) ) then
			return true 
		end
	end
	
	
	
	return false
end
local function CollisionBoxContainsProps( ent, minBound, maxBound )
	local pPos = ent:LocalToWorld(ent:OBBCenter())
	lowerBoxPos = Vector()
	lowerBoxPos:Set(pPos)
	lowerBoxPos:Add(minBound)
	upperBoxPos = Vector()
	upperBoxPos:Set(pPos)
	upperBoxPos:Add(maxBound)
	
	t = ents.FindInBox(lowerBoxPos, upperBoxPos)
	for key,value in pairs(t) do
		if value == ent then continue end
		if value:GetSolid() != SOLID_NONE then return true end
	end
	return false
end

function IsStuck(ply)
	local a,b = CollisionBoxOutsideMap(ply,ply:OBBMins(), ply:OBBMaxs()), CollisionBoxContainsProps(ply,ply:OBBMins(), ply:OBBMaxs())
	print( a, b)
	return a or b
end

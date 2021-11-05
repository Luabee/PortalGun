local STUN_STICK            = Material( "effects/stunstick" ); // draw.GetMaterial( "effects/stunstick" );
CONVERSION_UNITS_TO_INCHES  = 4 / 3;
CONVERSION_UNITS_TO_MPH     = CONVERSION_UNITS_TO_INCHES * 17.6;

local function StunStickEffect( _p, _e, _pos, _mat, _tab )
    local p = _e:Add( _mat, _pos )
    p:SetLifeTime(0)
    p:SetDieTime( math.Rand( 0.10, 0.25 ) )
    p:SetEndSize( 35 )
    p:SetStartSize( _tab.startsize )
    p:SetStartAlpha( _tab.alpha )
    p:SetEndAlpha( 0 )
    p:SetStartLength( 1 )
    p:SetEndLength( 0 )
    p:SetVelocity( Vector( 0, 0, 5 ) + ( VectorRand( ) * 15 ) )
    -- p:SetGravity( Vector( 0, 0, -100 ) )
end

hook.Add( "PostDrawViewModel", "AdminStick:StunStickFirstPerson", function( _vm, _p, _w )
    // If the player is in a vehicle, don't even bother
    if ( IsValid( _p:GetVehicle( ) ) ) then return; end

    // If they're not using the correct weapon, don't bother
    if ( _w:GetClass( ) != "swep_stunstick" || _w:GetClass( ) != "weapon_stunstick" ) then return; end

    // Spark 1b or so; worked well with current math so I left it.
    local _attachment = _vm:GetAttachment( 2 ); // _w:LookupAttachment( "Spark1b" ) -- Perfect, after seeing in 3rd person.
    if ( !_attachment ) then return; end

    // Declarations - sin to pulse in and out, yaw for rotation
    local _sin = math.abs( math.sin( CurTime( ) * 25 ) ) * 3; //math.sinwave( 25, 3, true )
    local _angs = _vm:GetAngles( );

    local _pos = _attachment.Pos + _attachment.Ang:Forward( ) * -2.25 + _attachment.Ang:Up( ) * -1.5 + _attachment.Ang:Right( ) * 0.6;
    local _e = ParticleEmitter( _pos );

    // Set the drawing material, render the two sprites; the smaller brighter one, the larger very transparent one and pulse based on sin
    render.SetMaterial( STUN_STICK );
    render.DrawSprite( _pos, 5 + _sin, 5 + _sin, Color( 255, 255, 255, 155 ) );
    render.DrawSprite( _pos, 20 + _sin, 20 + _sin, Color( 255, 255, 255, 10 ) );

    // If they're running / moving faster than 10mph, don't render the next set of effects because they look like hot metal shavings falling
    if ( _p:GetVelocity( ):Length( ) / CONVERSION_UNITS_TO_MPH > 10 ) then return; end

    // Update emitter position, and call the helper-functions for the effects.
    _e:SetPos( _pos );
    StunStickEffect( _p, _e, _pos, "effects/stunstick", { startsize = 10, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/physbeam", { startsize = 10, alpha = 235 } );
    StunStickEffect( _p, _e, _pos, "effects/tool_tracer", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "sprites/tp_beam001", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/electric", { startsize = 5, alpha = 75 } );
    _e:Finish( );
end );

hook.Add( "PostPlayerDraw", "AdminStick:StunStick", function( _p )
    // If the player is in a vehicle, don't even bother
    if ( IsValid( _p:GetVehicle( ) ) ) then return; end

    // If the weapon isn't valid, don't bother
    local _w = _p:GetActiveWeapon( );
    if ( !IsValid( _w ) ) then return; end

    // If they're not using the correct weapon, don't bother
    if ( _w:GetClass( ) != "swep_stunstick" || _w:GetClass( ) != "weapon_stunstick" ) then return; end

    local _muzzle = _w:LookupAttachment( "1" );
    local _attachment = _w:GetAttachment( _muzzle );
    local _pos = _attachment.Pos + _attachment.Ang:Forward( ) * 2.4;
    local _e = ParticleEmitter( _pos );

    // Declarations
    local _sin = math.abs( math.sin( CurTime( ) * 25 ) ) * 3; //math.sinwave( 25, 3, true )

    // Set the drawing material, render the two sprites; the smaller brighter one, the larger very transparent one and pulse based on sin
    render.SetMaterial( STUN_STICK );
    render.DrawSprite( _pos, 5 + _sin, 5 + _sin, Color( 255, 255, 255, 155 ) );
    render.DrawSprite( _pos, 20 + _sin, 20 + _sin, Color( 255, 255, 255, 10 ) );

    // If they're running / moving faster than 10mph, don't render the next set of effects because they look like hot metal shavings falling
    if ( _p:GetVelocity( ):Length( ) / CONVERSION_UNITS_TO_MPH > 10 ) then return; end
    
    // Update emitter position, and call the helper-functions for the effects.
    _e:SetPos( _pos );
    StunStickEffect( _p, _e, _pos, "effects/stunstick", { startsize = 10, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/physbeam", { startsize = 10, alpha = 235 } );
    StunStickEffect( _p, _e, _pos, "effects/tool_tracer", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "sprites/tp_beam001", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/electric", { startsize = 5, alpha = 75 } );
end );
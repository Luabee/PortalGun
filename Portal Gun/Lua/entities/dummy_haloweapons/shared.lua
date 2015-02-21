AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "GALIL MARK"
ENT.Author			= "Dr. Scandalous™"
ENT.Information		= "Standard Marksman Rifle"
ENT.Category		= "Half-Life: Containment"

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.PupTable		= {}
ENT.AmmoPerPLR		= 450
ENT.NextUseByPLR	= {}

local PickupSound	= Sound( "HL2Player.PickupWeapon" )
local DenySound		= Sound( "HL2Player.UseDeny" )

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 8
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

local Selfy = nil
function ENT:Initialize()
	Selfy = self
	if ( SERVER ) then
		self:SetUseType( 3 )
		self:SetModel( "models/weapons/w_rif_galil.mdl" )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:DrawHalo()
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
		--	phys:Wake()
			phys:EnableMotion( false )
		end
	end
end

function DrawHalo()
	local ent = "dummy_haloweapons"
	if !ENT then return end
	local Fluxor = math.tan(CurTime()*5)
	if Fluxor > 2 then Fluxor = 0 end
	local Flux = .5*Fluxor
	Flux = math.max(0.1, math.Clamp((Flux*.9)+.1, 0, 1))
	halo.Add( {ENT}, Color( 0, 0, 0, 255 ), 10, 10, 1, false, false )
	halo.Add( {ENT}, Color( 0, 255, 96, 255 ), 10*Flux, 10*Flux, 1, true, false )
end
hook.Add( "PreDrawHalos", "AddHalos", DrawHalo )

function PupPickup( ply, ent )
	if ent:GetClass():lower() == "con_pup_galil" then
		return false
	end
end
hook.Add( "PhysgunPickup", "AllowPhysgun", PupPickup )

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if !self.PupTable[ activator:UniqueID() ] then self.PupTable[ activator:UniqueID() ] = self.AmmoPerPLR end

		if !self.NextUseByPLR[ activator:UniqueID() ] then self.NextUseByPLR[ activator:UniqueID() ] = CurTime() end
		if CurTime() < self.NextUseByPLR[ activator:UniqueID() ] then return end
		self.NextUseByPLR[ activator:UniqueID() ] = CurTime() + 1

		if !activator:HasWeapon( "c01e5_galatz" ) then
			local Start = activator:GetAmmoCount( "ammo_primary" )
			local End
			local Addit = math.min( self.PupTable[ activator:UniqueID() ], math.random(0,30) )
			activator:Give( "c01e5_galatz" )
			activator:SelectWeapon( "c01e5_galatz" )
			activator:GiveAmmo( Addit, "ammo_primary", true )
			timer.Simple( 0.01, function() if IsValid( self ) && IsValid( activator ) then
							End = activator:GetAmmoCount( "ammo_primary" )
							self.PupTable[ activator:UniqueID() ] = self.PupTable[ activator:UniqueID() ] - (End - Start)
						end
					end )
			self:EmitSound( PickupSound )
		else
			if self.PupTable[ activator:UniqueID() ] <= 0 then self:EmitSound( DenySound ) return end
			local Start = activator:GetAmmoCount( "ammo_primary" )
			local End
			local Addit = math.min( self.PupTable[ activator:UniqueID() ], math.random(0,31) )
			activator:GiveAmmo( Addit, "ammo_primary", true )

			timer.Simple( 0.01, function() if IsValid( self ) && IsValid( activator ) then
							End = activator:GetAmmoCount( "ammo_primary" )
							self.PupTable[ activator:UniqueID() ] = self.PupTable[ activator:UniqueID() ] - (End - Start)
							if ( End - Start ) < Addit then self:EmitSound( DenySound ); return; end
						end
					end )
				self:EmitSound( PickupSound )

		end
	end
end
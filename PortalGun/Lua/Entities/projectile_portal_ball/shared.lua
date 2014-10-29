
AddCSLuaFile("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Portal Ball"
ENT.Author = "Mahalis"
ENT.Spawnable = false
ENT.AdminSpawnable = false

PrecacheParticleSystem("portal_1_projectile_ball")
PrecacheParticleSystem("portal_2_projectile_ball")
PrecacheParticleSystem("portal_1_projectile_stream")
PrecacheParticleSystem("portal_2_projectile_stream")
PrecacheParticleSystem("portal_1_projectile_trail")
PrecacheParticleSystem("portal_2_projectile_trail")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetModel("models/dav0r/hoverball.mdl")
	self.Entity:PhysicsInitSphere(1,"Metal")
	local phy = self.Entity:GetPhysicsObject()
	if phy:IsValid() then
		phy:EnableGravity(false)
		phy:EnableDrag(false)
	end
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.Entity:DrawShadow(false)
	
end

function ENT:SetEffects(type)
	self:SetNWInt("Kind", type)
	
	ParticleEffectAttach("portal_"..type.."_projectile_ball",PATTACH_ABSORIGIN_FOLLOW,self,1)
	ParticleEffectAttach("portal_"..type.."_projectile_stream",PATTACH_ABSORIGIN_FOLLOW,self,1)
	
end

function ENT:GetKind(kind)
	return self:GetNWInt("Kind", TYPE_BLUE)
end
function ENT:SetGun(ent)
	self.gun = ent
end
function ENT:GetGun()
	return self.gun
end

function ENT:PhysicsCollide(data,phy)
	self.Entity:Remove()
	-- print("Create Portal!")
end

-- local sprite = Material("sprites/light_glow02_add")
function ENT:Draw()
	-- local color = self:GetKind()==TYPE_BLUE and Color(160,176,255) or Color(255,128,64)
	-- render.SetMaterial(sprite)
	-- render.DrawSprite(self.Entity:GetPos(),40,40,color)
	-- self.Entity:DrawModel()
end

-- function ENT:Think()
	-- self:SetPos(self:GetPos()+self:GetVelocity()*FrameTime())
-- end
include("shared.lua")

local reticle = CreateClientConVar("portal_reticle","1",true,false)

/*---------------------------------------------------------
   Name: CalcViewModelView
   Desc: Overwrites the default GMod v_model system.
---------------------------------------------------------*/
function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)

	local pPlayer = self.Owner
	local Speed = pPlayer:GetVelocity():Length2D()
	local CT = CurTime()
	local FT = FrameTime()
	local BobCycleMultiplier = Speed / pPlayer:GetRunSpeed()

	BobCycleMultiplier = (BobCycleMultiplier > 1 and math.min(1 + ((BobCycleMultiplier - 1) * 0.2), 5) or BobCycleMultiplier)
	BobTime = BobTime + (CT - BobTimeLast) * (Speed > 0 and (Speed / pPlayer:GetWalkSpeed()) or 0)
	BobTimeLast = CT
	local BobCycleX = math.sin(BobTime * 0.5 % 1 * math.pi * 2) * BobCycleMultiplier
	local BobCycleY = math.sin(BobTime % 1 * math.pi * 2) * BobCycleMultiplier

	oldPos = oldPos + oldAng:Right() * (BobCycleX * 1.5)
	oldPos = oldPos
	oldPos = oldPos + oldAng:Up() * BobCycleY/2

	SwayAng = oldAng - SwayOldAng
	if math.abs(oldAng.y - SwayOldAng.y) > 180 then
		SwayAng.y = (360 - math.abs(oldAng.y - SwayOldAng.y)) * math.abs(oldAng.y - SwayOldAng.y) / (SwayOldAng.y - oldAng.y)
	else
		SwayAng.y = oldAng.y - SwayOldAng.y
	end
	SwayOldAng.p = oldAng.p
	SwayOldAng.y = oldAng.y
	SwayAng.p = math.Clamp(SwayAng.p, -3, 3)
	SwayAng.y = math.Clamp(SwayAng.y, -3, 3)
	SwayDelta = LerpAngle(math.Clamp(FrameTime() * 5, 0, 1), SwayDelta, SwayAng)
	
	return oldPos + oldAng:Up() * SwayDelta.p + oldAng:Right() * SwayDelta.y + oldAng:Up() * oldAng.p / 90 * 2, oldAng
end

surface.CreateFont( "xhair", {
	font = "HL2Cross", 
	size = 40, 
	weight = 400, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )
local cBlu = Color(80,144,255,255)
local cOrg = Color(255,200,80,255)
function Overlay()
	if !LocalPlayer() || !LocalPlayer():Alive() || !LocalPlayer():GetActiveWeapon() || !(LocalPlayer():GetActiveWeapon():IsValid()) then return end
	if LocalPlayer():GetActiveWeapon():GetClass() != "weapon_portalgun" then return end
	if !reticle:GetBool() then return end

	local w = ScrW()
	local h = ScrH()
	local cX = w / 2
	local cY = h / 2
	local trd = {}
		trd.start = LocalPlayer():GetShootPos()
		trd.endpos = trd.start + LocalPlayer():GetAimVector() * 4000
		trd.mask = MASK_SOLID_BRUSHONLY
	local trc = util.TraceLine(trd)
	
	local cRit = (LocalPlayer():GetActiveWeapon():GetNetworkedBool("OnlyBlue") and cBlu or cOrg)
	
	local validMat = (trc.MatType == 67 || trc.MatType == 68)
	local validBlu = true
	local validRed = true
	local hEnt = LocalPlayer():GetEyeTrace().Entity
	if hEnt != nil && hEnt:IsValid() && hEnt:GetClass() == "prop_portal" then
		if hEnt:GetNetworkedBool("blue") then
			validRed = false
		else
			validBlu = false
		end
	end
	local bBrack = (validMat && validBlu) and "[" or "{"
	local rBrack = (validMat && validRed) and "]" or "}"
	draw.SimpleText(bBrack,"xhair",cX-18,cY,cBlu,2,1)
	draw.SimpleText(rBrack,"xhair",cX+17,cY,cRit,0,1)
		
	local lastPort = LocalPlayer():GetActiveWeapon():GetNetworkedInt("LastPortal")
	
	bBrack = (lastPort == TYPE_BLUE) and "[" or "{"
	rBrack = (lastPort == TYPE_ORANGE) and "]" or "}"
	draw.SimpleText(bBrack,"xhair",cX-25,cY,cBlu,2,1)
	draw.SimpleText(rBrack,"xhair",cX+24,cY,cRit,0,1)
end

	
hook.Add("HUDPaint","DoPortalOverlays",Overlay)
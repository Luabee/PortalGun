ENT.Type = "point"
ENT.Base = "base_point"

ENT.fxd = ""

function ENT:Initialize()
	--print("info_hpd_controller initialized")
end

function ENT:KeyValue(key,value)
	if key == "LockPortal" then
		self.fxd = value
	end
end

function ENT:AcceptInput(inp,acti,call)
	if inp == "Lock" then
		local toFix = nil
		for _,p in pairs(ents.FindByName(self.fxd)) do
			toFix = p
			break
		end
		if toFix != nil && toFix:IsValid() then
			toFix.fixed = true
			for _,pg in pairs(ents.FindByClass("weapon_portalgun")) do
				pg.portalR = toFix
				pg:SetNetworkedBool("OnlyBlue",true)
				pg:SetNetworkedInt("LastPortal",2,true)
			end
		end
	elseif inp == "Unlock" then
		for _,pg in pairs(ents.FindByClass("weapon_portalgun")) do
			pg:Clear(true)
		end
	end
end
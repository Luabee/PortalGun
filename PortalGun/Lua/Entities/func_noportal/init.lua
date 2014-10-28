ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:PassesTriggerFilters(ent)
	return (ent:IsPlayer() || ent:GetClass() == "portalball")
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		for _,w in pairs(ents.FindByClass("portalgun")) do
			if w.Owner == ent then
				w:Clear(true)
				w:Lock(true)
				w:CheckExisting()
			end
		end
	else
		if ent:GetClass() == "portalball" then ent:Remove() end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		for _,w in pairs(ents.FindByClass("portalgun")) do
			if w.Owner == ent then
				w:Lock(false)
				w:CheckExisting()
			end
		end
	end
end
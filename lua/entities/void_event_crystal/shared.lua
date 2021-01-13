ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.IsVoidEventVoidCrystal = true

function ENT:SharedInit()
	self:SetColor(Color(0, 0, 0, 1))
	self:DrawShadow(false) --it literally glows, so no shadow
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
end

hook.Add("PhysgunPickup", "the_abx_void_event_cystals", function(ply, entity) if entity.IsVoidEventVoidCrystal then return false end end)
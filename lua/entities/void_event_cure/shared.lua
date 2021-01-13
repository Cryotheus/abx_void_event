ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Charge = 200

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Charge")
	
	if CLIENT then self:NetworkVarNotify("Charge", function(name, old, new) self.Text = new .. " / 200" end) end
end

function ENT:SharedInit() self:SetCharge(200) end
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Charge = 200

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Charge")
	self:SetCharge(200)
	
	if CLIENT then
		self:NetworkVarNotify("Charge", function(name, old, new)
			if new > 0 then self.Text = new .. " / 200"
			else self.Text = "200 / 200" end
		end)
	end
end

function ENT:SharedInit() end
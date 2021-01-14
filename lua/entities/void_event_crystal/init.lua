AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

resource.AddFile("models/abx/void_event/void_event_crystal_1.mdl")
resource.AddFile("models/abx/void_event/void_event_crystal_2.mdl")
resource.AddFile("models/abx/void_event/void_event_crystal_3.mdl")

--I don't know why, but my friend (silly goose#0210) thought he could make the crystals have no material by doing this
--frickin weirdo, but thanks
resource.AddSingleFile("materials/models/void_event_crystal_1/no_material.vmt")
resource.AddSingleFile("materials/models/void_event_crystal_2/no_material.vmt")
resource.AddSingleFile("materials/models/void_event_crystal_3/no_material.vmt")

local function calculate_new_health(health) return math.min(health - 5, health * 0.95) end

function ENT:Initialize()
	local model = "models/abx/void_event/void_event_crystal_" .. math.random(1, 3) .. ".mdl"
	
	self:SetModel(model)
	self:SharedInit()
	
	self:PhysicsInit(SOLID_VPHYSICS)
	
	local physics = self:GetPhysicsObject()
	
	physics:EnableMotion(false)
	physics:SetMass(5000) --not that we will move these, but whatever
end

--fuck decals
function ENT:OnTakeDamage(damage_info)
	--the frame after, remove the decals, again, because they are weird
	self:RemoveAllDecals()
	
	timer.Simple(0, function() if IsValid(self) then self:RemoveAllDecals() end end)
end

function ENT:Touch(entity)
	if IsValid(entity) then
		if entity:IsPlayer() then
			if entity:Alive() then
				local health = entity:Health()
				local max_health = entity:GetMaxHealth()
				
				if health > 5 and max_health > 5 then
					entity:SetArmor(0)
					entity:SetHealth(calculate_new_health(health))
					entity:SetMaxArmor(0)
					entity:SetMaxHealth(calculate_new_health(max_health))
				else entity:Kill() end
			end
		else
			
		end
	end
end
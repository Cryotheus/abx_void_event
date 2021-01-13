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

function ENT:Initialize()
	local model = "models/abx/void_event/void_event_crystal_" .. math.random(1, 3) .. ".mdl"
	
	self:SetModel(model)
	self:SharedInit()
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():SetMass(5000) --not that we will move these, but whatever
end
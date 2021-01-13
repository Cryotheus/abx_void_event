AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
resource.AddFile("materials/models/abx/void_event/cure.vmt")

function ENT:Initialize()
	self:SetMaterial("models/abx/void_event/cure.vmt")
	self:SetModel("models/props_lab/jar01a.mdl")
	self:SetUseType(CONTINUOUS_USE)
	self:SharedInit()
	
	--we want it to have collisions
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():SetMass(10)
	self:PhysWake()
end

function ENT:ReduceCharge(request)
	local charge = self:GetCharge() - request
	
	if charge <= 0 then
		--do stuff
		
		self:Remove()
	else self:SetCharge(charge) end
	
	return math.Clamp(request, 0, charge)
end

function ENT:Use(ply, caller)
	if IsValid(ply) and ply:IsPlayer() and (not caller or caller == ply) then
		local max_armor = ply:GetMaxArmor()
		local max_health = ply:GetMaxHealth()
		
		if max_health < 100 then
			local missing_max_health = 100 - max_health
			local max_health_heal = self:ReduceCharge(math.min(missing_max_health, 3))
			local new_max_health = max_health + max_health_heal
			
			print("DRUGS!\nmissing: " .. missing_max_health .. "\nwe will heal: " .. max_health_heal .. "\nnew max health" .. new_max_health .. "\n")
			
			ply:SetHealth(math.max(ply:Health(), new_max_health))
			ply:SetMaxHealth(new_max_health)
		end
		
		if max_armor < 100 then
			local missing_max_armor = 100 - max_armor
			local max_armor_heal =self:ReduceCharge(math.min(missing_max_armor, 1))
			local new_max_armor = max_armor + max_armor_heal
			
			--we won't give them armor lol, only max armor
			--ply:SetArmor(math.max(ply:Armor(), new_max_armor))
			ply:SetMaxArmor(new_max_armor)
		end
	else print(ply, caller) end
end
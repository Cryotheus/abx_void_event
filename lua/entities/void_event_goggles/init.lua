AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
resource.AddFile("materials/models/abx/void_event/cure.vmt")

--create a function on the player type that lets us know if they can see in the void
AccessorFunc(FindMetaTable("Player"), "ABXVoidEventGoggles", "ABXVoidEventGoggles", FORCE_BOOL)

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box004a.mdl")
	self:SetUseType(SIMPLE_USE)
	
	--[[ this model does not normally have collisions
	self:SetModel("models/props_lab/labpart.mdl")
	self:PhysicsInitBox(Vector(-4, -8, -4), Vector(4, 8, 4))
	--]]
	
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:GetPhysicsObject():SetMass(6) --some real lore here, because the box has goggles it's a little heavier than a normal box :)
	self:PhysWake()
end

function ENT:Use(ply, caller)
	--we want the player, and the player only to use the entity; mediums are not allowed
	if IsValid(ply) and ply:IsPlayer() and (not caller or caller == ply) then
		if ply:GetABXVoidEventGoggles() then ply:PrintMessage(HUD_PRINTTALK, "You already have void goggles.")
		else
			ply:SetABXVoidEventGoggles(true)
			
			self:Remove()
		end
	end
end
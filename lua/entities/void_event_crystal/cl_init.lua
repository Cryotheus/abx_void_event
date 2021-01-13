include("shared.lua")

ENT.Author = "Cryotheum#4096"
ENT.Category = "Void Event"
ENT.PrintName = "Void Crystal"
ENT.Purpose = "Spawns in the world consuming void, meant to be what destroys a void."

local overlay = Material("trails/electric")
local scr_h
local scr_h_triple
local scr_h_half
local scr_w
local scr_w_triple
local scr_w_half
local scale_scroll
local size = 256
local texture_scale_u
local texture_scale_v
local vector_one = Vector(1, 1, 1)

local function calc_vars(input_scr_w, input_scr_h)
	--we cache the values so we don't calculate them every frame
	scr_w, scr_h = input_scr_w, input_scr_h
	scr_w_triple, scr_h_triple = scr_w * 3, scr_h * 3
	scr_w_half, scr_h_half = scr_w * 0.5, scr_h * 0.5
	
	scale_scroll = math.min(scr_w, scr_h) * 0.003
	texture_scale_u = scr_w / size
	texture_scale_v = scr_h / size
end

--TODO: localize frequently used functions
function ENT:DrawTranslucent(flags)
	--don't render halos! we are already using stencils, so we don't want to interrupt their stencils
	if halo.RenderedEntity() == self then return end
	
	--calculate some values we will need
	local mat = Matrix()
	local real_time = RealTime() + self.OverlayOffsetTime
	local scroll = real_time * scale_scroll % size
	
	--scale and rotate the matrix
	mat:Translate(Vector(scr_w_half, scr_h_half))
	mat:Rotate(Angle(0, math.sin(real_time * 4) * 30 + self.OverlayOffsetAngle, 0))
	mat:Scale(vector_one * (math.sin(real_time * 12) * 0.2 + 1))
	mat:Translate(Vector(-scr_w_half, -scr_h_half))
	
	--set up stencil settings
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilEnable(true)
	render.SetStencilTestMask(0xFF)
	render.SetStencilWriteMask(0xFF)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilReferenceValue(1)
	render.ClearStencil()
	render.SetColorMaterial()
	
	--set our reference value in the stencil buffer where the model is
	self:DrawModel()
	
	--now, only set the compare function to equal to we only render where the stencil value is equal to the reference value
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	
	--draw a 2d graphic of purple and pulsing lasers
	cam.Start2D()
		surface.SetDrawColor(255, 0, 255, 128)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		
		--rotate and scale the texture
		cam.PushModelMatrix(mat)
			surface.SetDrawColor(224, 0, 192, 255)
			surface.SetMaterial(overlay)
			surface.DrawTexturedRectUV(-scr_w, -scr_h, scr_w_triple, scr_h_triple, scroll, scroll, texture_scale_u + scroll, texture_scale_v + scroll)
		cam.PopModelMatrix()
	cam.End2D()
	
	render.SetStencilEnable(false)
end

function ENT:ImpactTrace(trace, damage_type, impact_name) 
	--thank you my battle buddy PFC oneil! he let me know of the existence of this function
	--he tried to write "im gay" in my script, but ended up pressing tab and wrote "ImpactTrace gay"
	
	--do something special
	print(trace.HitPos)
	
	return true
end

function ENT:Initialize()
	--make the crystals a little more unique
	self.OverlayOffsetAngle = math.Rand(0, 360)
	self.OverlayOffsetTime = math.Rand(0, 0.25)
	
	self:SharedInit()
end

calc_vars(ScrW(), ScrH())
hook.Add("OnScreenSizeChanged", "the_abx_void_event_cystals", function() calc_vars(ScrW(), ScrH()) end)
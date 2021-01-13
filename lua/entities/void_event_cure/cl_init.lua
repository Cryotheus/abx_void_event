include("shared.lua")
surface.CreateFont("ABXVoidEventCure", {
	font = "Roboto",
	size = 64,
	weight = 500,
	antialias = true
})

ENT.Category = "Void Event"
ENT.PrintName = "Autobox™ Void Cure"
ENT.Text = "200 / 200"

function ENT:Initialize()
	--nice legs daisy dukes
	self:SharedInit()
end

--TODO: localize frequently used functions
function ENT:Draw(flags) self:DrawModel() end

function ENT:DrawTranslucent(flags)
	local start_pos = self:LocalToWorld(Vector(0, 0, 12))
	local target_pos = GetViewEntity():EyePos()
	local angle = (start_pos - target_pos):GetNormalized():Angle()
	
	angle:RotateAroundAxis(angle:Up(), -90)
	angle:RotateAroundAxis(angle:Forward(), 90)
	
	cam.Start3D2D(start_pos, angle, 0.05)
		draw.SimpleTextOutlined(self.Text, "ABXVoidEventCure", 0, 0, Color(237, 219, 189), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(66, 51, 48))
	cam.End3D2D()
end
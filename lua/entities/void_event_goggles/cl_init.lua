include("shared.lua")

ENT.Category = "Void Event"
ENT.PrintName = "Boggle's Goggles™"

ABXVoidEventGoggles = false

--TODO: localize frequently used functions
function ENT:Draw(flags) self:DrawModel() end

function ENT:DrawTranslucent(flags)
	local start_pos = self:LocalToWorld(Vector(0, 0, 7))
	local target_pos = GetViewEntity():EyePos()
	local angle = (start_pos - target_pos):GetNormalized():Angle()
	
	angle:RotateAroundAxis(angle:Up(), -90)
	angle:RotateAroundAxis(angle:Forward(), 90)
	
	cam.Start3D2D(start_pos, angle, 0.05)
		draw.SimpleTextOutlined(self.PrintName, "ABXVoidEventCure", 0, 0, Color(237, 219, 189), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(66, 51, 48))
	cam.End3D2D()
end
AddCSLuaFile("autorun/client/the_abx_void_event.lua")
resource.AddSingleFile("materials/entities/void_event_crystal.png")
resource.AddSingleFile("materials/entities/void_event_cure.png")
util.AddNetworkString("the_abx_void_event")

print("reloaded successfuly")

local good_void_starts = {
	gm_bigcity = {
		Vector(-9110, -4660, -11000), --rusty trombone
		Vector(-1380, 4860, -10280), --square donut building
		Vector(-8100, 4890, -10780), --yellow building with small outdoors hallway between green and white square regions
		Vector(1050, -8600, -120), --twin tower with pole, corner facing spawn a little down from the top
		Vector(-420, -4700, -10760), --alley where the popular spawn sniper spot is, the one with the occluder window
		Vector(10450, -8430, -11070) --alley with the graffit "BIG" near enterable yellow warehouse
	}
}

local good_void_starts_map = table.Copy(good_void_starts[game.GetMap()] or {})
local next_void_check = 0
local void_active = false --SetActiveTab
local void_regions = {}

local void_sents = {
	void_event_crystal = true,
	void_event_cure = true,
	void_event_goggles = true,
}

--local functions
local function sync(ply)
	net.Start("the_abx_void_event")
	net.WriteTable(void_regions)
	
	if ply then net.Send(ply) else net.Broadcast() end
end

local function void_disable()
	void_active = false
	
	hook.Remove("PlayerDeath", "the_abx_void_event")
	hook.Remove("Think", "the_abx_void_event")
end

local function void_enable()
	void_active = false
	
	hook.Add("Think", "the_abx_void_event", function()
		local cur_time = CurTime()
		
		if cur_time > next_void_check then
			next_void_check = cur_time + 0.5
			
			local victims = {}
			
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() then
					for index, void_data in ipairs(void_regions) do
						local void_distance = math.max(cur_time - void_data.start, 0) * void_data.speed
						
						if ply:GetPos():Distance(void_data.center) < void_distance then victims[ply] = true end
					end
				end
			end
			
			for ply in pairs(victims) do
				local armor = ply:Armor()
				
				if ply.AAT_GetBadgeProgress and ply:AAT_GetBadgeProgress("void_exploration") < 1 then ply:AAT_AddBadgeProgress("void_exploration", 1) end
				
				if armor > 0 then --if they have armor, take 2.5% or 1 armor every 0.5 seconds
					local armor_damage = math.max(armor * 0.025, 1)
					local new_armor = math.max(armor - armor_damage, 0)
					
					ply:SetArmor(new_armor)
					ply:SetMaxArmor(math.min(new_armor, ply:GetMaxArmor()))
				else --if they don't, take 10% of their health or 2 health every 0.5 seconds
					local health = ply:Health()
					local void_damage = math.max(health * 0.1, 2)
					
					--you can't heal void damage
					if void_damage >= health then ply:Kill()
					else
						local new_health = health - void_damage
						
						ply:SetHealth(new_health)
						ply:SetMaxArmor(0) --ya shoulda used armor, ya shoulda had gear, ya shoulda just stayed out of that thing really
						ply:SetMaxHealth(math.min(new_health, ply:GetMaxHealth()))
					end
				end
			end
		end
	end)
end

local function void_enable_safe() if table.IsEmpty(void_regions) then void_enable() end end

--concommand
concommand.Add("abx_void_add", function(ply, command, arguments, arguments_String)
	if IsValid(ply) and ply:IsSuperAdmin() then
		local speed = math.max(tonumber(arguments[1]) or 5, 0)
		local start_size = math.max(tonumber(arguments[2]) or 0, 0)
		
		void_enable_safe()
		
		table.insert(void_regions, {
			center = ply:GetEyeTraceNoCursor().HitPos,
			speed = speed,
			sphere = true,
			start = CurTime() - start_size / speed
		})
		
		sync()
	end
end, nil, "Start a void at the player's aim position.")

concommand.Add("abx_void_apocalypse", function(ply, command, arguments, arguments_String)
	if not IsValid(ply) or ply:IsSuperAdmin() then
		void_enable_safe()
		
		ply:PrintMessage(HUD_PRINTCONSOLE, "Starting the void apocalypse.")
		
		for index, position in ipairs(good_void_starts_map) do
			table.insert(void_regions, {
				center = position,
				speed = 5,
				sphere = true,
				start = CurTime()
			})
		end
		
		good_void_starts_map = {}
		
		sync()
	end
end, nil, "Start a void at every possible predefined spot on the map.")

concommand.Add("abx_void_clear", function(ply, command, arguments, arguments_String)
	if not IsValid(ply) or ply:IsSuperAdmin() then
		good_void_starts_map = table.Copy(good_void_starts[game.GetMap()])
		void_regions = {}
		
		sync()
		void_disable()
	end
end, nil, "Clear all active voids.")

concommand.Add("abx_void_start", function(ply, command, arguments, arguments_String)
	if not IsValid(ply) or ply:IsSuperAdmin() then
		if table.IsEmpty(good_void_starts_map) then ply:PrintMessage(HUD_PRINTCONSOLE, "There are no more points in the predefined list.")
		else
			local position = table.remove(good_void_starts_map, math.random(#good_void_starts_map))
			
			void_enable_safe()
			
			table.insert(void_regions, {
				center = position,
				speed = 5,
				sphere = true,
				start = CurTime()
			})
			
			ply:PrintMessage(HUD_PRINTCONSOLE, "Started a void at " .. tostring(position) .. ".")
			
			sync()
		end
	end
end, nil, "Start a void event from a random point in a predefined list.")

--hooks
hook.Add("PlayerDeath", "the_abx_void_event", function(victim, inflictor, attacker) victim:SetMaxArmor(100) end)

hook.Add("PlayerSpawnSENT", "the_abx_void_event", function(ply, class)
	if void_sents[class] then
		if void_active then
			--do something, like tax them
			
		elseif not ply:IsSuperAdmin() then return false end --only super admins can spawn this crap when there isn't an active void event
	end
end)

--net
net.Receive("the_abx_void_event", function(length, ply) sync(ply) end)

--reload
sync()
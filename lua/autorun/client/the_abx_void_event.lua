--local variables
local circle = {}
local color_mod_key = "$pp_colour_colour"
local cur_time = CurTime()
local entity_content_panel_tree
local entity_content_panel_void_node
local entity_content_panel_void_node_sizes = {}
local fog_percent
local goggles = false
local local_ply = LocalPlayer()
local in_void = false
local in_warn = false
local spawn_menu_tree
local void_ambience
--local void_enter_time = 0
local spawn_menu_node
local void_active = false
local void_hooks = {"InitPostEntity", "PreDrawSkyBox", "PreDrawTranslucentRenderables", "RenderScreenspaceEffects", "SetupWorldFog", "Think"}
--local void_leave_time = 0
local void_regions = {}
local void_sound
local warn_distance = 1000
local warn_percent = 0
local warn_percent_inverse = 1

--tables
local color_mod = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

--PlayerSpawnSENT
--local functions
local function calc_size(cur_time, start, speed) return math.max(cur_time - start, 0) * speed end

local function calc_vars(scr_w, scr_h)
	circle = {{x = scr_w * 0.5, y = scr_h * 0.5}}
	local radius = math.min(scr_w, scr_h) * 0.5 * 0.9
	local vertices = 40
	
	for index = 0, vertices do
		local angle = index * 2 * math.pi / vertices
		
		table.insert(circle, {x = math.cos(angle) * radius + scr_w * 0.5, y = math.sin(angle) * radius + scr_h * 0.5})
	end
end

local function draw_sphere(void_pos, radius) render.DrawSphere(void_pos, radius, 60, 60, Color(0, 0, 0, 0)) end

local function draw_void(mult)
	for index, void_data in ipairs(void_regions) do
		--I intended to allow more than just spheres but what ever
		draw_sphere(void_data.center, mult * calc_size(cur_time, void_data.start, void_data.speed))
	end
end

local function update_spawn_menu(state)
	--the node in the entities spawn menu, we only want to show it when a void is active
	if IsValid(entity_content_panel_void_node) then
		print("state of update", state)
		
		entity_content_panel_void_node:SetSize(unpack(state and entity_content_panel_void_node_sizes or {0, 0}))
		entity_content_panel_void_node:SetVisible(state)
		
		entity_content_panel_tree:Root():PerformLayout()
	end
end

local function void_enable()
	--stupidity!
	--set up color modify
	void_active = true
	void_ambience = CreateSound(local_ply, "ambient/atmosphere/ambience5.wav")
	void_sound = CreateSound(local_ply, "ambient/atmosphere/city_beacon_loop1.wav")
	
	--functions!
	
	update_spawn_menu(true)
	
	--hooks!
	--stop skybox rendering when we are in a void
	hook.Add("PreDrawSkyBox", "the_abx_void_event", function() if in_void then return true end end)
	
	--render void stencils
	hook.Add("PreDrawTranslucentRenderables", "the_abx_void_event", function(depth, sky_box)
		if sky_box then return end
		
		cur_time = CurTime()
		
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilEnable(true)
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilReferenceValue(1)
		render.ClearStencil()
		render.SetColorMaterial()
		
		render.SetStencilZFailOperation(STENCILOPERATION_INCR)
		
		draw_void(-1)
		
		render.SetStencilZFailOperation(STENCILOPERATION_DECR)
		
		draw_void(1)
		
		render.SetStencilPassOperation(STENCIL_ZERO)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		
		if goggles and in_void then
			cam.Start2D()
				local scale = 80
				local scr_w, scr_h = ScrW() - scale, ScrH() - scale
				
				surface.SetDrawColor(192, 16, 32, 128)
				surface.DrawPoly(circle)
			cam.End2D()
		end
		
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_LESSEQUAL)
		render.ClearBuffersObeyStencil(0, 0, 0, 255, false)
		
		--[[
		cam.Start2D()
			surface.SetDrawColor(192, 16, 32, 128)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()
		--]]
		
		render.SetStencilEnable(false)
	end)
	
	hook.Add("RenderScreenspaceEffects", "the_abx_void_event", function()
		if in_warn then
			--we want a quadratic increase, and a really sharp slope when we are close to the void
			color_mod[color_mod_key] = warn_percent_inverse
			local sharpen_contrast = warn_percent ^ 100 + (warn_percent ^ 2) * 0.02
			
			DrawColorModify(color_mod)
			DrawSharpen(100 * sharpen_contrast * math.Rand(0.6, 1.3), math.Rand(3, 5) * warn_percent)
		end
	end)
	
	hook.Add("SetupWorldFog", "the_abx_void_event", function()
		if in_warn then
			render.FogColor(0, 0, 0)
			render.FogEnd(26000 - 25500 * warn_percent)
			render.FogMaxDensity(math.min(warn_percent ^ 0.5, 1))
			render.FogMode(MATERIAL_FOG_LINEAR)
			render.FogStart(2000 - 1900 * warn_percent)
			
			return true
		end
	end)
	
	hook.Add("Think", "the_abx_void_event", function()
		--get the previous values so we can detect change
		local was_in_void = in_void
		local was_warned = warn_percent > 0
		
		local eye_pos = local_ply:GetViewEntity():EyePos()
		in_void = false
		local void_warn_shortest_distance = 113512
		
		--loop over all voids, sorry cpu ;-;
		for index, void_data in ipairs(void_regions) do
			local size = calc_size(cur_time, void_data.start, void_data.speed)
			local void_distance = eye_pos:Distance(void_data.center)
			local void_warn_distance = void_distance - size
			void_warn_shortest_distance = math.min(void_warn_shortest_distance, void_warn_distance)
			
			if void_distance < size then in_void = true end
		end
		
		--calculate the warn percentage and perform the gfx
		if math.max(void_warn_shortest_distance, 0) < warn_distance then
			in_warn = true
			warn_percent_inverse = math.Clamp(void_warn_shortest_distance / warn_distance, 0, 1)
			warn_percent = 1 - warn_percent_inverse
			
			util.ScreenShake(eye_pos, warn_percent ^ 2 * 3, 5, 0.2, 5)
			
			void_ambience:ChangeVolume(warn_percent)
		else
			in_warn = false
			warn_percent_inverse = 1
			warn_percent = 0
		end
		
		--enter and leaving void
		if was_in_void ~= in_void then
			if was_in_void then
				--they left the void
				void_leave_time = RealTime()
				
				void_sound:ChangeVolume(0, 3)
			else
				--they entered the void
				void_enter_time = RealTime()
				
				void_sound:ChangeVolume(1, 3)
			end
		end
		
		--enter and leaving warn zone
		if was_warned ~= in_warn then
			if was_warned then
				void_ambience:Stop()
				void_sound:Stop()
			else
				void_ambience:PlayEx(0, 100)
				void_sound:PlayEx(0, 100)
				void_sound:SetDSP(10)
			end
		end
	end)
end

local function void_disable()
	void_active = false
	
	if void_ambience then void_ambience:Stop() end
	if void_sound then void_sound:Stop() end
	
	update_spawn_menu(false)
	
	for index, hook_event in ipairs(void_hooks) do hook.Remove(hook_event, "the_abx_void_event") end
end

--hooks
hook.Add("InitPostEntity", "the_abx_void_event", function()
	local_ply = LocalPlayer()
	
	net.Start("the_abx_void_event")
	net.SendToServer()
end)

hook.Add("SpawnMenuOpen", "the_abx_void_event", function()
	local create_menu = g_SpawnMenu.CreateMenu
	local create_menu_sheets = create_menu:GetItems()
	local create_menu_entity_tab
	local create_menu_weapon_tab
	local first_time = false
	
	for index, sheet_data in pairs(create_menu_sheets) do
		if sheet_data.Name == "#spawnmenu.category.entities" then create_menu_entity_tab = sheet_data.Panel
		elseif sheet_data.Name == "#spawnmenu.category.weapons" then create_menu_weapon_tab = sheet_data.Panel end
	end
	
	--BRUUUUUUH THIS IS SO DEEP WTF
	--create_menu_sheets.entity:GetChild(0).ContentNavBar.Tree:Root()
	local entity_content_panel = create_menu_entity_tab:GetChild(0)
	local entity_content_panel_navigator = entity_content_panel.ContentNavBar
	entity_content_panel_tree = entity_content_panel_navigator.Tree
	local entity_content_panel_tree_root = entity_content_panel_tree:Root()
	local entity_content_panel_tree_root_children = entity_content_panel_tree_root:GetChildNodes()
	
	for index, node in pairs(entity_content_panel_tree_root_children) do
		if node:GetText() == "Void Event" then
			if not entity_content_panel_void_node then
				entity_content_panel_void_node = node
				entity_content_panel_void_node_sizes = {node:GetSize()}
				first_time = true
				
				print("It's out first time finding the node, so do magic things")
				
				node:SetIcon("autobox/scoreboard/badges/void_event/event.png")
				node:SetName("ABXVoidEventEntitiesNode")
				node:SetSize(unpack(void_active and entity_content_panel_void_node_sizes or {0, 0}))
				node:SetVisible(void_active)
				node:PerformLayout()
			end
		end
	end
	
	print("are we new:", first_time)
	
	--[[print("\n1. create_menu", create_menu)
	print(" 2. create_menu_entity_tab", create_menu_entity_tab)
	print("  3. create_menu_weapon_tab", create_menu_weapon_tab)
	print("   4. entity_content_panel", entity_content_panel)
	print("    5. entity_content_panel.HorizontalDivider", entity_content_panel.HorizontalDivider, "our test variable: " .. tostring(entity_content_panel.HorizontalDivider.ABXTest))
	print("    6. entity_content_panel_navigator", entity_content_panel_navigator)
	print("     7. entity_content_panel_tree", entity_content_panel_tree)
	print("      8. entity_content_panel_tree_root", entity_content_panel_tree_root)
	PrintTable(entity_content_panel_tree_root:GetChildNodes(), 1)]]
end)

--net
net.Receive("the_abx_void_event", function()
	local void_inactive = table.IsEmpty(void_regions)
	void_regions = net.ReadTable()
	
	if void_inactive ~= table.IsEmpty(void_regions) then (void_inactive and void_enable or void_disable)() end
end)

--reload
calc_vars(ScrW(), ScrH())
hook.GetTable().InitPostEntity.the_abx_void_event()

surface.CreateFont("ABXVoidEventEntity", {
	font = "Roboto",
	size = 64,
	weight = 500,
	antialias = true
})
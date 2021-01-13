autobox.badge:RegisterBadge("void_crystals", "Void Crystal Miner", "", 1, "autobox/scoreboard/badges/void_event/crystal_dark.png", true, function(ply)
	local badge_stages = {
		[0] = {
			Goal = 10,
			Desc = "Mine a void crystal found in the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/crystal_dark.png",
			Name = "Void Crystal Miner",
			ProgName = "mine a void crystal",
			Has = false,
			HasMax = false
		},
		[10] = {
			Goal = 50,
			Desc = "Mine 10 void crystals found in the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/crystal_dark.png",
			Name = "Void Crystal Collector",
			ProgName = "mine 10 void crystals",
			Has = true,
			HasMax = false
		},
		[50] = {
			Goal = 100,
			Desc = "Mine 50 void crystals found in the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/crystal.png",
			Name = "Void Crystal Collector",
			ProgName = "mine 10 void crystals",
			Has = true,
			HasMax = false
		},
		[100] = {
			Goal = 100,
			Desc = "Mine 100 void crystals found in the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/crystal_shiny.png",
			Name = "Void Crystal Enthusiast",
			ProgName = "mine 100 void crystals",
			Has = true,
			HasMax = true
		},
	}
	
	--tell them autobox.badge:ShowNotice(ply, "void_crystals")
	
	local badge_values = {10, 50, 100}
	local progress = ply:AAT_GetBadgeProgress("void_crystals")
	local progress_stage = 0
	
	for index, stage in ipairs(badge_values) do
		if progress >= stage then progress_stage = stage
		else break end
	end
	
	local badge = badge_stages[progress_stage]
	
	badge.GetVals = table.Copy(badge_values)
	
	if CLIENT then badge.Icon = Material(badge.Icon) end
	
	return badge
end)

resource.AddFile("materials/autobox/scoreboard/badges/void_event/crystal.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/crystal_dark.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/crystal_shiny.png")
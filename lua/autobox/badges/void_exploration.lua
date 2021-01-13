autobox.badge:RegisterBadge("void_exploration", "Void Victim", "", 1, "autobox/scoreboard/badges/void_event/event.png", true, function(ply)
	local badge_stages = {
		[0] = {
			Goal = 1,
			Desc = "Enter the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/event.png",
			Name = "Void Victim",
			ProgName = "enter the void",
			Has = false,
			HasMax = false
		},
		{
			Goal = 2,
			Desc = "Enter the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/event.png",
			Name = "Void Victim",
			ProgName = "enter the void",
			Has = true,
			HasMax = false
		},
		{
			Goal = 3,
			Desc = "Explore the world consuming void with the proper equipment",
			Icon = "autobox/scoreboard/badges/void_event/explorer.png",
			Name = "Void Explorer",
			ProgName = "explore the void",
			Has = true,
			HasMax = false
		},
		{
			Goal = 4,
			Desc = "Find a void crystal in the world consuming void",
			Icon = "autobox/scoreboard/badges/void_event/crystal_found.png",
			Name = "Void Explorer",
			ProgName = "find void crystals",
			Has = true,
			HasMax = true
		},
	}
	
	local badge = badge_stages[ply:AAT_GetBadgeProgress("void_exploration")]
	
	badge.GetVals = {1, 2, 3, 4}
	
	if CLIENT then badge.Icon = Material(badge.Icon) end
	
	return badge
end)

resource.AddFile("materials/autobox/scoreboard/badges/void_event/crystal_found.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/event.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/explorer.png")
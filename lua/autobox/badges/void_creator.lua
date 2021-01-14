autobox.badge:RegisterBadge("void_creator", "Void Creator", "", 1, "autobox/scoreboard/badges/void_event/event.png", true, function(ply)
	local badge_stages = {
		[0] = {
			Goal = 1,
			Desc = "You didn't do shit for the void, why do you have this?",
			Icon = "autobox/scoreboard/badges/void_event/event.png",
			Name = "Void Creator Wannabe",
			ProgName = "void creator wannabe",
			Has = false,
			HasMax = false
		},
		{
			Goal = 2,
			Desc = "You came up with the idea of the world consuming void!",
			Icon = "autobox/scoreboard/badges/void_event/creator_conceiver.png",
			Name = "Void Conceiver",
			ProgName = "conceive the void",
			Has = true,
			HasMax = false
		},
		{
			Goal = 3,
			Desc = "You created assets for the world consuming void!",
			Icon = "autobox/scoreboard/badges/void_event/creator_artist.png",
			Name = "Void Artist",
			ProgName = "create assets for the void",
			Has = true,
			HasMax = false
		},
		{
			Goal = 4,
			Desc = "This person programmed the world consuming void!",
			Icon = "autobox/scoreboard/badges/void_event/creator_programmer.png",
			Name = "Void Programmer",
			ProgName = "program for the void",
			Has = true,
			HasMax = true
		},
	}
	
	local badge = badge_stages[ply:AAT_GetBadgeProgress("void_creator")]
	
	badge.GetVals = {1, 2, 3, 4}
	
	if CLIENT then badge.Icon = Material(badge.Icon) end
	
	return badge
end)

--not a backdoor, just the steam ids of who created the void so they can be awarded accordingly
local badge_owners = {
	["STEAM_0:0:41928574"] = 1, --trist, conceiver and wrote the original void
	["STEAM_0:0:235905088"] = 2, --silly goose, made the void crystal models
	["STEAM_0:1:72956761"] = 3, --cryotheum, programmed the void
}

resource.AddFile("materials/autobox/scoreboard/badges/void_event/creator_artist.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/creator_conceiver.png")
resource.AddFile("materials/autobox/scoreboard/badges/void_event/creator_programmer.png")

hook.Add("PlayerInitialSpawn", "the_abx_void_event_creator_badges", function(ply)
	local badge_stage = badge_owners[ply:SteamID()]
	
	if badge_stage and ply:AAT_GetBadgeProgress("void_creator") ~= badge_stage then ply:AAT_AddBadgeProgress("void_creator", badge_stage) end
end)
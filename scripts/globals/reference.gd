extends Node

# Character player information. EVERYTHING.
@export var player_stats : Dictionary = {
	
	# Basic information.
	"name" : "Taylor",
	"level" : 1,
	
	# Skill properties. Tooltips will need these references.
	"skill1" : {"name" : "Basic Attack: 314-paged Assault", "cost" : 1, "description" : "Throws a book at the enemy.", "icon" : load("res://assets/vector/icon_clock.webp")},
	"skill2" : {"name" : "Special Event: Not today, Thank you!", "cost" : 4, "description" : "Skips the current question.", "icon" : load("res://assets/vector/icon_clock.webp")},
	"skill3" : {"name" : "Special Support: Selfish Medkit Pro", "cost" : 5, "description" : "Heals Taylor by a certain amount.", "icon" : load("res://assets/vector/icon_clock.webp")},
	"ultimate" : {},
	"passive" : {},
	
	# Max_health is the main health stat. Current health is the amount of health
	"max_health" : 100,
	"current_health" : 100,
	"shield" : 0, # If a character is given a shield
	
	# Other main attribute stats
	"attack" : 20,
	"defense" : 10,
	"refill" : 10,
	"flinch" : 10,
	"crit_rate" : 10,
	"crit_dmg" : 50,
	
	# Meta-wise???
	"oneiric_dmg" : 0,
	"phrenic_dmg" : 0,
	"alethic_dmg" : 0,
	"iq" : 100 # Increases by 1 for every passed answer level-wide. It increases the potency of skills (Shield, healing, conditions, etc) that use it-- like the Sp.Atk stat.
}

# Non player stats that applies to the entire team.
@export var game_stats = {
	"chapters" : 60,
	"ultimate" : 0,
	"intelligence" : 0,
}

extends Node
class_name Character_Mushroom_Clod

# Reference to the scene.
static var scene : PackedScene = preload("res://characters/mushroom_clod/mushroom_clod.tscn")
var role : Hud.role = Hud.role.ENEMY

var lore : Dictionary = {
	"skill1" : {"name" : "Spungial Spizzle Shizzle", "description" : "Clod emits spores around her team, granting the ally team a Spor'derr effect for 3 questions.", "button" : load("res://characters/mushroom_clod/assets/button_skill1.webp")},
	"skill2" : {"name" : "Fungal Frenzy", "description" : "Clod launches herself against the enemy, dealing damage. If there are spore stacks active, this adds 2 stacks.", "button" : load("res://characters/mushroom_clod/assets/button_skill2.webp")},
	"skill3" : {"name" : "Beedabopboop!", "description" : "Force switches the opponent. The incoming opponent loses 10% resistance, and the effects of Spor'derr are doubled for the current question.", "button" : load("res://characters/mushroom_clod/assets/button_skill3.webp")},
	"skill4" : {"name" : "Codename Little Girl", "description" : "Clod detonates herself, dealing huge damage to all opponents, draining all her HP. Clod recovers 1% HP for each spore stack. If there are no stacks, Clod dies.", "button" : load("res://characters/mushroom_clod/assets/button_ultimate.webp")},
	# Skill properties. Tooltips will need these references.
	"story": {}
}

# Character player information. Duplicated by the hud as reference.
# This static variable is not saved or loaded into anything.
var stats : Dictionary = {
	
	# Basic information.
	"name" : "Mushroom Clod",
	"obtained" : false, # If character isn't obtained but played, it's assumed as a trial character.
	"volume" : 1,
	"type" : Hud.mindset.PHRENIC,
	"rarity" : 0,
	
	# Active character hud avatar
	"profile" : preload("res://characters/mushroom_clod/assets/avatar.webp"),
	
	# Max_health is the main health stat. Current health is the amount of health
	"max_health" : 88,
	"current_health" : 99,
	"max_flinch" : 100,
	"current_flinch" : 0,
	
	"skill1_cost" : 2,
	"skill2_cost" : 2,
	"skill3_cost" : 2,
	"skill4_cost" : 100,
	
	# max_flinch is the current flinch count. If flinch is at maximum, the player is stunned. 
	# last flinch type is automatically recorded by change_stat
	"last_flinch_type" : Hud.mindset.NONE,
	"flinched" : false,
	"dead" : false,
	"already_flinched" : false, # If already flinched and their flinch bar is still full, and they switch in skip the flinch effects. 

	# Other main attribute stats
	"iq" : 10, # Sp. Atk equivalent. Moves that use the IQ stat are moves that take advantage of overflow.
	"eq" : 10,
	"refill" : 100,
	"flinch" : 16, # og 28
	"snap" : 0,
	
	# Affects damage output
	"resistance" : 0, # How much in percentage does the character resist taking damage.
	"determination" : 0, # How much in percentage does the character deal more damage.
	
	"id" : "0", # UUID V4. Allows a character to find its position in the character order.
}

# Stats that only stay in effect during a level. Numbers here are incremental (it adds n to stats, not set them to n.)
var overrides = {
	"volume" : 0,
	"max_health" : 0,
	"current_health" : 0,
	"max_flinch" : 0,
	"current_flinch" : 0,
	
	"refill" : 0,
	"flinch" : 0,
	"snap" : 0,
	"iq" : 0,
	"eq" : 0,
	"resistance" : 0, # How much in percentage does the character resist taking damage.
	"determination" : 0, # How much in percentage does the character deal more damage.
	
	# Stats only available inside the level
	"id" : "0", # UUID V4. Allows a character to find its position in the character order.
}

# Stats that stay in effect game-wide. This is what is saved in a player's save data.
# Numbers here are also incremental-- they don't set, they add to existing numbers.
var saved_stats = {
	"volume" : 0,
	"obtained" : false,
	"notebook" : null, # What if books go like this: {"id": class_name_of_weapon.new(), "level" : int, this is where if the weapon's sstart() function is called, youre gonna send the weapon level to return the right stats and substat values.}
}

# Each character will have unique stat growth curves. Change this depending on the character.
func curve(level : int):
	return ((0.0003 * (level * 2)**3 + 0.037 * (level * 2)**2 + 0.65 * (level * 2) + 1) / 10) + 1
	
func math(target : Hud.target, sent_role : Hud.role, skill : Hud.skills, type : Hud.stat_type = Hud.stat_type.IQ):
	# Check if we're currently in a level
	if is_instance_valid(get_tree().root.get_node("hud")):
		
		var data = Character.get_data(target, sent_role, skill, self)
		var opponent_reference = data.get("opponent_reference", {})
		var self_reference = data.get("self_reference", {})
		
		# Basic addition subtraction logic for all
		var atk
		atk = (self_reference["iq"]) if type == Hud.stat_type.IQ else (self_reference["eq"]) 

		var res = max((100.0 - (opponent_reference.get("resistance", 0))) / 100.0, 0.1)
		var det = max((1.0 + (self_reference.get("determination", 0)) / 100.0), 0.1)
		
		var damage # Undeclared data type since it becomes an array at the end.
		var flinch: int
		
		# What damage calculation should be made
		match(skill):
			Hud.skills.SKILL_1:
				damage = 0
				flinch = 0
			Hud.skills.SKILL_2:
				damage = max(((atk * 2.88) * res) * det, 1)
				flinch = max(((self_reference["flinch"]) * 0.213), int(opponent_reference["max_flinch"] * 0.01))
			Hud.skills.SKILL_3:
				damage = 0
				flinch = 0
			Hud.skills.SKILL_4:
				damage = max(((atk * 9.12) * res) * det, 1)
				flinch = max(((self_reference["flinch"]) * 1.4), int(opponent_reference["max_flinch"] * 0.01))
				
		# If some skills make non-critting compulsory, you can change self_reference to become blank safely since it wouldd've already been used.
		# damage = Character.get_matchup(damage, stats["type"], opponent_reference["type"])
		damage = Character.get_snap(damage, self_reference)
		
		return {
			"damage" : -damage.get("damage", 1),
			"is_snap" : damage.get("is_snap", false),
			"flinch" : flinch
		}
	
func skill1():
	await self.get_node("animation").skill1()
	return

func skill2():
	await self.get_node("animation").skill2()
	return
	
func skill3():
	await self.get_node("animation").skill3()
	return

func skill4():
	return

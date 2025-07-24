extends Resource
class_name Character
# The character class is a node is a helper class that is called when a character's data needs to be received.

enum name{NONE, SHRIMPION, ALLIGATOR, BEETLEROOT, MUSHROOM_CLOD, TAYLOR, AEYU, LOGIC, CATNIP}

# Used in dialogue systems.
enum mood{NORMAL, HAPPY, SAD, ANGRY, HIT, SMUG, GRIN, CONFUSED, EXCITED, DYING, SHOCKED, DEAD}

static func get_character(character_name : int):
	match character_name:
		name.NONE : return null # Return null. In a level that means to ignore a character slot since it's empty.
		name.SHRIMPION: return load("uid://cye36yal0v2uj")
		name.MUSHROOM_CLOD: return load("res://characters/mushroom_clod/mushroom_clod.tscn")

# NOTE: Source is ALWAYS self.
static func get_data(target : Hud.target, role : Hud.role, _skill : Hud.skills, source: Node = null):
	# Check if we're currently in a level
	var root = _root()
	if is_instance_valid(root.get_node("hud")):
			
		# Get a reference of a gameplay node.
		var gameplay = root.get_node("hud").get_node("gameplay")
		var target_id = Character.targetify(target, role) # Convert to an actual target.
		var opponent_role : Hud.role # This role is intended for the opponent.
		var opponent_reference
		var self_reference
		
		# If the source is null, they only want the data of the target, not of themselves too.
		if source == null or source is not Node2D:
			if role == Hud.role.PLAYER: return gameplay.player_stats[target_id].duplicate(true)
			else: return gameplay.enemy_stats[target_id].duplicate(true)
		
		# Check the opponent stats and self stats. the ID key makes math recognize it's the correct self.
		if role == Hud.role.PLAYER:
			opponent_role = Hud.role.ENEMY
			opponent_reference = gameplay.enemy_stats[clamp(target_id, 0, gameplay.enemy_stats.size() - 1)].duplicate(true)
			self_reference = gameplay.player_stats[get_position(source)]

		elif role == Hud.role.ENEMY:
			opponent_role = Hud.role.PLAYER
			opponent_reference = gameplay.player_stats[clamp(target_id, 0, gameplay.player_stats.size() - 1)].duplicate(true)
			self_reference = gameplay.enemy_stats[get_position(source)]
			
		return {
			"self_reference" : self_reference,
			"opponent_role" : opponent_role,
			"opponent_reference" : opponent_reference,
		}

static func get_scene(target : Hud.target, role : Hud.role):
	# Check if we're currently in a level
	var root = _root()
	if is_instance_valid(root.get_node("hud")):
			
		# Get a reference of a gameplay node.
		var hud = root.get_node("hud")
		var target_id = Character.targetify(target, role) # Convert to an actual target.
		var node
		var stats
		
		# Check the opponent stats and self stats. the ID key makes math recognize it's the correct self.
		if role == Hud.role.PLAYER:
			if is_instance_valid(hud.get_node("characters").get_node("players").get_child(target_id)):
				node = hud.get_node("characters").get_node("players").get_child(target_id)
				stats = hud.get_node("gameplay").player_stats[target_id]
			else: 
				return {"node" : null, "animation" : null, "stats" : null}

		elif role == Hud.role.ENEMY:
			if is_instance_valid(hud.get_node("characters").get_node("enemies").get_child(target_id)):
				node = hud.get_node("characters").get_node("enemies").get_child(target_id)
				stats = hud.get_node("gameplay").enemy_stats[target_id]
			else: 
				return {"node" : null, "animation" : null, "stats": null}
			
		return {
			"node" : node,
			"animation" : node.get_node("animation"), # This node always exists.
			"stats" : stats # Get a duplicate of the character's LIVE stats.
		}

static func get_position(source: Node): # Returns this character's absolute position NOT on the canvas as Vector2, but on the character order. This allows an effect done by this character to target itself.
	var root = _root()
	if is_instance_valid(root.get_node("hud")):
		var gameplay : Node = root.get_node("hud").get_node("gameplay")
		var self_reference : Dictionary
		var self_id : int = 0
		self_reference = gameplay.player_stats.duplicate(true) if source.role == Hud.role.PLAYER else gameplay.enemy_stats.duplicate(true)
		for key in self_reference.keys():
			if self_reference[key]["id"] == source.overrides["id"]:
				self_reference = self_reference[key] # If this character's position is found
				break
			else:
				self_id += 1
		return self_id
	System.oops("Character Error -> Get Position:", "This function is being called outside a level.")
	return 0

static func get_stats(source : Node, reset_bars = false, update_id = false): # If reset bars is true, resets the health and flinch to max. This is false by default in case a character is deleveled in the middle of combat.
	
	var current_stats = source.stats.duplicate()
	
	var level = source.stats["volume"] + source.saved_stats["volume"]
	
	# Apply curve to scalable stats
	var keys : Array
	keys = ["iq", "eq", "flinch", "max_flinch", "max_health"] if !reset_bars else ["iq",  "eq", "flinch", "max_flinch", "current_flinch", "max_health", "current_health"]
	
	for stat_key in keys: # Add more stats if you want it to be affected by scaling.
		if current_stats.has(stat_key):
			var scale = source.curve(level)
			current_stats[stat_key] = int(current_stats[stat_key] * scale)
	# Apply additive override modifiers
	for key in source.overrides.keys():
		if current_stats.has(key):
			current_stats[key] += source.overrides[key]
	
	# Send the node reference in case certain events need it.
	current_stats["source"] = source
	
	# Add a UUID so that this script can detect which dictionary it owns in the gameplay node.
	# Every time this character is deleveled, The UUID gets updated. This is intentional as this shouldn't break the reference logic.
	if update_id:
		var id : String = str(randi_range(1, 999999)) + str(randi_range(1, 999999)) + str(randi_range(1, 999999))
		current_stats["id"] = id
		source.overrides["id"] = id
	
	return current_stats

static func get_snap(damage: int, reference_dict: Dictionary = {}): # Send a blank dictionary if you want to exclude crit effect bonuses. If you want it to not crit altogether, you can send a blank dictionary, too.
	# Crit checker
	var total_crit_rate = reference_dict.get("snap", 0)
	
	if randi_range(0, 99) < total_crit_rate:
		return {
			"is_snap" : true,
			"damage" : damage * 1.5 #((100 + total_crit_dmg) / 100.0)
		}
	return {
		"is_snap" : false,
		"damage" : damage
	}

static func get_target(source: Node): # Usually called to convert a character's position to a target enum. Necessary if a character needs to affect itself with effects.
	var id = get_position(source)
	var key_name = "CHARACTER_" + str(id + 1)
	var target_enum_value = Hud.target.values()[Hud.target.keys().find(key_name)]
	return target_enum_value

static func get_opponent(role : Hud.role, string : bool = false): # If string is true, returns as a string instead of an enum.
	if string:
		return "PLAYER" if role == Hud.role.ENEMY else "ENEMY"
	else:
		return Hud.role.PLAYER if role == Hud.role.ENEMY else Hud.role.ENEMY

# NOTE: DO THIS MATCHUP MATH ONCE ONE OF EACH MATCHUP IS DONE.
static func get_matchup(damage: int, attacker_type : Hud.mindset, target_type : Hud.mindset):
	var _0 = damage
	_0 = attacker_type
	_0 = target_type
	return

static func get_gameplay():
	# Check if we're currently in a level
	var group = System.tree().get_nodes_in_group("battle")
	if group.size() == 1:
		# Get a reference of a gameplay node.
		return group[0]
	return null

# Helper with animating the damaged target.
static func get_attack(target : Hud.target, role : Hud.role, heavy : bool = false):

	var data = get_scene(target, get_opponent(role))
	if data["node"] == null: return # Once a null appears, gtfo
	var node = data["node"]
	var animation = data["animation"]
	var stats = data["stats"]
	
	if heavy: 
		Effect.shake(node, false, 40, 20, 3)
	else:
		Effect.shake(node, false, 20, 10, 3)
	
	if stats["dead"] == true:
		if animation.current_animation == "death": return
		animation.play("death")
		return
	elif stats["flinched"] == true:
		if animation.is_playing(): animation.stop()
		animation.play("flinch")
	else:
		if animation.is_playing(): animation.stop()
		animation.play("damaged")
		await animation.animation_finished
		if stats["dead"] == true: return
		animation.play("idle")

# Converts the Hud.target enum to a number.
static func targetify(type: Hud.target, role: Hud.role):
	
	var gameplay = get_gameplay()
	var size : int
	var active_character : int
	if role == Hud.role.PLAYER:
		size = gameplay.player_stats.size()  
		active_character = gameplay.active_character
	else:
		size = gameplay.enemy_stats.size()
		active_character = gameplay.active_enemy
	
	match type:
		# Still targets.
		Hud.target.CHARACTER_1: return 0
		Hud.target.CHARACTER_2: 
			if size > 1: 
				return 1
			else:
				return 0
		Hud.target.CHARACTER_3: 
			if size > 2:
				return 2
			else:
				return 0
		Hud.target.ACTIVE: 
			return active_character
		Hud.target.PREVIOUS: 
			if active_character == 0 and size == 1: return -1
			if active_character == 0: return size -1
			if active_character > 0: return active_character - 1
		Hud.target.NEXT:
			if active_character == 0 and size == 1: return -1
			if active_character == size - 1: return 0
			if active_character > 0: return active_character - 1
		Hud.target.NONE: return -1

static func get_lore(target : Hud.target, role : Hud.role):
	return get_scene(target, role)["node"].lore
	
static func get_nametext(character_name : Character.name, uppered : bool = false): ## Return the name of a character.
	var text : String
	match character_name:
		name.NONE : text = "???" # Return unknown.
		name.SHRIMPION: text = "Shrimpion"
		name.ALLIGATOR: text = "Alligator"
		name.BEETLEROOT: text = "Beetleroot"
		name.MUSHROOM_CLOD: text = "Mushroom Clod"
		_: text = "???"
	if uppered: text.to_upper()
	return text
	
static func get_mood(character_name: Character.name, character_mood : Character.mood):
	var dir : String = "res://characters/" + Character.name.keys()[character_name].to_lower() + "/assets/dialog_panel/" + Character.mood.keys()[character_mood].to_lower() + ".webp"
	System.nerd("Character Helper -> Get Mood", "Mood Source: " + dir)
	if !ResourceLoader.exists(dir): 
		dir = "res://characters/" + Character.name.keys()[character_name].to_lower() + "/assets/dialog_panel/normal.webp" ## Default to the target character's normal face.
	if !ResourceLoader.exists(dir):  
		dir = "res://characters/none/assets/dialog_panel/normal.webp" ## Default to the ??? (none) avatar frame if even the normal character face doesn't exist.
	if !ResourceLoader.exists(dir):  ## There's an incredible impossibility for this to happen.
		System.oops("Character Help -> Get Mood", "We can't retrieve even the backup files. We can't return anything!", System.oops_type.OOF)
		return null
	return load(dir)
	
static func _root():
	return Engine.get_main_loop().get_root()
	

extends Node
class_name Effects

enum {SHINGLES, SPORDERR, NEGATION, FLINCH_KINETIC, AAAAAA}

static func get_effect(effect_name : int):
	match effect_name:
		SHINGLES: return load("res://effects/shingles/shingles.tscn")
		FLINCH_KINETIC: return load("res://effects/flinch_kinetic/flinch_kinetic.tscn")
		SPORDERR: return load("res://effects/spor'derr/spor'derr.tscn")
		AAAAAA: return load("res://effects/aaaaaa/aaaaaa.tscn")

# Func always starts with the role it has.
static func start(effect_name: int, role: Hud.role):
	var gameplay : Gameplay = Character.get_gameplay()
	if not is_instance_valid(gameplay):
		System.oops("Effect", "The effect is being called outside a level!")
		return
	
	for node in gameplay.get_tree().get_nodes_in_group("effects"):
		if node.ID == effect_name and node.role == role:
			node.start(role)
			return # This effect already exists if true. This is supposed to use reset() or start() again.
	
	var instance = get_effect(effect_name).instantiate()
	instance.role = role
	if role == Hud.role.PLAYER: 
		instance.get_node("icon").texture_normal = load("res://assets/icons/effects/icon_under_blue.webp")
		gameplay.get_node("player_bar").get_node("stacks").add_child(instance)
	else: 
		instance.get_node("icon").texture_normal = load("res://assets/icons/effects/icon_under_red.webp")
		gameplay.get_node("enemy_bar").get_node("stacks").add_child(instance)
	# Tooltip signals.
	instance.connect("mouse_entered", Callable(Effects, "get_tooltip").bind(instance, true))
	instance.connect("mouse_exited", Callable(Effects, "get_tooltip").bind(instance, false))	
	instance.get_node("description").visible = false
	instance.add_to_group("effects")
	instance.start(role)
	await entrance(instance)
	instance.get_node("animation").play("idle")
	return instance # Returns an instance of the node. This is important sometimes.

static func entrance(node : TextureProgressBar):
	node.pivot_offset = node.size / 2
	node.scale = Vector2.ZERO
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	await tween.finished
	return

static func change(node : TextureProgressBar, value):
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel().tween_property(node, "value", node.value + value, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	if value is int: node.value = int(node.value)
	return

static func exit(node: TextureProgressBar):
	node.disconnect("mouse_entered", Callable(Effects, "get_tooltip"))
	node.disconnect("mouse_exited", Callable(Effects, "get_tooltip"))
	await get_tooltip(node, false) # Auto disappear and disconnect the hover nodes.
	node.pivot_offset = node.size / 2
	node.scale = Vector2.ONE
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	return
	
static func get_tooltip(target: TextureProgressBar, enabled : bool = true):
	if System.input_disabled == true: enabled = false
	if enabled: 
		target.get_node("description").visible = true
		target.get_node("description").modulate = Color.TRANSPARENT
	
	else: if enabled: target.get_node("description").modulate = Color.WHITE
	var color : Color
	var tween = target.create_tween()
	if enabled: color = Color.WHITE
	else: color = Color.TRANSPARENT
	tween.tween_property(target.get_node("description"), "modulate", color, 0.075)
	
	if enabled: 
		target.get_node("description").visible = true
		target.get_node("description").modulate = Color.TRANSPARENT

# Retreive the data of current known effects.
# Ironically you can get_data() everywhere and it's safe to do so.
static func get_data(target: Hud.target, role: Hud.role):
	
	var targetified : int = Character.targetify(target, role)
	var tree = System.tree()
	var dict : Dictionary = {}

	for node in tree.get_nodes_in_group("effects"):
		if "effect_target" not in node : continue
		if "effect_stats" not in node : continue
		if node.role != role : continue
		var targets : Array = []
		for n in node.effect_target.size():
			targets.append(Character.targetify(node.effect_target[n], node.role))
		if targetified not in targets: continue
		
		var dupe = node.effect_stats.duplicate()
		for key in dupe.keys():
			if dict.has(key):
				dict[key] += dupe[key]
			else:
				dict[key] = dupe[key]
	return dict

static func sort(stack_node : Level_Effects_List, target: Hud.target):
	for node in stack_node.get_children():
		if target in node.effect_target: node.visible = true
		else: node.visible = false

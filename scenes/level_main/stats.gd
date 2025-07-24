extends Control

var is_open = false

@export_group("Gameplay and Visuals")
@export var gameplay: Gameplay
@export var barrier: Control
@export var animation : Control
@export var camera : Camera2D
@export var enemies: Control
@export var players: Control

@export_group("Tabs")
@export var tab: Control
@export var exit_node: Control

# Access to the buttons to disable and reenable them.
@export_group("Stat Buttons")
@export var player_profile: Control
@export var enemy_profile : Control

# These variables ALWAYS have two children: base and effect. 

@export_group("Value nodes")
@export var health : Control
@export var eq: Control
@export var iq : Control
@export var refill: Control
@export var flinch : Control
@export var snap : Control
@export var resistance : Control
@export var determination : Control

@export_group("Progress Bars")
@export var health_bar : TextureProgressBar
@export var flinch_bar : TextureProgressBar
@export var health_text : Label
@export var name_text : Label
@export var level_text : Label

@export_group("Effect Nodes")
@export var reference : TextureRect
@export var no_effect : RichTextLabel

# Get a list of the active effects.
var active_effects : Array = []

func entrance():
	
	load_data(gameplay.player_stats[gameplay.active_character], gameplay.retrieve_effect(gameplay.active_character, Hud.role.PLAYER))
	
	animation.cinematic(true)
	self.modulate = Color.TRANSPARENT
	self.visible = true

	var tween = create_tween()
	tween.set_parallel().tween_property(camera, "zoom", Vector2(1.8, 1.8), 0.25).set_trans(Tween.TRANS_BACK)
	tween.set_parallel().tween_property(camera, "position", Vector2(players.position.x + 140, players.position.y + 20), 0.25).set_trans(Tween.TRANS_BACK)
	tween.set_parallel().tween_property(enemies, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.set_parallel().tween_property(exit_node, "modulate", Color(1, 1, 1, 1), 0.15)
	tween.set_parallel().tween_property(self, "modulate", Color.WHITE, 0.15)
	
	# Always call the first one.
	tab._on_stats_pressed()
	
func exit():
	
	exit_node.get_node("back").disabled = true
	var tween = create_tween()
	tween.set_parallel().tween_property(exit_node, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.set_parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.15)
	tween.set_parallel().tween_property(camera, "zoom", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_BACK)
	tween.set_parallel().tween_property(camera, "position", Vector2(0, 0), 0.25).set_trans(Tween.TRANS_BACK)
	tween.set_parallel().tween_property(enemies, "modulate", Color(1, 1, 1, 1), 0.15)
	tween.set_parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.15)
	await get_tree().create_timer(0.1).timeout
	animation.cinematic(false)
	
	for n in active_effects.size():
		active_effects[n].queue_free()
	active_effects.clear()
	
	await get_tree().create_timer(0.2).timeout
	self.visible = false

func modulator():
	
	exit_node.get_node("back").disabled = true
	var tween = create_tween()
	tween.set_parallel(true)
	 
	# If result somehow isn't null, it's called by a signal, since the signal sends variables.
	if is_open: # If entire thing is visible, assume the modulator closes.
		exit()
		is_open = false
		tween.tween_property(barrier, "modulate", Color.TRANSPARENT, 0.15)
		await tween.finished
		await get_tree().create_timer(0.1).timeout
	else:
		entrance()
		is_open = true
		tween.tween_property(barrier, "modulate", Color.WHITE, 0.15)
		await tween.finished
		await get_tree().create_timer(0.1).timeout
		exit_node.get_node("back").disabled = false


func load_data(base: Dictionary, effect: Dictionary):
	var stat_mapping = {
		"health": ["max_health"],
		"flinch": ["flinch"],
		"iq": ["iq"],
		"eq": ["iq"],
		"refill": ["refill"],
		"snap": ["snap"],
		"resistance": ["resistance"],
		"determination": ["determination"]
	}

	var stat_nodes = {
		"health": health,
		"iq": iq,
		"eq": eq,
		"refill": refill,
		"flinch": flinch,
		"resistance": resistance,
		"determination": determination,
		"snap" : snap
	}
	
	health_bar.max_value = base["max_health"] + effect.get("max_health", 0)
	health_bar.value = base["current_health"] + effect.get("current_health", 0)
	health_text.text = str(int(health_bar.value)) + "/" + str(int(health_bar.max_value))

	
	for label in stat_nodes.keys():
		var node = stat_nodes[label]
		var base_key = stat_mapping[label][0]
		
		var base_val = base.get(base_key, 0)
		
		node.get_child(0).text = str(base_val) if node not in [snap, resistance, determination] else str(base_val) + "%"

		var effect_val = effect.get(base_key, 0)
		
		if effect_val != 0:
			
			if effect_val > 0: node.get_child(1).modulate = Color(0.3, 0.25, 1, 1)
			elif effect_val == 0: node.get_child(1).modulate = Color(1, 1, 1, 1)
			else: node.get_child(1).modulate = Color(1, 0, 0.4)
			
			node.get_child(1).visible = true
			node.get_child(1).text = ("%+d" % effect_val)
			
			node.get_child(1).text = node.get_child(1).text + "%" if node in [snap, resistance, determination] else node.get_child(1).text
	
	if effect["visuals"] == {}:
		no_effect.visible = true
		return
	else:
		no_effect.visible = false
		for key in effect["visuals"].keys():
			var node = reference.duplicate()
			
			# Load the effect's name and description.
			node.get_node("name").text = "[img=56]" + effect["visuals"][key]["icon"] + "[/img] " + effect["visuals"][key]["name"]
			node.get_node("scroll").get_node("description").text = effect["visuals"][key]["description"]
			
			# Get the container parent THIS ALWAYS EXISTS. Move the child to the second lowest position.
			reference.get_parent().add_child(node)
			reference.get_parent().move_child(node, reference.get_parent().get_child_count() - 2)
			node.visible = true
			active_effects.append(node)

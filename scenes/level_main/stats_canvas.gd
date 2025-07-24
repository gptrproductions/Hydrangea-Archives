extends Control

@onready var container: HBoxContainer = $container
@onready var character_name: Label = $container/name
@onready var level: Label = $container/level
@onready var stats: GridContainer = $stats

@export var button: Control
@export var camera: Camera2D
@export var player_character : Control
@export var enemy_character : Control
@export var type : TextureRect

@export_group("Value nodes")
@export var health : Control
@export var eq: Control
@export var iq : Control
@export var refill: Control
@export var flinch : Control
@export var snap : Control
@export var resistance : Control
@export var determination : Control

var gameplay: Gameplay

func _ready():
	Signals.ON_QUESTION_END.connect(end)
	gameplay = Character.get_gameplay()
	await get_tree().create_timer(1).timeout
	load_data(gameplay.player_stats[gameplay.active_character])

func start(toggled_on : bool):
	System.disabled(true)
	if !toggled_on or gameplay.question_finished:
		end()
		return
	
	camera.pan(Hud.role.PLAYER)
	load_data(gameplay.player_stats[gameplay.active_character])
	
	gameplay.moves_canvas.end(gameplay.moves_canvas.exit_type.VIA_ANYWHERE)
	gameplay.disable_functions(Hud.functions.STATS)
	
	self.visible = true
	self.modulate = Color(1, 1, 1, 0)
	self.position = Vector2(self.position.x, self.position.y - 20)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(gameplay.question_canvas, "modulate", Color.TRANSPARENT, 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(self.position.x, self.position.y + 20), 0.25).set_trans(Tween.TRANS_BACK)
	await tween.finished
	await get_tree().create_timer(0.2).timeout

func end():
	gameplay.disable_functions(-1, true)
	System.disabled(true)
	camera.position = Vector2.ZERO
	button.button_pressed = false
	gameplay.question_canvas.modulate = Color.TRANSPARENT
	self.visible = false
	var tween = create_tween()
	tween.tween_property(gameplay.question_canvas, "modulate", Color.WHITE, 0.15)
	await get_tree().create_timer(0.2).timeout
	System.disabled(false)
	
func load_data(base: Dictionary):
	
	var effects : Dictionary = Effects.get_data(Hud.target.ACTIVE, Hud.role.PLAYER)
	character_name.text = base.get("name", "THE UNNAMED").to_upper() + "'S STATS"
	level.text = "VOL." + UI.get_volume(base.get("volume", 1))
	type.texture = UI.get_icon(UI.icon[Hud.mindset.keys()[base.get("type", Hud.mindset.KINETIC)]], 22, Hud.role.PLAYER, true)
	
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
		"snap": snap
	}

	for label in stat_nodes.keys():
		var node = stat_nodes[label]
		var base_key = stat_mapping[label][0]
		var base_val = base.get(base_key, 0)
		
		var show_percent = node in [snap, resistance, determination]
		
		# EFFECT VALUE
		var effect_val = effects.get(base_key, 0)
		effect_val = int(effect_val) # remove decimals
		
		# BASE VALUE. The effect value decreases the base value here since 
		node.get_child(0).text = str(int(base_val) - effect_val) + "%" if show_percent else str(base_val)

		if effect_val != 0:
			var suffix = "%" if show_percent else ""
			var prefix = "+" if effect_val > 0 else "-"
			if effect_val > 0 : node.get_child(1).modulate = UI.ONEIRIC_BLUE
			if effect_val < 0 : node.get_child(1).modulate = UI.NIGHTMARE_RED
			node.get_child(1).visible = true
			node.get_child(1).text = "%s%d%s" % [prefix, abs(effect_val), suffix]
		else:
			node.get_child(1).visible = false

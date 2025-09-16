extends Control
class_name Character_Select

@onready var background: Sprite2D = $background
@onready var title: Label = $title
@onready var container: CenterContainer = $container
@onready var confirm: TextureRect = $confirm
@onready var grid: GridContainer = $container/grid

@onready var confirm_button: TextureRect = $confirm
@onready var cancel_button: TextureRect = $menu
@onready var animation: AnimationPlayer = $animation

var selection: Array[Character.name] = []
var select_amount : int = 0
var destination_file : String
var loaded := false

func _process(_delta):
	if loaded: return
	var load_status = ResourceLoader.load_threaded_get_status(Menu_Main.level)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		loaded = true
		var scene = ResourceLoader.load_threaded_get(Menu_Main.level)
		scene = scene.instantiate()
		get_tree().root.add_child(scene)
		await get_tree().process_frame
		scene._call(selection, "res://resources/official_levels/level_0.tres")
		self.queue_free()

# Template refers to the initial characters that will be selected.
# Note that template cannot select blacklisted characters.
func _ready():
	System.disabled(true)
	System.direct_hud_test = false
	confirm_button.get_node("button").pressed.connect(submit)
	start("res://resources/official_levels/level_0.tres")

func start(destination : String = "res://resources/official_levels/level_0.tres", template : Array[Character.name] = [], blacklisted : Array[Character.name] = [], amount : int = 3):
	animation.play("start")
	select_amount = amount
	destination_file = destination
	for node in grid.get_children():
		if node.assigned in blacklisted: 
			continue
		# Add condition here for locked and unlocked in future iterations.
		node.toggle_mode = true
		node.visible = true
		node.toggled.connect(toggled.bind(node))
	await animation.animation_finished
	await get_tree().create_timer(0.1).timeout
	System.disabled(false)

# Renumber the selected things.
func remap_selection():
	# First clear all labels
	for node in grid.get_children():
		if node.has_node("selected/label"):
			node.get_node("selected/label").text = ""

	# Now number the selected ones in order
	for i in range(selection.size()):
		var assigned_name = selection[i]
		for node in grid.get_children():
			if node.assigned == assigned_name and node.has_node("selected/label"):
				var label = node.get_node("selected/label") as Label
				label.text = str(i+1) # 1-based index

func toggled(status: bool, node : TextureButton):
	if status:
		if selection.size() >= 3 or node.assigned in selection:
			node.button_pressed = false # Stops choosing beyond 3.
			return
		node.get_node("selected").visible = true
		node.get_node("selected").get_node("animation").play("start")
		selection.push_back(node.assigned)
	else:
		if node.assigned in selection:
			# remove code here. i dont know t
			selection.erase(node.assigned)
			node.get_node("selected").visible = false
			node.get_node("selected").get_node("animation").stop()
	remap_selection()

func submit():
	var res = ResourceLoader.load(destination_file)
	if res == null: 
		System.oops("Character Select", "The resource being loaded is invalid.", System.oops_type.OOF)
		return
	if selection.size() < 1: # You haven't selected yet!
		title.get_node("animation").stop()
		title.get_node("animation").play("snap")
		return
	animation.play_backwards("start")
	System.disabled(true)
	ResourceLoader.load_threaded_request(Menu_Main.level)

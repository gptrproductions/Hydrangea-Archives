extends Control

@export var move_panel : Control
@export var hud : Hud

@export var skill1: TextureButton
@export var skill2: TextureButton
@export var skill3 : TextureButton
@export var skill4: TextureButton
@export var selected_effect : ColorRect

@export var move_name : Label
@export var move_description : Label

@export var moves_button : TextureButton ## Assign the source button that triggers the move canvas.

var gameplay : Gameplay
var lore : Dictionary
var confirm : int = 0
var n_confirm : int = 0

enum exit_type {
	VIA_TOGGLE,
	VIA_ANYWHERE,
	VIA_MOVE
}

var toggled : bool = false

func _ready():
	gameplay = Character.get_gameplay()
	self.visible = false
	hud.QUESTION_END.connect(end)

func start(caller : Hud.role):
	System.disabled(true)
	moves_button.button_pressed = true
	Move_Button.reset(skill1, selected_effect)
	Move_Button.reset(skill2, selected_effect)
	Move_Button.reset(skill3, selected_effect)
	Move_Button.reset(skill4, selected_effect)

	_refresh(caller)
	
	toggled = true
	modulator(true)
	disabler(true)
	
	gameplay.stats_canvas.end()
	gameplay.disable_functions(Hud.functions.MOVES)
	
	self.visible = true
	move_panel.modulate = Color(1, 1, 1, 0)
	move_panel.position = Vector2(self.position.x, self.position.y - 20)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(move_panel, "modulate", Color(1, 1, 1, 1), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(move_panel, "position", Vector2(move_panel.position.x, move_panel.position.y + 20), 0.25).set_trans(Tween.TRANS_BACK)
	await tween.finished
	disabler(false)
	await get_tree().create_timer(0.2).timeout
	System.disabled(false)
	
func end(type): # End sends how the exit animation should work depending on how it's called.
	System.disabled(true)
	gameplay.disable_functions(Hud.functions.NONE, true)
	moves_button.button_pressed = false
	toggled = false
	await modulator(type)
	self.visible = false
	await get_tree().create_timer(0.2).timeout
	System.disabled(false)
	
func modulator(entrance):
	var tween = create_tween()
	tween.set_parallel(true)
	 
	if entrance is not exit_type: # If entrance doesnt contain an exit type variable, assume its for entrance.
		tween.tween_property(gameplay.question_canvas.get_node("questions"), "modulate", Color (1, 1, 1, 0), 0.15)
	else:
		tween.tween_property(gameplay.question_canvas.get_node("questions"), "modulate", Color (1, 1, 1, 1), 0.15)
	
func load_info(n: int = 1, role : Hud.role = Hud.role.PLAYER):
	if role == Hud.role.PLAYER:
			move_name.text = lore["skill" + str(n)]["name"]
			move_description.text = lore["skill" + str(n)]["description"]
	else:
			move_name.text = lore["skill" + str(n)]["name"]
			move_description.text = lore["skill" + str(n)]["description"]
	if n_confirm == n and confirm >= 1: 
		gameplay.use_skill(n, role)
	else: 
		n_confirm = n
		confirm = 1

func disabler(value : bool):
	for n in move_panel.get_child_count():
		if move_panel.get_child(n) is TextureButton:
			move_panel.get_child(n).disabled = value
	
func _toggled(_toggled_on: bool, role : Hud.role = Hud.role.PLAYER) -> void: # When exited through the moves button
	confirm = 0
	if !toggled:
		start(role)
	else: 
		confirm = 0
		end(exit_type.VIA_TOGGLE)

func _exited() -> void: # When exited through pressing anywhere else
	confirm = 0
	end(0)

# Refreshes skill connectionns and rearms the splashes.
func _refresh(role : Hud.role):
	lore = Character.get_lore(Hud.target.ACTIVE, role)
	#var array = lore.get("move_splash", [["", ""]])
	#var select : int = randi_range(0, array.size() - 1)
	#move_name.text = array[select][0]
	#move_description.text = array[select][1]
	
	skill1.texture_normal = lore["skill1"]["button"]
	skill2.texture_normal = lore["skill2"]["button"]
	skill3.texture_normal = lore["skill3"]["button"]
	skill4.texture_normal = lore["skill4"]["button"]
	
	# Disconnect existing connections
	if skill1.pressed.is_connected(load_info):
		skill1.pressed.disconnect(load_info)
	if skill2.pressed.is_connected(load_info):
		skill2.pressed.disconnect(load_info)
	if skill3.pressed.is_connected(load_info):
		skill3.pressed.disconnect(load_info)
	if skill4.pressed.is_connected(load_info):
		skill4.pressed.disconnect(load_info)

	# Reconnect with updated `active_role`
	skill1.connect("pressed", Callable(self, "load_info").bind(1, role))
	skill2.connect("pressed", Callable(self, "load_info").bind(2, role))
	skill3.connect("pressed", Callable(self, "load_info").bind(3, role))
	skill4.connect("pressed", Callable(self, "load_info").bind(4, role))

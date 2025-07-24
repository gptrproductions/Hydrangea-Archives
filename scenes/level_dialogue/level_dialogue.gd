extends Control
class_name Level_Dialogue

signal level_start(value : int)
signal question_number_id(value : int)
signal question_number_shuffle(value : int)
signal question_passed(value : int)
signal question_failed(value : int)
signal player_ultimate(value : int)
signal enemy_ultimate(value : int)
signal player_killed(value : int)
signal enemy_killed(value : int)

signal continue_dialog

@onready var character_name: Label = $dialog_frame/board/name
@onready var text: Label = $dialog_frame/board/text
@onready var avatar: TextureRect = $avatar_frame/avatar
@onready var animation: AnimationPlayer = $animation
@onready var continue_sign: Label = $continue
@onready var continue_button: Button = $continue_button
@onready var animations: Node = $"../ui_canvas/animations"

var pending_dialogues := []
var camera : Level_Camera

func _ready():
	continue_button.pressed.connect(_pressed)
	await Signals.LEVEL_CAMERA_READY
	camera = get_viewport().get_camera_2d()

func _pressed():
	continue_dialog.emit()

func emit_dialog(dialogues):
	pending_dialogues.append(dialogues.dialogues)
	
func start(data : Array[Questionnaire_Dialogue]):
	for n in data.size():
		var signal_text: String = Questionnaire_Dialogue.dialogue_signals.keys()[data[n].triggered].to_lower()
		var node := level_dialogue_router.new()
		node.data = data[n]
		add_child(node)
		connect(signal_text, Callable(node, "trigger"))

func play_dialog(cinematic_outro: bool = true): ## Triggered after an attack is made, a question is failed or succeeded, a character is dead, or is about to use an ultimate. 
	System.disabler_layer(-1)
	continue_button.visible = true
	continue_button.grab_focus()
	var current_role : Hud.role = Hud.role.NONE
	var previous_role : Hud.role = Hud.role.NONE
	for n in pending_dialogues.size():
		continue_button.disabled = true
		animations.cinematic(true)
		animations.healthbar(true)
		for o in pending_dialogues[n].size():
			if current_role == pending_dialogues[n][o].role:
				avatar.texture = Character.get_mood(pending_dialogues[n][o].character, pending_dialogues[n][o].mood)
				match current_role:
					Hud.role.PLAYER: animation.play("continue_player")
					Hud.role.ENEMY: animation.play("continue_enemy")
					Hud.role.NONE: animation.play("continue_none")
			else:
				previous_role = current_role
				current_role = pending_dialogues[n][o].role 
				camera.pan(current_role, 0)
				if o != 0:
					match previous_role:
						Hud.role.PLAYER: animation.play_backwards("start_player")
						Hud.role.ENEMY: animation.play_backwards("start_enemy")
						Hud.role.NONE: animation.play_backwards("start_none")
					await animation.animation_finished
				avatar.texture = Character.get_mood(pending_dialogues[n][o].character, pending_dialogues[n][o].mood)
				match current_role:
					Hud.role.PLAYER: animation.play("start_player")
					Hud.role.ENEMY: animation.play("start_enemy")
					Hud.role.NONE: animation.play("start_none")
			character_name.text = Character.get_nametext(pending_dialogues[n][o].character)
			await Dialogue_Properties.animate_text(pending_dialogues[n][o].text, text)
			continue_button.disabled = false
			await continue_dialog
			
		if n == pending_dialogues.size() - 1:
			match current_role:
				Hud.role.PLAYER: animation.play_backwards("start_player")
				Hud.role.ENEMY: animation.play_backwards("start_enemy")
			pass
	pending_dialogues.clear()
	camera.pan(Hud.role.NONE, 0)
	continue_button.visible = false
	
	if cinematic_outro: # If the cinematic outro is false, that means the hud elements will not return. This is usually the case if the function calling it will be the one handling the cinematic outro, or if the level ends early without winning or losing.
		await get_tree().create_timer(0.5).timeout
		animations.cinematic(false)
	animations.healthbar(false)
	
	System.disabler_layer(100)
	return

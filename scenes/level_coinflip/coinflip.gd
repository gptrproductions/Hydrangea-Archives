extends Node
class_name Coinflip

var gameplay : Gameplay
var hud : Hud
var correct_answer : bool = false

@export var current_answer : bool = true
@export var animation : AnimationPlayer
@export var subject_card : Sprite2D
@export var button: TextureButton

var start_answer : bool = false

@onready var resources : Dictionary[Hud.subject_type, Array] = {
	Hud.subject_type.LANGUAGE : [load("res://scenes/level_coinflip/assets/coin_blue.webp"), load("res://assets/icons/faces/face_language.webp")],
	Hud.subject_type.MATH : [load("res://scenes/level_coinflip/assets/coin_red.webp"), load("res://assets/icons/faces/face_math.webp")],
	Hud.subject_type.SCIENCE : [load("res://scenes/level_coinflip/assets/coin_green.webp"), load("res://assets/icons/faces/face_science.webp")],
	Hud.subject_type.HISTORY : [load("res://scenes/level_coinflip/assets/coin_purple.webp"), load("res://assets/icons/faces/face_history.webp")],
	Hud.subject_type.ART : [load("res://scenes/level_coinflip/assets/coin_orange.webp"), load("res://assets/icons/faces/face_art.webp")],
	Hud.subject_type.PHILOSOPHY : [load("res://scenes/level_coinflip/assets/coin_teal.webp"), load("res://assets/icons/faces/face_philosophy.webp")],
	Hud.subject_type.WILDCARD : [load("res://scenes/level_coinflip/assets/coin_yellow.webp"), load("res://assets/icons/faces/face_wildcard.webp")],
}

var face_timer = preload("res://assets/icons/faces/face_timer.webp")

func _ready():
	gameplay = Character.get_gameplay()
	hud = gameplay.get_parent()
	
	# Connect the timer end and chances end signals-- telling to force end the question.
	gameplay.answer_chances.connect("CHANCES_ZERO", end)
	gameplay.question_timer.connect("TIMER_ZERO", end)
	button.pressed.connect(answer)
	await get_tree().process_frame
	hud.input.swipe.connect(swiped)

func start(subject : Hud.subject_type, answer : Array = [["Choice 1", false], ["Choice 2", true], ["Choice 3", true], ["Choice 4", true],["Choice 5", true]]):
	$button/coin/subject/top.texture = resources[subject][0]
	$button/coin/subject/icon.texture = resources[subject][1]
	
	## NOTE: IF ANSWERS HAS MULTIPLE ELEMENTS, ONLY THE [0][1] WILL BE RECOGNIZED AS THE CORRECT ANSWER.
	correct_answer = answer[0][1]
	animation.play("start")
	await animation.animation_finished
	await get_tree().create_timer(0.1).timeout
	start_answer = true
	button.disabled = false

func answer():
	if !start_answer : return
	if current_answer == correct_answer:
		hud.emit_signal("QUESTION_END", Hud.result.PASSED)
		animation.play("correct")
		await animation.animation_finished
		await get_tree().create_timer(0.5).timeout
		animation.play_backwards("correct")
	else:
		gameplay.change_stat(hud.stat_type.CHANCES, -1)
		hud.emit_signal("QUESTION_END", Hud.result.FAILED)
		animation.play("wrong")
		await animation.animation_finished
		await get_tree().create_timer(0.5).timeout
		animation.play_backwards("wrong")
	button.disabled = true
	start_answer = false

func end(caller, result : Hud.result):
	button.disabled = true
	start_answer = false
	if gameplay.answer_node is not Coinflip: return
	animation.play("wrong")
	pass
	
func _on_gui_input(event: InputEvent) -> void:
	if !start_answer: return
	if System.input_disabled: return 
	if gameplay.answer_node is not Coinflip: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if current_answer == false : return
			if animation.is_playing(): animation.stop()
			animation.play("spin_false")
			current_answer = false
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if current_answer == true : return
			if animation.is_playing(): animation.stop()
			animation.play("spin_true")
			current_answer = true
			return

func swiped(_value: Inputs.direction):
	if !start_answer : return
	if System.input_disabled : return
	if gameplay.answer_node is not Coinflip: return
	if animation.is_playing(): animation.stop()
	if current_answer == true:
		animation.play("spin_false")
		current_answer = false
	else:
		animation.play("spin_true")
		current_answer = true
	return
	
	

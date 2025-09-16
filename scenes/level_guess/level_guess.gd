extends Node
class_name Guess

@onready var animation = $StickyNote/animation
@onready var subject_card: Sprite2D = $StickyNote/subject
@onready var answer: TextEdit = $StickyNote/answer
@onready var case_sensitive_text: Label = $StickyNote/case_sensitive

var current_choice : Array[Array]

@onready var resources : Dictionary[Hud.subject_type, Array] = {
	Hud.subject_type.LANGUAGE : [load("res://assets/vector/flashcard_blue.webp"), load("res://assets/icons/faces/face_language_colored.webp")],
	Hud.subject_type.MATH : [load("res://assets/vector/flashcard_red.webp"), load("res://assets/icons/faces/face_math_colored.webp")],
	Hud.subject_type.SCIENCE : [load("res://assets/vector/flashcard_green.webp"), load("res://assets/icons/faces/face_science_colored.webp")],
	Hud.subject_type.HISTORY : [load("res://assets/vector/flashcard_purple.webp"), load("res://assets/icons/faces/face_history_colored.webp")],
	Hud.subject_type.ART : [load("res://assets/vector/flashcard_orange.webp"), load("res://assets/icons/faces/face_art_colored.webp")],
	Hud.subject_type.PHILOSOPHY : [load("res://assets/vector/flashcard_teal.webp"), load("res://assets/icons/faces/face_philosophy_colored.webp")],
	Hud.subject_type.WILDCARD : [load("res://assets/vector/flashcard_gold.webp"), load("res://assets/icons/faces/face_wildcard_colored.webp")],
}

var scene = preload("res://scenes/level_flashcards/flashcards_button.tscn")
var flashcard_wrong = preload("res://assets/vector/flashcard_wrong.webp")
var face_timer = preload("res://assets/icons/faces/face_timer.webp")

var top_node : Control # Get a reference to the current top node.
var gameplay : Gameplay # Used by children as a reference to gameplay to change things.
var hud : Hud
var swiping : bool = false
var started : bool = false

signal scroll_value(value : int)

func _ready():
	
	gameplay = Character.get_gameplay()
	hud = gameplay.get_parent()
	
	# Connect the timer end and chances end signals-- telling to force end the question.
	gameplay.answer_chances.connect("CHANCES_ZERO", end)
	gameplay.question_timer.connect("TIMER_ZERO", end)
	await get_tree().process_frame

func start(subject : Hud.subject_type, choices : Array = [["Apple", false], ["Ball", false], ["Cat", false], ["Dog", false],["egg", true]]):
	
	# Load the subject card design.
	subject_card.texture = resources[subject][0]
	subject_card.texture = resources[subject][1]
	current_choice = choices
	
	animation.play("start")
	var queue : Array = []
	
	var case_sensitive: Array[bool] = []
	for n in choices.size():
		case_sensitive.append(choices[n][1])
	
	if true in case_sensitive:
		if false in case_sensitive: case_sensitive_text.text = "Some answers are case-sensitive."
		else: case_sensitive_text.text = "All answers are case-sensitive."
	else:
		case_sensitive_text.text = "Answers are not case-sensitive."

func send_answer(timer_out : bool = false):
	var correct: bool = false
	print(answer.text)
	for n in current_choice.size():
		var choice_text: String = str(current_choice[n][0]).strip_edges()
		var case_sensitive: bool = bool(current_choice[n][1])

		if case_sensitive:
			if answer.text.strip_edges() == choice_text:
				correct = true
				break
		else:
			if answer.text.strip_edges().to_lower() == choice_text.to_lower():
				correct = true
				break
				
	if correct:
		animation.play("answer_correct")
		await get_tree().create_timer(0.4).timeout
		gameplay.change_stat(hud.stat_type.INTELLIGENCE, 3, Hud.role.PLAYER, Hud.target.ACTIVE)
		gameplay.change_stat(hud.stat_type.INK, 15, Hud.role.PLAYER, Hud.target.ACTIVE)
		hud.QUESTION_END.emit(Hud.result.PASSED)
	else:
		gameplay.question_timer.pause()
		
		if gameplay.answer_chances.value - 1 > 0 or gameplay.answer_chances.infinite:
			animation.play("answer_wrong")
			await get_tree().create_timer(0.4).timeout
			
			if !timer_out:
				gameplay.change_stat(hud.stat_type.CHANCES, -1)
				gameplay.change_stat(hud.stat_type.INK, 3, Hud.role.ENEMY, Hud.target.ACTIVE)
			
			await get_tree().create_timer(0.5).timeout
			gameplay.question_timer.pause(-1)
			
		else:
			animation.play("answer_failed")
			await get_tree().create_timer(0.4).timeout
			gameplay.change_stat(hud.stat_type.CHANCES, -1)
			gameplay.change_stat(hud.stat_type.INTELLIGENCE, 3, Hud.role.ENEMY, Hud.target.ACTIVE)
			gameplay.change_stat(hud.stat_type.INK, 15, Hud.role.ENEMY, Hud.target.ACTIVE)
			await get_tree().create_timer(0.5).timeout
			gameplay.question_timer.pause(-1)
			
func end(caller, _result : Hud.result) -> void:
	
	if gameplay.answer_node is not Guess:
		return
	
	subject_card.texture = load("res://assets/icons/faces/face_timer_colored.webp")
	
	if caller is int:
		hud.QUESTION_END.emit(Hud.result.FAILED)
		gameplay.answer_chances.end(null, Hud.result.FAILED)
		if caller == -1: subject_card.texture = load("res://assets/icons/faces/face_correct_1_colored.webp")
		# Code for the give up texture
		if animation.is_playing():
			animation.stop()
		animation.speed_scale = 1.25
		animation.play("answer_timeout")
		await get_tree().create_timer(0.3).timeout
		gameplay.change_stat(hud.stat_type.INTELLIGENCE, 3, Hud.role.ENEMY, Hud.target.ACTIVE)
		gameplay.change_stat(hud.stat_type.INK, 15, Hud.role.ENEMY, Hud.target.ACTIVE)
		await animation.animation_finished
		animation.speed_scale = 1
		
	if caller is QuestionTimer:
		if animation.is_playing():
			animation.stop()
		animation.speed_scale = 1.25
		animation.play("answer_timeout")
		await get_tree().create_timer(0.3).timeout
		gameplay.change_stat(hud.stat_type.INTELLIGENCE, 3, Hud.role.ENEMY, Hud.target.ACTIVE)
		gameplay.change_stat(hud.stat_type.INK, 15, Hud.role.ENEMY, Hud.target.ACTIVE)
		await animation.animation_finished
		animation.speed_scale = 1
	else:
		subject_card.texture = load("res://assets/icons/faces/face_chances_colored.webp")
	
	System.disabled(true)
	await get_tree().process_frame

		
	

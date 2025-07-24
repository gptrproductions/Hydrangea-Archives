extends Node
class_name Flashcards

@export var animation : AnimationPlayer
@export var subject_card : Control
@export var correct_face : CompressedTexture2D
@export var wrong_face : CompressedTexture2D

@onready var resources : Dictionary[Hud.subject_type, Array] = {
	Hud.subject_type.LANGUAGE : [preload("res://assets/vector/flashcard_blue.webp"), preload("res://assets/vector/face_language.webp")],
	Hud.subject_type.MATH : [preload("res://assets/vector/flashcard_red.webp"), preload("res://assets/vector/face_math.webp")],
	Hud.subject_type.SCIENCE : [preload("res://assets/vector/flashcard_green.webp"), preload("res://assets/vector/face_science.webp")],
	Hud.subject_type.HISTORY : [preload("res://assets/vector/flashcard_purple.webp"), preload("res://assets/vector/face_history.webp")],
	Hud.subject_type.ART : [preload("res://assets/vector/flashcard_orange.webp"), preload("res://assets/vector/face_art.webp")],
	Hud.subject_type.PHILOSOPHY : [preload("res://assets/vector/flashcard_teal.webp"), preload("res://assets/vector/face_philosophy.webp")],
	Hud.subject_type.WILDCARD : [preload("res://assets/vector/flashcard_gold.webp"), preload("res://assets/vector/face_wildcard.webp")],
}

var scene = preload("res://scenes/level_flashcards/flashcards_button.tscn")
var flashcard_wrong = preload("res://assets/vector/flashcard_wrong.webp")
var face_timer = preload("res://assets/vector/face_timer.webp")

var top_node : Control # Get a reference to the current top node.
var gameplay : Gameplay # Used by children as a reference to gameplay to change things.
var hud : Hud

signal scroll_value(value : int)

func _ready():
	gameplay = self.get_parent().get_parent().get_parent()
	hud = self.get_parent().get_parent().get_parent().get_parent()
	
	# Connect the timer end and chances end signals-- telling to force end the question.
	gameplay.answer_chances.connect("CHANCES_ZERO", end)
	gameplay.question_timer.connect("TIMER_ZERO", end)

func start(subject : Hud.subject_type, choices : Array = [["Choice 1", false], ["Choice 2", true], ["Choice 3", true], ["Choice 4", true],["Choice 5", true]]):
	# Load the subject card design.
	subject_card.get_child(1).disabled = true
	subject_card.get_child(1).texture_normal = resources[subject][0]
	subject_card.get_child(1).get_child(0).texture = resources[subject][1]
	
	animation.play("start")
	var queue : Array = []

	# Checks for nodes that are not named "stack" or 1 to be added to the queue.
	for n in range(self.get_child_count()):
		var child = self.get_child(n)
		if child.name == "stack": 
			continue
		queue.append(child)
		child.scale = Vector2(2, 2)
		child.visible = true
	
	await get_tree().process_frame
	for n in queue.size():
		queue[n].queue_free()

	for n in choices.size():
		var choice = scene.instantiate()
		add_child(choice)
		choice.get_child(0).get_child(1).text = choices[n][0]
		
		if choices[n][1] == true:
			choice.get_child(0).get_child(2).texture = choice.get_child(0).correct_face
		else:
			choice.get_child(0).get_child(2).texture = choice.get_child(0).wrong_face
		
		self.move_child(choice, 1)
		choice.get_child(0).start()
		
		choice.scale = Vector2(2, 2)
		choice.position.y = choice.position.y - 3
		choice.get_child(0).scale = Vector2(0.24, 0.24)
		
		if n != 0: choice.visible = false # Invisible if not top node.
		
	emit_signal("scroll_value", -(choices.size() + 1))
	self.move_child(self.get_child(1), 0)
	
func end(caller, _result : Hud.result):
	gameplay.change_stat(hud.stat_type.INTELLIGENCE, 2, Hud.role.ENEMY, Hud.target.ACTIVE)
	gameplay.change_stat(hud.stat_type.INK, 10, Hud.role.ENEMY, Hud.target.ACTIVE)
	
	# Default fallback if the top node is unchanged
	if !is_instance_valid(top_node): top_node = self.get_child(self.get_child_count() - 1).get_child(0)
	
	System.disabled(true)
	
	# Plays the flip animation of the node in the highest layer. Flipping on the main script will mean all choices will flip-- we only need the current active one.
	top_node._on_button_down()
	top_node.get_child(0).play("flip")

	await get_tree().process_frame
	
	# Check which mechanic is calling.
	if caller is QuestionTimer:
		top_node.texture_normal = flashcard_wrong
		top_node.get_child(2).texture = face_timer
		
	# Add more here if more mechanics are used.
	top_node._on_button_up()
	return

func animate():
	await get_tree().create_timer(0.5).timeout

	self.position = Vector2(self.position.x + 200, self.position.y + 200)
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(self.position.x - 200, self.position.y - 200), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

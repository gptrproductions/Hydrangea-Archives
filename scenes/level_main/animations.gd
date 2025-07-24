extends Node
# Note: Animations is a node that contains all multi-node level animations. 
# This means that these animations animate a larger group of nodes-- example, the children of question_canvas has children that has scripts that tween themselves.
# Essentially, this control tweens their parent in conjunction with another node, centralizing it.
# THIS IS STRICTLY JUST ANIMATIONS. NO STATS ARE CHANGED HERE-- THAT'S GAMEPLAY'S RESPONSIBILITY.
# ALSO THESE INCLUDES ANIMATIONS THAT MIGHT NEED A BIT MORE MATH BECAUSE THE POSITION OR ZOOM OR SCALE OF AN OBJECT VARIES
# AND THEREFORE NEEDS TO MAINTAIN THE CURRENT VALUE AND TWEEN FROM THAT VALUE.

signal LOAD_QUESTION

@export var question_canvas : Control
@export var player_canvas : Control
@export var ui_canvas : Control
@export var player_active: Control
@export var enemy_canvas : Control
@export var enemy_active : Control
@export var vignette : Control

@export var camera : Camera2D
@export var effect : AnimationPlayer

var is_cinematic : bool
var is_healthbar : bool

func _ready():
	effect.animation_started.connect(zoom)

func load_question():
	var question = question_canvas.get_node("questions")
	var animation_local = $"../progress/animations" # Contains a canvas' local AnimationPlayer that is played in conjunction with this function.
	
	LOAD_QUESTION.emit()
	
	# Reset positions
	question.position = Vector2(question.position.x, question.position.y + 300)
	animation_local.get_node("timer_entrance").play("start_timer")
	animation_local.get_node("chances_entrance").play("start_chances")
	var tween = create_tween()
	tween.tween_property(question, "position", Vector2(question.position.x, question.position.y - 300), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): tween.kill())

func cinematic(request : bool):
	
	if request == is_cinematic: return # Function does nothing if the cinematic request is to be true, but the cinematic is already true.
	
	if !is_cinematic:
		# Scale the canvas out logic
		vignette.visible = true
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_canvas, "scale", Vector2(2, 1), 0.10).set_ease(Tween.EASE_IN)
		#tween.tween_property(player_active, "scale", Vector2(1, 0.25), 0.10).set_ease(Tween.EASE_IN)
		tween.tween_property(enemy_canvas, "scale", Vector2(2, 1), 0.10).set_ease(Tween.EASE_IN)
		#tween.tween_property(enemy_active, "scale", Vector2(-1, 0.25), 0.10).set_ease(Tween.EASE_IN)
		tween.tween_property(question_canvas, "modulate", Color (1, 1, 1, 0), 0.15)
		tween.tween_property(ui_canvas, "modulate", Color (1, 1, 1, 0), 0.15)
		tween.tween_property(vignette, "modulate", Color (1, 1, 1, 1), 0.15)
		
		await get_tree().create_timer(0.05).timeout
		
		# Move the canvas out logic
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_canvas, "scale", Vector2(0.5, 1), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(player_canvas, "position", Vector2(player_canvas.position.x - 500, player_canvas.position.y), 0.05).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player_active, "scale", Vector2(0.25, 0.25), 0.06).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player_active, "position", Vector2(player_active.position.x - 500, player_active.position.y), 0.05).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_canvas, "scale", Vector2(0.5, 1), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_canvas, "position", Vector2(enemy_canvas.position.x + 500, enemy_canvas.position.y), 0.05).set_ease(Tween.EASE_OUT)
		#tween.tween_property(enemy_active, "scale", Vector2(-0.4, 0.4), 0.06).set_ease(Tween.EASE_OUT)
		#tween.tween_property(enemy_active, "position", Vector2(enemy_active.position.x + 500, enemy_active.position.y), 0.05).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.06).timeout
		
		player_canvas.visible = false
		#player_active.visible = false
		enemy_canvas.visible = false
		#enemy_active.visible = false
		
		# Cinematic Bar logic
		is_cinematic = true

	else:
				
		# Cinematic Bar logic
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_canvas, "scale", Vector2(1.5, 1), 0.06).set_ease(Tween.EASE_IN)
		tween.tween_property(player_canvas, "position", Vector2(player_canvas.position.x + 500, player_canvas.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		#tween.tween_property(player_active, "scale", Vector2(0.3, 0.25), 0.06).set_ease(Tween.EASE_IN)
		#tween.tween_property(player_active, "position", Vector2(player_active.position.x + 500, player_active.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(enemy_canvas, "scale", Vector2(1.5, 1), 0.06).set_ease(Tween.EASE_IN)
		tween.tween_property(enemy_canvas, "position", Vector2(enemy_canvas.position.x - 500, enemy_canvas.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		#tween.tween_property(enemy_active, "scale", Vector2(-0.3, 0.25), 0.06).set_ease(Tween.EASE_IN)
		#tween.tween_property(enemy_active, "position", Vector2(enemy_active.position.x - 500, enemy_active.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		player_canvas.visible = true
		player_active.visible = true
		enemy_canvas.visible = true
		enemy_active.visible = true

		await get_tree().create_timer(0.05).timeout
		
		# Scale the canvas out logic
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_canvas, "scale", Vector2(1, 1), 0.10).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player_active, "scale", Vector2(0.4, 0.4), 0.10).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_canvas, "scale", Vector2(1, 1), 0.10).set_ease(Tween.EASE_OUT)
		#tween.tween_property(enemy_active, "scale", Vector2(-0.4, 0.4), 0.10).set_ease(Tween.EASE_OUT)
		tween.tween_property(question_canvas, "modulate", Color (1, 1, 1, 1), 0.15)
		tween.tween_property(ui_canvas, "modulate", Color.WHITE, 0.15)
		tween.tween_property(vignette, "modulate", Color.TRANSPARENT, 0.15)
		await get_tree().create_timer(0.05).timeout
		vignette.visible = false
		is_cinematic = false

func healthbar(request: bool):
	
	if request == is_healthbar: return # Function does nothing if the healthbar request is to be true, but the cinematic is already true.
	
	if !is_healthbar:

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_active, "scale", Vector2(1, 0.25), 0.10).set_ease(Tween.EASE_IN)
		tween.tween_property(enemy_active, "scale", Vector2(-1, 0.25), 0.10).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(0.05).timeout
		
		# Move the canvas out logic
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_active, "scale", Vector2(0.25, 0.25), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(player_active, "position", Vector2(player_active.position.x - 500, player_active.position.y), 0.05).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_active, "scale", Vector2(-0.4, 0.4), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_active, "position", Vector2(enemy_active.position.x + 500, enemy_active.position.y), 0.05).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.06).timeout

		player_active.visible = false
		enemy_active.visible = false
		is_healthbar = true

	else:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_active, "scale", Vector2(0.3, 0.25), 0.06).set_ease(Tween.EASE_IN)
		tween.tween_property(player_active, "position", Vector2(player_active.position.x + 500, player_active.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(enemy_active, "scale", Vector2(-0.3, 0.25), 0.06).set_ease(Tween.EASE_IN)
		tween.tween_property(enemy_active, "position", Vector2(enemy_active.position.x - 500, enemy_active.position.y), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		player_active.visible = true
		enemy_active.visible = true

		await get_tree().create_timer(0.05).timeout
		
		# Scale the canvas out logic
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(player_active, "scale", Vector2(0.4, 0.4), 0.10).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_active, "scale", Vector2(-0.4, 0.4), 0.10).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(0.05).timeout
		is_healthbar = false
		
func zoom(_current_animation : String):
	return ## for now while we figure thigs out
	#if current_animation != "dead": return
	#var tween = create_tween()
	#tween.tween_property(camera, "zoom", camera.zoom + Vector2(0.4, 0.4), 0.01).set_ease(Tween.EASE_IN)
	#await get_tree().create_timer(0.03).timeout
	#tween = create_tween()
	#tween.tween_property(camera, "zoom", camera.zoom - Vector2(0.4, 0.4), 0.05).set_ease(Tween.EASE_OUT)
	

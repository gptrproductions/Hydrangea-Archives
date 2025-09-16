extends Node2D
class_name Inputs

signal swipe
var swipe_start = null
var minimum_drag = 100

enum direction{UP, DOWN, LEFT, RIGHT}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			swipe_start = event.position
		else:
			_calculate_swipe(event.position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		else:
			_calculate_swipe(event.position)
		
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var input_swipe = swipe_end - swipe_start
	print(swipe)
	if abs(input_swipe.y) > minimum_drag:
		if input_swipe.y > 0:
			emit_signal("swipe", direction.DOWN)
			print("down!")
		else:
			emit_signal("swipe", direction.UP)
			print("up!")

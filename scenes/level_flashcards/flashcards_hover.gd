extends TextureButton
class_name Flashcards_Object2

# actually touch this code and remake it so that it only has one button that changes depending on the scrolled choice.
# keep the animations tho

# Give the child nodes a direct reference to gameplay()   and hud()
var gameplay
var hud
var is_mouse_inside = false
var signal_pressed = false
static var is_scrolling = false
static var is_held_down = false
static var scroll_value = 0
static var is_visibling = false

@export var correct_face : Texture2D
@export var wrong_face : Texture2D

func start():
	await get_tree().create_timer(0.1).timeout
	gameplay = self.get_parent().get_parent().gameplay
	hud = self.get_parent().get_parent().hud
	set_process_input(true)
	self.get_parent().get_parent().move_child(self.get_parent().get_parent().get_node("stack"), 0)
	await get_tree().create_timer(0.1).timeout
	self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 1).get_child(0).disabled = false
	
func _input(event):
	if System.input_disabled: return
	if event is InputEventMouseMotion and is_mouse_inside:
		var mouse_position = event.position
		var relative_mouse_position = mouse_position - position
		var viewport_scale = get_viewport().get_visible_rect().size / size
		var adjusted_mouse_pos = (relative_mouse_position - (size / 2)) / viewport_scale
		adjusted_mouse_pos.x *= size.x / size.y  # Aspect ratio compensation
		self.material.set_shader_parameter("_mousePos", adjusted_mouse_pos)
		
func _on_mouse_entered():
	if System.input_disabled: return
	is_mouse_inside = true
	var tween = create_tween()
	tween.tween_property(self.get_parent().get_parent(), "scale", Vector2(1.05, 1.05), 0.2).set_trans(Tween.TRANS_BACK)

func _on_mouse_exited():
	is_mouse_inside = false
	var tween = create_tween()
	var tween2 = create_tween()
	tween.tween_property(self.material, "shader_parameter/_mousePos", Vector2(0, 0), 0.25).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(self.get_parent().get_parent(), "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	
func _on_button_down() -> void:
	is_held_down = true
	var tween = create_tween()
	tween.tween_property(self.get_parent().get_parent(), "scale", Vector2(0.9, 0.9), 0.10).set_trans(Tween.TRANS_BACK)
	
func _on_button_up() -> void:
	var tween = create_tween()
	tween.tween_property(self.get_parent().get_parent(), "scale", Vector2(1, 1), 0.10).set_trans(Tween.TRANS_BACK)
	is_held_down = false
	
func _on_pressed() -> void:
	if System.input_disabled: return
	System.disabled(true)
	self.disabled = true
	signal_pressed = true
	self.get_child(0).play("flip")
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/_mousePos", Vector2(0, 0), 0.25).set_trans(Tween.TRANS_BACK)
	
	if self.get_child(2).texture == correct_face:
		gameplay.change_stat(hud.stat_type.INTELLIGENCE, 2, Hud.role.PLAYER, Hud.target.ACTIVE)
		gameplay.change_stat(hud.stat_type.INK, 15, Hud.role.PLAYER, Hud.target.ACTIVE)
		get_tree().root.get_node("hud").emit_signal("QUESTION_END", Hud.result.PASSED)
		await get_tree().create_timer(0.1).timeout
		self.texture_normal = preload("res://assets/vector/flashcard_correct.webp")
		await get_tree().create_timer(0.2).timeout
	else:
		gameplay.change_stat(hud.stat_type.TIMER, 2) # Changing the stat of a timer by two means pausing the timer by 2 seconds.
		gameplay.change_stat(hud.stat_type.CHANCES, -1)

		self.texture_normal = preload("res://assets/vector/flashcard_wrong.webp")
		if gameplay.answer_chances.value > 0 or gameplay.answer_chances.max_value == 0: # If chances' max value is zero, it means its infinite, so it will never run out of chances.
			gameplay.change_stat(hud.stat_type.INTELLIGENCE, 1, Hud.role.ENEMY, Hud.target.ACTIVE)
			await get_tree().create_timer(2).timeout
		else: 
			self.get_child(2).texture = preload("res://assets/vector/face_chances.webp")
		
		if gameplay.answer_chances.value > 0 or gameplay.answer_chances.max_value == 0 :
			signal_pressed = false
			System.disabled(false)
		else:
			gameplay.change_stat(hud.stat_type.INK, 10, Hud.role.ENEMY, Hud.target.ACTIVE)	
			signal_pressed = true
			System.disabled(true)
		
		await get_tree().create_timer(1.2).timeout
		
func _on_gui_input(event: InputEvent) -> void:
	if System.input_disabled: return 
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and is_scrolling == false and signal_pressed == false and is_held_down == false:
			visibler(true, MOUSE_BUTTON_WHEEL_UP)
			self.get_parent().get_parent().move_child(self.get_parent().get_parent().get_node("stack"), 0)
			if !self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 2).name == "stack":
				self.get_parent().get_parent().top_node = self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 1).get_child(0)
			else:
				self.get_parent().get_parent().top_node = self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 2).get_child(0)
			
			self.disabled = true
			is_scrolling = true
			self.get_parent().get_parent().move_child(self.get_parent().get_parent().get_child(0), self.get_parent().get_parent().get_child(1).get_index() + scroll_value)
			
			# Set the new top node-- but it references the button inside the control, not the control itself.
			# The reason why this is always 0 is because 0 will always be the next top node.
			var tween = create_tween()
			var tween3 = create_tween()
			tween.set_speed_scale(1.25)
			tween3.set_speed_scale(1.25)
			tween.tween_property(self.get_parent(), "rotation", 2, 0.15).set_trans(Tween.TRANS_SINE)
			tween3.tween_property(self.get_parent().get_parent(), "rotation", 0.1, 0.15).set_trans(Tween.TRANS_SINE)
			await get_tree().create_timer(0.1).timeout
			self.get_parent().get_parent().move_child(self.get_parent(), 0) # Bring the front node to the back.
			var tween2 = create_tween()
			var tween4 = create_tween()
			tween2.set_speed_scale(1.25)
			tween4.set_speed_scale(1.25)
			tween2.tween_property(self.get_parent(), "rotation", 0, 0.40).set_trans(Tween.TRANS_BACK)
			tween2.tween_property(self.get_parent(), "scale", Vector2(2,2), 0.25).set_trans(Tween.TRANS_BACK)
			tween4.tween_property(self.get_parent().get_parent(), "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
			await tween4.finished
			await visibler(false, null, 0.07)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and is_scrolling == false and signal_pressed == false and is_held_down == false:
			visibler(true, MOUSE_BUTTON_WHEEL_DOWN)
			self.get_parent().get_parent().move_child(self.get_parent().get_parent().get_node("stack"), 0)
			if !self.get_parent().get_parent().get_child(0).name == "stack":
				self.get_parent().get_parent().top_node = self.get_parent().get_parent().get_child(0).get_child(0)
			else:
				self.get_parent().get_parent().top_node = self.get_parent().get_parent().get_child(1).get_child(0)
			self.disabled = true
			is_scrolling = true
			# Set the new top node-- but it references the button inside the control, not the control itself.
			# The reason why this is always 0 is because 0 will always be the next top node.
			var tween = create_tween()
			var tween3 = create_tween()
			tween.set_speed_scale(1.25)
			tween3.set_speed_scale(1.25)
			tween.tween_property(self.get_parent().get_parent().top_node.get_parent(), "rotation", -2, 0.15).set_trans(Tween.TRANS_SINE)
			tween3.tween_property(self.get_parent().get_parent() , "rotation", -0.1, 0.15).set_trans(Tween.TRANS_SINE)
			await get_tree().create_timer(0.1).timeout
			self.get_parent().get_parent().move_child(self.get_parent().get_parent().top_node.get_parent(), self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 1).get_index() + scroll_value) # Bring the front node to the second highest
			var tween2 = create_tween()
			var tween4 = create_tween()
			tween2.set_speed_scale(1.25)
			tween4.set_speed_scale(1.25)
			tween2.tween_property(self.get_parent().get_parent().top_node.get_parent(), "rotation", 0, 0.40).set_trans(Tween.TRANS_BACK)
			tween2.tween_property(self.get_parent().get_parent().top_node.get_parent(), "scale", Vector2(2,2), 0.25).set_trans(Tween.TRANS_BACK)
			tween4.tween_property(self.get_parent().get_parent(), "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
			await tween4.finished
			await visibler(false, null, 0.07)
			
		# Checks the current active node's texture, too. If it's the 'incorrect' flashcard, it doesn't enable the button so the player can't click the wrong choice they already clicked.
		if signal_pressed == false and is_scrolling == false and self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 1).get_child(0).texture_normal != preload("res://assets/vector/flashcard_wrong.webp"):
			self.get_parent().get_parent().get_child(self.get_parent().get_parent().get_child_count() - 1).get_child(0).disabled = false
		
func visibler(on_start, event_type, wait : float = 0):
	if on_start:
		for n in self.get_parent().get_parent().get_child_count():
			self.get_parent().get_parent().get_child(n).visible = true
	else:
		await get_tree().create_timer(wait).timeout
		var parent = self.get_parent().get_parent()
		var count = parent.get_child_count()
		var last_index = count - 1
		for n in count:
			var child = parent.get_child(n)
			if child.name == "stack":
				child.visible = true
			elif n == last_index:
				child.visible = true
			else:
				child.visible = false
		is_scrolling = false


func _on_scroll_set(value : int) -> void:
	scroll_value = value

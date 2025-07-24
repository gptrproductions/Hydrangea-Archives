extends TextureRect
class_name Menu_Editor

@export var main_menu : Menu_Main
@export var back_button : BaseButton

func _ready():
	# Add data reading logic here
	visible = false
	modulate = Color.TRANSPARENT
	scale = Vector2(2, 2)
	back_button.pressed.connect(end)
	pass
	
func start(): # Entrance the editor panel.
	visible = false
	modulate = Color.TRANSPARENT
	scale = Vector2(2, 2)
	System.disabled(true)
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	main_menu.get_node("ui").get_node("disabler").color = Color.BLACK # Turn the disabler black by default
	System.disabled(false)

func end(): # Exit the editor panel.
	System.disabled(true)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.BLACK, 0.2)
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	main_menu.animation.play("start_return")
	visible = false
	System.disabled(false)
	

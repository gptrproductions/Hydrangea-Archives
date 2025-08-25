extends Sprite2D

@onready var animation: AnimationPlayer = $animation
@onready var submit: TextureButton = $Path2D/PathFollow2D/TextureButton

func _on_answer_text_changed() -> void:
	var n = randi_range(1, 2)
	
	if animation.is_playing():
		animation.stop()
		
	if n == 1: 
		$animation.play("shake_right")
	else:
		$animation.play("shake_left")
		

func _on_texture_button_pressed() -> void:
	if animation.is_playing():
		animation.stop()
	animation.play("answer")

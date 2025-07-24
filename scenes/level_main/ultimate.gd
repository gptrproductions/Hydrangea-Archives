extends TextureProgressBar
class_name Ultimate

@export var ink : ColorRect
@export var animation : AnimationPlayer
@export var text : Label
@export var button : Control
@export var glow: ColorRect

var ultimate_used : bool = false

func _ready():
	System.INPUT_DISABLED.connect(_disabled)

func change(current_value: int, _target : Hud.target, glow_color : Color):
	
	var tween = create_tween()
	tween.tween_property(self, "value", self.value + current_value, 1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel().tween_property(glow, "color", glow.color +glow_color, 0.15).set_trans(Tween.TRANS_SINE)
	await tween.finished
	tween = create_tween()
	tween.tween_property(glow, "color", glow.color -glow_color, 0.15).set_trans(Tween.TRANS_SINE)
	
func _on_value_changed(current_value: float, target : Hud.role) -> void:
	if self.value < 100:
		ink.material.set("shader_parameter/progress", current_value / 100)
	text.text = str(snappedi(current_value, 1))
	
	if !ultimate_used and self.value >= 100: 
		if target == Hud.role.PLAYER: animation.play("quota_reached")
		else: animation.play("enemy_quota_reached")
		animation.seek(0.15, true)
		ultimate_used = true
		
	if self.value < 100 and ultimate_used == true:
		if target == Hud.role.PLAYER: animation.play("quota_down")
		else: animation.play("enemy_quota_down")
		ultimate_used = false

# Glass hover functions. Controlled by signals since the button textures are stupid.
func _hovered():
	if !System.input_disabled: button.material.set_shader_parameter("HOVER", true)

func _dehovered():
	if !System.input_disabled: button.material.set_shader_parameter("HOVER", false)

func _button_down():
	if !System.input_disabled: button.material.set_shader_parameter("PRESSED", true)
	
func _button_up():
	if !System.input_disabled: button.material.set_shader_parameter("PRESSED", false)
	
func _disabled():
	if button is TextureButton: # Dedicated to the enemy ultimate, which is not a button but a TextureRect.
		button.material.set_shader_parameter("HOVER", false)
		button.material.set_shader_parameter("PRESSED", false)
		pass

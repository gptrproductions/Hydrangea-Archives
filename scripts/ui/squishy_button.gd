extends TextureButton
class_name SquishyButton

var is_mouse_in = false
var texture
var normalized_mouse_pos
var default_scale = self.scale
var active_tween : Tween
var glowable : bool

@export var glow : Control
@export var selector : Selector

func _ready():
	mouse_entered.connect(entered)
	mouse_exited.connect(exited)
	button_down.connect(down)
	
	if is_instance_valid(selector):
		selector.focused.connect(bounce)
	if is_instance_valid(glow):
		glowable = true

func _gui_input(event: InputEvent):
	if is_mouse_in and event is InputEventMouseMotion and !disabled:
		# Get the local mouse position within the button area
		var mouse_pos = event.position
		var button_size = self.size
		normalized_mouse_pos = mouse_pos / button_size
		# Pass the normalized position to the shader
		self.material.set_shader_parameter("mouse_position", normalized_mouse_pos)

func entered():
	is_mouse_in = true
	if glowable and !disabled: 
		glow.visible = true
		self.modulate = Color.WHITE       

func exited():
	if glowable and !disabled: 
		glow.visible = false
		self.modulate = Color.WHITE
	is_mouse_in = false
	
	if self.material.get("shader_parameter/mouse_position") != null:
		var tween = create_tween()
		tween.tween_property(self.material, "shader_parameter/mouse_position", Vector2(0.0, 0.0), 0.2)

func down() -> void:
	if glowable and !disabled: 
		self.modulate = Color(0.7, 0.7, 0.7)
	if active_tween is Tween:
		active_tween.stop()
	var tween = create_tween()
	active_tween = tween
	self.pivot_offset = self.size / 2
	self.scale = default_scale * 0.9
	tween.tween_property(self, "scale", default_scale, 0.2).set_trans(Tween.TRANS_BOUNCE)
	if !glowable : return
	await get_tree().create_timer(0.1).timeout
	self.modulate = Color.WHITE
# Used by buttons that might need manual hovering.
func bounce(node: Control) -> void:
	if self != node: return
	if self.disabled == true : return
	await get_tree().process_frame
	self.pivot_offset = self.size / 2
	self.scale = default_scale * 0.9
	var tween = create_tween()
	active_tween = tween
	tween.tween_property(self, "scale", default_scale, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	

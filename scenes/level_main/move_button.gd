extends TextureButton
class_name Move_Button

@export var selected_effect : Control
@export var value : int = 0
static var selected : int = 0

var is_mouse_in = false
var texture
var normalized_mouse_pos
var default_scale = self.scale
var active_tween : Tween

var unpressed_scale : Vector2 = Vector2(0.95, 0.95)
var unpressed_color : Color = Color(0.75, 0.75, 0.75, 1)
var pressed_scale : Vector2 =  Vector2(1.05, 1.05)
var regular_scale : Vector2 = Vector2(1 ,1)
var regular_color : Color = Color.WHITE

func _ready():
	mouse_entered.connect(entered)
	mouse_exited.connect(exited)
	button_down.connect(down)
	button_up.connect(up)
	pressed.connect(on_pressed)
	Signals.ON_MOVE.connect(animate)

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

func up():
	var tween = create_tween()
	if selected == value:
		tween.tween_property(self, "scale", pressed_scale, 0.05).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self, "scale", unpressed_scale, 0.05).set_ease(Tween.EASE_IN_OUT)
	
func exited():
	is_mouse_in = false
	
	if self.material.get("shader_parameter/mouse_position") != null:
		var tween = create_tween()
		tween.tween_property(self.material, "shader_parameter/mouse_position", Vector2(0.0, 0.0), 0.2)

func down() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", scale * 0.9, 0.05).set_ease(Tween.EASE_IN_OUT)
	
func on_pressed():
	selected = value
	Signals.ON_MOVE.emit(value)
	
func animate(sent_value : int):
	var tween = create_tween()
	if sent_value == value: 
		selected_effect.position = self.position - Vector2(20, 20)
		
		tween.tween_property(self, "modulate", regular_color, 0.05).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "scale", pressed_scale, 0.05).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "rotation", 0.1, 0.05).set_ease(Tween.EASE_IN_OUT)
		tween.set_parallel(false)
		tween.tween_property(self, "rotation", -0.1, 0.05).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "rotation", 0.0, 0.05).set_ease(Tween.EASE_IN_OUT)
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", unpressed_color, 0.05).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", unpressed_scale, 0.15).set_trans(Tween.TRANS_BACK)

static func reset(node : Control, current_selected : Control):
	node.modulate = Color(1, 1 ,1, 1)
	current_selected.visible = false
	node.scale = Vector2(1, 1)

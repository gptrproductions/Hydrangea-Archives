extends TextureButton

func _ready():
	# Autoconnect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_ELASTIC)

func _on_mouse_exited() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	
func _on_button_down() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_ELASTIC)
	self.modulate = Color(0.8, 0.7, 0.6, 1)
	
func _on_button_up() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	self.modulate = Color.WHITE

extends TextureRect

@export var button: TextureButton

func _ready():
	button.pressed.connect(_pressed)
	
func _pressed():
	Character.get_gameplay().get_parent().get_node("menu").entrance()

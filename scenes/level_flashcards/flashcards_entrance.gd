extends TextureButton
class_name Flashcards_Object1

# AAAAAAA DON'T TOUCH ANYTHING UNLESS IT'S TIME TO FIX THAT GOSH DARN BUG.
# YADA YADA YADA THIS MAKES THE CHOICES BOU

@export var flashcard_controller : Control

var animator : Node
var is_mouse_inside = false
var signal_pressed = false
static var is_scrolling = false
static var is_held_down = false
static var scroll_value = 0

func _ready():
	animator = self.get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("ui_canvas").get_node("animations")
	self.pivot_offset = size / 2
	animator.connect("LOAD_QUESTION", animate)
	
func _on_scroll_set(value : int) -> void:
	scroll_value = value
	
func animate():
	System.disabled(true)
	# Reset all scale sizes first. All are and will always be control nodes, so no need for fallback
	for node in self.get_parent().get_parent().get_parent().get_children():
		node.scale = Vector2(2,2)
	await get_tree().create_timer(2).timeout
	$"../animation".play("entrance")
	System.disabled(false)

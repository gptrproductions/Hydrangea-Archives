extends TextureButton
class_name Dropdown

@onready var string: Label = $string
@onready var options: VBoxContainer = $popup/box/options
@onready var box: NinePatchRect = $popup/box
@onready var reference: Button = $reference
@onready var popup: CanvasLayer = $popup
@onready var catcher: Button = $popup/catcher

signal on_hover(element)
signal on_selected(element)

@export var choices : Array[String]
@export var selected : int = 0
@export var box_width_override : float = 0.0
	
var animating : bool = false # Fixes potential timing issues.
var current_size : Vector2 = Vector2.ZERO

const CHECKMARK_COLORED = preload("res://assets/vector/checkmark_radio_selected.webp")
const CHECKMARK_DISABLED = preload("res://assets/vector/checkmark_radio_unselected.webp")

func _ready():
	
	Signals.ON_QUESTION_END.connect(_on_pressed)
	
	if selected > choices.size() -1 or selected < 1: selected = 0 
	if choices.size() == 1: disabled = true
	catcher.connect("pressed", Callable(self, "_on_open").bind(false))
	set_process_unhandled_input(true)
	for n in choices.size():
		var node = reference.duplicate()
		node.text = choices[n]
		options.add_child(node)
		node.visible = true
		node.connect("pressed", Callable(self, "_on_pressed").bind(n))
	await get_tree().process_frame
	box.size.x += box_width_override
	box.size.y = ((98 * choices.size()) * options.scale.y) + 60
	current_size = box.size
	_on_pressed(selected)
	toggled.connect(_on_open)
	scaler() # Check the scale of the thing first.

func _on_open(is_toggled: bool = false):
	if is_toggled:
		scaler()
		box.size.y = 0
		popup.visible = true
		var tween = create_tween()
		tween.tween_property(box, "size", current_size, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		for node in options.get_children():
			node.disabled = false
	else:
		button_pressed = false
		for node in options.get_children():
			node.disabled = true
		var tween = create_tween()
		tween.tween_property(box, "size", Vector2(current_size.x, 0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		await tween.finished
		popup.visible = false
		
func _on_pressed(n : int = selected, via_signal = true):
	button_pressed = false
	if selected > choices.size() - 1 or selected < 1: selected = 0
	selected = n
	for node in options.get_children():
		node.icon = CHECKMARK_DISABLED
	
	string.text = options.get_child(n).text
	options.get_child(n).icon = CHECKMARK_COLORED
	
	if via_signal: on_selected.emit(selected)
	
	var tween = create_tween()
	tween.tween_property(box, "size", Vector2(current_size.x, 0), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween.finished
	popup.visible = false

func scaler():
	box.scale = Vector2(get_global_transform().x.x, get_global_transform().y.y)
	box.global_position = Vector2(self.global_position.x - (box.size.x * box.scale.x) + (99 * box.scale.x), self.global_position.y + (110 * box.scale.y))

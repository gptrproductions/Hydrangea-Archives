extends Control
class_name Level_Effects_List

@export var gameplay : Gameplay
@export var node_size : Vector2 = Vector2(32, 32)
@export var role : Hud.role

signal finished
var is_playing : bool = false
var origin : Vector2
var multiplier : int

func _ready():
	
	if role == Hud.role.PLAYER:
		origin = pivot_offset
		multiplier = 1
	else:
		origin = size
		multiplier = -1
	
	connect("child_entered_tree", Callable(self, "arrange").bind(true))
	child_exiting_tree.connect(arrange)
	child_order_changed.connect(arrange)
	
func arrange(_node: Node = null, entered : bool = false):
	var n := 0
	if is_playing:
		await finished
	
	if entered: _node.position = Vector2((origin.x + (((self.get_child_count() - 1) * 120) * multiplier)), _node.position.y)
	
	is_playing = true
	for node in get_children():
		
		if !is_instance_valid(node): 
			n += 1
			continue
		
		if node.visible == false:
			continue
		
		var tween = create_tween()
		tween.tween_property(node, "position", Vector2((origin.x + ((n * 110) * multiplier)), node.position.y), 0.15).set_trans(Tween.TRANS_BACK)
		n += 1
		await tween.finished
		
	is_playing = false
	finished.emit()

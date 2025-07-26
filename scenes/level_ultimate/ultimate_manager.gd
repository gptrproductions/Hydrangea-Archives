extends TextureRect
## Manages all ultimate viewports.
class_name Level_Ultimate

signal start(viewport: SubViewport, duration: float)

func _ready():
	add_to_group("level_ultimate")
	start.connect(_texture)
	
static func get_viewport_canvas():
	var node = System.tree().get_nodes_in_group("level_ultimate")
	if is_instance_valid(node[0]):
		return node[0]
	return null
	
func _texture(viewport : SubViewport, duration : float):
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_WHEN_VISIBLE
	texture = viewport.get_texture()
	visible = true
	await get_tree().create_timer(duration).timeout
	visible = false
	texture = ImageTexture.new()
	viewport.render_target_update_mode= SubViewport.UpdateMode.UPDATE_DISABLED

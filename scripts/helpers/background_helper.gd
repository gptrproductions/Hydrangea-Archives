extends Control
class_name Background

# If a node wants to modify a background's properties, they can by doing this
static func get_background():
	var gameplay : Gameplay = Character.get_gameplay()
	if is_instance_valid(gameplay):
		return gameplay.get_parent().get_child(0) ## BG IS ALWAYS CHILD 0
	return null

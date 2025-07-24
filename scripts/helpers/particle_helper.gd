extends Resource
class_name Particle ## A helper for separate particle systems. Some particles and attack effects may be put in separate scenes and played that way for modularity.

enum name{ATTACK_TACKLED} # Add more depending on the particle.

## Instantiates and returns a reference to the node.
static func start(particle_name : name, target_node : Node, scale : Vector2 = Vector2(1 ,1)):
	var node
	match particle_name:
		name.ATTACK_TACKLED: node = preload("res://particles/attack_tackled/attack_tackled.tscn")
	node = node.instantiate()
	target_node.add_child(node)
	node.scale = scale
	node.start()
	return node

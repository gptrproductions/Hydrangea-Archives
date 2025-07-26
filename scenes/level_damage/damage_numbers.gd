extends Control
class_name Damage

var scene = preload("res://scenes/level_damage/damage_numbers.tscn")

func start(stat = Hud.stat_type, value : int = 0, role : Hud.role = Hud.role.PLAYER, _target_character: Hud.target = Hud.target.ACTIVE, damage_type : Hud.mindset = Hud.mindset.KINETIC, is_snap : bool = false, is_weak : bool = true, _source_character : Hud.target = Hud.target.NONE, _source_role : Hud.role = Hud.role.NONE):
	# If the move doesn't affect the shield or the health bar of the active character, return.
	if stat != Hud.stat_type.CURRENT_HEALTH: return
	
	var instance = scene.instantiate()

	var _0
	_0 = role
	
	match(damage_type): # For the color of the damage numebr.
		Hud.mindset.KINETIC:
			instance.get_node("value").color = UI.KINETIC_YELLOW
		Hud.mindset.ONEIRIC:
			instance.get_node("value").color = UI.ONEIRIC_BLUE
		Hud.mindset.ALETHIC:
			instance.get_node("value").color = UI.ALETHIC_ORANGE
		Hud.mindset.PHRENIC:
			instance.get_node("value").color = UI.PHRENIC_GREEN
		_:
			instance.get_node("value").color = Color.WHITE
	
	# If weak, do BW scale.
	if is_weak:
		pass
	
	instance.get_node("value").font_size = 48 if is_snap else 36
	instance.get_node("value").font = "SpaceMonoB" if is_snap else "SpaceMono"
	instance.get_node("value").bbcode = str(-value) if is_snap else str(-value)
	instance.z_index = 100
	
	# Where should the damage numbers be located?
	if role == Hud.role.PLAYER: 
		self.get_parent().get_node("players").add_child(instance)
		print(instance.get_parent())
	elif role == Hud.role.ENEMY: 
		self.get_parent().get_node("enemies").add_child(instance)
		print(instance.get_parent())
		instance.scale.x = -2
	instance.position = instance.position - Vector2(randi_range(-50, 50), randi_range(-50, 150))
	
	instance.get_node("value").advance()
	remove(instance)
	var tween = create_tween()
	tween.tween_property(instance, "position", Vector2(instance.position.x, instance.position.y -300), 2)
	await get_tree().create_timer(1).timeout
	tween = create_tween()
	tween.set_parallel().tween_property(instance, "scale", Vector2(0, 0), 0.15).set_trans(Tween.TRANS_SINE)

func remove(node):
	await get_tree().create_timer(2.20).timeout
	node.queue_free()

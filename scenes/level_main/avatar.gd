extends Control

@export var role : Hud.role
@export var health : Health

var flinch_effect : TextureRect
var dead_effect : TextureRect
var has_died := false

func _ready():
	# Connect signals to this script
	Signals.ON_FLINCH.connect(flinched) # The signal is connected to the MAIN Signals autoload since only the active character can flinch.
	flinch_effect = get_node("flinch")
	dead_effect = get_node("dead")
	health.DEAD.connect(dead)
	
# Manages the flinch animation.
func flinched(flinched_role : Hud.role):
	if health.dead : return
	if role != flinched_role:
		return
		
	var icon = flinch_effect.get_node("icon")
	flinch_effect.visible = true
	flinch_effect.self_modulate = Color(2, 2, 2, 1)
	icon.scale = Vector2(1, 1)
	icon.modulate = Color(1, 1, 1, 1)
	
	var tween = create_tween()
	tween.tween_property(flinch_effect, "self_modulate", Color.WHITE, 0.1).set_ease(Tween.EASE_OUT)
	tween.set_parallel().tween_property(icon, "scale", Vector2(1.5, 1.5), 0.5).set_ease(Tween.EASE_OUT)
	tween.set_parallel().tween_property(flinch_effect, "self_modulate", Color(0, 0, 0, 1), 0.5)
	tween.tween_property(icon, "modulate", Color(0, 0, 0, 1), 0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	flinch_effect.visible = false

func dead():
	if has_died : return
	has_died = true
	var icon = dead_effect.get_node("icon")
	dead_effect.visible = true
	dead_effect.self_modulate = Color(1.4, 0, 0.32, 1)
	icon.scale = Vector2(1, 1)
	icon.modulate = Color(1, 1, 1, 1)
	
	var tween = create_tween()
	tween.tween_property(dead_effect, "self_modulate", Color.WHITE, 0.1).set_ease(Tween.EASE_OUT)
	tween.set_parallel().tween_property(icon, "scale", Vector2(1.5, 1.5), 0.5).set_ease(Tween.EASE_OUT)
	tween.set_parallel().tween_property(dead_effect, "self_modulate", Color(0, 0, 0, 1), 0.5)
	tween.tween_property(icon, "modulate", Color(0, 0, 0, 1), 0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	dead_effect.visible = false

extends Camera2D
class_name Level_Camera

var gameplay: Gameplay
var effects : Control
var ultimate_canvas : Control
var start: bool = false
var active_tween : Tween
var active_zoom : Tween
var ui_canvas : Control
var dialog_vignette : Control

const EASE_SPEED := 5

@export var player_pos := Vector2(-284, 44)
@export var enemy_pos := Vector2(276, 44)

func _ready():
	
	await get_tree().process_frame
	gameplay = Character.get_gameplay()
	
	if !is_instance_valid(gameplay):
		System.oops("Level_Camera", "Gameplay doesn't exist! Figure out what made this level camera exist, as Level_Camera should only appear in the Hud node.", System.oops_type.OOF)
		return
	
	effects = gameplay.get_parent().get_node("effects")
	ultimate_canvas = gameplay.get_parent().get_node("ultimate_canvas")
	ui_canvas = gameplay.get_node("ui_canvas")
	dialog_vignette = gameplay.get_node("dialogue_canvas").get_node("vignette")
	start = true
	
func _process(delta):
	if start:
		var new_pos : Vector2 = gameplay.position.lerp(position, EASE_SPEED * delta)
		gameplay.position = new_pos
		#gameplay.scale = Vector2(1.0 / zoom.x, 1.0 / zoom.y)
		effects.position = new_pos
		ultimate_canvas.position = new_pos
		dialog_vignette.position = new_pos
		
func pan(target: Hud.role = Hud.role.NONE, duration : float = 0.25, hard : Tween.EaseType = Tween.EASE_IN_OUT, trans : Tween.TransitionType = Tween.TRANS_SINE):
	if active_tween is Tween: active_tween.kill()

	var pos : Vector2
	if target == Hud.role.PLAYER: pos = player_pos
	elif target == Hud.role.ENEMY: pos = enemy_pos
	else: pos = Vector2.ZERO
	
	var tween = create_tween()
	active_tween = tween
	tween.tween_property(self, "position", pos, duration).set_ease(hard).set_trans(trans)
	await tween.finished
	return

func focus(pos : Vector2 = zoom, duration : float = 0.25, hard : Tween.EaseType = Tween.EASE_IN_OUT, trans : Tween.TransitionType = Tween.TRANS_SINE):
	if active_zoom is Tween: active_zoom.kill()
	var tween = create_tween()
	active_zoom = tween
	tween.tween_property(self, "zoom", pos, duration).set_ease(hard).set_trans(trans)
	await tween.finished
	return
	
func get_pos(role : Hud.role = Hud.role.NONE):
	if role == Hud.role.PLAYER: return player_pos
	elif role == Hud.role.ENEMY: return enemy_pos
	return Vector2.ZERO

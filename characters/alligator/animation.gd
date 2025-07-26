extends AnimationPlayer

# If it detects the the gameplay node isn't present, the character is not being used in a level but was summoned nonetheless.
# This is usually for the chraracter's almanac or character build screen.
var on_display : bool = false

var camera : Level_Camera
var role : Hud.role
var opp : Hud.role
var character_control

var target_position : Vector2
var original_position : Vector2

# Passive stacks. Add more if the character emits more effects
var effect_stack : int = -1
var effect_target : Hud.target

# Some characters have an ultimate canvas. This is where cutscenes or full screen ultimate effects are displayed independent of shit.
# NOTE: Only some characters may have this. DO NOT REFERENCE THIS OUTSIDE THIS SCRIPT OR THE DATA SCRIPT OF A CHARACTER.
@export var ultimate_canvas: Node
# The animation for the CUTSCENE. Can be disabled in the options,
@export var ultimate_cutscene : AnimationPlayer # Or AnimatedSprite, depends.

@export var idle_fixer : Sprite2D # Used sparingly throughout many characters, during times where the transition to idle feels cut off.
func _ready(): # This is good as is for all characters. Don't change.
	
	if Character.get_gameplay() == null: 
		on_display = true
		idle()
		return
	
	character_control = self.get_parent().get_parent() # Get the node itself.
	role = self.get_parent().role # Get the node's current role.
	camera = get_viewport().get_camera_2d() # Get the level's camera.
	opp = Character.get_opponent(role) # Get the opponent.
	target_position = camera.get_pos(opp)
	original_position = camera.get_pos(role)
	
func idle():
	if idle_fixer.position != Vector2.ZERO:
		var tween = create_tween()
		tween.tween_property(idle_fixer, "position", Vector2.ZERO, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(idle_fixer.get_parent(), "rotation", 0, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		await tween.finished
	self.play("idle")

func skill1():
	camera.pan(role)
	self.play("skill_1")
	await get_tree().create_timer(0.1).timeout
	Effect.shake(camera, false, 10, 10, 5, 2)
	await get_tree().create_timer(0.45).timeout
	Effect.flash(Background.get_background(), Color(1, 0.7, 0, 1) * 4, 0.2, 0.0, 0.1)
	await get_tree().create_timer(0.5).timeout
	camera.pan()
	Effects.start(Effects.SPORDERR, role)
	idle()
	print("done")
	return
	
func skill2():
	return

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

@onready var skill3_particle: GPUParticles2D = $"../skill3"

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
		await tween.finished
	self.play("idle")

func skill1():
	self.play("skill_1")
	camera.pan(role)
	Effect.shake(camera, false, 10, 10, 45, 2)
	await camera.focus(Vector2(2.5, 2.5), 1, Tween.EASE_IN, Tween.TRANS_SINE)
	camera.focus(Vector2(1.5, 1.5), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(0.1).timeout
	Effect.flash(Background.get_background(), Color("96E9B8") * 4, 0.2, 0.0, 0.1)
	await get_tree().create_timer(0.55).timeout
	camera.pan()
	camera.focus(Vector2(1, 1), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await self.animation_finished
	Effects.start(Effects.SPORDERR, role)
	idle()
	
func skill2():
	print(Character.get_target(self.get_parent()))
	self.play("skill_2")
	camera.pan(role)
	camera.focus(Vector2(1.5, 1.5), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(2.0).timeout
	camera.pan(opp)
	character_control.position = target_position
	# Emit this function a few times to time damage takes with animations.
	await get_tree().create_timer(0.5).timeout
	Particle.start(Particle.name.ATTACK_TACKLED, character_control, Vector2(2,2))
	var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_2)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.PHRENIC, values.get("is_snap", false), false, Character.get_target(self.get_parent()), role)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.PHRENIC, false, false, Character.get_target(self.get_parent()), role)
	Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control
	Effect.shake(camera, false, 10, 10, 5, 0)
	await get_tree().create_timer(0.8).timeout
	var tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 0.5)
	camera.pan()
	camera.focus(Vector2(1, 1), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	idle()
	return

func skill3():
	self.play("skill_3")
	if role == Hud.role.ENEMY: 
		skill3_particle.process_material.set("gravity", Vector3(-800, 0, 0))
		skill3_particle.position.x = 300
	else:
		skill3_particle.process_material.set("gravity", Vector3(800, 0, 0))
		skill3_particle.position.x = 300
		
	camera.pan(role)
	Effect.shake(camera, false, 12, 12, 45, 2)
	await camera.focus(Vector2(1.8, 1.8), 1, Tween.EASE_IN, Tween.TRANS_SINE)
	camera.focus(Vector2(1.2, 1.2), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(0.1).timeout
	Effect.flash(Background.get_background(), Color("96E9B8") * 4, 0.2, 0.0, 0.1)
	await get_tree().create_timer(0.5).timeout
	camera.pan(opp)
	
	await get_tree().create_timer(2).timeout
	camera.pan()
	camera.focus(Vector2(1, 1), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await self.animation_finished
	Effects.start(Effects.SPORDERR, role)
	idle()

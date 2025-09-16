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
var opp_control

# Passive stacks. Add more if the character emits more effects
var effect_stack : int = -1
var effect_target : Hud.target

var skill1_stack : int = 0

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
	opp_control = Character.get_node_role(opp)
	target_position = camera.get_pos(opp)
	original_position = camera.get_pos(role)
	
func idle(transition_to_3: bool = false):
	if transition_to_3: # Use this to smoothly transition to skill3.
		var tween = create_tween()
		tween.tween_property(idle_fixer, "position", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(idle_fixer, "rotation", 3.14, 0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		await tween.finished
		return
	if idle_fixer.position != Vector2.ZERO or idle_fixer.rotation != 3.14:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(idle_fixer, "position", Vector2.ZERO, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(idle_fixer.get_parent(), "rotation", 0, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		await tween.finished
	self.play("idle")

func skill1():
	camera.pan(role)
	if skill1_stack > 4:
		
		self.play("skill_1_fail")
		await get_tree().create_timer(0.45).timeout
		Effect.flash(Background.get_background(), Color(1, 0.0, 0, 1) * 4, 0.2, 0.0, 0.1)
		await get_tree().create_timer(1).timeout
	else:
		self.play("skill_1")
		var gameplay: Gameplay = Character.get_gameplay()
		gameplay.change_stat(Hud.stat_type.RESISTANCE, 5, role, Character.get_target(self.get_parent()))
		skill1_stack += 1
		await get_tree().create_timer(0.1).timeout
		Effect.shake(camera, false, 10, 10, 5, 2)
		await get_tree().create_timer(0.45).timeout
		Effect.flash(Background.get_background(), Color(1, 0.7, 0, 1) * 4, 0.2, 0.0, 0.1)
	
	await get_tree().create_timer(0.5).timeout
	camera.pan()
	idle()
	Signals.MOVE_FINISHED.emit(Hud.skills.SKILL_1)
	Signals.DEATHCHECK_FINISHED.emit(false) # Emit it on moves that dont kill.
	return
	
func skill2():
	await idle(true)
	self.play("skill_2")
	camera.pan(role)
	await camera.focus(Vector2(1.5, 1.5), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(0.1).timeout
	camera.pan(opp, 0.3)
	await get_tree().create_timer(0.2).timeout

	# Emit this function a few times to time damage takes with animations.
	Particle.start(Particle.name.ATTACK_TACKLED, opp_control, Vector2(2, 2))
	Effect.shake(camera, false, 10, 10, 5)
	var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_2)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.KINETIC, values.get("is_snap", false), false, Character.get_target(self.get_parent()), role)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.KINETIC, false, false, Character.get_target(self.get_parent()), role)
	Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control
	
	var tween = create_tween()
	if role == Hud.role.PLAYER: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(70, 0), 0.1).set_ease(Tween.EASE_IN)
	else: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(-70, 0), 0.1).set_ease(Tween.EASE_IN)
	
	camera.focus(Vector2(2, 2), 0.25, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.9).timeout
	
	tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 0.5)
	camera.focus(Vector2(1, 1), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(Hud.role.NONE, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	idle()
	Signals.MOVE_FINISHED.emit(Hud.skills.SKILL_2)
	return

func skill3():
	await idle(true)
	self.play("skill_3")
	camera.pan(role)
	await camera.focus(Vector2(1.5, 1.5), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await animation_finished
	camera.focus(Vector2(1, 1), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(role)
	await get_tree().create_timer(0.2).timeout
	var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_3)
	Effects.start(Effects.DAMASCUS, role, abs(values.get("damage", 1)))
	await get_tree().create_timer(0.2).timeout
	idle()
	Signals.MOVE_FINISHED.emit(Hud.skills.SKILL_3)
	Signals.DEATHCHECK_FINISHED.emit(false) # Emit it on moves that dont kill.
	return

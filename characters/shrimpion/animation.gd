extends AnimationPlayer

# If it detects the the gameplay node isn't present, the character is not being used in a level but was summoned nonetheless.
# This is usually for the chraracter's almanac or character build screen.
var on_display : bool = false

var camera : Level_Camera
var role : Hud.role
var opp : Hud.role
var character_control
var opp_control

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

func _ready(): # This is good as is for all characters. Don't change.
	
	if Character.get_gameplay() == null: 
		on_display = true
		idle()
		return
	
	character_control = self.get_parent().get_parent() # Get the node itself.
	role = self.get_parent().role # Get the node's current role.
	opp_control = character_control.get_parent().get_node("enemies") if role == Hud.role.PLAYER else character_control.get_parent().get_node("players") 
	camera = get_viewport().get_camera_2d() # Get the level's camera.
	opp = Character.get_opponent(role) # Get the opponent.
	target_position = camera.get_pos(opp)
	original_position = camera.get_pos(role)
	
func idle(): # Also good as is, unless the character has multiple idles.
	self.play("idle")

func skill1():
	self.play("skill_1")
	camera.pan(role)
	await camera.focus(Vector2(1.5, 1.5), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(opp, 1)
	
	var tween = create_tween()
	if role == Hud.role.PLAYER: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(70, 0), 1)
	else: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(-70, 0), 1)
	await tween.finished
	
	if Character.get_stats(self.get_parent())["dead"]: return
	await get_tree().create_timer(0.6).timeout
	camera.focus(Vector2(2, 2), 0.25, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(0.4).timeout
	
	# Emit this function a few times to time damage takes with animations.
	for n in 3:
		var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_1)
		Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, values.get("is_snap", false), false, Character.get_target(self.get_parent()), role)
		Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, false, false, Character.get_target(self.get_parent()), role)
		Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control
		await get_tree().create_timer(0.2).timeout
	
	tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 0.5)
	camera.focus(Vector2(1, 1), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(Hud.role.NONE, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	idle()
	return

func skill2():
	self.play("skill_2")
	camera.pan(role)
	await camera.focus(Vector2(1.5, 1.5), 0.6, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1.25).timeout
	await camera.pan(opp, 0.1)
	
	var tween = create_tween()
	if role == Hud.role.PLAYER:
		tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(70, 0), 0.1)
	else:
		tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(-70, 0), 0.2)

	camera.focus(Vector2(2, 2), 0.25, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)

	# Emit this function a few times to time damage takes with animations.
	for n in 4:
		var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_2)
		Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, values.get("is_snap", false), false, Character.get_target(self.get_parent()), role)
		Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, false, false, Character.get_target(self.get_parent()), role)
		Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control
		await get_tree().create_timer(0.2).timeout
	
	tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 0.5)
	camera.focus(Vector2(1, 1), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(Hud.role.NONE, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	idle()
	return

func skill3():
	self.play("skill_3")
	camera.pan(role)
	await camera.focus(Vector2(1.5, 1.5), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(0.1).timeout
	camera.pan(opp, 0.3)
	await get_tree().create_timer(0.2).timeout

	# Emit this function a few times to time damage takes with animations.
	Particle.start(Particle.name.ATTACK_TACKLED, opp_control, Vector2(2, 2))
	Effect.shake(camera, false, 10, 10, 5)
	var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_3)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, values.get("is_snap", false), false, Character.get_target(self.get_parent()), role)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, false, false, Character.get_target(self.get_parent()), role)
	Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control
	
	var tween = create_tween()
	if role == Hud.role.PLAYER: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(70, 0), 0.1).set_ease(Tween.EASE_IN)
	else: tween.set_parallel().tween_property(character_control, "position", target_position - Vector2(-70, 0), 0.1).set_ease(Tween.EASE_IN)
	
	camera.focus(Vector2(2, 2), 0.25, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.9).timeout
	Effects.start(Effects.SHINGLES, Character.get_opponent(role))
	
	tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 0.5)
	camera.focus(Vector2(1, 1), 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	camera.pan(Hud.role.NONE, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_BACK)
	await get_tree().create_timer(1).timeout
	idle()
	return

func skill4():
	
	if true: # Replace with autoload option that tells whether to skip ultimate animations or not
		Character.get_gameplay().visible = false
		ultimate_cutscene.play("start")
		await get_tree().create_timer(3).timeout
	self.play("skill_4")
	Level_Ultimate.get_viewport_canvas().start.emit(ultimate_canvas, 4) # Send the ultimate effect viewport. Some characters may not have this so use depending on the character.
	Effect.shake(ultimate_canvas.get_node("combat_effect"), false, 5, 1, 8)
	Effect.shake(Character.get_gameplay().get_parent().get_node("characters"), false, 5, 1, 8)
	var original_index = character_control.z_index 
	character_control.z_index = -10
	await get_tree().create_timer(0.4).timeout
	Character.get_gameplay().visible = true
	camera.pan(opp)
	camera.focus(Vector2(1.5, 1.5), 0)
	var tween = create_tween()
	tween.tween_property(character_control, "position", Vector2(target_position.x * 4, original_position.y), 1).set_ease(Tween.EASE_OUT)
	
	var values : Dictionary = self.get_parent().math(Hud.target.ACTIVE, role, Hud.skills.SKILL_4)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_HEALTH, values.get("damage", -1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, values.get("is_snap", false), false ,Character.get_target(self.get_parent()), role)
	Signals.emit_signal("ON_ATTACKED", Hud.stat_type.CURRENT_FLINCH, values.get("flinch", 1), Character.get_opponent(role), Hud.target.ACTIVE, Hud.mindset.ALETHIC, false, false, Character.get_target(self.get_parent()), role)
	Character.get_attack(Hud.target.ACTIVE, role) # Manually trigger damage animation for control

	await get_tree().create_timer(1.2).timeout
	Effect.shake(ultimate_canvas.get_node("combat_effect"), false, 5, 1, 9)
	Effect.shake(Character.get_gameplay().get_parent().get_node("characters"), false, 5, 1, 9)
	await get_tree().create_timer(0.4).timeout
	tween = create_tween()
	tween.tween_property(character_control, "position", original_position, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	camera.focus(Vector2.ONE, 0.25, Tween.EASE_OUT, Tween.TRANS_SINE)
	await camera.pan()
	character_control.z_index = original_index
	await get_tree().create_timer(1).timeout
	idle()
	

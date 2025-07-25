extends TextureProgressBar
class_name Flinch

# References to the flinch active nodes.
@export var progress : Control
@export var glow : ColorRect
@export var particle : GPUParticles2D

@export var flinch_material : ShaderMaterial
@export var role : Hud.role
@export var effect : AnimationPlayer
@export var parent : Control
@export var health : Health

var gameplay : Gameplay
const glow_color : Color = Color(0.5, 0.2, 0.32, 1)

var flinch_type : Hud.mindset # Records the newest flinch instance's type.
var is_flinch := false
var flinched_after_question := false # Becomes true if the flinch occurs after it.
var first_switch : bool = true # Only true during first switch. Forces visual nodes to be visible upon first switch.

# Other flinch types don't have stacks since they're one-off effects.
var kinetic_stack = -1
var nightmare_stack = -1

func _ready():
	gameplay = Character.get_gameplay()
	if role == Hud.role.PLAYER:
		value_changed.connect(_on_player_value_changed)
	else:
		value_changed.connect(_on_enemy_value_changed)
	Signals.ON_QUESTION_START.connect(flinch_effect)
	
func switch(active_character : int, current_role : Hud.role):
	match current_role:
		Hud.role.PLAYER:
			value = gameplay.player_stats[active_character]["current_flinch"]
			max_value = gameplay.player_stats[active_character]["max_flinch"]
			is_flinch = gameplay.player_stats[active_character]["flinched"]
			#progress.visible = gameplay.player_stats[active_character]["flinched"] or first_switch
			glow.visible = gameplay.player_stats[active_character]["flinched"] or first_switch
			particle.visible = gameplay.player_stats[active_character]["flinched"]
		Hud.role.ENEMY:
			value = gameplay.enemy_stats[active_character]["current_flinch"]
			max_value = gameplay.enemy_stats[active_character]["max_flinch"]
			is_flinch = gameplay.enemy_stats[active_character]["flinched"]
			#progress.visible = gameplay.enemy_stats[active_character]["flinched"] or first_switch
			glow.visible = gameplay.enemy_stats[active_character]["flinched"] or first_switch
			particle.visible = gameplay.enemy_stats[active_character]["flinched"]
	first_switch = false # Becomes false for the rest of the level.
			
func change(target_value, _target_character : Hud.target, mindset : Hud.mindset):

	# Don't allow flinch value to change. This is if certain conditions require flinch to change value in the middle of the flinch.
	if is_flinch : return
	
	# Future sight-- flicks the flinch in advance when it notices to goes to max value before it gets there.
	if target_value + value > max_value:
		var target_atm : int
		target_atm = Character.targetify(Hud.target.ACTIVE, role)
		if role == Hud.role.PLAYER: gameplay.player_stats[target_atm]["flinched"] = true 
		else: 
			print("sd")
			gameplay.enemy_stats[target_atm]["flinched"] = true 
	
	flinch_type = mindset
	var tween = create_tween()
	tween.tween_property(self, "value", self.value + target_value, 0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func _on_enemy_value_changed(current_value: float) -> void:
	if health.dead == true: return
	gameplay.enemy_stats[gameplay.active_enemy]["current_flinch"] = current_value
	flinch_material.set("shader_parameter/progress", (current_value / max_value))
	if current_value >= max_value:
		# Just in case the active character had changed mid-flinch (which usually doesnt), keep the current active character in memory by converting it to the cahracter position instead.
		var target_atm = Character.targetify(Hud.target.ACTIVE, role)
		gameplay.enemy_stats[target_atm]["flinched"] = true
		Signals.ON_FLINCH.emit(Hud.role.ENEMY)
		is_flinch = true
		await full()
		
func _on_player_value_changed(current_value : float) -> void:
	if health.dead == true: return
	gameplay.player_stats[gameplay.active_character]["current_flinch"] = current_value
	flinch_material.set("shader_parameter/progress", (current_value / max_value))
	if current_value >= max_value:
		# Just in case the active character had changed mid-flinch (which usually doesnt), keep the current active character in memory by converting it to the cahracter position instead.
		var target_atm = Character.targetify(Hud.target.ACTIVE, role)
		gameplay.player_stats[target_atm]["flinched"] = true
		Signals.ON_FLINCH.emit(Hud.role.PLAYER)
		is_flinch = true
		await full()
		await get_tree().process_frame
	
func full(_dummy = null, _dummy2 = null):
	if role == Hud.role.PLAYER and gameplay.player_stats[Character.targetify(Hud.target.ACTIVE, role)]["already_flinched"]: 
			await Signals.ON_QUESTION_START
			return # Ignore if the character is currently flinched
	elif role == Hud.role.ENEMY and gameplay.enemy_stats[Character.targetify(Hud.target.ACTIVE, role)]["already_flinched"]: 
			await Signals.ON_QUESTION_START
			return # Ignore if the character is currently flinched
			
	if role == Hud.role.PLAYER: gameplay.player_stats[Character.targetify(Hud.target.ACTIVE, role)]["already_flinched"] = true
	elif role == Hud.role.ENEMY: gameplay.enemy_stats[Character.targetify(Hud.target.ACTIVE, role)]["already_flinched"] = true

	System.disabled(true)
	if effect.is_playing():
		effect.stop()
		effect.play("RESET")
	effect.play("flinch_player") # THATS JUST THE NAME, IT'S ACTUALLY THE FLINCH FOR ALL ROLES
	Effect.shake(parent, false, 7, 3, 3)
	flinch_effect(flinch_type) # Trigger the flinch effect.
	glow.modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(glow, "modulate", glow_color, 0.2)
	particle.visible = true
	glow.visible = true
	flinch_material.set("speed", 1)
	await get_tree().create_timer(0.5).timeout
	System.disabled(false)
	await Signals.ON_QUESTION_START
	if role == Hud.role.PLAYER: await empty_player()
	else: await empty_enemy()
	return 0
	
func empty_player():
	var tween = create_tween()
	tween.tween_property(glow, "modulate", Color.WHITE, 0.2)
	await tween.finished
	glow.visible = false
	is_flinch = false
	if gameplay.player_stats[Character.targetify(Hud.target.ACTIVE, Hud.role.PLAYER)]["flinched"]:
		gameplay.change_stat(Hud.stat_type.CURRENT_FLINCH, -max_value, Hud.role.PLAYER, Hud.target.ACTIVE, Hud.mindset.KINETIC)
		tween = create_tween()
		tween.tween_property(glow, "modulate", glow_color, 0.2)
		particle.visible = false
		flinch_material.set("speed", 0.2)
		await tween.finished
		
	for key in gameplay.player_stats.keys():
		if gameplay.player_stats[key]["flinched"]:
			gameplay.player_stats[key]["current_flinch"] = 0
			gameplay.player_stats[key]["flinched"] = false
			gameplay.player_stats[key]["already_flinched"] = false
	return 
	
func empty_enemy():
	var tween = create_tween()
	tween.tween_property(glow, "modulate", Color.WHITE, 0.2)
	await tween.finished
	glow.visible = false
	is_flinch = false
	if gameplay.enemy_stats[Character.targetify(Hud.target.ACTIVE, Hud.role.ENEMY)]["flinched"]:
		tween = create_tween()
		gameplay.change_stat(Hud.stat_type.CURRENT_FLINCH, -max_value, Hud.role.ENEMY, Hud.target.ACTIVE, Hud.mindset.KINETIC)
		tween.tween_property(glow, "modulate", glow_color, 0.2)
		particle.visible = false
		flinch_material.set("speed", 0.2)
		await tween.finished
	# Set everyone's flinch to false. This is non-discriminating as all flinches will end after a question anyway.
	for key in gameplay.enemy_stats.keys():
		if gameplay.enemy_stats[key]["flinched"]:
			gameplay.enemy_stats[key]["current_flinch"] = 0
			gameplay.enemy_stats[key]["flinched"] = false
			gameplay.enemy_stats[key]["already_flinched"] = false

	return
	
func flinch_effect(type: Hud.mindset = Hud.mindset.NONE):
	
		match(type):
			Hud.mindset.KINETIC:
				Effects.start(Effects.FLINCH_KINETIC, role)
			Hud.mindset.ALETHIC:
				gameplay.change_stat(Hud.stat_type.INTELLIGENCE, +2, role)

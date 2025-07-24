extends TextureProgressBar
class_name Chances
var CLASS_NAME  = "chances" # Used by nerd, oops, and other conditions. Since codign is stupid, set it up to have the same name as the class name. It's okay not to, though.

@export var particle_limited : GPUParticles2D
@export var particle_infinite : GPUParticles2D
@export var particle_zero : GPUParticles2D
@export var text : Label
@export var glow : ColorRect
@export var timer : TextureProgressBar
@export var infinite_icon : TextureRect

const light_glow : Color = Color(0.95, 0.6, 0, 1)
const dark_glow : Color = Color(0.51, 0.38, 0.102, 1)
const glow_red : Color = Color("900010")

var gameplay : Gameplay

# Signal emitted that can be received by question type nodes so they can end input.
signal CHANCES_ZERO

func _ready():
	gameplay = Character.get_gameplay()
	timer.TIMER_ZERO.connect(end)
	CHANCES_ZERO.connect(end)
	self.value_changed.connect(_on_progress_bar_value_changed)
	await get_tree().create_timer(2).timeout

func start(chances : int = 1):

	# Set default for values that are used for two of these three conditionals.
	text.visible = true
	particle_zero.visible = false
	glow.color = dark_glow
	
	if chances < 1:
		particle_limited.visible = false
		particle_infinite.visible = true
		infinite_icon.visible = true
		text.visible = false
		self.max_value = 0
		
	if chances >= 1:
		particle_limited.visible = true
		particle_infinite.visible = false
		infinite_icon.visible = false
		self.max_value = chances
	
	if chances > 10:
		System.oops(CLASS_NAME, "Okay, do you really need that much chances?", System.oops_type.NOTICE)
	
	text.text = str(int(self.max_value))
	self.value = self.max_value
	
func change(amount : int = -1):
	
	# If the value is already zero before any value is changed, assume the lives count is infinite.
	if self.max_value == 0:
		System.nerd(CLASS_NAME, "The current question has infinite lives, so deductions will do nothing.")
		return
	
	self.value = self.value + amount
	Effect.shake(self)
	
	if amount < 0: # Flashes red if lives are reduced
		Effect.flash(self, Color(1, 0, 0.2, 1), 0.5, 0, 0.2)
	elif amount > 0: # Flashes blue if lives are increased
		Effect.flash(self, Color(0.3, 0, 1, 1), 0.5, 0, 0.2)
	else:
		System.oops(CLASS_NAME, "The chances bar didn't budge. Is this intended?", System.oops_type.NOTICE)
	
	# Nerd out the values
	System.nerd(CLASS_NAME, "The amount was changed by " + str(amount) + ". There are " + str(self.max_value) + " available chances remaining.")
	
	# This part of the func downwards is if the value of the chances reaches zero.
	if self.value > 0:
		return
		
	CHANCES_ZERO.emit(self, Hud.result.FAILED)
	gameplay.get_parent().emit_signal("QUESTION_END", Hud.result.FAILED)
	
# Emits when change() is emitted.
func _on_progress_bar_value_changed(current_value: float):
	text.text = str(int(current_value))

func end(_source, result):
	if result == Hud.result.FAILED:
		particle_limited.visible = false
		particle_limited.visible = false
		particle_infinite.visible = false
		particle_zero.visible = true
		
		var tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.1, 0)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.525, 0)
		tween.set_parallel().tween_property(glow, "color", glow_red, 0)
		await tween.finished
		tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.3, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.605, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow, "color", glow_red, 0.5).set_trans(Tween.TRANS_SINE)

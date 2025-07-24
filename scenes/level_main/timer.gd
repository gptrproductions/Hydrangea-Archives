extends TextureProgressBar
class_name QuestionTimer

# Refers to the icon being used by the progressbar.
@export var icon = TextureRect
@export var text = Label

# Refers to the effect used if the thing is infinite or not.
@export var infinite_effect : GPUParticles2D
@export var timed_effect : GPUParticles2D
@export var zero_effect : GPUParticles2D

@export var infinite_icon : TextureRect
@export var glow = ColorRect

const light_glow : Color = Color(0.95, 0.6, 0, 1)
const dark_glow : Color = Color(0.51, 0.38, 0.102, 1)
const glow_red : Color = Color("900010")

var gameplay : Gameplay
var current_tween : Tween
var math : float = 0.5

# Signal emitted that can be received by question type nodes so they can end input.
signal TIMER_UPDATED(current_value : float)
signal TIMER_ZERO(result : Hud.result)

func _ready():
	gameplay = Character.get_gameplay()
	self.value_changed.connect(_on_progress_bar_value_changed)
	self.get_parent().get_parent().get_parent().get_parent().connect("QUESTION_END", end)

func start(duration = 5):
	zero_effect.visible = false
	if duration < 1:
		infinite_effect.visible = true
		infinite_icon.visible = true
		timed_effect.visible = false
		text.visible = false
		glow.color = light_glow
		self.max_value = 100 # Set to 100 instead of 0 because 0 breaks the game logic
		self.value = self.max_value
		await get_tree().create_timer(2).timeout
		Signals.ON_TIMER_START.emit()
		return
		
	# Default resets
	zero_effect.visible = false
	glow.color = dark_glow
	infinite_effect.visible = false
	infinite_icon.visible = false
	timed_effect.visible = true
	text.visible = true
	self.max_value = duration
	self.value = self.max_value
	math = ((self.size.x / 2) * 0.98) / self.max_value
	
	# Call manually before tween starts to update the position of the timer and bar effect positions.
	_on_progress_bar_value_changed(self.max_value)
	
	var tween = create_tween()
	tween.tween_property(self, "value", 0, duration)
	current_tween = tween
	await pause(2)
	Signals.ON_TIMER_START.emit()
	
func _on_progress_bar_value_changed(current_value: float):
	timed_effect.position = Vector2((current_value) * math, timed_effect.position.y)
	text.text = str(current_value)
	
	TIMER_UPDATED.emit(current_value)
	
	if current_value in [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]:
		var tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.3, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.625, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow, "color", light_glow, 0.5).set_trans(Tween.TRANS_SINE)
		await tween.finished
		tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.1, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.825, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow, "color", dark_glow, 0.5).set_trans(Tween.TRANS_SINE)

	if current_value == 0.0:
		Effect.shake(self)
		Effect.flash(self, Color(1, 0, 0.2, 1), 0.5, 0, 0.2)
		TIMER_ZERO.emit(self, Hud.result.FAILED)
		gameplay.get_parent().emit_signal("QUESTION_END", Hud.result.FAILED)

# Function to pause the timer with a set duration.
func pause(duration = 0):
	
	if duration < 0: 
		duration = -duration
		System.oops("Timer -> Pause", "You sent a negative countdown value-- I positived it for you.", System.oops_type.NOTICE)
	elif duration == 0:
		System.nerd(str(self), "Pausing indefinitely...")

	if is_instance_valid(current_tween) and current_tween is Tween:
		current_tween.pause()
		if duration == 0: return
		await get_tree().create_timer(duration).timeout
		if current_tween.is_valid(): current_tween.play()
	else:
		System.oops("Timer -> Pause", "The tween is already dead so we can't pause it.", System.oops_type.BAD)

func resume():
	if !(is_instance_valid(current_tween) and current_tween is Tween): return
	if current_tween.is_valid(): current_tween.play()

func end(result):
	if is_instance_valid(current_tween) and current_tween is Tween:
		current_tween.kill()
	else:
		System.oops("Timer -> End", "The tween is already dead so there really isn't anything to kill.", System.oops_type.NOTICE)
	
	if result == Hud.result.FAILED:
		infinite_effect.visible = false
		timed_effect.visible = false
		zero_effect.visible = true
			
		var tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.1, 0)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.525, 0)
		tween.set_parallel().tween_property(glow, "color", glow_red, 0)
		await tween.finished
		tween = create_tween()
		tween.tween_property(glow.material, "shader_parameter/b_offset", 0.3, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow.material, "shader_parameter/smooth_fade", 0.605, 0.5).set_trans(Tween.TRANS_SINE)
		tween.set_parallel().tween_property(glow, "color", glow_red, 0.5).set_trans(Tween.TRANS_SINE)

extends TextureRect
class_name Sudo

@export var sudo_button: TextureButton
@export var sudo_point : TextureRect

var gameplay : Gameplay
var amount : int = 1
var stop : bool = false

func _ready():
	sudo_point.get_node("animation").play("appear")
	sudo_button.pressed.connect(start)
	gameplay = Character.get_gameplay()
	gameplay.get_parent().QUESTION_END.connect(full_stop)
	Signals.ON_QUESTION_START.connect(full_start)
	
func start():
	var text_effect = gameplay.get_parent().get_node("effects").get_node("text_effect")
	
	await get_tree().process_frame
	
	if stop: return # Avoid time conflicts
	
	if amount <= 0: 
		sudo_point.get_node("animation").play("blink")
		return
	
	amount -= 1
	gameplay.question_timer.end(Hud.result.PASSED)
	gameplay.question_timer.start(0)
	if gameplay.current_question_type == Hud.question_type.COINFLIP: return # Coinflip doesn't make chances infinite.
	gameplay.answer_chances.start(0)
	
	if sudo_point.get_node("animation").is_playing():
		sudo_point.get_node("animation").stop()
	
	if text_effect.is_playing():
		text_effect.stop()

	sudo_point.get_node("animation").play("disappear")
	text_effect.play("sudo")

func full_stop(_result):
	stop = true

func full_start():
	stop = false
	
	

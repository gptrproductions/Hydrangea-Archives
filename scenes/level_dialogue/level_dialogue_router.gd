extends Node
class_name level_dialogue_router

var data

func trigger(value : int):
	var override : bool = false # If this is true during the pre-checks, trigger the dialog anyway. This is done when a value doesn't need to be exactly the value stored in the data but is still qualified to be triggered.
	
	if (data.triggered == Questionnaire_Dialogue.dialogue_signals.PLAYER_KILLED or Questionnaire_Dialogue.dialogue_signals.ENEMY_KILLED) and value == 1 and data.value == 0:
		override = true
	
	if data.value == value or override:
		self.get_parent().emit_dialog(data)
		queue_free()

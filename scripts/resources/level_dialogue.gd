extends Resource
class_name Questionnaire_Dialogue

enum dialogue_signals {
	LEVEL_START, ## The dialog is played once the level starts. The dialog's value is ignored.
	QUESTION_NUMBER_ID, ## The dialog is played right before a question starts. The dialog's value pertains to the question ID the dialog will trigger on.
	QUESTION_NUMBER_SHUFFLE, ## The dialog is played right before a question starts. The dialog's value pertains to the current in-level question number the dialog will trigger on.
	QUESTION_PASSED, ## The dialog is played right after a question is passed. The dialog's value pertains to the question ID the number the dialog will trigger on.
	QUESTION_FAILED, ## The dialog is played right after a question is failed. The dialog's value pertains to the question ID the number the dialog will trigger on.
	PLAYER_ULTIMATE, ## The dialog is played right before a player uses its ultimate. The dialog's value pertains to how many times the player ultimate has to have been used before triggering the dialog.
	ENEMY_ULTIMATE, ## The dialog is played right before an enemy uses its ultimate. The dialog's value pertains to how many times the enemy ultimate has to have been used before triggering the dialog.
	PLAYER_KILLED, ## The dialog is played right after a player dies. The dialog's value pertains to the amount of currently dead players (Up to 3) needed for the dialog to be played. If the value is set to 3, it's effectively a defeat message.  
	ENEMY_KILLED, ## The dialog is played right after an enemy dies. The dialog's value pertains to the amount of currently dead enemies (Up to 3) needed for the dialog to be played. If the value is set to 3, it's effectively a victory message.  
}

@export var triggered: dialogue_signals ## Tells which signal to wait for in order to make the dialog play. If two dialogs have the same dialog and the same value, the first entry goes first.
@export var value: int ## The value attached to the trigger. This means various things depending on the trigger. Refer to the dialog signals enum.
@export var dialogues: Array[Dialogue_Properties]

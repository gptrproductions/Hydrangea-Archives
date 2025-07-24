extends Resource
class_name Questionnaire

@export var properties : Questionnaire_Properties

@export var question_data : Array[Questionnaire_Questions]

## This is a dictionary of dictionaries. If a triggered dictionary is greater than 1, it will trigger then in order until the all dialogues are used.
@export var dialog_data : Array[Questionnaire_Dialogue]

extends Resource
class_name Questionnaire_Questions

@export var question_type: Hud.question_type = Hud.question_type.FLASHCARDS
@export var subject: Hud.subject_type = Hud.subject_type.LANGUAGE
@export var question_title: String = "First Question!"
@export var question_text: String = "This is a test question. What are you doing here!?"
@export var choices: Array[Array] = [["Interesting 1", true], ["Interesting 2", false], ["Interesting 3", false]] ## All possible choices. Each choice is put inside an array, with the second element always being a boolean. The boolean can be used by all question types to enable or disable a key property. For Flashcards and Twinsies, this boolean defines whether a choice is correct or not. For Enumeration and Identification, it defines an answer's case sensitivity.
@export var timer: int = 30
@export var chances: int = 1
@export var required_answers: int = 1
@export var hint_text: String = "All these answers are actually correct."
@export var trivia_text: String = "You probably need more than this to get through me!"
@export var wrong_text: String = "You only had a 25% chance to do this right, but you fumbled it anyway."

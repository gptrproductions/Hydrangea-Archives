extends Resource
class_name Questionnaire_Properties

@export_group("Level Description")
@export var icon: int = 1
@export var level_number: String = "Exercise 0-1"
@export var level_name: String = "In The Beginning..."
@export var level_description_text: String = "This is a test level. What the heck are you doing here!?"
@export var encounter_type : Hud.encounter_type # Tells how the encounter occured.
@export var version: int = 1

@export_group("Level Properties")
@export var game_mode : Hud.game_mode = Hud.game_mode.NORMAL
@export var quiz_mode: bool = false
@export var enable_hints: bool = true
@export var enable_dialogues: bool = true
@export var loop_questions: bool = false
@export var shuffle_questions: bool = true
@export var enemy_difficulty: Hud.difficulty = Hud.difficulty.DUMB
@export var stat_difficulty: Hud.difficulty = Hud.difficulty.DUMB

## This involves the current squad of enemies the player will be fighting.
@export_group("Enemies")
@export var enemy1 : Character.name = Character.name.SHRIMPION
@export var enemy2 : Character.name = Character.name.NONE
@export var enemy3 : Character.name = Character.name.NONE

## The levels of the enemies. If the character's level is not within the numbers 1-15, it will default to 1.
@export var enemy_levels : Array[int] = [5, 5, 5]

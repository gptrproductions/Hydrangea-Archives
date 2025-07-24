extends Control
class_name Hud
# The hud's is where each question sent to it is parsed. 
# It also contains game-level identifiers.
# Enums for the current squad position. 

# Triggered by a question or a mechanic when a question is passed or failed-- stops both the timer and chances to reduce further.
# It also tells the gameplay node that the question is done. If a player selects the correct answer, QUESTION_END can be emitted, passing the PASSED enum result.
signal QUESTION_END(result : result)

# Triggered by gameplay to tell the hud that one gameplay cycle has been done.
signal GAMEPLAY_END

# Used by question types and timer/chances mechanics to tell whether a question is passed or failed. This can also be used if a level is completed or failed.
enum result { 
	PASSED,
	FAILED,
}

enum role {
	PLAYER,
	ENEMY,
	PASSIVE,
	NONE
}

# Enums for all question types. These are the in-game names.
enum question_type {
	FLASHCARDS, # Multiple choice
	TWINSIES, # True or false 
	ET_AL, # Enumeration
	HMM, # Identification
}

enum subject_type {
	LANGUAGE,
	MATH,
	SCIENCE,
	HISTORY,
	ART,
	PHILOSOPHY,
	WILDCARD
}

enum mindset {
	KINETIC,
	ONEIRIC,
	ALETHIC,
	PHRENIC,
	NIGHTMARE,
	NONE
}

# Enums for current character statuses.
enum order {
	ACTIVE,
	INACTIVE,
	PASSIVE, # Pertains to an equippable supporting character that wont be playable for that level, but its passive will be active anyways.
}

# Enums for every single stat in a level. EVERYTHING.
enum stat_type {
	
	# NOTE: Non-player stats.
	QUESTION, # Changes the question, along with the amount of lives and chances based on the value. 
	TIMER, # When called to change(), the value here will reset the timer.
	CHANCES, # When called to change(), the value here will change if a player picked the wrong answer.
	INTELLIGENCE, # When called to change(), the value here will change if the answer is correct / other circumstamces.
	MAX_CHAPTERS, # Called to change the maximum usable chapter points.
	CURRENT_CHAPTERS, # Called to change the amount of chapters a player currently has.
	INK,
	
	# NOTE: Player and Enemy stats. often called with a number. The number corresponds to which character gets their stat changed.
	MAX_HEALTH,
	CURRENT_HEALTH,
	FLINCH_STATUS,
	MAX_FLINCH,
	CURRENT_FLINCH,
	
	IQ,
	EQ,
	REFILL,
	FLINCH,
	SNAP,
	
	RESISTANCE,
	DETERMINATION,
}

enum target { # This move may be used outside moves, such as specifying which character to switch to. 
	# Still targets.
	CHARACTER_1,
	CHARACTER_2,
	CHARACTER_3,
	ACTIVE,
	PREVIOUS,
	NEXT,
	BACK, 
	NONE
}

enum game_mode { # This move determines what the game mode is.
	NORMAL,
	SMART,
	DUEL
}

enum effect_type { # This enum determines where the buff/nerf came from.
	PASSIVE, # This effect came from a character passive.
	MOVE, # This effect is applied due to a character move.
	ANOMALY, # This effect is caused by a level override.
	BOOKMARK, # This is an effect applied by a bookmark.
	WEAPON # This is an effect applied by a weapon.
}

enum skills { # This enum lists the possible skill categories of every character.
	SKILL_1,
	SKILL_2,
	SKILL_3,
	SKILL_4,
	EFFECT,
	PASSIVE,
	SPECIAL, # In case a character has a special move.
}

enum difficulty { ## Can be used to figure out how difficult the enemy should be. 
	DUMB, ## All decisions made are made by random. When used to specify stat difficulty, nerfs the opponents' stats by 20%.
	EASY, ## All decisions made are made by random, but some common sense moves are used. When used to specify stat difficulty, nerfs the opponents' stats by 10%.
	NORMAL, ## 50/50 between random choices and best possible choices.
	HARD, ## Ocassional mistakes, but commonly makes good choices. When used to specify stat difficulty, buffs the opponents' stats by 20%.
	SMART, ## No random choices. All choices are the best possible choice. When used to specify stat difficulty, buffs the opponents' stats by 40%.
}

enum encounter_type {
	AMBUSH, # The player was not expecting this battle. Usually used for surprise attacks.
	CHALLENGE, # The player was challenged by a person or a squad.
	ENCOUNTER, # Common battles, used when a battle is expected but not necessarily challenged by the opponent squad.
}

enum functions {
	NONE,
	MOVES,
	SWITCH,
	STATS,
	SUDO,
	PAUSE,
}

# Reference to the character canvas.
var characters : Control
var enemies : Control

# Contains the character scripts, along with their scenes.
var loaded_characters : Array = []
var loaded_enemies : Array = []
var loaded_mode : game_mode

@export var debug_fps : Label
@export var damage : Damage

func _process(_delta):
	debug_fps.text = "FPS: " + str(Engine.get_frames_per_second())

func _ready():
	System.disabled(true)
	$characters/camera.make_current()
	Signals.LEVEL_CAMERA_READY.emit()
	await get_tree().process_frame
	Signals.ON_ATTACKED.connect(damage.start)
	characters = self.get_node("characters").get_node("players")
	enemies = self.get_node("characters").get_node("enemies")
	_call([Character.name.MUSHROOM_CLOD, Character.name.SHRIMPION], load("res://resources/official_levels/level_0.tres"))

func _call(character : Array, data : Questionnaire): # Called to start a level.
	var enemy = [data.properties.enemy1, data.properties.enemy2, data.properties.enemy2]
	
	# Only enable when dialogues are enabled.
	if data.properties.enable_dialogues: $gameplay/dialogue_canvas.start(data.dialog_data)

	# Load character 1 and their stats.
	for n in character.size():
		
		var asset = Character.get_character(character[n])
		if asset == null: continue
		asset = asset.instantiate()
		
		asset.role = role.PLAYER # Assign the role before putting it on the scene tree!
		characters.add_child(asset)
		loaded_characters.append(asset)
		asset.visible = false
		asset.get_node("animation").play("idle")

	for n in enemy.size():
		# Load enemy 1 and their stats. Do this for the next enemy,
		var asset = Character.get_character(enemy[n])
		if asset == null: continue
		asset = asset.instantiate()
		asset.role = role.ENEMY # Assign the role before putting it on the scene tree!
		enemies.add_child(asset)
		loaded_enemies.append(asset)
		asset.visible = false
		asset.get_node("animation").play("idle")

	# Tell gameplay to retrieve the loaded stats.
	Signals.LEVEL_CAMERA_READY.emit()
	await $gameplay.start()
	await get_tree().process_frame
	$gameplay/ui_canvas/timer.visible = true
	var question_number : int = 0
	var question_size : int = data.question_data.size()
	while 1 == 1:
		
		if question_number == question_size: question_number = 0
		
		$gameplay.change_questions (question_number,
		data.question_data[question_number].subject, 
		data.question_data[question_number].question_title, 
		data.question_data[question_number].question_type,
		data.question_data[question_number].question_text,
		data.question_data[question_number].choices,
		data.question_data[question_number].timer,
		data.question_data[question_number].chances,
		data.question_data[question_number].trivia_text,
		data.question_data[question_number].wrong_text)
		$gameplay/question_canvas.visible = true
		
		question_number += 1
		await GAMEPLAY_END
		await get_tree().create_timer(2).timeout
	

extends Node
class_name Gameplay
static var CLASS_NAME = "Gameplay"

@export_group("Hud")
@export var dad : Hud # The father of all nodes in a level. This is referenced in the gameplay script so that it has access to all the necessary enums.
@export var background_canvas: Control
@export var character_canvas: Control
@export var player_canvas : Control
@export var enemy_canvas : Control
@export var question_canvas : Control
@export var stats_canvas : Control
@export var moves_canvas : Control
@export var dialog_canvas : Level_Dialogue

@export_group("Visuals")
@export var background : Control
@export var gradient : Control
@export var character_control : Control
@export var player_asset : Control
@export var enemy_asset : Control
@export var text_effect : AnimationPlayer

# Connect every single game object that has an attached value.
@export_group("Player Stats")
@export var player_health : TextureProgressBar
@export var player_flinch : TextureProgressBar
@export var player_ink : TextureProgressBar ## Refers to the progress bar of the ultimate.
@export var player_intelligence : Control
@export var player_bar: Control
@export var player_effects_list: Level_Effects_List

@export_group("Enemy Stats")
@export var enemy_health : TextureProgressBar
@export var enemy_flinch : TextureProgressBar
@export var enemy_ink : TextureProgressBar ## Refers to the progress bar of the ultimate.
@export var enemy_intelligence : Control
@export var enemy_bar: Control
@export var enemy_effects_list: Level_Effects_List

@export_group("Question Panel") 
@export var question_splash : Label ## This pertains to the title of the question. 
@export var question_label : Label ## This node is for the label which handles questions.
@export var question_subject : Hud.subject_type ## This node is for the control that handles the style of the question depending on the subject.
@export var question_timer : TextureProgressBar ## References the timer. Progressbars like these have their own scripts to start and stop.

@export_group("Answer Panel") 
var answer_node ## This contains the instanced answer panel. Answer panels are separate instances that receive choices (if it has multiple choices) or provide input (If it's an identification or enumeration), answers (can be multiple), and returns a boolean whether the player passed or not.
@export var answer_chances : TextureProgressBar ## References the chances. Progressbars like these have their own scripts to start and stop.

@export_group("Others")
@export var animation: Node
@export var disabler : Control

@onready var moves_button: Control = $player_canvas/moves/button
@onready var switch_button: Control = $player_canvas/switch/button
@onready var stats_button: Control = $player_canvas/stats/button
@onready var sudo_button: Control = $player_canvas/sudo/button

var active_character = 0
var active_enemy = 0

var player_intel : int = 0
var enemy_intel : int = 0

var player_ultimate_count : int = 0 # Records how many times an ultimate was used.
var enemy_ultimate_count : int = 0

# Stats for the three character squad.
var player_stats : Dictionary[int, Dictionary] = {}
var enemy_stats : Dictionary[int, Dictionary] = {}

# Stats for the player effects.
var effects : Dictionary[String, Dictionary] = {}

# Monitors which phase the question cycle is currently in.
var question_finished : bool = false
var previous_character : int = -1
var previous_enemy : int = -1

var player_last_stand : bool = false
var enemy_last_stand : bool = false

func _init():
	add_to_group("battle")

func _ready():
	# Connecting to global signals.
	Signals.ON_ATTACKED.connect(change_stat)
	dad = self.get_parent()
	
# Called after hud finishes loading. This is different from _ready which is triggered simultaneously.
func start():
	dialog_canvas.level_start.emit(0)
	# Loads stats depending on the amount of characters in the start() function.
	for n in dad.loaded_characters.size():
		player_stats[n] = Character.get_stats(dad.loaded_characters[n], true, true)
		
	for n in dad.loaded_enemies.size():
		enemy_stats[n] = Character.get_stats(dad.loaded_enemies[n], true, true)
	
	previous_character = player_stats.size() - 1 if player_stats.size() < 1 else -1
	previous_enemy = enemy_stats.size() - 1 if enemy_stats.size() < 1 else -1
	
	# Starts the stats up.
	player_switch(0, true)
	enemy_switch(0, true)
	
	change_stat(Hud.stat_type.INTELLIGENCE, 7, Hud.role.PLAYER)
	await get_tree().create_timer(1).timeout
	await dialog_canvas.play_dialog()
	
# This is to switch active characters.
func player_switch(number: int, refresh: bool = false, animated: bool = true):
	if player_last_stand: return

	var tries := 0
	while tries < player_stats.size():
		var target = (active_character + number) % player_stats.size()

		if !player_stats[target]["dead"]:
			previous_character = player_stats.size() - 2 if active_character != 0 else player_stats.size() - 1
			if !refresh:
				if animated:
					text_effect.stop()
					text_effect.play("switch_player")

				for n in player_stats.size():
					dad.loaded_characters[n].visible = false

				change_stat(dad.stat_type.INTELLIGENCE, 0, Hud.role.PLAYER, Hud.target.ACTIVE)
				System.nerd(CLASS_NAME, "Switching to character #" + str(target) + "...")

			active_character = target
			dad.loaded_characters[active_character].visible = true

			player_health.max_value = player_stats[active_character]["max_health"]
			player_health.value = player_stats[active_character]["current_health"]
			player_health.targetified = active_character
			player_health.dead = player_stats[active_character]["dead"]

			player_bar.switch(player_stats[active_character]["profile"], player_stats[active_character]["type"])
			Effects.sort(player_effects_list, Character.get_target(dad.loaded_characters[active_character]))
			player_effects_list.arrange(null, false)
			if !refresh:
				Signals.ON_SWITCH.emit(Hud.role.PLAYER)
			player_flinch.switch(active_character, Hud.role.PLAYER)
			return
		else:
			number += 1
			tries += 1

	# If we looped and found no one alive, do nothing
func enemy_switch(number: int, refresh: bool = false, animated: bool = true):
	if enemy_last_stand: return

	var tries := 0
	while tries < enemy_stats.size():
		var target = (active_enemy + number) % enemy_stats.size()

		if !enemy_stats[target]["dead"]:
			previous_enemy = enemy_stats.size() - 2 if active_enemy != 0 else enemy_stats.size() - 1

			if !refresh:
				if animated:
					text_effect.stop()
					text_effect.play("switch_enemy")

				for n in enemy_stats.size():
					dad.loaded_enemies[n].visible = false

				change_stat(dad.stat_type.INTELLIGENCE, 0, Hud.role.ENEMY, Hud.target.ACTIVE)
				System.nerd(CLASS_NAME, "Switching to enemy #" + str(target) + "...")

			active_enemy = target
			dad.loaded_enemies[active_enemy].visible = true

			enemy_health.max_value = enemy_stats[active_enemy]["max_health"]
			enemy_health.value = enemy_stats[active_enemy]["current_health"]
			enemy_health.targetified = active_enemy
			enemy_health.dead = enemy_stats[active_enemy]["dead"]

			enemy_bar.switch(enemy_stats[active_enemy]["profile"], enemy_stats[active_enemy]["type"])
			Effects.sort(enemy_effects_list, Character.get_target(dad.loaded_enemies[active_enemy]))
			enemy_effects_list.arrange(null, false)
			if !refresh:
				Signals.ON_SWITCH.emit(Hud.role.ENEMY)
			enemy_flinch.switch(active_enemy, Hud.role.ENEMY)
			return
		else:
			number += 1
			tries += 1
	# If we looped and found no one alive, do nothing

# Gameplay processes the questions send by the hud.
func change_questions(question_number: int = 0, subject = dad.subject_type.LANGUAGE, splash := "MODULO!", type = dad.question_type.FLASHCARDS, question := "So, what about airline food?", choices : Array[Array] = [["Dies in shambles and self-destructs if the number is odd", false],["Returns the quotient", false],["Returns absolutely nothing but pain and suffering that will destroy us all", true],["You haven't done anything about the framerate yet, loser!", false]], timer_value := 5, chances_value := 0, trivia_correct := "Interesting! Good Job!", trivia_wrong := "Bruh, How!?"):
	
	question_finished = false
	dialog_canvas.question_number_id.emit(question_number)
	Signals.ON_QUESTION_START.emit()

	question_canvas.get_node("questions").get_child(1).visible = false
	question_canvas.get_node("questions").get_child(2).visible = false
	
	# Checks which type of question the current question is.
	match type:
		dad.question_type.FLASHCARDS:
			answer_node = question_canvas.get_node("questions").get_child(1)
		dad.question_type.COINFLIP:
			answer_node = question_canvas.get_node("questions").get_child(2)

	# Loads the question splash text.
	question_splash.text = splash
	question_label.text = question
	
	# Loads the question and answer panel by sending the choices. 
	answer_node.visible = true
	answer_node.start(subject, choices) # Answer node may treat the choices array differently depending on the current question type.
	animation.load_question() # Animates the load_question.
	
	# Initializes the timer and the chances.
	question_timer.start(timer_value)
	answer_chances.start(chances_value)
	
	System.disabled(true)
	
	# Waits for the mechanics to be stopped-- as that means the question has finished executing.
	var result = await dad.QUESTION_END
	
	Signals.ON_QUESTION_END.emit()
	
	question_finished = true
	
	if result == Hud.result.PASSED: 
		dialog_canvas.question_passed.emit(question_number)
		text_effect.play("question_passed")
	else: 
		dialog_canvas.question_failed.emit(question_number)
		text_effect.play("question_failed")
	
	await text_effect.animation_finished
	await get_tree().create_timer(1).timeout
	await dialog_canvas.play_dialog(false)
	await use_skill(randi_range(1 ,1), Hud.role.ENEMY, true)

	question_splash.text = "FOR YOUR INFORMATION..."
	if result == Hud.result.PASSED: 
		question_label.text = trivia_correct
	else: 
		question_label.text = trivia_wrong
	
	await get_tree().create_timer(4).timeout
	dad.GAMEPLAY_END.emit()

# Calling timer with change stat and the value makes.
# damage_type, location, is_crit, and is_weak are only used by HP and shield stats. 
func change_stat(type, value, role : Hud.role = Hud.role.NONE, target_character : Hud.target = Hud.target.NONE, damage_type : Hud.mindset = Hud.mindset.KINETIC, _is_crit : bool = false, _is_weak : bool = true, _source_character : Hud.target = Hud.target.NONE, _source_role: Hud.role = Hud.role.NONE):
	var target_number = await Character.targetify(target_character, role)
	if target_number is not int: return
	
	match type:
		dad.stat_type.CHANCES:
			answer_chances.change(value)
		dad.stat_type.TIMER:
			question_timer.pause(+(value)) # If the whoever is stupid enough to do negatives 
		dad.stat_type.INK:
			if role == Hud.role.PLAYER: player_ink.change(value, target_number, Color(0, 0.26, 0.2))
			elif role == Hud.role.ENEMY: enemy_ink.change(value, target_number, Color(0.23, 0, 0.12))
		dad.stat_type.INTELLIGENCE:
			if role == Hud.role.PLAYER: await player_intelligence.change(value, target_number, Hud.role.PLAYER)
			elif role == Hud.role.ENEMY: await enemy_intelligence.change(value, target_number, Hud.role.ENEMY)
		dad.stat_type.MAX_HEALTH:
			if role == Hud.role.PLAYER: player_health.max_value = player_health.max_value + value
			elif role == Hud.role.ENEMY: enemy_health.max_value = enemy_health.max_value + value
		dad.stat_type.MAX_FLINCH:
			if role == Hud.role.PLAYER: player_flinch.max_value += value
			elif role == Hud.role.ENEMY: enemy_flinch.max_value += value
		dad.stat_type.CURRENT_HEALTH:
			if role == Hud.role.PLAYER:
				for node in player_effects_list.get_children():
					if "is_shield" in node:
						if Character.targetify(target_character, role) in node.targets and node.is_shield: 
							value = node._change(value) # Update the value and returns the remaining HP.
							if value >= 0: return # If the value is more than or equal to 0, return.
							else: break
						else: continue
					else: continue
				player_health.change(value, target_number)
			elif role == Hud.role.ENEMY: 
				for node in enemy_effects_list.get_children():
					if "is_shield" in node:
						if Character.targetify(target_character, role) in node.targets and node.is_shield: 
							value = node._change(value) # Update the value and returns the remaining HP.
							if value >= 0: return # If the value is more than or equal to 0, return.
							else: break
						else: continue
					else: continue
				enemy_health.change(value, target_number)
		dad.stat_type.CURRENT_FLINCH:
			if role == Hud.role.PLAYER: player_flinch.change(value, target_number, damage_type)
			elif role == Hud.role.ENEMY: enemy_flinch.change(value, target_number, damage_type)
		dad.stat_type.IQ:
			if role == Hud.role.PLAYER: player_stats[target_number]["iq"] += value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["iq"] += value
		dad.stat_type.EQ:
			if role == Hud.role.PLAYER: player_stats[target_number]["eq"] += value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["eq"] += value
		dad.stat_type.FLINCH_STATUS:
			if role == Hud.role.PLAYER: player_stats[target_number]["flinched"] = value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["flinched"] = value
		dad.stat_type.RESISTANCE:
			if role == Hud.role.PLAYER: player_stats[target_number]["resistance"] += value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["resistance"] += value
		dad.stat_type.DETERMINATION:
			if role == Hud.role.PLAYER: player_stats[target_number]["determination"] += value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["determination"] += value
		dad.stat_type.SNAP:
			if role == Hud.role.PLAYER: player_stats[target_number]["snap"] += value
			elif role == Hud.role.ENEMY: enemy_stats[target_number]["snap"] += value
	return

func use_skill(type : int, role : Hud.role = Hud.role.PLAYER, question_ended = false):
	question_timer.pause()
	moves_canvas.end(moves_canvas.exit_type.VIA_MOVE)
	
	if role == Hud.role.PLAYER:
		if type != 4: 
			change_stat(Hud.stat_type.INTELLIGENCE, -player_stats[active_character]["skill" + str(type) + "_cost"], role, active_character)
			await get_tree().create_timer(0.1 * (10 + player_stats[active_character]["skill" + str(type) + "_cost"]) - 0.7).timeout
	else:
		if type != 4: 
			change_stat(Hud.stat_type.INTELLIGENCE, -enemy_stats[active_enemy]["skill" + str(type) + "_cost"], role, active_enemy)
			await get_tree().create_timer(0.1 * (10 + player_stats[active_character]["skill" + str(type) + "_cost"]) - 0.7).timeout

	var tween = create_tween()
	tween.tween_property(question_canvas.get_node("questions"), "modulate", Color(1, 1, 1, 0), 0.15)
	await animation.cinematic(true)
	# Inser remove intelligence logic here
	
	System.disabled(true)
	
	# If skill used is that of the player
	if role == Hud.role.PLAYER:
		# Arrange which character overlaps on top. -3 and -1 are constant.
		player_asset.z_index = -1
		enemy_asset.z_index = -3
		
		match type:
			1:
				if dad.loaded_characters[active_character].has_method("skill1"):
					await dad.loaded_characters[active_character].skill1()
			2:
				if dad.loaded_characters[active_character].has_method("skill2"):
					await dad.loaded_characters[active_character].skill2()
			3:
				if dad.loaded_characters[active_character].has_method("skill3"):
					await dad.loaded_characters[active_character].skill3()
			4:
				if dad.loaded_characters[active_character].has_method("skill4"):
					dialog_canvas.player_ultimate.emit(player_ultimate_count)
					await dialog_canvas.play_dialog()
					await dad.loaded_characters[active_character].skill4()
					player_ultimate_count += 1
			_:
				System.nerd("Gameplay -> Use Skill", "Skill Panic")
		
		player_asset.z_index = -1
	# If skill used is that of the enemy
	elif role == Hud.role.ENEMY:
		# Arrange which character overlaps on top. -3 and -1 are constant.
		player_asset.z_index = -3
		enemy_asset.z_index = -1
		match type:
			1:
				if dad.loaded_enemies[active_enemy].has_method("skill1"):
					await dad.loaded_enemies[active_enemy].skill1()
			2:
				if dad.loaded_enemies[active_enemy].has_method("skill2"):
					await dad.loaded_enemies[active_enemy].skill2()
			3:
				if dad.loaded_enemies[active_enemy].has_method("skill3"):
					await dad.loaded_enemies[active_enemy].skill3()
			4:
				if dad.loaded_enemies[active_enemy].has_method("skill4"):
					dialog_canvas.enemy_ultimate.emit(enemy_ultimate_count)
					await dialog_canvas.play_dialog()
					await dad.loaded_enemies[active_enemy].skill4()
					enemy_ultimate_count += 1
			_:
				System.nerd("Gameplay -> Use Skill", "Skill Panic")

	await check_death()
	await dialog_canvas.play_dialog(false)
	await get_tree().create_timer(1).timeout
	animation.cinematic(false)
	# If the move was called after the question was passed or failed, keep the input disabled and wait for the question to reenable it.
	question_canvas.get_node("questions").modulate = Color.TRANSPARENT
	question_canvas.visible = true
	tween = create_tween()
	tween.tween_property(question_canvas.get_node("questions"), "modulate", Color(1, 1, 1, 1), 0.15)

	if question_ended == false:
		System.disabled(false)
		
	question_timer.resume()
	
func check_death():
	if enemy_stats[active_enemy]["dead"] == true:
		var dead = 0
		for n in enemy_stats.size():
			if enemy_stats[n].get("dead", false): dead += 1
		dialog_canvas.enemy_killed.emit(dead)
		if enemy_stats[active_enemy]["death_type"] == Character.death_type.CUTSCENE: await get_tree().create_timer(2.5).timeout
		enemy_switch(1, false, false)
			
	if player_stats[active_character]["dead"] == true:
		var dead = 0
		for n in player_stats.size():
			if player_stats[n].get("dead", false): dead += 1
		dialog_canvas.player_killed.emit(dead)
		if player_stats[active_character]["death_type"] == Character.death_type.CUTSCENE: await get_tree().create_timer(2.5).timeout
		player_switch(1, false, false)
		
	if dead_count(Hud.role.PLAYER) == player_stats.size() - 1: player_last_stand = true
	if dead_count(Hud.role.ENEMY) == enemy_stats.size() - 1: enemy_last_stand = true
		
func dead_count(role: Hud.role):
	var death_count : int = 0
	if role == Hud.role.PLAYER:
		for n in player_stats.size():
			if player_stats[n]["dead"]:
				death_count += 1
	else:
		for n in enemy_stats.size():
			if enemy_stats[n]["dead"]:
				death_count += 1
	return death_count


func disable_functions(type: Hud.functions, override : bool = false): # Disables the buttons. Used by the buttons themselves to ensure only one is active at a time
	if override:
		moves_button.disabled = false
		switch_button.disabled = false
		stats_button.disabled = false
		sudo_button.disabled = false
		return
	
	moves_button.disabled = true
	switch_button.disabled = true
	stats_button.disabled = true
	sudo_button.disabled = true
		
	match type:
		Hud.functions.MOVES: moves_button.disabled = false
		Hud.functions.SWITCH: switch_button.disabled = false
		Hud.functions.STATS: stats_button.disabled = false
		Hud.functions.SUDO: sudo_button.disabled = false

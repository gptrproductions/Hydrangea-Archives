extends Node
class_name Combat

enum move_type {
	ATTACK,
	DEFENSE,
	FLINCH,
	SUDO,
	SUPPORT
}

# Track per-character move usage this turn
static var turn_usage: Dictionary = {}
static var last_switched_from: int = -1

static func decision() -> int:
	var gameplay = Character.get_gameplay()
	var enemy_active = Character.targetify(Hud.target.ACTIVE, Hud.role.ENEMY)
	var player_active = Character.targetify(Hud.target.ACTIVE, Hud.role.PLAYER)

	var lore = Character.get_lore(Hud.target.ACTIVE, Hud.role.ENEMY)
	var stats = gameplay.enemy_stats[enemy_active]
	var player_stats = gameplay.player_stats[player_active]

	# --- Quick refs ---
	await System.tree().create_timer(0.1).timeout
	
	
	var intel: int = gameplay.enemy_intel
	var ink: float = gameplay.enemy_ink.value
	var hp: int = stats.get("current_health", 0)
	var max_hp: int = stats.get("max_health", 1)
	var player_hp: int = player_stats.get("current_health", 0)
	var player_max_hp: int = player_stats.get("max_health", 1)
	var flinch_val: int = gameplay.player_flinch.value
	var flinch_max: int = gameplay.player_flinch.max_value

	# --- Track move usage ---
	if not turn_usage.has(enemy_active):
		turn_usage[enemy_active] = 0

	# --- 0. Respect per-character move cap ---
	if turn_usage[enemy_active] >= 2:
		var switched = try_switch(gameplay, enemy_active, intel)
		if switched:
			return 0
		return -1 # end turn

	# --- 1. Ultimate check ---
	if ink >= 100:
		turn_usage[enemy_active] += 1
		return 4

	# --- 2. Desperation defense check ---
	if hp < max_hp * 0.3:
		var defensive: Array[int] = []
		for i in range(1, 4):
			var skill = lore.get("skill%d" % i)
			if skill and skill.type == move_type.DEFENSE and intel >= stats.get("skill%d_cost" % i, 0):
				defensive.append(i)
		if defensive.size() > 0:
			turn_usage[enemy_active] += 1
			return defensive.pick_random()

	# --- 3. Opportunistic kill check ---
	if player_hp < player_max_hp * 0.25:
		var killers: Array[int] = []
		for i in range(1, 4):
			var skill = lore.get("skill%d" % i)
			if skill and skill.type == move_type.ATTACK and intel >= stats.get("skill%d_cost" % i, 0):
				killers.append(i)
		if killers.size() > 0:
			turn_usage[enemy_active] += 1
			return killers.pick_random()

	# --- 4. Opportunistic flinch setup ---
	if flinch_val < flinch_max and flinch_val >= flinch_max * 0.7:
		var flinchers: Array[int] = []
		for i in range(1, 4):
			var skill = lore.get("skill%d" % i)
			if skill and skill.type == move_type.FLINCH and intel >= stats.get("skill%d_cost" % i, 0):
				flinchers.append(i)
		if flinchers.size() > 0:
			turn_usage[enemy_active] += 1
			return flinchers.pick_random()

	# --- 5. Support balancing ---
	# Give support a baseline chance each turn (20%)
	if randi_range(1, 100) <= 20:
		var supporters: Array[int] = []
		for i in range(1, 4):
			var skill = lore.get("skill%d" % i)
			if skill and skill.type == move_type.SUPPORT and intel >= stats.get("skill%d_cost" % i, 0):
				supporters.append(i)
		if supporters.size() > 0:
			turn_usage[enemy_active] += 1
			return supporters.pick_random()

	# --- 6. Otherwise pick any affordable move ---
	var affordable: Array[int] = []
	for i in range(1, 4):
		var cost = stats.get("skill%d_cost" % i, 0)
		if intel >= cost:
			affordable.append(i)
	if affordable.size() > 0:
		turn_usage[enemy_active] += 1
		return affordable.pick_random()

	# --- 7. If nothing usable, try switching ---
	var switched_a = try_switch(gameplay, enemy_active, intel)
	if switched_a:
		return 0

	# --- 8. Otherwise, end turn ---
	return -1


# --- Helper: Switch logic ---
static func try_switch(gameplay, enemy_active: int, intel: int) -> bool:
	for char_index in gameplay.enemy_stats.keys():
		if char_index == enemy_active:
			continue
		if char_index == last_switched_from:
			continue # don't bounce back immediately

		var teammate_stats = gameplay.enemy_stats[char_index]
		if teammate_stats.get("current_health", 0) <= teammate_stats.get("max_health", 1) * 0.2:
			continue # skip critically low hp

		var teammate_lore = Character.get_lore(Hud.target.CHARACTER_1 + char_index, Hud.role.ENEMY)
		for i in range(1, 4):
			var cost = teammate_stats.get("skill%d_cost" % i, 0)
			var skill = teammate_lore.get("skill%d" % i)
			if skill and intel >= cost:
				turn_usage[char_index] = 0
				last_switched_from = enemy_active
				return true
	return false

extends Node
class_name UI

## MINDSET COLORS
# THESE COLORS CAN BE SUBSTITUTED FOR POSITIVE AND NEGATIVES TOO.
const ONEIRIC_BLUE : Color = Color("5f5bf8")
const NIGHTMARE_RED : Color = Color("c90032")
const ALETHIC_ORANGE : Color = Color("ff6b28")
const KINETIC_YELLOW : Color = Color("ddad00")
const PHRENIC_GREEN : Color = Color("0FCB96")

# Get the roman numeral.
static func get_volume(num: int):
	if num is not int: System.oops("UI -> Get Volume", "The string is not an integer value.", System.oops_type.OOF)
	var result := ""
	var roman_map := [
		[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"],
		[100, "C"], [90, "XC"], [50, "L"], [40, "XL"],
		[10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]
	]
	for pair in roman_map:
		while num >= pair[0]:
			result += pair[1]
			num -= pair[0]
	return result

# Tip: All of these enums are letter-for-letter file names (but lowercase), though they are connected with an _player.webp or _enemy.webp depending if the Hud.role is Hud.role.PLAYER or Hud.role.ENEMY.
# If the role is invalid or Hud.role.NONE (invalid is safer), it's _neutral.webp.
# NOTE: intelligence, kinetic, oneiric, alethic, phrenic, and nightmare are not roleable, so they are immediately followed by .webp no matter the role.
# ICON PATHS: "res://assets/icons/stats/"
enum icon {DEAD, INTELLIGENCE, HP, IQ, EQ, FLINCH, REFILL, RES, DET, KINETIC, ONEIRIC, ALETHIC, PHRENIC, NIGHTMARE}

static func get_icon(want_icon: UI.icon, size: int = 22, role: Hud.role = Hud.role.PLAYER, is_icon : bool = false):
	var base_name : String = icon.keys()[want_icon].to_lower()

	# Icons that do *not* have role suffixes
	var no_role_icons = [
		UI.icon.INTELLIGENCE,
		UI.icon.KINETIC,
		UI.icon.ONEIRIC,
		UI.icon.ALETHIC,
		UI.icon.PHRENIC,
		UI.icon.NIGHTMARE
	]

	var suffix := ""
	if no_role_icons.has(want_icon):
		suffix = ".webp"
	else:
		match role:
			Hud.role.PLAYER:
				suffix = "_player.webp"
			Hud.role.ENEMY:
				suffix = "_enemy.webp"
			_:
				suffix = "_neutral.webp"

	var path = "res://assets/icons/stats/%s%s" % [base_name, suffix]
	
	if is_icon: return load(path)
	return "[img=%d]%s[/img]" % [size, path]

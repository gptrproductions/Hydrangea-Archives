extends Node
class_name UI

## MINDSET COLORS
const ONEIRIC_BLUE : Color = Color("5f5bf8")
const NIGHTMARE_RED : Color = Color("c90032")
const ALETHIC_ORANGE : Color = Color("ff6b28")
const KINETIC_YELLOW : Color = Color("ffaa00")
const PHRENIC_GREEN : Color = Color("0FCB96")

const LANGUAGE_BLUE : Color = Color("0F95C1")
const MATH_RED : Color = Color("C70009")
const SCIENCE_GREEN : Color = Color("1B7F00")
const HISTORY_PURPLE : Color = Color("7900BC")
const ART_ORANGE : Color = Color("D35700")
const PHILOSOPHY_TEAL : Color = Color("00876D")
const WILDCARD_GOLD : Color = Color("F7B100")

const LANGUAGE_BLUE_LIGHT : Color = Color("B8E9F9")
const MATH_RED_LIGHT : Color = Color("FFB1B4")
const SCIENCE_GREEN_LIGHT : Color = Color("B3FF9F")
const HISTORY_PURPLE_LIGHT : Color = Color("E2AEFF")
const ART_ORANGE_LIGHT : Color = Color("FFD3B4")
const PHILOSOPHY_TEAL_LIGHT : Color = Color("A1FFEC")
const WILDCARD_GOLD_LIGHT : Color = Color("FFECBD")

# Alias mapping: alternate names to enum keys
const keyword_to_enum_key := {
	"RESISTANCE": "RES",
	"DETERMINATION": "DET"
}

# Roman numeral conversion
static func get_volume(num: int):
	if num is not int:
		System.oops("UI -> Get Volume", "The string is not an integer value.", System.oops_type.OOF)
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

# Enum icons
enum icon {DEAD, INTELLIGENCE, HP, IQ, EQ, FLINCH, REFILL, RES, DET, KINETIC, ONEIRIC, ALETHIC, PHRENIC, NIGHTMARE}

# Icon retrieval
static func get_icon(want_icon: UI.icon, size: int = 22, role: Hud.role = Hud.role.PLAYER, is_icon : bool = false):
	var base_name : String = icon.keys()[want_icon].to_lower()

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
			Hud.role.PLAYER: suffix = "_player.webp"
			Hud.role.ENEMY: suffix = "_enemy.webp"
			_: suffix = "_neutral.webp"

	var path = "res://assets/icons/stats/%s%s" % [base_name, suffix]
	
	if is_icon:
		return load(path)
	return "[img=%d]%s[/img]" % [size, path]

# Text stylizer with enum recognition
# Text stylizer with enum recognition
static func stylize(text: String, font_size: int = 16) -> String:
	var result = "[color=aaaaaa]"
	var icon_names = get_icon_names()
	var words = text.split(" ")

	for word in words:
		var trailing_punct := ""
		var clean_word := word.strip_edges()

		# Detect trailing punctuation
		if clean_word.length() > 0 and not is_letter_or_digit(clean_word[-1]):
			trailing_punct = clean_word[-1]
			clean_word = clean_word.left(clean_word.length() - 1)

		var unprocessed_word := clean_word
		var processed_word = word

		# Convert alternate names to actual enum key
		if keyword_to_enum_key.has(clean_word):
			clean_word = keyword_to_enum_key[clean_word]

		# If it's a valid icon enum name
		if icon_names.has(clean_word):
			var proper = unprocessed_word.capitalize() if clean_word != "HP" else unprocessed_word
			var enum_value = UI.icon.keys().find(clean_word)
			var bbcode_icon = get_icon(enum_value, font_size, Hud.role.PLAYER)
			result += "%s[color=ffffff]%s[/color][color=aaaaaa]%s " % [bbcode_icon, proper, trailing_punct]
			continue

		# Color symbols: !! @@ ## $$ %% prefixes
		var color_code := ""
		var color_word := ""

		if unprocessed_word.begins_with("!!"):
			color_code = "c90032"
			color_word = unprocessed_word.substr(2)
		elif unprocessed_word.begins_with("@@"):
			color_code = "ff6b28"
			color_word = unprocessed_word.substr(2)
		elif unprocessed_word.begins_with("##"):
			color_code = "ffaa00"
			color_word = unprocessed_word.substr(2)
		elif unprocessed_word.begins_with("$$"):
			color_code = "0fcb96"
			color_word = unprocessed_word.substr(2)
		elif unprocessed_word.begins_with("%%"):
			color_code = "5f5bf8"
			color_word = unprocessed_word.substr(2)

		if color_code != "":
			var proper = color_word
			result += "[color=%s]%s[/color][color=aaaaaa]%s " % [color_code, proper, trailing_punct]
			continue

		# Color all-uppercase non-keywords
		if clean_word == clean_word.to_upper() and not icon_names.has(clean_word):
			var proper = clean_word.capitalize()
			result += "[color=ffffff]%s[/color][color=aaaaaa]%s " % [proper, trailing_punct]
			continue

		# Color numeric strings (e.g., 999, 42.5)
		if clean_word.is_valid_float():
			result += "[color=dddddd]%s[/color][color=aaaaaa]%s " % [clean_word, trailing_punct]
			continue

		# Default: no special formatting
		result += "%s " % processed_word

	return result.strip_edges()


# Helper to get all enum key names
static func get_icon_names():
	var icon_names := []
	for i in range(UI.icon.size()):
		icon_names.append(UI.icon.keys()[i])
	return icon_names

static func is_letter_or_digit(char: String) -> bool:
	if char.length() != 1:
		return false
	var c := char.unicode_at(0)
	return (c >= 'a'.unicode_at(0) and c <= 'z'.unicode_at(0)) or \
		   (c >= 'A'.unicode_at(0) and c <= 'Z'.unicode_at(0)) or \
		   (c >= '0'.unicode_at(0) and c <= '9'.unicode_at(0))

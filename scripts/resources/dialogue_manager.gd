extends Resource
class_name Dialogue_Properties ## A master class for all sorts of dialogue-- inside the level, in the world, everywhere.

@export var character: Character.name = Character.name.SHRIMPION ## If the character is invalid or set to none it will play out as a dialogue from an unknown character. Use none if you want to keep the identity of a character hidden during dialogue. 
@export var role: Hud.role = Hud.role.NONE ## If the role is invalid or set to none, the dialogue becomes a narration piece. Usually a dialogue node would center the text, but the image and name of a character, if set, will not appear.
@export var mood: Character.mood = Character.mood.NORMAL ## Tells the dialogue system which image of the target character to display in the dialogue. If this is invalid, it defaults to normal.
@export var text: String = "..." ## The message. If the text box is empty or invalid, it defaults to an ellipsis.
@export var duration : int = 0 ## How long the dialogue will stay on screen if auto dialogue is on (The duration timer will start counting down after the dialogue's entrance animation has finished animating,). If this is zero or invalid, then it's set to 

static func animate_text(text_message: String, node: Label) -> void:
	if not (node is Label):
		System.oops("Dialogue", "You sent an incompatible node to animate. Aborting", System.oops_type.BAD)
		return
		
	node.visible_characters = node.get_total_character_count()
	await System.tree().process_frame
	
	node.text = text_message
	# Pre-split the text and delays
	var chunks = text_message.split("§")
	var segments: Array[String] = []
	var delays: Array[float] = []

	segments.append(chunks[0])
	var regex = RegEx.new()
	regex.compile(r"^([0-9]*\.?[0-9]+)")

	for i in range(1, chunks.size()):
		var chunk = chunks[i]
		var result = regex.search(chunk)

		if result:
			var number = result.get_string(1).to_float()
			delays.append(number)
			var remaining = chunk.substr(result.get_end(), chunk.length() - result.get_end())
			segments.append(remaining)
		else:
			delays.append(0.0)
			segments.append(chunk)

	# Set the whole text upfront
	node.text = "".join(segments)
	node.visible_characters = 0

	# Animate revealing characters
	var char_idx = 0
	var default_delay = 0.02

	for i in segments.size():
		var segment = segments[i]

		# Apply extra delay **before** typing this segment!
		if i > 0:
			var extra_delay = delays[i - 1]
			if extra_delay > 0.0:
				await System.tree().create_timer(extra_delay).timeout

		for j in segment.length():
			char_idx += 1
			node.visible_characters = char_idx
			await System.tree().create_timer(default_delay).timeout

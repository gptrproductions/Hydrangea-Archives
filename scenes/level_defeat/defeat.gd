extends TextureRect

@onready var death_sprites : Dictionary[Character.name, Array] = { # Includes the death scale.
	Character.name.NONE : ["null", Vector2.ZERO],
	Character.name.SHRIMPION : ["res://characters/shrimpion/assets/death_2.webp", Vector2.ONE],
	Character.name.MUSHROOM_CLOD : ["res://characters/mushroom_clod/assets/death/poof.webp", Vector2(1.25, 1.25)],
	Character.name.ALLIGATOR : ["res://characters/alligator/assets/dead.webp", Vector2(0.9, 0.9)],
	Character.name.BEETLEROOT: ["res://characters/beetleroot/assets/beetleroot_beetroot.webp", Vector2(0.5, 0.5)]
	# Add more for every new character
}

func _ready(loaded_characters : Array = UI.current_active_characters):
	System.disabled(false)
	if is_instance_valid(Character.get_gameplay()):
		Character.get_gameplay().get_parent().queue_free()

	if loaded_characters.size() not in [1, 2, 3]: return
	if loaded_characters.size() == 1:
		$Node2D2/character_2.texture = load(death_sprites[loaded_characters[0]][0])	# Use the already centered character 2 position.
		$Node2D2/character_2.scale = death_sprites[loaded_characters[0]][1]
		$Node2D2/character_2.position = Vector2(0, 90)
	elif loaded_characters.size() == 2:
		$Node2D2/character_1.position = Vector2(-240, 90)
		$Node2D2/character_2.position = Vector2(240, 90)
		$Node2D2/character_1.texture = load(death_sprites[loaded_characters[0]][0])
		$Node2D2/character_2.texture = load(death_sprites[loaded_characters[1]][0])
		$Node2D2/character_1.scale = death_sprites[loaded_characters[0]][1]
		$Node2D2/character_2.scale = death_sprites[loaded_characters[1]][1]
	else:
		$Node2D2/character_1.position = Vector2(-480, 180)
		$Node2D2/character_2.position = Vector2(0, 90)
		$Node2D2/character_3.position = Vector2(480, 180)
		$Node2D2/character_1.texture = load(death_sprites[loaded_characters[0]][0])
		$Node2D2/character_2.texture = load(death_sprites[loaded_characters[1]][0])
		$Node2D2/character_3.texture = load(death_sprites[loaded_characters[2]][0])
		$Node2D2/character_1.scale = death_sprites[loaded_characters[0]][1]
		$Node2D2/character_2.scale = death_sprites[loaded_characters[1]][1]
		$Node2D2/character_3.scale = death_sprites[loaded_characters[2]][1]
	visible = true

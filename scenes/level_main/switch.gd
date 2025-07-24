extends TextureRect
class_name Switch

@export var hud : Hud
var gameplay : Gameplay
@export var intelligence : Control

func _ready():
	gameplay = Character.get_gameplay()
	pass

func _on_pressed_player() -> void:

	if gameplay.player_intel >= 1:
		System.disabled(true)
		await gameplay.change_stat(hud.stat_type.INTELLIGENCE, -1, Hud.role.PLAYER, Hud.target.ACTIVE)
		gameplay.player_switch(1)
		System.disabled(false)
	else:
		intelligence.snap(1)
		
func _on_pressed_enemy() -> void:
	if gameplay.enemy_intel >= 1:
		System.disabled(true)
		await gameplay.change_stat(hud.stat_type.INTELLIGENCE, -1, Hud.role.PLAYER, Hud.target.ACTIVE)
		gameplay.enemy_switch(1)
		System.disabled(false)
	else:
		intelligence.snap(1)

#func disabler():
#	if gameplay.player_stats.size() == 1:
#		self.get_child(0).disabled = true
#	if gameplay.enemy_stats.size() == 1:
#		self.get_child(0).disabled = true
		

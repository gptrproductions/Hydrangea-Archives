extends Control

@export var animation : AnimationPlayer
@export var role : Hud.role
@export var character_panel : Control
@export var health : Control

func _ready() -> void:
	animation.play("idle")
	
	if role == Hud.role.PLAYER:
		character_panel.get_node("panel").texture = preload("res://assets/vector/panel_player.webp")
	else:
		character_panel.get_node("panel").texture = preload("res://assets/vector/panel_enemy.webp")
		
# This function is called by the switch button to change the design of the bookmark.
func switch(avatar, mindset : Hud.mindset):
	
	character_panel.get_node("profile").get_node("picture").texture = avatar
	if health.dead: 
		character_panel.get_node("panel").texture = preload("res://assets/vector/panel_dead.webp")
	elif role == Hud.role.PLAYER:
		character_panel.get_node("panel").texture = preload("res://assets/vector/panel_player.webp")
		animation.play("idle")
	else:
		character_panel.get_node("panel").texture = preload("res://assets/vector/panel_enemy.webp")
		animation.play("idle")
	
	match mindset:
		Hud.mindset.KINETIC:
			character_panel.get_node("profile").texture = preload("res://assets/vector/profile_kinetic.webp")
		Hud.mindset.ONEIRIC:
			character_panel.get_node("profile").texture = preload("res://assets/vector/profile_oneiric.webp")
		Hud.mindset.ALETHIC:
			character_panel.get_node("profile").texture = preload("res://assets/vector/profile_alethic.webp")
		Hud.mindset.PHRENIC:
			character_panel.get_node("profile").texture = preload("res://assets/vector/profile_phrenic.webp")
		_:
			character_panel.get_node("profile").texture = preload("res://assets/vector/profile_dead.webp")

extends TextureProgressBar
class_name Health

@export var text : RichTextLabel
@export var role : Hud.role
@export var animation : AnimationPlayer
@export var effect : AnimationPlayer
@export var parent : Control
@export var flinch : Control
@export var target : Hud.target

var targetified : int
var gameplay = Gameplay
var dead := false
signal DEAD

func _ready():
	
	gameplay = Character.get_gameplay()
	if role == Hud.role.PLAYER:
		value_changed.connect(_on_player_value_changed)
		
	elif role == Hud.role.ENEMY:
		value_changed.connect(_on_enemy_value_changed)
	targetified = Character.targetify(target, role)

func change(target_value, _target_character : Hud.target, duration : float = 0.25):
	
	# Foresight if the character dies. It it does,
	if self.value + target_value <= 0: 
		if role == Hud.role.PLAYER:
			gameplay.player_stats[targetified]["dead"] = true
		else:
			gameplay.enemy_stats[targetified]["dead"] = true
		Signals.ON_DEATH.emit(target)
		dead = true
		
	if animation.is_playing():
		animation.stop()
		animation.play("damage")
		
	var tween = create_tween()
	text.modulate = Color.RED
	# Duration can be changed, for example, to represent damage over time.
	tween.tween_property(self, "value", self.value + target_value, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(text, "modulate", Color.WHITE, 0.3)
	
	await animation.animation_finished
	if !dead: animation.play("idle") 
	
func _on_enemy_value_changed(current_value: float = 0) -> void:
	gameplay.enemy_stats[gameplay.active_enemy]["current_health"] = current_value
	text.text = UI.get_icon(UI.icon.HP, 22, Hud.role.ENEMY) + str(int(value)) if !dead else UI.get_icon(UI.icon.DEAD, 22, Hud.role.ENEMY) + str(int(value))
	if current_value == 0.0: kill()
	
func _on_player_value_changed(current_value : float = 0) -> void:
	gameplay.player_stats[gameplay.active_character]["current_health"] = current_value
	text.text = UI.get_icon(UI.icon.HP, 22, Hud.role.PLAYER) + str(int(value)) if !dead else UI.get_icon(UI.icon.DEAD, 22, Hud.role.PLAYER) + str(int(value))
	if current_value == 0.0: kill()
	
# Do the death animation for the character.
func kill():
	await get_tree().create_timer(0.1).timeout
	if animation.is_playing():
		animation.stop()
	animation.speed_scale = 5
	
	flinch.get_parent().visible = false
	flinch.get_parent().get_parent().get_node("glow").visible = false
	flinch.get_parent().get_parent().get_node("particle").visible = false
	
	if role == Hud.role.PLAYER: animation.play("dead_player")
	else: animation.play("dead_enemy")
		
	DEAD.emit()
	if effect.is_playing():
		effect.stop()
	effect.play("dead")
	await Effect.slow(0.2, 1.5)
	animation.speed_scale = 1

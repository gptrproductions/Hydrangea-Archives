extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var animation: AnimationPlayer = $animation
@onready var particle: GPUParticles2D = $particle

func _input(event): ## Debug
	if is_instance_valid(Character.get_gameplay()): return
	if event is InputEventKey and event.pressed:
		start()

func start():
	Effect.shake(self, false, 5, 5, 3)
	visible = true
	sprite.visible = true
	sprite.play("default")
	await get_tree().create_timer(0.05).timeout 
	particle.emitting = true
	animation.play("start")
	await animation.animation_finished
	visible = false

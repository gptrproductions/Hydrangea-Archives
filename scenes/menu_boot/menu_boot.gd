extends Node

var menu_main := "res://scenes/menu_main/menu_main.tscn"
var obtained := false
var scene
var load_status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
@onready var animation: AnimationPlayer = $animation

func _ready():
	animation.play("start")
	await animation.animation_finished
	await get_tree().create_timer(2).timeout
	ResourceLoader.load_threaded_request(menu_main)

func _process(_delta):
	if obtained:
		return
	# Update load_status each frame
	load_status = ResourceLoader.load_threaded_get_status(menu_main)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene = ResourceLoader.load_threaded_get(menu_main)
		start()
		obtained = true

func start():
	var instanced_scene = scene.instantiate()
	get_tree().root.add_child(instanced_scene)
	await get_tree().process_frame
	animation.play("end_white")
	await get_tree().create_timer(0.2).timeout
	instanced_scene.start()
	await get_tree().create_timer(2).timeout
	queue_free()

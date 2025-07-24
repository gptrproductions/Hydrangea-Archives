extends Node
class_name Menu_Main

@onready var animation: AnimationPlayer = $animation
@onready var camera: Camera2D = $camera
@onready var menu: Pause_Menu = $menu

const level = "res://scenes/level_main/hud.tscn"
var loaded := false

# Panel Buttons
@onready var curtain: SquishyButton = $canvas/room/curtain
@onready var bag: SquishyButton = $canvas/room/bag
@onready var shop: SquishyButton = $canvas/room/shop
@onready var tv: SquishyButton = $canvas/room/tv
@onready var community: SquishyButton = $canvas/room/community
@onready var editor: SquishyButton = $canvas/room/editor
@onready var settings: SquishyButton = $canvas/room/settings

@onready var disabler: ColorRect = $ui/disabler

# Instantiated Panels
@onready var editor_panel: Menu_Editor = $ui/editor_panel

func _process(_delta):
	if loaded: return
	var load_status = ResourceLoader.load_threaded_get_status(level)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		loaded = true
		var scene = ResourceLoader.load_threaded_get(level)
		scene = scene.instantiate()
		get_tree().root.add_child(scene)
		await get_tree().process_frame
		scene._call([Character.name.MUSHROOM_CLOD, Character.name.SHRIMPION], load("res://resources/official_levels/level_0.tres"))
		self.queue_free()

func start():
	animation.speed_scale = 3
	animation.play("start_open")
	System.disabled(false)

func _on_tv_pressed() -> void:
	await tweener(tv.get_node("offset").global_position)
	await get_tree().create_timer(1).timeout
	animation.play("start_open")

func _on_settings_pressed() -> void:
	menu.entrance()

func _on_curtain_pressed() -> void:
	await tweener(curtain.get_node("offset").global_position)
	set_process(true)
	ResourceLoader.load_threaded_request(level)

func tweener(zoom_on: Vector2):
	disabler.visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "position", zoom_on, 0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(camera, "zoom", Vector2(5, 5), 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	await get_tree().create_timer(0.5).timeout
	tween = create_tween()
	tween.tween_property(disabler, "color", Color.WHITE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	return

func _on_bag_pressed() -> void:
	await tweener(bag.get_node("offset").global_position)
	pass # Replace with function body.

func _on_shop_pressed() -> void:
	await tweener(shop.get_node("offset").global_position)
	pass # Replace with function body.

func _on_community_pressed() -> void:
	pass # Replace with function body.

func _on_editor_pressed() -> void:
	await tweener(editor.get_node("offset").global_position)
	await get_tree().create_timer(0.5).timeout
	editor_panel.start()

extends Control

@export var highlight : TextureRect
enum tabs { STATS, EFFECTS, BUILD }
var active_tab = tabs.STATS

@export var stats_button: TextureButton
@export var effects_button: TextureButton
@export var build_button: TextureButton

@export var stats_scroll: ScrollContainer
@export var effects_scroll: ScrollContainer
@export var build_scroll: ScrollContainer

const stats_position = Vector2(13, 3)
const effects_position = Vector2(278, 3)
const build_position = Vector2(536, 3)

func _ready():
	_on_stats_pressed()

# Makes everything invisible and makes modulates transparent.
func reset():
	
	stats_scroll.get_parent().visible = false
	effects_scroll.get_parent().visible = false
	build_scroll.get_parent().visible = false
	stats_button.disabled = false
	effects_button.disabled = false
	build_button.disabled = false
	stats_button.modulate = Color(0.5, 0.5, 0.5, 1)
	effects_button.modulate = Color(0.5, 0.5, 0.5, 1)
	build_button.modulate = Color(0.5, 0.5, 0.5, 1)
	stats_scroll.get_parent().modulate = Color.TRANSPARENT
	effects_scroll.get_parent().modulate = Color.TRANSPARENT
	build_scroll.get_parent().modulate = Color.TRANSPARENT

func _on_stats_pressed() -> void:
	reset()
	stats_scroll.scroll_vertical = int(stats_scroll.get_v_scroll_bar().max_value)
	stats_button.disabled = true
	stats_button.modulate = Color.WHITE
	stats_scroll.get_parent().visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(highlight, "position", stats_position, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(stats_scroll.get_parent(), "modulate", Color.WHITE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(stats_scroll, "scroll_vertical", -20, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	
func _on_effects_pressed() -> void:
	reset()
	effects_scroll.scroll_vertical = int(effects_scroll.get_v_scroll_bar().max_value)
	effects_button.disabled = true
	effects_button.modulate = Color.WHITE
	effects_scroll.get_parent().visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(highlight, "position", effects_position, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(effects_scroll.get_parent(), "modulate", Color.WHITE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(effects_scroll, "scroll_vertical", -20, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)

func _on_build_pressed() -> void:
	reset()
	build_scroll.scroll_vertical = int(build_scroll.get_v_scroll_bar().max_value)
	build_button.disabled = true
	build_button.modulate = Color.WHITE
	build_scroll.get_parent().visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(highlight, "position", build_position, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(build_scroll.get_parent(), "modulate", Color.WHITE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(build_scroll, "scroll_vertical", -20, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)

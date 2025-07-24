extends TextureRect
class_name Chapters

@export var progress : TextureProgressBar
@export var text : Label
	
func change(value):
	var tween = create_tween()
	tween.tween_property(progress, "value", progress.value + value, 0.5).set_trans(Tween.TRANS_ELASTIC)

func _value_changed(value: float):
	text.text = str(snappedi(value, 1))

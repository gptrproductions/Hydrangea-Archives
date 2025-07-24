extends CanvasLayer
class_name Pause_Menu

enum button_type{GENERAL, VIDEO, AUDIO, ACCESSIBILITY, DEBUG}

@export var is_level : bool
@export var buttons : VBoxContainer
@export var panels : Control
@export var animation: AnimationPlayer
@export var catcher : TextureButton

@onready var settings_panel: Control = $center/container/settings_panel
@onready var level_panel: Control = $center/container/level_panel
@onready var viewport: TextureRect = $center/container/level_panel/progress

var selector : Selector

signal pause_visible
signal pause_invisible

var selected : int


func _ready():
	var n = 0
	for node in buttons.get_children():
		node.connect("pressed", Callable(self, "switch").bind(n))
		n += 1
	catcher.pressed.connect(exit)
	
	if is_level: 
		# Try checking if the settings panel is called inside a level.
		var gameplay = Character.get_gameplay()
		if is_instance_valid(gameplay):
			gameplay.get_parent().QUESTION_END.connect(exit) # If gameplay exists, Hud exists. Connect when the timer is finished to force exit.
			gameplay.get_node("selector") # Gets the selector so it can manually let it go.
			viewport.texture = gameplay.get_node("ui_canvas").get_node("progress").get_texture()
		level_panel.visible = true

func switch(type : button_type):
	pause_visible.emit()
	enabler()
	var node : Control
	match type:
		button_type.GENERAL:
			buttons.get_node("general").disabled = true
			node = panels.get_node("general")
		button_type.VIDEO:
			buttons.get_node("video").disabled = true
			node = panels.get_node("video")
		button_type.AUDIO:
			buttons.get_node("audio").disabled = true
			node = panels.get_node("audio")
		button_type.ACCESSIBILITY:
			buttons.get_node("accessibility").disabled = true
			node = panels.get_node("accessibility")
		button_type.DEBUG:
			buttons.get_node("debug").disabled = true
			node = panels.get_node("debug")
	
	for n in panels.get_children():
		n.visible = false
	
	if is_instance_valid(node):
		node.visible = true
		for n in node.get_children():
			n.modulate = Color.TRANSPARENT
		for n in node.get_children():
			var tween = create_tween()
			tween.tween_property(n, "modulate", Color.WHITE, 0.09)
			await get_tree().create_timer(0.03).timeout
			
func enabler():
	for node in buttons.get_children():
		node.disabled = false

func entrance():
	catcher.grab_focus()
	if is_instance_valid(selector) : selector.hide_()
	for node in buttons.get_children():
		node.down()
		node.visible = false
	self.visible = true
	animation.play("start")
	
	# Enable the first tab.
	buttons.get_child(0).disabled = true
	selected = 0
	switch(button_type.GENERAL)
	
	for node in buttons.get_children():
		node.visible = true
		await get_tree().create_timer(0.05).timeout

func exit(_result = null):
	if !self.visible: return
	animation.play("end")
	await animation.animation_finished
	self.visible = false
	if is_instance_valid(selector) : selector.show_()
	pause_invisible.emit()

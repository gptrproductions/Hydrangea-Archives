extends TextureRect
class_name Selector

signal selector_enabled(selector)
signal selector_disabled(selector)

signal focused(node : Control)
signal selected(node)

enum sel_pos {UP, DOWN, LEFT, RIGHT}

@export_group("Properties")
## Tells the selector where the selection icon should be placed. It also automatically rotates the arrow icon inward to the by 90 degrees. Note that the arrow's position will be based off the rect size of the target control node, and not based off the size of the node's texture (if there is any). 
@export var selector_position : sel_pos = sel_pos.LEFT
## Changes the position of the selector icon based off the current selector position.
@export var position_offset : Vector2
## Tells the selector which nodes it can present the arrow to. The first target will be the first focus.
@export var targets : Array[Control]
## If you want the selector blocked by a local pause menu, connect it here
@export var pause_menu : Pause_Menu

var focus_var : int = 0
var disabled : bool = true
var target : Control = null
var first_focus : bool = true

func _ready():
	# ISSUES TO ADDRESS
	# INPUT DISABLED IS NOT WORKING IN STATS CANVAS ENTRANCE AND EXIT, ALLOWING YOU TO SPAM. FIX SPAM TOMR.
	# SOMEHOW, BUTTON 1 OF MOVES CANVAS IS STILL BEING NAVIGATED TO. FIMD THE CONCERN AND STOP IT.
	
	System.INPUT_ENABLED.connect(show_)
	System.connect("INPUT_DISABLED", Callable(self, "hide_").bind(null, true))
	for node in targets:
		node.focus_entered.connect(switch)
	
	var gameplay : Gameplay = Character.get_gameplay()
	if is_instance_valid(gameplay):
		gameplay.get_parent().QUESTION_END.connect(hide_)
		
	
func hide_(_var1 = null, minor_disabling : bool = false): 
	if !minor_disabling: self.visible = false
	disabled = true
	for node in targets:
		node.focus_mode = Control.FOCUS_NONE
		
func show_(): 
	self.visible = true
	disabled = false
	for node in targets:
		node.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(target):
		if !target.is_visible_in_tree(): target = targets[0]
		target.grab_focus()
	switch(true)
		
func _input(event):
	if disabled or System.input_disabled : 
		return
	if is_instance_valid(pause_menu):
		if pause_menu.visible: 
			return
	if event is InputEventKey and event.pressed and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner != null : return
		if first_focus:
			target = targets[0]
			targets[0].grab_focus()
			first_focus = false
		else:
			target.grab_focus()

	elif event is InputEventKey and !event.pressed and event.is_action_released("ui_cancel"):
		pause_menu.entrance()
		pass
		
func switch(reconnected : bool = false):
	
	# Make sure you switch only when a button is visible.
	if is_instance_valid(target):
		if !get_viewport().gui_get_focus_owner().is_visible_in_tree():
			target.grab_focus()
		
	if !is_instance_valid(target) : return
	if target != get_viewport().gui_get_focus_owner() and !reconnected:
		target = get_viewport().gui_get_focus_owner()
		focused.emit(target)
		
	self.global_position = Vector2(target.global_position.x + (target.get_global_rect().size.x / 2) - self.get_global_rect().size.x / 2, 
								target.global_position.y + (target.get_global_rect().size.y / 2) - self.get_global_rect().size.y / 2)
	self.global_position.x = get_pos().x
	self.global_position += position_offset

	
func get_pos():
	var final_position : Vector2
	match selector_position:
		sel_pos.LEFT:
			final_position.x = self.global_position.x - (target.get_global_rect().size.x) + (target.get_global_rect().size.x / 4)
		sel_pos.RIGHT:
			final_position.x = self.global_position.x + (target.get_global_rect().size.x) - (target.get_global_rect().size.x / 4)
	return final_position

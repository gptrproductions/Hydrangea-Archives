extends Node

signal INPUT_DISABLED
signal INPUT_ENABLED

# Used by all nodes to check whether input is disabled or not.
var input_disabled : bool = false

enum oops_type{
	NOTICE,
	GOOD,
	BAD,
	OOF, # Force apsdofipsdf.
}

# Universal disabler. 
var disabler : CanvasLayer

func _ready():
	disabler = preload("res://scenes/ui_disabler/ui_disabler.tscn").instantiate()
	add_child(disabler)
	
# Called by a function if a game logic error occurs.
func oops(node, message, type : oops_type = oops_type.NOTICE):
	
	if !Settings.DEBUG_MESSAGES_ON: return
	
	if node is not String: # would rather keep this syntax sentence-like so it's easier for my baby brain to 0ioaudsfipausgf
		push_error("The caller of oops is not a string. I'm not racist against other variable types, but we only accomodate strings here. Not my fault if the caller looks janky af")
		node = str(node)
	
	match type:
		oops_type.NOTICE:
			print_rich("[color=gray][::] " + str(node) + " says: " + message)
		oops_type.GOOD:
			print_rich("[color=green][:D] " + str(node) + " says: " + message)
		oops_type.BAD:
			print_rich("[color=yellow][:(] " + str(node) + " says: " +  message)
		oops_type.OOF:
			print_rich("[color=red][X(]" + str(node) + " says: " + message)
		_:
			push_error("Calling from " + str(node) + " says: " + message, ": The oops message ooped!")

# Called by a function if Settings.NERD_ABOUT_IT is true. Essentially, what it does is SEND SPECIFIC VALUES.
func nerd(node, message):
		
	if !Settings.NERD_ABOUT_IT: return

	if node is not String: # would rather keep this syntax sentence-like so it's easier for my baby brain to 0ioaudsfipausgf
		push_error("The caller of nerd is not a string. I'm not saying that int, node, or dictionaries have no fundamental right to be the caller here-- it's just that it feels weird...")
		node = str(node)
	
	print_rich("[color=orange][NERD][color=gray] " +  str(node) + " says: " + message)

# Called by a function to disable/ednable all input. input_disabled can be used to check if recognizing input is allowed.
func disabled(what : bool):
	
	if is_instance_valid(Character.get_gameplay()):
		if Character.get_gameplay().question_finished: what = true
		
	disabler.visible = what
	if what is not bool: oops("System", "tf did you send to the input function frfr", oops_type.BAD)
	input_disabled = what
	if input_disabled:
		INPUT_DISABLED.emit()
	else:
		INPUT_ENABLED.emit()

# An easy override if you want the disabler to not click on anything but keep it enabled anyway.
# This may be used in level dialogues or in nodes that require being clicked even when clicking is disabled.
func disabler_layer(value : int = 100):
	disabler.layer = value
	
# Prints the current hierarchy.
func print_trees(node: Node = get_tree().root, indent: int = 0) -> void:
	print("  ".repeat(indent) + node.name)
	for child in node.get_children():
		print_trees(child, indent + 1)

func tree():
	return get_tree()

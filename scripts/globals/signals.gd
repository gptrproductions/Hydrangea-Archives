extends Node

# Animation signals.
signal LOAD_QUESTION

# Bandage Signals.
signal LEVEL_CAMERA_READY ## If a camera variable is needed on _ready() of a node, the function will have to wait until the level camera node is instantiated.

# NOTE: The ID name can be anything. The ID is usually concatenated with the character's role to differentiate player and enemy stacks.
# ANOTHER NOTE: The visuals variable is important as it provides the effect's description. If no visuals dictionary is sent, the effect still happens, but it won't be listed.
signal effect(id: String, type: Hud.effect_type, stack_count: int, role: Hud.role, target: Hud.target, stat: Hud.stat_type, value: float, percentage : bool, visuals : Dictionary)
signal parry(is_parried : bool)

# Static button signals.
signal ON_MOVE_SELECTED(id : int)

# Event signals. These are used exclusively by effects and stat conditions that depend on it.
signal ON_QUESTION_START(question_number : int, question_subject : Hud.subject_type)
signal ON_QUESTION_END(result : Hud.result)
signal ON_ATTACKED(type : Hud.stat_type, value, role : Hud.role, target_character : Hud.target, damage_type : Hud.mindset, is_crit : bool, is_weak : bool, source_character : Hud.target, source_role : Hud.role) # Emitted with values of the target.
signal ON_HEALED(role: Hud.role, character: Hud.target) # Emitted with values of the target.
signal ON_MOVE(role: Hud.target) # Emitted when a move is made.
signal ON_SWITCH(role: Hud.target) # Emitted when a character switch happens. This includes switches against their will.
signal ON_TIMER_START
signal ON_FLINCH(role: Hud.role)
signal ON_DEATH(target: Hud.target)
signal ON_EFFECT_ADDED(effect : Dictionary)
signal ON_EFFECT_CHANGED(effect : Dictionary)
signal ON_EFFECT_REMOVED(effect : Dictionary)

# Object versions of signals. This is for instructing functions that need it to connect to the signals.
enum event {
	ON_QUESTION_START,
	ON_QUESTION_END,
	ON_ATTACKED,
	ON_HEALED,
	ON_MOVE,
	ON_SWITCH,
	ON_TIMER_START,
	ON_FLINCH,
	ON_DEATH,
}

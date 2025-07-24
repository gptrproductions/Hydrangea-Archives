extends TextureProgressBar

# Visual Descriptions
const effect_name : String = "Shingles" 
const effect_type : Hud.effect_type = Hud.effect_type.PASSIVE
const description : String = "The affected character's flinch meter increases by 10% for the next 3 questions."

# What appears in-game.
const active_dumb : String = "*'s flinch meter increases for the next three questions."
const active_val : String = "*'s flinch meter increases by 10% for the next 3 questions."

# Textures
@onready var texture: TextureRect = $icon/texture
@onready var stack_text: RichTextLabel = $stack

# Local variables. This is changed in-game by signals.
var role : Hud.role
var stack : int = 0

func _ready():
	Signals.ON_QUESTION_START.connect(_change)
	
# Func always starts with the role it has.
func start(sent_role: Hud.role):
	self.max_value = 3
	self.value = 3
	self.stack = 0
	
	# Change Stats here.
	
func _change():
	
	# Change stats here.
	pass

func end():
	# All change stats must be reset here when ending the effect.
	# NOTE: If the buff provided is a percentage, be more cautious as you're affecting the attack directly.
	queue_free()

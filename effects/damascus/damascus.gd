extends TextureProgressBar

# Visual Descriptions
const ID : int = Effects.DAMASCUS
const effect_name : String = "Damascus" 
const effect_type : Hud.effect_type = Hud.effect_type.MOVE
const description : String = "All characters will be shielded."

# Nodes that benefic from quick access
@onready var texture: TextureRect = $icon/texture
@onready var stack_text: RichTextLabel = $stack
@onready var desc_norm: NinePatchRect = $description_normal
@onready var desc_dumb: NinePatchRect = null # Doesn't exist, it's simple enough as it is

# NOTE: Any effect library takes from this variables. This allows a script to filter which character has the effect.
var targets : Array[Hud.target] = [Hud.target.CHARACTER_1, Hud.target.CHARACTER_2, Hud.target.CHARACTER_3]

# Local variables. This is changed in-game by signals.
var role : Hud.role
var finished : bool = false
var active : bool = false # Stop from retriggering the plus effects
var is_shield : bool = true

# Effect target and stats. This is retrieved by a stats canvas.
# Usually, effect_target is compared with a target variable. If positive, they retrieve the stats.
# Whatever value is in this dictionary that is not zero will then be retreived.
# It's simple to dynamically update this. Just call effect_stats["stat"] to change the stats so that the stats_canvas can reflect this.
# NOTE: If this doesn't exist, it's okay. It won't be listed on the chracter effects list tho.
@export var effect_target : Array[Hud.target] = [Hud.target.CHARACTER_1, Hud.target.CHARACTER_2, Hud.target.CHARACTER_3]
@export var effect_stats : Dictionary = {
	"health": 0,
	"iq": 0,
	"eq": 0,
	"refill": 0,
	"flinch": 0,
	"resistance": 0,
	"determination": 0,
	"snap" : 0,
}

func _ready():
	# Check if the question is finished.
	var gameplay = Character.get_gameplay()
	if gameplay is not Gameplay: return
	if gameplay.question_finished: finished = true

# Func always starts with the role it has.
func start(_sent_role: Hud.role, setting_value = 0):
	
	var data = Character.get_data(Hud.target.ACTIVE, role, Hud.skills.SKILL_3, null)

	self.min_value = 0
	self.max_value += setting_value
	self.value += setting_value
	await get_tree().process_frame
	$stack.text = str(int(value))

	# Set the effect's duration or stack count. Usually the stack is maintained when started prematurely.

	if !active:
		active = true
		# The effect's stat change logic. Change Stats here.

func _change(cur_value):
	if cur_value > 0: return # Don't cure the shield if a recovery move occurs.
	var falloff : int = value + cur_value
	value = value + cur_value
	$stack.text = str(int(value))
	if self.value == 0:
		die()
		return falloff # If there is still more damage to be dealt but the shield had already broken, return any excess.
	return 0
	
func die():
	await Effects.exit(self)
	await get_tree().process_frame
	queue_free()
	return

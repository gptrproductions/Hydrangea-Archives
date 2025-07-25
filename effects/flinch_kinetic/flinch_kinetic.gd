extends TextureProgressBar

# Visual Descriptions
const ID : int = Effects.FLINCH_KINETIC
const effect_name : String = "Kinetic Flinch" 
const effect_type : Hud.effect_type = Hud.effect_type.PASSIVE
const description : String = "The character's resistance is down by 50% for one question."

# Nodes that benefic from quick access
@onready var texture: TextureRect = $icon/texture
@onready var stack_text: RichTextLabel = $stack
@onready var desc: NinePatchRect = $description

# NOTE: Any effect library takes from this variables. This allows a script to filter which character has the effect.
var targets : Array[Hud.target] = [Hud.target.CHARACTER_1, Hud.target.CHARACTER_2, Hud.target.CHARACTER_3]

# Local variables. This is changed in-game by signals.
var role : Hud.role
var stack : int = 0
var finished : bool = false
var active : bool = false #Stop from retriggering the plus effects

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
	"resistance": -50,
	"determination": 0,
	"snap" : 0,
}

func _ready():
	# Effect-wide signals. This is selective.
	Signals.ON_QUESTION_START.connect(_change)
	
	# Check if the question is finished.
	var gameplay = Character.get_gameplay()
	if gameplay is not Gameplay: return
	if gameplay.question_finished: finished = true

# Func always starts with the role it has.
func start(_sent_role: Hud.role):
	
	# Set the effect's duration or stack count. Usually the stack is maintained when started prematurely.
	self.min_value = 0
	self.max_value = 1
	self.value = 1
	self.stack = self.stack
	
	if !active:
		active = true
		# The effect's stat change logic. Change Stats here.
		var gameplay = Character.get_gameplay()
		gameplay.change_stat(Hud.stat_type.RESISTANCE, -50, role, Hud.target.CHARACTER_1)
		gameplay.change_stat(Hud.stat_type.RESISTANCE, -50, role, Hud.target.CHARACTER_2)
		gameplay.change_stat(Hud.stat_type.RESISTANCE, -50, role, Hud.target.CHARACTER_3)

func _change():
	if finished:
		finished = false
		return
	await Effects.change(self, -1)

	if self.value == 0:
		await Effects.exit(self)
		# This is where you apply the stat reversal logic.
		var gameplay = Character.get_gameplay()
		
		gameplay.change_stat(Hud.stat_type.RESISTANCE, 50, role, Hud.target.CHARACTER_1)
		gameplay.change_stat(Hud.stat_type.RESISTANCE, 50, role, Hud.target.CHARACTER_2)
		gameplay.change_stat(Hud.stat_type.RESISTANCE, 50, role, Hud.target.CHARACTER_3)
		queue_free()
		return
	

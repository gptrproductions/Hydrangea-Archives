extends TextureProgressBar

# Visual Descriptions
const ID : int = Effects.SHINGLES
const effect_name : String = "Shingles" 
const effect_type : Hud.effect_type = Hud.effect_type.MOVE
const description : String = "The affected character's flinch meter increases by [color=C30058]10%[/color] for the next 3 questions."

# Nodes that benefic from quick access
@onready var texture: TextureRect = $icon/texture
@onready var stack_text: RichTextLabel = $stack
@onready var desc: NinePatchRect = $description

# Local variables. This is changed in-game by signals.
var role : Hud.role
var stack : int = 0
var absolute : int = -1

# Effect target and stats. This is retrieved by a stats canvas.
# Usually, effect_target is compared with a target variable. If positive, they retrieve the stats.
# Whatever value is in this dictionary that is not zero will then be retreived.
# It's simple to dynamically update this. Just call effect_stats["stat"] to change the stats so that the stats_canvas can reflect this.
# NOTE: If this doesn't exist, it's okay. It won't be listed on the chracter effects list tho.
@export var effect_target : Array[Hud.target] = []
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
	
	# Effect-wide signals. This is selective.
	Signals.ON_TIMER_START.connect(_change)
	
# Func always starts with the role it has. Just in case, the effect helper still sends the role.
func start(_sent_role: Hud.role):
	
	# Set the effect's duration or stack count. Usually the stack is maintained when started prematurely.
	self.min_value = 0
	self.max_value = 3
	self.value = 3
	self.stack = self.stack
	
	# Change Stats here.
	absolute = Character.targetify(Hud.target.ACTIVE, role)
	effect_target.append(absolute)
	
func _change():
	await Effects.change(self, -1)

	if self.value == 0:
		await Effects.exit(self)
		# This is where you apply the stat reversal logic.
		queue_free()
		return
	
	# The effect's stat change logic.
	var gameplay = Character.get_gameplay()
	var data = Character.get_data(absolute, role, Hud.skills.EFFECT, self)
	gameplay.change_stat(Hud.stat_type.CURRENT_FLINCH, data["max_flinch"] * 0.1, role, absolute)

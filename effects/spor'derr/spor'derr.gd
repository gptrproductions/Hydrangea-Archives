extends TextureProgressBar

# Visual Descriptions
const ID : int = Effects.SPORDERR
const effect_name : String = "Spor'derr" 
const effect_type : Hud.effect_type = Hud.effect_type.MOVE
const description : String = "Emits spores for 3 questions. If Mushroom Clod attacks or is attacked, she spores the offending character."

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
	
	# Effect-wide signals. This is selective.
	Signals.ON_TIMER_START.connect(_change)
	Signals.ON_ATTACKED.connect(_revenge)
	
# Func always starts with the role it has. Just in case, the effect helper still sends the role.
func start(_sent_role: Hud.role):
	
	# Set the effect's duration or stack count. Usually the stack is maintained when started prematurely.
	self.min_value = 0
	self.max_value = 3
	self.value = 3
	
	# Get a reference since Clod is applying this to herself.
	absolute = Character.targetify(Hud.target.ACTIVE, role)
	effect_target.append(absolute)
	
func _change():
	await Effects.change(self, -1)
	if self.value == 0:
		await Effects.exit(self)
		var gameplay = Character.get_gameplay()
		gameplay.change_stat(Hud.stat_type.DETERMINATION, -stack, role, Hud.target.CHARACTER_1)
		gameplay.change_stat(Hud.stat_type.DETERMINATION, -stack, role, Hud.target.CHARACTER_2)
		gameplay.change_stat(Hud.stat_type.DETERMINATION, -stack, role, Hud.target.CHARACTER_3)
		queue_free()
		return

func _revenge(type : Hud.stat_type, _value, target_role : Hud.role, _target_character : Hud.target, _damage_type : Hud.mindset, _is_crit : bool, _is_weak : bool, source_character: Hud.target, source_role : Hud.role):
	var increment : int = 0
	if type != Hud.stat_type.CURRENT_HEALTH: return
	if Character.targetify(source_character, source_role) == absolute and source_role == role: ## THAT'S DEFINITELY CLOD ATTACKING.
		increment = 2
	else:
		if target_role != role: return
		increment = 1
		
	var gameplay = Character.get_gameplay()

	# Get pre-stack value to compute the actual delta
	var previous_stack = stack
	stack = clamp(stack + increment, 0, 20)
	var actual_increment = stack - previous_stack  # This is what we really added

	# Apply actual increment everywhere
	effect_stats["determination"] = stack
	gameplay.change_stat(Hud.stat_type.DETERMINATION, actual_increment, role, Hud.target.CHARACTER_1)
	gameplay.change_stat(Hud.stat_type.DETERMINATION, actual_increment, role, Hud.target.CHARACTER_2)
	gameplay.change_stat(Hud.stat_type.DETERMINATION, actual_increment, role, Hud.target.CHARACTER_3)
	stack_text.text = str(stack)

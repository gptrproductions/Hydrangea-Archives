extends Control
class_name Intelligence

var gameplay : Gameplay
@export var hud : Hud

var current_value : int = 0
var visibility : Array = [false, false, false, false, false, false, false]

func _ready():
	gameplay = Character.get_gameplay()

func change(value : int, _target_character : Hud.target = Hud.target.ACTIVE, role : Hud.role = Hud.role.PLAYER): # Target character to change the stat. If nothing is specified it defaults to the active character. Since im afraid to break shit, i added a role variable to check if the player is an enemy or not.
	# Gets the current active character's value.
	if role == Hud.role.PLAYER: current_value = gameplay.player_intel
	elif role == Hud.role.ENEMY: current_value = gameplay.enemy_intel
	
	# Gets a reference of the previous value before changing it to see if it increased or decreased.
	var past_value : int = current_value
	current_value = current_value + value
	
	if current_value < 0: 
		System.oops("Intelligence - > change", "Value sent to change is causing a negative number. Don't worry though, this might be intentional!", System.oops_type.NOTICE)
		current_value = 0
	
	if current_value > 7:
		current_value = 7
	
	if current_value > past_value: animate()
	else: animate_backwards()
	
	if role == Hud.role.PLAYER: gameplay.player_intel = current_value
	elif role == Hud.role.ENEMY: gameplay.enemy_intel = current_value
		
func animate():
	for n in 7:
		if n + 1 <= current_value and visibility[n] == false:
			self.get_child(n).get_node("animation").play("appear")
			visibility[n] = true
		elif n + 1 > current_value and visibility[n] == true:
			self.get_child(n).get_node("animation").play("disappear")
			visibility[n] = false
		await get_tree().create_timer(0.10).timeout

func animate_backwards():
	for n in range(6, -1, -1): 
		if n + 1 <= current_value and visibility[n] == false:
			self.get_child(n).get_node("animation").play("appear")
			visibility[n] = true
		elif n + 1 > current_value and visibility[n] == true:
			self.get_child(n).get_node("animation").play("disappear")
			visibility[n] = false
		await get_tree().create_timer(0.10).timeout

func snap(value : int): # Animates the intelligence points to tell how much IP is missing to use that move.
	if value <= current_value:
		System.oops("Intelligence -> Snap", "The Intelligence point needed for the action is sufficient. No snapping needed!", )
		return
	
	for n in range(current_value, value):
		self.get_child(n).get_node("animation").play("blink")
	
func force(): # Force change the visuals to reflect
	for n in range(6, -1, -1): 
		if n + 1 <= current_value and visibility[n] == false:
			self.get_child(n).get_node("animation").play("appear")
			visibility[n] = true
		elif n + 1 > current_value and visibility[n] == true:
			self.get_child(n).get_node("animation").play_backwards("appear")
			visibility[n] = false
		await get_tree().create_timer(0.10).timeout	

extends Node

# Enums of stoppable effects. Available for perpetual effects that doesnt need to have a duration.
enum stoppable { SHAKE, FLASH, BLINK }

# A Dictionary of effects.
var active : Array
var slow_active : bool = false

var h: float = 0
var v: float = 0

# Signals of stoppable effects
signal _shake(target: Node)

# SECURITY ooh it lights up red if i type it in capital letters thats interesting anyway SECURITY CHECK-- KILL PREVIOUS TWEEN AND RESET THE EFFECT IF CALLED BEFORE THE PREVIOUS ONE FINISHES
func _check(type: String, node: Node, erase : bool = false):
	var n : int = 0 # Somehow the code breaks with a for loop? srsly i don't get code logic sometimes.
	while n < active.size():
		if erase == true:
			active.remove_at(n)
			continue
			
		if active[n][0] == type and active[n][1] == node: return true
		n += 1
	return false

# Lah stoppes the stoppage. The stop dictionary for each function is Stahp lah
func stop(target: Node, what: stoppable):
	emit_signal("_" + stoppable.keys()[what].to_lower(), target)

# Booty function
func shake(target : Node, endless = false, h_intensity : int = 5, v_intensity : int = 1, repeats : int = 3, buildup : float = 0): ## If buildup is more than 0, gradually increase intensity
	
	# Check or make reference
	if _check("shake", target) == true: return
	active.append(["shake", target])

	var original_position : Vector2
	if target is Camera2D: original_position = Vector2.ZERO
	else: original_position = target.position
	var stahp : Dictionary[String, bool] = {"r u sure" : false}
	var n = 0
	
	h = 0
	v = 0
	
	var intensity_tween = create_tween()
	intensity_tween.set_parallel(true)
	intensity_tween.tween_property(self, "h", h_intensity, buildup).set_ease(Tween.EASE_IN)
	intensity_tween.tween_property(self, "v", v_intensity, buildup).set_ease(Tween.EASE_IN)
	
	# This function run doesn't kill a programmer, but it's fucking scary to deal with
	while n < repeats:
		if target is Camera2D:
			@warning_ignore("narrowing_conversion")
			target.offset = original_position + Vector2(randi_range(randi_range(h - 1, h + 1), randi_range(-h - 1, -h_intensity + 1)), randi_range(randi_range(v- 1, v + 1), randi_range(-v - 1, -v + 1)))
		else:
			@warning_ignore("narrowing_conversion")
			target.position = original_position + Vector2(randi_range(randi_range(h - 1, h + 1), randi_range(-h- 1, -h_intensity + 1)), randi_range(randi_range(v- 1, v + 1), randi_range(-v - 1, -v + 1)))
		
		await get_tree().create_timer(0.03).timeout
		
		# If endless is true, n will maintain its value until a signal is emitted-- forever. Until stop becomes true, that is.
		if endless == true:
			_shake.connect(func(node): stahp["r u sure"] = node == target, CONNECT_ONE_SHOT)
			await get_tree().process_frame
			n = 0
		
		if stahp["r u sure"] == true:
			break
		
		n = n + 1
	
	var string
	string = "offset" if target is Camera2D else "position"
	var tween = create_tween()
	tween.tween_property(target, string, original_position, 0.2).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	tween.kill()

	# Erase the element
	_check("shake", target, true)

# Public indecency function
func flash(target, color : Color = Color(1, 0, 0.2, 1), release : float = 0.2, attack : float = 0, hold : float = 0.1):
	
	# Check or make reference
	if _check("flash", target) == true: return
	active.append(["flash", target])
	
	var original_color = target.modulate
	
	if attack > 0:
		var tween = create_tween()
		tween.tween_property(target, "modulate", color, attack)
		await get_tree().create_timer(attack).timeout
	else:
		target.modulate = color
			
	# +0.01s to not somehow crash the code??? what
	await get_tree().create_timer(hold).timeout
	
	if release > 0:
		var tween2 = create_tween()
		tween2.tween_property(target, "modulate", original_color, release)
		await get_tree().create_timer(release).timeout
	else:
		target.modulate = original_color
		
	# Erase the element
	_check("flash", target, true)

# If speed is 1, the entire blink cycle lasts one second. If amount is less than 1, it blinks forever until stopped. 
#func blink(target, amount : int = 0, color : Color = Color(1.2, 1.2, 1.2), speed : float = 1):
	# coming soon idiot
	#pass

func slow(scale : float = 0.25, duration : float = 1.5):
	Engine.time_scale = scale
	await get_tree().create_timer(duration * scale).timeout
	if duration <= 0 : return
	Engine.time_scale = 1
	return

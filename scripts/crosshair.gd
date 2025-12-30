extends Sprite2D

@export var max_rotation_speed: float = 4.0  # Speed at full ammo
@export var min_rotation_speed: float = 0.5  # Speed at 1 bullet
@export var recoil_amount: float = 1.4

var base_scale: Vector2 
var current_ammo: int = 1
var max_ammo: int = 1
var is_aiming: bool = false
var is_reversing: bool = false 
var is_perfect_window: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	add_to_group("Crosshair")
	base_scale = scale 

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if is_reversing:
		rotation -= max_rotation_speed * delta
		# CHECK FOR PERFECT RELOAD INPUT
		if is_perfect_window and Input.is_action_just_pressed("reload"):
			trigger_perfect_reload()
	elif current_ammo > 0:
		# SLOWING PART: Calculate percentage and interpolate speed
		var ammo_pct = float(current_ammo) / float(max_ammo)
		var dynamic_speed = lerp(min_rotation_speed, max_rotation_speed, ammo_pct)
		rotation += dynamic_speed * delta
	# Else (0 ammo and not reloading) it stays still
	
	check_for_enemy()



func set_perfect_window(state: bool):
	is_perfect_window = state
	# Turn Blue if true, otherwise stay white/red
	if state:
		modulate = Color.CYAN
		scale = base_scale * 1.5 # Pop it up slightly so it's easier to see
	else:
		modulate = Color.WHITE
		scale = base_scale

func trigger_perfect_reload():
	# Tell the weapon to finish NOW
	get_tree().call_group("gun", "finish_reload_early")
	# Visual feedback
	set_perfect_window(false)
	apply_recoil() # Reuse recoil as a "Success" pop
	
func set_reverse(state: bool):
	is_reversing = state

func set_aiming(state: bool):
	if is_aiming == state: return 
	is_aiming = state
	
	var tween = create_tween()
	if is_aiming:
		tween.tween_property(self, "scale", base_scale * 0.7, 0.1)
	else:
		tween.tween_property(self, "scale", base_scale, 0.1)
		
func update_ammo_values(current: int, total: int):
	current_ammo = current
	max_ammo = total

func apply_recoil():
	var tween = create_tween()
	scale = base_scale * recoil_amount
	tween.tween_property(self, "scale", base_scale, 0.1)

func check_for_enemy():
	# 1. PRIORITY: If we are in the reload mini-game, stay BLUE
	if is_perfect_window:
		modulate = Color.CYAN
		return # Exit the function so it doesn't turn white/red

	# 2. Otherwise, do normal detection
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = global_position
	params.collision_mask = 4294967295 
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var results = space_state.intersect_point(params)
	
	var found_enemy = false
	for result in results:
		if result.collider.is_in_group("Enemy"):
			found_enemy = true
			break
			
	modulate = Color.RED if found_enemy else Color.WHITE

func change_crosshair(new_texture: Texture2D):
	texture = new_texture 

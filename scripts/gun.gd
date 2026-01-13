extends Area2D

# --- NEW SNIPER TOGGLE ---
@export var is_sniper: bool = false 
@export var base_damage: int = 20
@export var sniper_crosshair_scene: PackedScene 

@export_group("Ammo Settings")
@export var mag_size: int = 15
@export var reload_time: float = 2.0
@export var fire_rate: float = 0.15

@export_group("Aiming Settings")
@export var hip_fire_spread: float = 15.0 
@export var aim_speed_multiplier: float = 0.5 

@export_group("Setup")
@export var bullet_scene: PackedScene
@export var upgrade_data: WeaponUpgradeData # Drag your .tres file here

@export_group("Combat Settings")
@export var knockback_force: float = 150 

@export_group("Visuals")
@export var crosshair_texture: Texture2D 
 
var is_upgraded: bool = false
var hud = null 
var current_ammo: int = 0
var is_equipped: bool = false
var can_shoot: bool = true
var is_reloading: bool = false
var player_in_range: Node2D = null 
var is_aiming: bool = false



func _process(_delta: float) -> void:
	if is_equipped:
		is_aiming = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		get_tree().call_group("Crosshair", "set_aiming", is_aiming)
		get_tree().call_group("Player", "set_aiming", is_aiming)
		get_tree().call_group("Crosshair", "update_ammo_values", current_ammo, mag_size)
		
		if hud == null:
			hud = get_tree().root.find_child("CanvasLayer", true, false)
		if hud:
			hud.update_ammo(current_ammo, mag_size)
		
		look_at(get_global_mouse_position())
		scale.y = -1 if abs(rotation_degrees) > 90 else 1
		
		if Input.is_action_pressed("attack") and can_shoot and not is_reloading:
			if current_ammo > 0: shoot()
			else: reload()
		
		if Input.is_action_just_pressed("reload") and not is_reloading:
			reload()
	else:
		# --- PICKUP CHECK ---
		if player_in_range != null:
			if Input.is_action_just_pressed("interact"):
				pick_up(player_in_range)

func shoot():
	can_shoot = false
	current_ammo -= 1
	
	# --- SNIPER DAMAGE MULTIPLIER ---
	var final_damage = base_damage
	if is_sniper:
		var crosshair = get_tree().get_first_node_in_group("Crosshair")
		if crosshair and crosshair.has_method("get_damage_multiplier"):
			final_damage = base_damage * crosshair.get_damage_multiplier()

	var spread = 0.0
	if not is_aiming:
		spread = deg_to_rad(randf_range(-hip_fire_spread, hip_fire_spread))
	
	if bullet_scene:
		var b = bullet_scene.instantiate()
		get_tree().root.add_child(b)
		b.global_position = global_position
		b.global_rotation = global_rotation + spread
		
		# Pass damage to bullet
		if b.has_method("set_damage"):
			b.set_damage(final_damage)
		if b.has_method("set_knockback"):
			b.set_knockback(knockback_force)
	
	get_tree().call_group("Crosshair", "apply_recoil")
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func reload():
	if current_ammo == mag_size or is_reloading: return 
	is_reloading = true
	get_tree().call_group("Crosshair", "set_reverse", true)
	var random_delay = randf_range(reload_time * 0.2, reload_time * 0.7)
	await get_tree().create_timer(random_delay).timeout
	
	if is_reloading:
		get_tree().call_group("Crosshair", "set_perfect_window", true)
		await get_tree().create_timer(0.5).timeout
		get_tree().call_group("Crosshair", "set_perfect_window", false)

	await get_tree().create_timer(reload_time - random_delay).timeout
	if is_reloading:
		complete_reload()

func finish_reload_early():
	complete_reload()

func complete_reload():
	current_ammo = mag_size
	is_reloading = false
	get_tree().call_group("Crosshair", "set_reverse", false)
	get_tree().call_group("Crosshair", "set_perfect_window", false)

# --- PICKUP RADIUS FIXES ---
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_equipped:
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	# This prevents the "pick up from anywhere" bug
	if body == player_in_range:
		player_in_range = null

func pick_up(body: Node2D):
	var gun_hold = body.get_node_or_null("GunPoint")
	if gun_hold:
		# 1. Clear the range variable FIRST
		player_in_range = null
		
		# 2. If we already have a gun, drop it
		if gun_hold.get_child_count() > 0:
			var old_gun = gun_hold.get_child(0)
			drop_weapon(old_gun)
		
		# 3. Equip the new gun
		is_equipped = true
		current_ammo = randi_range(1, mag_size)
		
		# --- CROSSHAIR SWAP ---
		if is_sniper and sniper_crosshair_scene:
			get_tree().call_group("Crosshair", "swap_to_sniper_style", sniper_crosshair_scene)
		elif crosshair_texture:
			get_tree().call_group("Crosshair", "change_crosshair", crosshair_texture)
		
		call_deferred("reparent_to_player", gun_hold)

func reparent_to_player(new_parent: Node2D):
	# THIS IS THE FIX: Only remove if it actually has a parent
	if get_parent():
		get_parent().remove_child(self)
	
	# Now add it to the player's GunPoint
	new_parent.add_child(self)
	
	# Reset position and rotation so it sits perfectly in the hand
	position = Vector2.ZERO
	rotation = 0
	
	# Use set_deferred to avoid physics errors
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func drop_weapon(weapon_node):
	weapon_node.is_equipped = false
	weapon_node.player_in_range = null 
	
	# 1. Store the CURRENT global position of the gun before unparenting
	var drop_pos = global_position 
	
	# 2. Remove from player
	if weapon_node.get_parent():
		weapon_node.get_parent().remove_child(weapon_node)
	
	# 3. Add to the main level
	get_tree().root.add_child(weapon_node)
	
	# 4. Set the position back to where the player was
	weapon_node.global_position = drop_pos
	
	# 5. Optional: Offset it so it's not directly under the player's feet
	# This moves it 40 pixels to the right of where it was
	weapon_node.global_position += Vector2(40, 0).rotated(rotation)
	
	weapon_node.set_deferred("monitoring", true)
	weapon_node.set_deferred("monitorable", true)

func upgrade_weapon():
	if is_upgraded or !upgrade_data: return
	
	is_upgraded = true
	
	# Apply Multipliers
	fire_rate *= upgrade_data.fire_rate_multiplier
	base_damage = int(base_damage * upgrade_data.damage_multiplier)
	
	# Apply Bonuses
	mag_size += upgrade_data.mag_size_bonus
	knockback_force += upgrade_data.knockback_bonus
	
	# Update Name and Color
	modulate = upgrade_data.upgraded_color
	
	# Refill Ammo
	current_ammo = mag_size

func apply_material_bonus(material_type: String):
	match material_type:
		"fire_crystal":
			# Decrease fire_rate (lower is faster)
			fire_rate = max(0.05, fire_rate * 0.95) 
		"burning_neon":
			# Increase damage
			base_damage += 3
		"battery":
			# Increase mag size
			mag_size += 5
			current_ammo = mag_size # Refill ammo with the new capacity
	
	# Visual flare: flash the gun green to show it worked
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE if !is_upgraded else upgrade_data.upgraded_color, 0.1)

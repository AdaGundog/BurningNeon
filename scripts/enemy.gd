extends CharacterBody2D

@export_group("Stats")
@export var health: int = 3
@export var speed: float = 150.0
@export var friction: float = 0.15 # NEW: How fast the enemy recovers from knockback

@export_group("Distance Settings")
@export var min_distance: float = 200.0 
@export var shooting_range: float = 400.0 

@export_group("Combat")
@export var fire_rate: float = 1.0 
@export var bullet_scene: PackedScene

var player: Node2D = null
var can_shoot: bool = true

func _ready() -> void:
	player = get_tree().root.find_child("Player", true, false)

func _physics_process(_delta: float) -> void:
	if player:
		var dist = global_position.distance_to(player.global_position)
		var target_velocity = Vector2.ZERO # Start with the idea of standing still
		
		# 1. MOVEMENT CALCULATION
		if dist > min_distance:
			var direction = global_position.direction_to(player.global_position)
			target_velocity = direction * speed
		
		# 2. APPLYING PHYSICS (The "Knockback Friendly" part)
		# Instead of forcing velocity, we smoothly move toward our target speed.
		# This allows external forces (bullets) to affect our velocity!
		velocity = velocity.move_toward(target_velocity, speed * friction)
		
		# 3. SHOOTING
		if dist <= shooting_range and can_shoot:
			shoot()
			
	move_and_slide()

func shoot() -> void:
	if bullet_scene and player:
		can_shoot = false
		var b = bullet_scene.instantiate()
		get_tree().root.add_child(b)
		b.global_position = global_position
		b.look_at(player.global_position)
		
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

# Gizmos remain the same
func _draw() -> void:
	draw_arc(Vector2.ZERO, min_distance, 0, TAU, 100, Color(0, 0.6, 1, 0.4), 2.0)
	draw_arc(Vector2.ZERO, shooting_range, 0, TAU, 100, Color(1, 0, 0, 0.4), 2.0)

func _process(_delta: float) -> void:
	queue_redraw()

func take_damage(amount: int) -> void:
	health -= amount
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	if health <= 0:
		queue_free()

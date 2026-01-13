extends Area2D

@export var speed: float = 2000.0
@export var lifetime: float = 3.0
@export var trail_length: int = 10 # How many segments the trail has

@onready var trail: Line2D = $Line2D

var damage: int = 0 
var knockback: float = 0.0
var hit_list: Array[Node2D] = []

func _ready():
	# This makes the trail stay in place in the world 
	# while the bullet moves forward
	trail.top_level = true 

func _physics_process(delta: float) -> void:
	# Move the bullet
	position += transform.x * speed * delta
	
	# Update the trail
	update_trail()
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func update_trail():
	# Add current position to the line
	trail.add_point(global_position)
	
	# If the trail is too long, remove the oldest point
	if trail.get_point_count() > trail_length:
		trail.remove_point(0)

func _on_body_entered(body: Node2D):
	# 1. Check if we already hit this specific enemy
	if hit_list.has(body):
		return # Skip if already hit
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		# Add to hit list so it only takes damage ONCE from this bullet
		hit_list.append(body)
		
		if body is CharacterBody2D:
			var direction = Vector2.RIGHT.rotated(global_rotation)
			body.velocity += direction * knockback
			
	# 2. Piercing logic: 
	# We DO NOT call queue_free() here for enemies.
	# But we DO want the bullet to stop if it hits a wall!
	if body is StaticBody2D:
		queue_free()

func set_knockback(val: float):
	knockback = val

func set_damage(amount):
	damage = amount

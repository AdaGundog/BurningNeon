extends Area2D

# This will now appear in the Inspector on the right
@export var speed: float = 700.0
@export var lifetime: float = 2.0 
var damage: int = 0 # This will be set by the gun
var knockback: float = 0.0



func _physics_process(delta: float) -> void:
	# 1. Move forward
	position += transform.x * speed * delta
	
	# 2. Countdown the timer
	lifetime -= delta
	
	# 3. Destroy if time is up
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		# Use the variable 'damage' that was passed from the gun!
		body.take_damage(damage) 
		
		# --- APPLY KNOCKBACK ---
		if body is CharacterBody2D:
			var direction = Vector2.RIGHT.rotated(global_rotation)
			body.velocity += direction * knockback
			
	queue_free()
 
func set_knockback(val: float):
	knockback = val

func set_damage(amount):
	damage = amount

extends Area2D

@export_group("Bullet Settings")
@export var speed: float = 500.0
@export var lifetime: float = 3.0
@export var damage: int = 1 # You can now change this in the Inspector!

func _physics_process(delta: float) -> void:
	# 1. Move forward
	position += transform.x * speed * delta
	
	# 2. Life timer
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Check if the hit object is the Player
	# You should add a "take_damage" function to your Player script too!
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	
	# Optional: Hit walls but ignore the enemy who shot it
	if body is StaticBody2D or body is TileMapLayer:
		queue_free()

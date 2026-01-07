extends Area2D

@export var value: int = 10
var target: Node2D = null
var is_magnetized: bool = false
var move_speed: float = 0.0 # Starts at 0 and accelerates

func _ready():
	# Connect the small center area to pick up the coin
	body_entered.connect(_on_coin_body_entered)
	# Connect the large outer area to detect the player
	$DetectionArea.body_entered.connect(_on_detection_body_entered)

func _process(delta):
	if is_magnetized and target:
		# Accelerate toward player for a "snap" feel
		move_speed += 20.0 
		global_position = global_position.move_toward(target.global_position, move_speed * delta)

func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		is_magnetized = true

func _on_coin_body_entered(body):
	if body.is_in_group("Player"):
		GameSettings.add_money(value)
		# Play a 'ching' sound here
		queue_free()

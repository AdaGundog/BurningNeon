extends Area2D

@export var door_price: int = 750
@export var door_name: String = "Debris"

var player_in_zone = null

func _ready():
	$Label.hide() # Hide price by default
	$Label.text = "Press [E] to clear %s [%d]" % [door_name, door_price]

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = body
		$Label.show()

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		$Label.hide()

func _input(event):
	if event.is_action_pressed("interact") and player_in_zone:
		attempt_buy_door()

func attempt_buy_door():
	if GameSettings.player_money >= door_price:
		GameSettings.add_money(-door_price)
		open_door()
	else:
		# Optional: Play a "no money" sound
		print("Not enough points!")

func open_door():
	# You can add a sound effect or particles here
	queue_free() # This deletes the door and the buy zone	

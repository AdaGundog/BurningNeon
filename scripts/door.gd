extends Area2D
@export var open_sound: AudioStream
@export var keep_closed_sound: AudioStream

@export var door_price: int = 750
@export var door_name: String = "Debris"
# NEW: Match this to the group name of the spawn points in the next room
@export var zone_to_unlock: String = "Zone2" 

var player_in_zone = null

func _ready():
	$Label.hide()
	$Label.text = "Press [E] to clear %s [%d]" % [door_name, door_price]

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = body
		$Label.show()

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		$Label.hide()

func _input(_event):	
	# Using Input.is_action_just_pressed is usually safer in _input(event)
	if Input.is_action_just_pressed("interact") and player_in_zone:
		attempt_buy_door()

func attempt_buy_door():
	if GameSettings.player_money >= door_price:
		GameSettings.add_money(-door_price)
		open_door()
	else:
		print("Not enough points!")
		AudioManager.play_sound_at(keep_closed_sound, global_position)


func open_door():
	# Play the sound through the global manager
	if open_sound:
		AudioManager.play_sound_at(open_sound, global_position)
	
	get_tree().call_group("RoundManager", "unlock_zone", zone_to_unlock)
	queue_free() # Now it's safe to delete immediately!

extends Area2D

@export_group("Settings")
@export var weapon_to_give: PackedScene # Drag the Gun.tscn here
@export var price: int = 500
@export var weapon_name: String = "Sniper"
@export var buy_sound: AudioStream

var player_in_zone: Node2D = null


func _ready():
	# Set up the label text
	$PriceLabel.text = "Press B to buy " + weapon_name + " [$" + str(price) + "]"
	$PriceLabel.hide() # Hide until player is close
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)



func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = body
		$PriceLabel.show()

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		$PriceLabel.hide()

func _input(_event):
	# Check if the player is actually in the zone first
	if player_in_zone:
		# Use 'Input' (Capital I) instead of 'event'
		if Input.is_action_just_pressed("buy"):
			if GameSettings.player_money >= price:

				buy_weapon()
			else:
				show_not_enough_money()

func buy_weapon():
	AudioManager.play_sound_at(buy_sound, global_position)
	GameSettings.add_money(-price)
	
	var new_gun = weapon_to_give.instantiate()
	
	# Set the new gun's position to the player's position BEFORE adding it
	new_gun.global_position = player_in_zone.global_position
	
	get_tree().root.add_child(new_gun)
	
	# Now the swap will happen at the player's location
	new_gun.pick_up(player_in_zone)

func show_not_enough_money():
	$PriceLabel.text = "NOT ENOUGH MONEY!"
	$PriceLabel.modulate = Color.RED
	await get_tree().create_timer(1.0).timeout
	$PriceLabel.modulate = Color.WHITE
	$PriceLabel.text = "Press B to buy " + weapon_name + " [$" + str(price) + "]"

extends Area2D

@export var upgrade_cost: int = 1000
var player_in_zone: Node2D = null

func _ready():
	$UIHint.text = "Hold E to Upgrade Weapon [$%d]" % upgrade_cost
	$UIHint.hide()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = body
		$UIHint.show()

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		$UIHint.hide()

func _input(_event):
	if player_in_zone and Input.is_action_just_pressed("interact"):
		attempt_upgrade()

func attempt_upgrade():
	# 1. Check Money
	if GameSettings.player_money < upgrade_cost:
		show_message("NOT ENOUGH MONEY!")
		return
	
	# 2. Find the weapon in player's hand
	var gun_point = player_in_zone.get_node_or_null("GunPoint")
	if gun_point and gun_point.get_child_count() > 0:
		var current_gun = gun_point.get_child(0)
		
		# 3. Check if already upgraded
		if current_gun.has_method("upgrade_weapon") and not current_gun.is_upgraded:
			GameSettings.add_money(-upgrade_cost)
			perform_upgrade_sequence(current_gun)
		else:
			show_message("ALREADY UPGRADED!")

func perform_upgrade_sequence(gun):
	# Optional: You could hide the gun for 2 seconds to simulate the machine "working"
	$AudioStreamPlayer2D.play()
	gun.hide()
	$UIHint.text = "UPGRADING..."
	# Play sound here
	
	await get_tree().create_timer(2.0).timeout
	
	gun.show()
	gun.upgrade_weapon()
	$AudioStreamPlayer2D.stop()
	$UIHint.text = "Hold E to Upgrade Weapon [$%d]" % upgrade_cost

func show_message(text):
	var _old_text = $UIHint.text
	$UIHint.text = text
	await get_tree().create_timer(1.5).timeout
	$UIHint.text = "Hold E to Upgrade Weapon [$%d]" % upgrade_cost

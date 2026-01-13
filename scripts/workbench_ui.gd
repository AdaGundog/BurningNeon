extends Control

# We will update these button texts to show current inventory counts
@onready var fire_btn = $Panel/VBoxContainer/FireButton
@onready var neon_btn = $Panel/VBoxContainer/NeonButton
@onready var batt_btn = $Panel/VBoxContainer/BatteryButton
@export var upgrade_sound: AudioStream
func _ready():
	add_to_group("WorkbenchUI")
	hide() # Start hidden
	
	# Connect the buttons to functions
	fire_btn.pressed.connect(_on_material_pressed.bind("fire_crystal"))
	neon_btn.pressed.connect(_on_material_pressed.bind("burning_neon"))
	batt_btn.pressed.connect(_on_material_pressed.bind("battery"))
	$Panel/VBoxContainer/CloseButton.pressed.connect(hide_ui)

func show_ui():
	update_labels()
	show()
	# This makes the mouse visible so you can click buttons
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func hide_ui():
	hide()
	# This hides the mouse again for your twin-stick shooting
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 

func update_labels():
	# This displays "Add Fire Crystal (5 left)" on the button
	fire_btn.text = "Fire Crystal (%d left)" % GameSettings.inventory["fire_crystal"]
	neon_btn.text = "Burning Neon (%d left)" % GameSettings.inventory["burning_neon"]
	batt_btn.text = "Battery (%d left)" % GameSettings.inventory["battery"]

func _on_material_pressed(type: String):
	if GameSettings.inventory[type] > 0:
		var player = get_tree().get_first_node_in_group("Player")
		var gun_point = player.get_node_or_null("GunPoint")
		
		if gun_point and gun_point.get_child_count() > 0:
			var gun = gun_point.get_child(0)
			
			# Spend the material
			GameSettings.inventory[type] -= 1
			# Apply the bonus (the function we added to your gun script)
			gun.apply_material_bonus(type)
			AudioManager.play_sound_at(upgrade_sound,global_position)
			update_labels() # Refresh the numbers on the buttons
		else:
			print("No gun held!")
	else:
		print("Not enough materials!")

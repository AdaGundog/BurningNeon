extends Control

@onready var dvd_button = $DVDButton

# Movement variables
@export var speed: float = 200.0
var velocity: Vector2 = Vector2(1, 1) # Initial direction

# Change this to the path of your main game scene
@export_file("*.tscn") var game_scene_path: String

func _ready() -> void:
	# Randomize the starting direction
	var angles = [45, 135, 225, 315]
	var random_angle = deg_to_rad(angles.pick_random())
	velocity = Vector2.RIGHT.rotated(random_angle)
	
	# Connect the button click
	dvd_button.pressed.connect(_on_dvd_button_pressed)

func _process(delta: float) -> void:
	# Move the button
	dvd_button.position += velocity * speed * delta
	
	# Get the screen size and button size
	var screen_size = get_viewport_rect().size
	var button_size = dvd_button.size
	
	# Bounce off Horizontal walls (Left/Right)
	if dvd_button.position.x <= 0 or dvd_button.position.x + button_size.x >= screen_size.x:
		velocity.x *= -1
		change_color()

	# Bounce off Vertical walls (Top/Bottom)
	if dvd_button.position.y <= 0 or dvd_button.position.y + button_size.y >= screen_size.y:
		velocity.y *= -1
		change_color()

func change_color():
	# Classic DVD screensaver behavior: change color on every bounce
	dvd_button.modulate = Color(randf(), randf(), randf(), 1.0)

func _on_dvd_button_pressed():
	# Switch to the game!
	get_tree().change_scene_to_file(game_scene_path)

extends Control

@onready var dvd_button = $DVDButton
@onready var click_sound: AudioStreamPlayer2D = $ClickSound

@export var speed: float = 250.0
var velocity: Vector2 = Vector2(1, 1)

@export_file("*.tscn") var game_scene_path: String

func _ready() -> void:
	if dvd_button == null:
		return

	# Start white
	dvd_button.modulate = Color.WHITE
	
	# Randomize starting direction
	var angles = [45, 135, 225, 315]
	var random_angle = deg_to_rad(angles.pick_random())
	velocity = Vector2.RIGHT.rotated(random_angle)
	
	dvd_button.pressed.connect(_on_dvd_button_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	if dvd_button == null: return
	
	# Linear movement
	dvd_button.position += velocity * speed * delta
	
	var screen_size = get_viewport_rect().size
	var button_size = dvd_button.size * dvd_button.scale
	
	# Check Horizontal Walls
	if dvd_button.position.x <= 0:
		dvd_button.position.x = 0
		velocity.x *= -1
		change_color()
	elif dvd_button.position.x + button_size.x >= screen_size.x:
		dvd_button.position.x = screen_size.x - button_size.x
		velocity.x *= -1
		change_color()

	# Check Vertical Walls
	if dvd_button.position.y <= 0:
		dvd_button.position.y = 0
		velocity.y *= -1
		change_color()
	elif dvd_button.position.y + button_size.y >= screen_size.y:
		dvd_button.position.y = screen_size.y - button_size.y
		velocity.y *= -1
		change_color()

func change_color():
	# This generates a random color every time it hits a wall
	# We use randf() for Red, Green, and Blue channels
	dvd_button.modulate = Color(randf(), randf(), randf(), 1.0)

func _on_dvd_button_pressed():
	if game_scene_path != "":
		if has_node("ClickSound"):
			$ClickSound.play()
			speed = 0 # Freeze the DVD logo
			# Wait for a specific amount of time (e.g., 0.5 seconds)
			await get_tree().create_timer(1.30).timeout
		
		get_tree().change_scene_to_file(game_scene_path)

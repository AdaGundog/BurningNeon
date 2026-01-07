extends CanvasLayer

@onready var dvd_logo = $ColorRect/DVDLogo
var screen_size: Vector2
var logo_speed: Vector2 = Vector2(200, 200) # Adjust for speed

func _ready():
	hide() # Start hidden
	process_mode = Node.PROCESS_MODE_ALWAYS # IMPORTANT: This lets the menu run while the game is paused
	screen_size = get_viewport().get_visible_rect().size

func _process(delta):
	if is_visible():
		move_dvd_logo(delta)

func move_dvd_logo(delta):
	# Move the logo
	dvd_logo.position += logo_speed * delta
	
	# Check for bouncing off screen edges
	if dvd_logo.position.x <= 0 or dvd_logo.position.x + dvd_logo.size.x >= screen_size.x:
		logo_speed.x *= -1
		dvd_logo.modulate = Color(randf(), randf(), randf()) # Change color on hit like the classic meme
		
	if dvd_logo.position.y <= 0 or dvd_logo.position.y + dvd_logo.size.y >= screen_size.y:
		logo_speed.y *= -1
		dvd_logo.modulate = Color(randf(), randf(), randf())

# --- BUTTON LOGIC ---

func _input(_event):
	# Check if the player pressed the Escape key (ui_cancel)
	# Use "Input" with a capital I
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()



	# This function is created automatically when you connect the signal
func _on_resume_button_pressed():
	# This runs the toggle_pause function we wrote earlier
	toggle_pause()

# This function is created when you connect the QuitButton's pressed signal
func _on_quit_button_pressed():
	# This closes the game
	get_tree().quit()

extends CharacterBody2D

const SPEED = 300.0
const DODGE_SPEED = 800.0 # Fast burst
const DODGE_DURATION = 0.2
@export var dodge_cooldown: float = 1.0 # Seconds between dodges

@export_group("Stats")
@export var max_health: int = 10
@onready var current_health: int = max_health

@onready var _animated_sprite = $AnimatedSprite2D
@onready var hud = get_tree().root.find_child("CanvasLayer", true, false)

var speed_modifier: float = 1.0
var is_dodging: bool = false
var is_invincible: bool = false # This is the "Ghost" mode during dodge
var can_dodge: bool = true # NEW: Track cooldown state

func _ready():
	add_to_group("Player")
	if hud:
		hud.update_health(current_health, max_health)

func _physics_process(_delta: float) -> void:
	# 1. Check for Dodge with Cooldown
	if Input.is_action_just_pressed("dodge") and not is_dodging and can_dodge:
		start_dodge()

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_dodging:
		# Velocity is set in start_dodge
		pass
	elif direction != Vector2.ZERO:
		velocity = direction * (SPEED * speed_modifier)
		_animated_sprite.play("walk")
		_animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * speed_modifier)
		_animated_sprite.play("idle")

	move_and_slide()

# --- THE DAMAGE SYSTEM ---
func take_damage(amount: int):
	# If we are dodging, we take ZERO damage!
	if is_invincible:
		print("Dodged the hit!")
		return
	
	current_health -= amount
	print("Player health: ", current_health)
	
	if hud:
		hud.update_health(current_health, max_health)
	
	# Visual feedback for getting hit (Flash Red)
	_animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	_animated_sprite.modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die():
	# Restart the level or show Game Over
	get_tree().reload_current_scene()

# --- THE DODGE SYSTEM ---
func start_dodge():
	is_dodging = true
	is_invincible = true
	can_dodge = false # Start the cooldown
	
	# Visual cue: Ghostly transparency
	_animated_sprite.modulate.a = 0.5 
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.RIGHT if not _animated_sprite.flip_h else Vector2.LEFT
		
	velocity = input_dir * DODGE_SPEED
	
	# Wait for the dash to end
	await get_tree().create_timer(DODGE_DURATION).timeout
	
	is_dodging = false
	is_invincible = false
	_animated_sprite.modulate.a = 1.0 # Normal look
	
	# --- COOLDOWN LOGIC ---
	# Player is no longer dashing, but can't dodge again yet
	# Let's make the player slightly blue to show they are "recharging"
	_animated_sprite.modulate = Color(0.7, 0.7, 1.0) 
	
	await get_tree().create_timer(dodge_cooldown).timeout
	
	# Ready to dodge again!
	can_dodge = true
	_animated_sprite.modulate = Color.WHITE # Back to normal

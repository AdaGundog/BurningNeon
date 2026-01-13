extends Node2D

@export_group("Spawn Configuration")
@export var enemy_pool: Array[EnemyType] = []

@export_group("Round Settings")
@export var base_enemy_count: int = 5
@export var enemies_per_round: int = 3
@export var spawn_delay: float = 2.0 
@export var round_start_sound: AudioStream
var unlocked_zones: Array[String] = ["Zone1"] # Start with the first room
var enemies_to_spawn: int = 0
var enemies_alive: int = 0

func _ready():
	add_to_group("RoundManager") # Moved up to ensure it's in group immediately
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	start_round()

# NEW: This function is called by the Door script
func unlock_zone(zone_name: String):
	if not unlocked_zones.has(zone_name):
		unlocked_zones.append(zone_name)
		print("New spawning zone unlocked: ", zone_name)

func start_round():
	AudioManager.play_sound_at(round_start_sound, global_position)
	enemies_to_spawn = base_enemy_count + (GameSettings.current_round * enemies_per_round)
	enemies_alive = 0
	$SpawnTimer.start()

func spawn_enemy():
	# 1. NEW: Collect all spawn points from ONLY unlocked zones
	var valid_spawn_points = []
	for zone in unlocked_zones:
		# This gets all Marker2Ds in "Zone1", then "Zone2", etc.
		valid_spawn_points.append_array(get_tree().get_nodes_in_group(zone))
	
	if valid_spawn_points.size() == 0: 
		print("Warning: No spawn points found in unlocked zones!")
		return

	# 2. Filter enemy pool (existing logic)
	var available_enemies = []
	for type in enemy_pool:
		if GameSettings.current_round >= type.min_round:
			available_enemies.append(type)
	
	if available_enemies.size() == 0: return

	# 3. Choose point and enemy
	var random_point = valid_spawn_points.pick_random()
	var chosen_type = available_enemies.pick_random()
	var enemy = chosen_type.scene.instantiate()
	
	get_tree().root.add_child(enemy)
	enemy.global_position = random_point.global_position
	
	enemies_alive += 1
	enemy.tree_exited.connect(_on_enemy_killed)

func _on_spawn_timer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
	else:
		$SpawnTimer.stop()

func _on_enemy_killed():
	enemies_alive -= 1
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		next_wave_countdown()

func next_wave_countdown():
	# Use a dedicated timer or check if inside tree to avoid the 'data.tree' null error
	if is_inside_tree():
		await get_tree().create_timer(5.0).timeout 
		GameSettings.next_round()
		start_round()

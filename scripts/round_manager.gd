extends Node2D

@export_group("Spawn Configuration")
## Drag your .tres resource files into this array
@export var enemy_pool: Array[EnemyType] = []

@export_group("Round Settings")
@export var base_enemy_count: int = 5
@export var enemies_per_round: int = 3
@export var spawn_delay: float = 2.0 

var enemies_to_spawn: int = 0
var enemies_alive: int = 0

func _ready():
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	start_round()

func start_round():
	enemies_to_spawn = base_enemy_count + (GameSettings.current_round * enemies_per_round)
	enemies_alive = 0
	$SpawnTimer.start()

func spawn_enemy():
	# 1. Filter the pool for enemies allowed in this round
	var available_enemies = []
	for type in enemy_pool:
		if GameSettings.current_round >= type.min_round:
			available_enemies.append(type)
	
	if available_enemies.size() == 0: return

	# 2. Pick one and spawn at a random Marker2D in "SpawnPoints" group
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	var random_point = spawn_points.pick_random()
	
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
	# Wait 5 seconds before the next round starts
	await get_tree().create_timer(5.0).timeout 
	GameSettings.next_round()
	start_round()

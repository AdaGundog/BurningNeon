extends Resource
class_name EnemyType

@export var name: String = "Zombie"
@export var scene: PackedScene
@export var min_round: int = 1
@export var spawn_chance: float = 1.0 # Higher means more common

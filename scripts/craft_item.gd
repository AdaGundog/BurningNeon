extends Resource
class_name CraftItem

@export var item_name: String
@export var icon: Texture2D
@export var trait_type: String # "fire_rate", "ammo", or "damage"
@export var power_bonus: float = 0.2 # The 20% boost

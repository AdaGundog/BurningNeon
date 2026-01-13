extends Resource
class_name WeaponUpgradeData

@export_group("Multipliers")
@export var fire_rate_multiplier: float = 0.5 # Lower is faster (delay between shots)
@export var damage_multiplier: float = 1.5
@export var speed_multiplier: float = 1.1

@export_group("Flat Increases")
@export var mag_size_bonus: int = 15
@export var knockback_bonus: float = 200.0

@export_group("Visuals")
@export var upgraded_color: Color = Color.GOLD
@export var upgraded_name_prefix: String = "Ultra "

extends Area2D

# Set this in the Inspector for each specific material scene
@export_enum("fire_crystal", "battery", "burning_neon") var material_type: String = "fire_crystal"
@export var amount: int = 1

func _ready():
	# Connect the signal if a player enters the area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# Call the global GameSettings (assuming it's an Autoload named GameSettings)
		GameSettings.collect_material(material_type, amount)
		queue_free() # Remove the item from the world

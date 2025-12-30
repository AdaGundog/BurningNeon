extends CanvasLayer

# Use "unique names" or exact paths. 
# Tip: Right-click the node in the scene tree and select "Access as Unique Name"
# Then you can use %HealthBar instead of the full path.
@onready var health_bar = find_child("HealthBar", true, false)
@onready var ammo_label = find_child("AmmoLabel", true, false)

	
func update_health(current: int, max_val: int):
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current
		
	else:
		print("Error: HealthBar node not found!")

func update_ammo(current: int, max_val: int):
	if ammo_label:
		ammo_label.text = "Ammo: %s / %s" % [current, max_val]
		
		
	else:
		print("Error: AmmoLabel node not found!")

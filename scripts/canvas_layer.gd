extends CanvasLayer

# These update the visual nodes on your screen
func update_health(current: int, max_val: int):
	# Using % access for the ProgressBar
	var bar = get_node_or_null("%HealthBar")
	if bar:
		bar.max_value = max_val
		bar.value = current
	else:
		# If you see this in the console, right-click your bar and 
		# select "Access as Unique Name"
		print("UI Error: %HealthBar not found!")

func update_ammo(current: int, max_val: int):
	# Using % access for the Label
	var label = get_node_or_null("%AmmoLabel")
	if label:
		label.text = "Ammo: " + str(current) + " / " + str(max_val)
	else:
		print("UI Error: %AmmoLabel not found!")

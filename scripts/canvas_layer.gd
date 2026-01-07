extends CanvasLayer

func _ready():
	# 1. Set the initial text
	# We use the update_text function immediately to set the starting value
	update_text(GameSettings.player_money)
	
	# 2. Connect to the Global Signal
	GameSettings.money_changed.connect(update_text)
	
	GameSettings.round_changed.connect(update_round_text)
	update_round_text(GameSettings.current_round)

func update_text(new_amount):
	# Using % access to find the label specifically
	var label = get_node_or_null("%MoneyLabel")
	
	if label:
		label.text = "$" + str(new_amount)
		
		# "Juice" - Make the label pop
		var tween = create_tween()
		label.pivot_offset = label.size / 2 # Ensure it scales from the center
		label.scale = Vector2(1.2, 1.2)
		tween.tween_property(label, "scale", Vector2.ONE, 0.2)
	else:
		print("UI Error: %MoneyLabel not found! Right-click the label and 'Access as Unique Name'.")

# --- Your existing Health and Ammo functions ---

func update_health(current: int, max_val: int):
	var bar = get_node_or_null("%HealthBar")
	if bar:
		bar.max_value = max_val
		bar.value = current

func update_ammo(current: int, max_val: int):
	var label = get_node_or_null("%AmmoLabel")
	if label:
		label.text = "Ammo: " + str(current) + " / " + str(max_val)

func update_round_text(new_round):
	var label = get_node_or_null("%RoundLabel")
	if label:
		label.text = "ROUND " + str(new_round)

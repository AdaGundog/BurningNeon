extends Node

# --- Signals ---
signal money_changed(new_amount)
signal round_changed(new_round)
signal inventory_changed(materials)

# --- Stats & Rounds ---
var player_money: int = 1000
var current_round: int = 1

# --- Inventory ---
var inventory = {
	"fire_crystal": 0,
	"battery": 0,
	"burning_neon": 0
}

# --- Money Logic ---
func add_money(amount: int):
	player_money += amount
	money_changed.emit(player_money)

# --- Round Logic ---
func next_round():
	current_round += 1
	round_changed.emit(current_round)

# --- Inventory Logic ---
func collect_material(type: String, amount: int):
	if inventory.has(type):
		inventory[type] += amount
		inventory_changed.emit(inventory)
		print("Collected ", amount, " ", type, ". Total: ", inventory[type])
	else:
		print("Warning: Item type ", type, " not found in GameSettings inventory!")

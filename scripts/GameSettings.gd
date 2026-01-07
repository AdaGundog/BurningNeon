extends Node

signal money_changed(new_amount)
signal round_changed(new_round) # New signal for the UI

var player_money: int = 1000
var current_round: int = 1

func add_money(amount: int):
	player_money += amount
	money_changed.emit(player_money)

func next_round():
	current_round += 1
	round_changed.emit(current_round)

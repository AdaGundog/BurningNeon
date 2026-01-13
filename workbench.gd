extends Area2D

# This will automatically find the Label named UIHint
@onready var ui_hint = $UIHint 

var player_in_zone: Node2D = null

func _ready():
	ui_hint.hide() # Start hidden
	ui_hint.text = "Press [E] to use Workbench"

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = body
		ui_hint.show()

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		ui_hint.hide()
		# Close the menu if player walks away
		get_tree().call_group("WorkbenchUI", "hide_ui")

func _input(_event):
	if player_in_zone and Input.is_action_just_pressed("interact"):
		# This opens the crafting menu you made earlier
		get_tree().call_group("WorkbenchUI", "show_ui")

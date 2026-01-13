extends Node

func play_sound_at(stream: AudioStream, pos: Vector2):
	var player = AudioStreamPlayer2D.new()
	add_child(player)
	player.stream = stream
	player.global_position = pos
	player.play()
	# Delete the player automatically when the sound ends
	player.finished.connect(player.queue_free)

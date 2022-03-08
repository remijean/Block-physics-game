extends Node2D


#### BUILT-IN ####

func _input(event: InputEvent) -> void:
	# Toggle fullscreen
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

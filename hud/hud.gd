extends CanvasLayer

onready var counter = $Counter
onready var fps = $FPS


#### BUILT-IN ####

func _process(_delta: float) -> void:
	fps.set_text(String(Engine.get_frames_per_second()))


#### SIGNAL RESPONSES ####

func _on_World_blocks_count(number) -> void:
	counter.set_text(String(number))

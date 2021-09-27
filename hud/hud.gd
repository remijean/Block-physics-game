extends CanvasLayer

onready var counter = $Counter
onready var fps = $FPS

func _process(_delta):
	fps.set_text(String(Engine.get_frames_per_second()))

func _on_World_blocks_count(number):
	counter.set_text(String(number))

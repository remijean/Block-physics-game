extends TileMap

signal pixels_count(number)

enum Types { NONE = -1, STONE, SAND, WATER }

var type_weights := {
	Types.NONE: 0,
	Types.STONE: 3,
	Types.SAND: 2,
	Types.WATER: 1
}
var current_type = Types.STONE

func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	var cell_position = world_to_map(mouse_position)
	
	# Add pixel
	if Input.is_action_pressed("add"):
		set_cellv(cell_position, current_type)
	# Delete pixel
	if Input.is_action_pressed("delete"):
		set_cellv(cell_position, Types.NONE)
	
	# Switch cell type
	if Input.is_action_just_pressed("stone"):
		current_type = Types.STONE
	if Input.is_action_just_pressed("sand"):
		current_type = Types.SAND
	if Input.is_action_just_pressed("water"):
		current_type = Types.WATER
	
func physics_pixels(type: int):
	var pixels = get_used_cells_by_id(type)
	for pixel in pixels:
		var x = pixel.x
		var y = pixel.y
		var random_x = pow(-1, randi() % 2)
		
		# Temporary clean
		if map_to_world(pixel).y > get_viewport_rect().size.y:
			set_cellv(pixel, Types.NONE)
			continue
		
		# Check adjacent pixels
		var left_right = check_swap_pixel(pixel, Vector2(x + random_x, y))
		var down_left_right = check_swap_pixel(pixel, Vector2(x + random_x, y + 1))
		var down = check_swap_pixel(pixel, Vector2(x, y + 1))
		
		# Movement
		match type:
			Types.SAND:
				if down:
					swap_pixel(pixel, Vector2(x, y + 1))
				elif left_right && down_left_right:
					swap_pixel(pixel, Vector2(x + random_x, y + 1))
			Types.WATER:
				if down:
					swap_pixel(pixel, Vector2(x, y + 1))
				elif left_right && down_left_right:
					swap_pixel(pixel, Vector2(x + random_x, y + 1))
				elif left_right:
					swap_pixel(pixel, Vector2(x + random_x, y))

func check_swap_pixel(from: Vector2, to: Vector2):
	return type_weights[get_cellv(from)] > type_weights[get_cellv(to)]

func swap_pixel(from: Vector2, to: Vector2):
	var from_type = get_cellv(from)
	var to_type = get_cellv(to)
	set_cellv(from, to_type)
	set_cellv(to, from_type)

func _on_PixelSpeed_timeout():
	physics_pixels(Types.SAND)
	physics_pixels(Types.WATER)
	emit_signal("pixels_count", get_used_cells().size())

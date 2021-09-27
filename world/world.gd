extends TileMap

signal blocks_count(number)

enum { TYPE_NONE = -1, TYPE_STONE, TYPE_SAND, TYPE_WATER }

const BRUSH_SIZE := 2
const WEIGHT_TYPES = {
	TYPE_NONE: 0,
	TYPE_STONE: 3,
	TYPE_SAND: 2,
	TYPE_WATER: 1
}

var current_type := TYPE_STONE

func _process(_delta):
	var position = world_to_map(get_viewport().get_mouse_position())
	
	# Add block
	if Input.is_action_pressed("add"):
		for x in BRUSH_SIZE:
			for y in BRUSH_SIZE:
				set_cell(position.x - (BRUSH_SIZE / 2.0) + x, position.y - (BRUSH_SIZE / 2.0) + y, current_type)
	
	# Delete block
	if Input.is_action_pressed("delete"):
		for x in BRUSH_SIZE:
			for y in BRUSH_SIZE:
				set_cell(position.x - (BRUSH_SIZE / 2.0) + x, position.y - (BRUSH_SIZE / 2.0) + y, TYPE_NONE)
	
	# Switch cell type
	if Input.is_action_just_pressed("stone"):
		current_type = TYPE_STONE
	if Input.is_action_just_pressed("sand"):
		current_type = TYPE_SAND
	if Input.is_action_just_pressed("water"):
		current_type = TYPE_WATER
	
func physics(type: int):
	var blocks = get_used_cells_by_id(type)
	for block in blocks:
		# Temporary clean
		if map_to_world(block).y > get_viewport_rect().size.y:
			set_cellv(block, TYPE_NONE)
			continue
		
		# Directions
		var random_x = pow(-1, randi() % 2)
		var left_right = Vector2(block.x + random_x, block.y)
		var down_left_right = Vector2(block.x + random_x, block.y + 1)
		var down = Vector2(block.x, block.y + 1)
		
		# Movements
		match type:
			TYPE_SAND:
				if check_swap(block, down):
					swap(block, down)
				elif check_swap(block, left_right) && check_swap(block, down_left_right):
					swap(block, down_left_right)
			TYPE_WATER:
				if check_swap(block, down):
					swap(block, down)
				elif check_swap(block, left_right) && check_swap(block, down_left_right):
					swap(block, down_left_right)
				elif check_swap(block, left_right):
					swap(block, left_right)

func check_swap(from: Vector2, to: Vector2):
	return WEIGHT_TYPES[get_cellv(from)] > WEIGHT_TYPES[get_cellv(to)]

func swap(from: Vector2, to: Vector2):
	var from_type = get_cellv(from)
	var to_type = get_cellv(to)
	set_cellv(from, to_type)
	set_cellv(to, from_type)

func _on_PhysicsSpeed_timeout():
	physics(TYPE_SAND)
	physics(TYPE_WATER)
	emit_signal("blocks_count", get_used_cells().size())

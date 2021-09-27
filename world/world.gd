extends TileMap

signal blocks_count(number)

enum {
	TYPE_NONE = -1,
	TYPE_STONE,
	TYPE_SAND,
	TYPE_WATER,
	TYPE_GAS,
	TYPE_DIRT,
	TYPE_MUD
}

const BRUSH_MIN := 1
const BRUSH_MAX := 8
const PHYSICS_TYPES = [TYPE_SAND, TYPE_WATER, TYPE_GAS, TYPE_MUD]
const WEIGHT_TYPES = {
	TYPE_NONE: 0,
	TYPE_GAS: 100,
	TYPE_WATER: 200,
	TYPE_SAND: 300,
	TYPE_MUD: 400,
	TYPE_DIRT: 500,
	TYPE_STONE: 600
}

var brush_size := 1
var current_type := TYPE_STONE

func _process(_delta):
	var position = world_to_map(get_viewport().get_mouse_position())
	var brush_size_half = floor(brush_size / 2.0)
	
	# Add block
	if Input.is_action_pressed("add"):
		for x in brush_size:
			for y in brush_size:
				set_cell(position.x - brush_size_half + x, position.y - brush_size_half + y, current_type)
	
	# Delete block
	if Input.is_action_pressed("delete"):
		for x in brush_size:
			for y in brush_size:
				set_cell(position.x - brush_size_half + x, position.y - brush_size_half + y, TYPE_NONE)
	
	# Brush increase
	if Input.is_action_just_released("brush_increase"):
		brush_size = int(min(BRUSH_MAX, brush_size * 2))
	
	# Brush decrease
	elif Input.is_action_just_released("brush_decrease"):
		brush_size = int(max(BRUSH_MIN, brush_size / 2.0))
	
	# Temporary type switch
	if Input.is_action_just_pressed("stone"):
		current_type = TYPE_STONE
	if Input.is_action_just_pressed("sand"):
		current_type = TYPE_SAND
	if Input.is_action_just_pressed("water"):
		current_type = TYPE_WATER
	if Input.is_action_just_pressed("gas"):
		current_type = TYPE_GAS
	if Input.is_action_just_pressed("dirt"):
		current_type = TYPE_DIRT
	if Input.is_action_just_pressed("mud"):
		current_type = TYPE_MUD
	
func physics(type: int):
	var blocks = get_used_cells_by_id(type)
	for block in blocks:
		# Temporary clean
		var position = map_to_world(block).y
		if position < 0 || position > get_viewport_rect().size.y:
			set_cellv(block, TYPE_NONE)
			continue
		
		# Directions
		var random_x = pow(-1, randi() % 2)
		var up = Vector2(block.x, block.y - 1)
		var up_left_right = Vector2(block.x + random_x, block.y - 1)
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
			TYPE_GAS:
				if check_swap(block, up):
					swap(block, up)
				elif check_swap(block, left_right) && check_swap(block, up_left_right):
					swap(block, up_left_right)
				elif check_swap(block, left_right):
					swap(block, left_right)
			TYPE_MUD:
				if check_swap(block, down):
					swap(block, down)

func check_swap(from: Vector2, to: Vector2):
	return WEIGHT_TYPES[get_cellv(from)] > WEIGHT_TYPES[get_cellv(to)]

func swap(from: Vector2, to: Vector2):
	var from_type = get_cellv(from)
	var to_type = get_cellv(to)
	set_cellv(from, to_type)
	set_cellv(to, from_type)

func _on_PhysicsSpeed_timeout():
	emit_signal("blocks_count", get_used_cells().size())
	for type in PHYSICS_TYPES:
		physics(type)

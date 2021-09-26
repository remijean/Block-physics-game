extends TileMap

enum { STONE_CELL, SAND_CELL, WATER_CELL }

var weights := {
	INVALID_CELL: 0,
	STONE_CELL: 3,
	SAND_CELL: 2,
	WATER_CELL: 1
}
var current_type := STONE_CELL

func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	var cell_position = world_to_map(mouse_position)
	
	# Add
	if Input.is_action_pressed("add"):
		set_cell(cell_position.x, cell_position.y, current_type)
	# Delete
	if Input.is_action_pressed("delete"):
		set_cell(cell_position.x, cell_position.y, INVALID_CELL)
	
	# Switch type
	if Input.is_action_just_pressed("stone"):
		current_type = STONE_CELL
	if Input.is_action_just_pressed("sand"):
		current_type = SAND_CELL
	if Input.is_action_just_pressed("water"):
		current_type = WATER_CELL

func _physics_process(_delta):
	physics_cell(SAND_CELL)
	physics_cell(WATER_CELL)
	
func physics_cell(type: int):
	var cells = get_used_cells_by_id(type)
	for cell in cells:
		var x = cell.x
		var y = cell.y
		var random_x = pow(-1, randi() % 2)
		
		# Temporary clean
		if map_to_world(cell).y > get_viewport_rect().size.y:
			set_cellv(cell, INVALID_CELL)
			continue
		
		# Check adjacent cells
		var left_right = cell_is_free(cell, x + random_x, y)
		var down_left_right = cell_is_free(cell, x + random_x, y + 1)
		var down = cell_is_free(cell, x, y + 1)
		
		# Movement
		match type:
			SAND_CELL:
				if down:
					swap_cell(cell, x, y + 1)
				elif left_right && down_left_right:
					swap_cell(cell, x + random_x, y + 1)
			WATER_CELL:
				if down:
					swap_cell(cell, x, y + 1)
				elif left_right && down_left_right:
					swap_cell(cell, x + random_x, y + 1)
				elif left_right:
					swap_cell(cell, x + random_x, y)

func cell_is_free(from: Vector2, x: int, y: int):
	var from_type = get_cellv(from)
	var to_type = get_cell(x, y)
	return weights[from_type] > weights[to_type]

func swap_cell(from: Vector2, x: int, y: int):
	var from_type = get_cellv(from)
	var to_type = get_cell(x, y)
	if from_type != to_type:
		set_cellv(from, to_type)
		set_cell(x, y, from_type)

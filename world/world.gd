extends TileMap

enum { STONE_CELL, SAND_CELL, WATER_CELL }

const TYPES = [ STONE_CELL, SAND_CELL, WATER_CELL ]

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
	
	# Switch type
	if Input.is_action_just_pressed("stone"):
		current_type = STONE_CELL
	if Input.is_action_just_pressed("sand"):
		current_type = SAND_CELL
	if Input.is_action_just_pressed("water"):
		current_type = WATER_CELL
	
	# Add
	if Input.is_action_pressed("add"):
		set_cellv(cell_position, current_type)
	
	# Delete
	if Input.is_action_pressed("delete"):
		set_cellv(cell_position, INVALID_CELL)

func physics():
	for type in TYPES:
		var cells = get_used_cells_by_id(type)
		for cell in cells:
			var x = cell.x
			var y = cell.y
			var random_x = pow(-1, randi() % 2)
			
			# Check adjacent cells
			var down = cell_is_free(cell, x, y + 1)
			var down_left_right = cell_is_free(cell, x + random_x, y + 1)
			var left_right = cell_is_free(cell, x + random_x, y)
			
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
					elif left_right:
						swap_cell(cell, x + random_x, y)
					elif left_right && down_left_right:
						swap_cell(cell, x + random_x, y + 1)

func cell_is_free(from: Vector2, x: int, y: int):
	return weights[get_cellv(from)] > weights[get_cell(x, y)]

func swap_cell(from: Vector2, x: int, y: int):
	var from_type = get_cellv(from)
	var to_type = get_cell(x, y)
	set_cell(x, y, from_type, false, false, true)
	set_cellv(from, to_type, false, false, true)

func _on_Timer_timeout():
	physics()

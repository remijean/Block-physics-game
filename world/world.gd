extends TileMap

signal blocks_count(number)

# The order must be the same as in the titleset
enum {
	BLOCK_NONE = -1,
	BLOCK_STONE,
	BLOCK_DIRT,
	BLOCK_MUD,
	BLOCK_SAND
}

const BLOCKS_WITH_PHYSICS = [
	BLOCK_SAND,
	BLOCK_MUD
]

const BLOCKS_WEIGHT = {
	BLOCK_NONE: 0,
	BLOCK_SAND: 1,
	BLOCK_MUD: 2,
	BLOCK_STONE: 10,
	BLOCK_DIRT: 10
}

var current_block := BLOCK_STONE


#### BUILT-IN ####

func _process(_delta: float) -> void:
	var position = world_to_map(get_viewport().get_mouse_position())
	
	# Add block
	if Input.is_action_pressed("add"):
		set_cell(position.x, position.y, current_block)
		
	# Delete block
	if Input.is_action_pressed("delete"):
		set_cell(position.x, position.y, BLOCK_NONE)
		
	# Block switch
	if Input.is_action_just_released("next"):
		current_block = int(min(3, current_block + 1))
	elif Input.is_action_just_released("previous"):
		current_block = int(max(0, current_block - 1))


#### LOGIC ####

func _blocks_physics(type: int) -> void:
	var blocks = get_used_cells_by_id(type)
	blocks.shuffle()
	for block in blocks:
		# Directions
		var down = Vector2(block.x, block.y + 1)
		var diagonal_random = Vector2(block.x + pow(-1, randi() % 2), block.y + 1)
		
		# Movements
		match type:
			BLOCK_MUD:
				if _check_swap(block, down):
					_swap(block, down)
			BLOCK_SAND:
				if _check_swap(block, down):
					_swap(block, down)
				elif _check_swap(block, diagonal_random):
					_swap(block, diagonal_random)

func _check_swap(from: Vector2, to: Vector2) -> bool:
	return BLOCKS_WEIGHT[get_cellv(from)] > BLOCKS_WEIGHT[get_cellv(to)]

func _swap(from: Vector2, to: Vector2) -> void:
	var from_type = get_cellv(from)
	var to_type = get_cellv(to)
	set_cellv(from, to_type)
	set_cellv(to, from_type)


#### SIGNAL RESPONSES ####

func _on_PhysicsSpeed_timeout() -> void:
	emit_signal("blocks_count", get_used_cells().size())
	for type in BLOCKS_WITH_PHYSICS:
		_blocks_physics(type)

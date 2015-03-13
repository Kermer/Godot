extends TileMap

# Add part from other TileMap
func add_part( pos, part, part_size, start_pos = Vector2(0,0) ):
	if !part extends TileMap:
		print("Can only create from TileMap!")
		return
	pos = world_to_map(pos)
	for x in range(start_pos.x, part_size.x):
		for y in range(start_pos.y, part_size.y):
			var cell_id = part.get_cell(x, y)
			if cell_id != -1: # part cell is not empty
				set_cell(pos.x + x, pos.y + y, cell_id) # apply to our main TileMap

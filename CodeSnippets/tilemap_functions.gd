extends TileMap

# Add part from other TileMap
func add_part( pos, part, part_size, part_pos = Vector2(0,0) ):
	if !part extends TileMap:
		print("Can only create from TileMap!")
		return
	pos = world_to_map(pos)
	for x in range(part_pos.x, part_pos.x + part_size.x):
		for y in range(part_pos.y, part_pos.y + part_size.y):
			var cell_id = part.get_cell(x, y)
			if cell_id != -1: # part cell is not empty
				set_cell(pos.x + x, pos.y + y, cell_id) # apply to our main TileMap


# returns TileMap area (pos + size)
# credits to: Username ( http://www.godotengine.org/forum/viewtopic.php?f=15&t=1821 )
func get_tilemap_area(tilemap=self, world_pos=true):
	var rect = tilemap.get_item_rect()
	if world_pos == false:
		rect.pos = tilemap.world_to_map( rect.pos )
		rect.size = tilemap.world_to_map( rect.size )
	return rect

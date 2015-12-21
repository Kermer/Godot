# All credits goes to:
#	Daniel Lewan - TeddyDD
# for his Godot-Cave-Generator ( https://gitlab.com/TeddyDD/Godot-Cave-Generato )

# Everything is MIT licensed, please let me know if I need to add the license/copyright anywhere


tool
extends Panel

var scene_root = null # base node for TileMap path
var map = []
var size = Vector2()
var last_map = [] # stores last map

var smoothed = false # true if map was smoothed at least once

var drag = false # for window(panel) movement

func _ready():
	# test settings
#	scene_root = get_node("/root")
	# connect signals
	get_node("BGenerate").connect("pressed",self,"_generate")
	get_node("BSmooth").connect("pressed",self,"_smooth")
	get_node("BClose").connect("pressed",self,"hide")
	get_node("BExport").connect("pressed",self,"_export")
	get_node("BRollback").connect("pressed",self,"_rollback")
	
	get_node("Path/LineEdit").connect("text_changed",self,"_nodepath_changed")
	var path = get_node("Path/LineEdit").get_text()
	# update "Path/Label" displayed text
	_nodepath_changed(path)
	
	# allow to move the window
	set_process_input(true)

# only fires if event is within control area
func _input_event(ev):
	if ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == 1:
		# on LMB press
		if ev.is_pressed():
			drag = true
		# on LMB release
		else:
			drag = false
		print(drag)

# fires when any input is sent
func _input(ev):
	if drag and ev.type == InputEvent.MOUSE_MOTION:
		set_pos( get_pos() + ev.relative_pos )


func get_map():
	return map
func get_map_size():
	return size
func get_last_map():
	return last_map
func set_root( new_root ):
	if !(new_root extends Node):
		return FAILED
	scene_root = new_root
	return OK
func get_root():
	return scene_root

func _generate():
	randomize()
	size.x = get_node("Size/X").get_val()
	size.y = get_node("Size/Y").get_val()
	var fill_percent = get_node("Fill/Value").get_val()
	
	# remember last map (for undo)
	if !smoothed:
		last_map = []+map
	# reset variable
	smoothed = false
	# allow rollback?
	if last_map.size() >= 9 and get_node("BRollback").is_disabled():
		get_node("BRollback").set_disabled(false)
	map.resize(size.x*size.y)
	for y in range(size.y):
		for x in range(size.x):
			var i = y * size.x + x # index of current tile
			# fill map with random tiles
			if randi() % 101 < fill_percent or x == 0 or x == size.x - 1 or y == 0 or y == size.y - 1:
				map[i] = 1
			else:
				map[i] = 0
	# show preview of the map
	preview()

func _smooth():
	# if it's "Preview"
	if !get_node("Preview").is_visible():
		get_node("Preview").show()
		return
	# if it's "Smooth"
	if !smoothed:
		last_map = []+map
	# we need to skip borders of screen
	for y in range(1,size.y -1): 
		for x in range(1,size.x - 1):
			var i = y * size.x + x
			if map[i] == 1: # if it was a wall
				if touching_walls(Vector2(x,y)) >= 4: # and 4 or more of its eight neighbors were walls
					map[i] = 1 # it becomes a wall
				else:
					map[i] = 0
			elif map[i] == 0: # if it was empty
				if touching_walls(Vector2(x,y)) >= 5: # we need 5 or neighbors
					map[i] = 1
				else:
					map[i] = 0
	
	smoothed = true
	# after using "smooth" allow to rollback the map
	if last_map.size() >= 9:
		#smoothed = true # 
		get_node("BRollback").set_disabled(false)
	# show preview
	preview()

# Export map to TileMap
func _export():
	# get values
	var nodepath = get_node("Path/LineEdit").get_text()
	var tmap = scene_root.get_node(nodepath)
	var empty_id = int(get_node("EmptyTile/ID").get_value())
	var wall_id = int(get_node("WallTile/ID").get_value())
	# create backup as child of this TileMap
	var b_tmap = tmap.duplicate()
	b_tmap.hide()
	b_tmap.set_name("BACKUP_TMAP")
	tmap.add_child(b_tmap)
	b_tmap.set_owner(scene_root) # so changes saves inside editor
	
	tmap.clear()
	
	var tiles = [empty_id,wall_id]
	for y in range(size.y):
		for x in range(size.x):
			var i = y * size.x + x
			tmap.set_cell(x,y, tiles[ map[i] ]) # 0 -> empty_id, 1 -> wall_id
	
	hide() # exporting done ;)

# load last memorized map
func _rollback():
	map = []+last_map
	get_node("BRollback").set_disabled(true)
	preview()

# return count of touching walls 
func touching_walls(point):
	var result = 0
	for y in [-1,0,1]:
		for x in [-1,0,1]:
			if x == 0 and y == 0: #we don't want to count tested point
				continue
			var i = (y + point.y) * size.x + (x + point.x)
			if map[i] == 1:
				result += 1
	return result

# show preview of our map
func preview():
	var p_node = get_node("Preview")
	p_node.set_map( map, size ) # prepare preview map
	p_node.update() # call _draw()
	if p_node.is_hidden() == true: # if it's hidden then show it
		p_node.show()

# when nodepath is changed
func _nodepath_changed( npath ):
	get_node("BExport").set_disabled(true)
	if scene_root == null:
		print("(CaveGenerator) scene_root is not specified! Use set_root() in main script!")
		return
	var target = null
	if scene_root.has_node(npath): # has_node to prevent console ERROR spam
		target = scene_root.get_node(npath)
	var label = get_node("Path/Label")
	if target == null:
		label.set_text("(null)")
	elif target.get_type() != "TileMap":
		label.set_text(str("Not TileMap (",target.get_name(),")"))
	else:
		label.set_text(target.get_name())
		get_node("BExport").set_disabled(false)
		# update ID error prompts
		var tiles_count = get_tiles_count( target )
		update_max_tile_id(tiles_count)

# returns amount of tiles in tileset
func get_tiles_count( tmap ):
	var tset = tmap.get_tileset()
	if tset == null:
		return 0
	return tset.get_last_unused_tile_id()-1

# Updates tiles ID notification
func update_max_tile_id( tiles_count ):
	var empty = get_node("EmptyTile")
	var wall = get_node("WallTile")
	empty.max_id = tiles_count
	empty._val_changed()
	wall.max_id = tiles_count
	wall._val_changed()

extends Control

var vec = Vector2()
onready var node1 = get_node("Start")
onready var node2 = get_node("End")

func _ready():
	set_process_input(true)

func intersect(rect,pos,vec):
	if rect.size==Vector2() or vec==Vector2():
		return pos
	
	var intersect = pos
	var v = vec.normalized()
	
	if (sign(v.x) == 0):
		if (sign(v.y) == -1): intersect.y = 0
		else: intersect.y = rect.size.y
	elif (sign(v.y) == 0):
		if (sign(v.x) == -1): intersect.x = 0
		else: intersect.x = rect.size.x
	else:
		var vmax = Vector2()
		if sign(v.x) == -1: vmax.x = (0-pos.x) / v.x
		else: vmax.x = (rect.size.x-pos.x) / v.x
		if sign(v.y) == -1: vmax.y = (0-pos.y) / v.y
		else: vmax.y = (rect.size.y-pos.y) / v.y
		
		if abs(vmax.x) < abs(vmax.y):
			intersect += v * vmax.x
		else:
			intersect += v * vmax.y
	
	return intersect


func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		var pos = get_node("Start").get_local_mouse_pos()
		vec = pos
		update()
	elif ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed():
		var pos = get_node("Start").get_global_mouse_pos()
		get_node("Start").set_global_pos(pos)

# Show 'vec' visualisation and move the 2nd point
func _draw():
	draw_rect(Rect2(Vector2(),get_size()),Color(0,1,0,0.3))
	var pos = get_node("Start").get_pos()
	draw_line(pos,pos+vec,Color(1,0,0,0.6),3)
	
	var end_pos = intersect(Rect2(Vector2(),get_size()),pos,vec)
	get_node("End").set_pos(end_pos)
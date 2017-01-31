# Returns position of line intersection with walls
#	Check 'Demos/intersect-demo'

#	rect (Rect2) - represents room size. It's planned to make use of .pos as offset
#	pos (Vector2) - point from which line will be drawn
#	vec (Vector2) - direction of the line

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
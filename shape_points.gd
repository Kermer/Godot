
func get_shape_points( body = self, shape_id = 0, global_pos = true ):
	var points = Vector2Array()
	if !(body extends CollisionObject2D): # body doesn't use shapes
		return points
	if body.get_shape(shape_id) == null: # there's no shape with that id
		return points
	
	var pos = body.get_global_pos()
	if global_pos == false:
		pos = Vector2(0,0)
	
	var shape = body.get_shape( shape_id )
	print(shape.get_import_metadata())
	var shape_pos = body.get_shape_transform( shape_id ).get_origin()
	var rot = body.get_shape_transform( shape_id ).get_rotation() + body.get_rot()
	pos = pos + shape_pos
	
	if shape extends RectangleShape2D:
		var ex = shape.get_extents().rotated( rot )
		points.push_back( pos - ex )
		points.push_back( pos + Vector2(ex.x, -ex.y) )
		points.push_back( pos + ex )
		points.push_back( pos - Vector2(ex.x, -ex.y) )
	elif shape extends CircleShape2D or shape extends CapsuleShape2D:
		print("Calculating points for Circle/Capsule is really ineffective, skipping...")
	elif shape extends RayShape2D:
		var length = shape.get_length()
		points.push_back( pos )
		points.push_back( pos + Vector2(0,length).rotated(rot) )
	elif shape extends LineShape2D:
		pass
	elif shape extends ConvexPolygonShape2D:
		var poly_points = shape.get_points()
		for point_pos in poly_points:
			points.push_back( pos + point_pos.rotated(rot) )
	elif shape extends ConcavePolygonShape2D:
		# unsure if this one works
		var poly_points = shape.get_segments()
		for point_pos in poly_points:
			points.push_back( pos + point_pos.rotated(rot) )
	elif shape extends SegmentShape2D:
		points.push_back( shape.get_a().rotated(rot) )
		points.push_back( shape.get_b().rotated(rot) )
	
	return points

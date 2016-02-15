extends Sprite

func _ready():
	set_pos( get_global_mouse_pos() )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	set_process_input(true)

func set_pos( pos ): # function overriding
	# keep mouse inside viewport
	var rect = get_viewport_rect()
	if pos.x < rect.pos.x:
		pos.x = rect.pos.x
	elif pos.x > rect.pos.x+rect.size.x:
		pos.x = rect.pos.x+rect.size.x
	if pos.y < rect.pos.y:
		pos.y = rect.pos.y
	elif pos.y > rect.pos.y+rect.size.y:
		pos.y = rect.pos.y+rect.size.y
	set("transform/pos",pos)

func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		set_pos( get_pos()+ev.relative_pos )

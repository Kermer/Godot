# Recommended to use as Autoload
# Allows you to map Joystick Axes to trigger some actions
# Only tested on Xbox-like gamepad

extends Node

var actions = []

func _ready():
# add_action( device_id, axis_id, value, action_name )
	add_action(0,0,-0.6,"ui_left")
	add_action(0,0,0.6,"ui_right")
	add_action(0,1,-0.6,"ui_up")
	add_action(0,1,0.6,"ui_down")
#	del_action(0,0,-0.6,"ui_left")

func add_action(device,axis,val,name):
	var new_action = [device,axis,val,name]
	actions.append(new_action)
	updated()

func del_action(device,axis,val,name):
	var action = [device,axis,val,name]
	var idx = actions.find(action)
	if idx == -1:
#		print("Can't delete non-existing joystick action: ",name,": ",device,", ",axis,", ",val)
		return 1
	actions.remove(idx)
	updated()
	return 0

func updated():
	if actions.size() == 0:
		set_process_input(false)
	elif !is_processing_input():
		set_process_input(true)

func _input(ev):
	if ev.type == InputEvent.JOYSTICK_MOTION:
		for action in actions:
			if ev.device == action[0] and ev.axis == action[1]:
				var val = action[2]
				if val < 0:
					if ev.value < val:
						if !Input.is_action_pressed(action[3]):
							Input.action_press(action[3])
					else:
						if Input.is_action_pressed(action[3]):
							Input.action_release(action[3])
				elif val > 0:
					if ev.value > val:
						if !Input.is_action_pressed(action[3]):
							Input.action_press(action[3])
					else:
						if Input.is_action_pressed(action[3]):
							Input.action_release(action[3])

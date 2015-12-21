tool
extends EditorPlugin

var button = null
var panel = null
#var panel_visible = false

func get_name():
	return "Cave Generator"

func _enter_tree():
	button = Button.new()
	button.set_text("Cave Generator")
	button.connect("pressed",self,"_show_window")
	add_custom_control(CONTAINER_CANVAS_EDITOR_MENU,button)
	
	panel = preload("panel.tscn").instance()
	var scene_root = get_tree().get_edited_scene_root()
	panel.set_root(scene_root) # custom function
	panel.set_pos(Vector2(200,200)) # some initial offset, panel can be moved (LMB+drag) anyway
	panel.hide()
	add_child(panel)
	
func _show_window():
	panel.show()

func _exit_tree():
	button.queue_free()
	button = null


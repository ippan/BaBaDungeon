extends Spatial

signal on_active(value)

signal on_click()

var is_active = false
var block = null

var trap = null

func change_color(color):
	$model.material_override = $model.material_override.duplicate()
	$model.material_override.albedo_color = color

func on_mouse_entered():
	is_active = true
	emit_signal("on_active", is_active)


func on_mouse_exited():
	is_active = false
	emit_signal("on_active", is_active)


func on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_pressed():
		emit_signal("on_click")

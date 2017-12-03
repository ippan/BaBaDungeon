extends Spatial

func _ready():
	var camera = get_viewport().get_camera()
	var position = camera.unproject_position(global_transform.origin)
	
	$base_position.set_global_position(position)

func set_size(size):
	$base_position/number.text_size = size
	
func set_number(number):
	$base_position/number.set_number(number)

func set_color(color):
	$base_position.modulate = color
extends Spatial

var offset = Vector2(0, 0)
var velocity = Vector2(0, -20.0)
var duration = 0.5

var elapsed = 0.0

func _ready():
	var camera = get_viewport().get_camera()
	var position = camera.unproject_position(global_transform.origin)
	
	$base_position.set_global_position(position + offset)

func _process(delta):
	elapsed += delta
	
	$base_position.modulate.a = 1.0 - elapsed / duration
	$base_position/number.rect_position += velocity * delta
	
	if elapsed > duration:
		queue_free()

func set_size(size):
	$base_position/number.text_size = size
	
func set_number(number):
	$base_position/number.set_number(number)

func set_color(color):
	$base_position.modulate = color
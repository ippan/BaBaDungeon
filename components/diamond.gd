extends Spatial

var elapsed = 0.0

var block

onready var sprite_node = $sprite

func set_block(location):
	block = location
	translation = Vector3(block.x, 0, block.y)

func _process(delta):
	elapsed += delta
	sprite_node.translation = Vector3(0, sin(elapsed * PI * 0.2) / 8.0 + 0.125 + 0.25, 0)
	
extends "trap.gd"

func animate(t):
	if t < 0.25:
		animation_node.visible = true
		animation_node.rotation_degrees = Vector3(0.0, (randi() % 4) * 90, 0.0)
	else:
		animation_node.visible = false

var effect_color = Color(1.0, 1.0, 0.5, 1.0)

func logic():
	var block = get_block()
	for ghost in ghost_query.get_ghosts(block.x, block.y):
		ghost.change_color(effect_color, 0.5)
		ghost.add_effect("paralysis", 10.0, effect_color, 0.0)
		ghost.on_hit(data.get_attack())
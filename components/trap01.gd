extends "trap.gd"

var active_position = Vector3(0, 0.25, 0)

func animate(t):
	if t < 0.5:
		animation_node.translation = active_position
	else:
		animation_node.translation = active_position.linear_interpolate(Vector3(0, 0, 0), (t - 0.5) * 2.0)

func logic():
	var block = get_block()
	for ghost in ghost_query.get_ghosts(block.x, block.y):
		ghost.change_color(Color(1.0, 0.5, 0.5, 1.0), 0.2)
		ghost.on_hit(data.get_attack())
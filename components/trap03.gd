extends "trap.gd"

var active_position = Vector3(0, 0.25, 0)

var next_elapsed = 0

var effect_color = Color(0.3, 1.0, 0.3, 1.0)

func animate(t):
	if elapsed < next_elapsed:
		return
	
	if not active:
		return

func logic():
	var block = get_block()
	for ghost in ghost_query.get_ghosts(block.x, block.y):
		if not ghost.effects.has("poison"):
			ghost.change_color(effect_color, 1.0 / ghost.speed)
		ghost.add_effect("poison", 10.0, effect_color, 0.0)
		

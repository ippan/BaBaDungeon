extends "trap.gd"

var active_position = Vector3(0, 0.25, 0)

var trigger_time = 0.0

func get_interval():
	return 0

func animate(t):
	if trigger_time == 0:
		return
	
	t = elapsed - trigger_time
	
	if t < 1.0:
		animation_node.scale = Vector3(1.0, 1.0 + (1.0 - t) * cos(t * 8.0 * PI), 1.0)
	else:
		animation_node.scale = Vector3(1.0, 1.0, 1.0)

func get_target(block):
	if block.neighbors.size() == 4:
		return block.neighbors[randi() % 4]
		
	var targets = [ { "x": -1, "y": 0 }, { "x": 1, "y": 0 }, { "x": 0, "y": -1 }, { "x": 0, "y": 1 } ]
	
	for target in targets:
		if not block.is_neighbor({ "x": block.x + target.x, "y": block.y + target.y }):
			return { "x": block.x + target.x, "y": block.y + target.y }
	

func logic():
	
	if trigger_time > 0.0:
		if elapsed - trigger_time > data.get_interval():
			trigger_time = 0.0
		else:
			return
	
	var block = get_block()
	var ghosts = ghost_query.get_ghosts(block.x, block.y)
	
	if ghosts.size() == 0:
		return
		
	trigger_time = elapsed
	var target = get_target(block)
	
	for ghost in ghosts:
		ghost.set_path([ { "x": ghost.translation.x, "y": ghost.translation.z }, target ])
		ghost.change_state("flying")
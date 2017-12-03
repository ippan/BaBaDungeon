extends "trap.gd"

var trigger_time = 0.0
var triggered = false

var target_block

func get_interval():
	return 0

var normal_position = Vector3(0, 0, 0)

func animate(t):
	if trigger_time > 0:
		
		t = elapsed - trigger_time
		
		if t < 0.5:
			var block = get_block()
			animation_node.translation = Vector3(lerp(normal_position.x, target_block.x - block.x, t * 2.0), 1.0 - pow(4.0 * (t - 0.25), 2), lerp(normal_position.z, target_block.y - block.y, t * 2.0))
			return
		elif t < 1.0:
			return
	
	animation_node.translation = normal_position

func on_hit():
	for ghost in ghost_query.get_ghosts(target_block.x, target_block.y):
		ghost.change_color(Color(1.0, 0.5, 0.5, 1.0), 0.2)
		ghost.on_hit(data.get_attack())

func check_target(block, delta_x, delta_y):
	return ghost_query.get_ghosts(block.x + delta_x, block.y + delta_y).size() > 0

func query_range(block, distance):
	for y in [ -1, 0, 1 ]:
		for x in [ -1, 0, 1 ]:
			if x == 0 and y == 0:
				continue
			
			if check_target(block, x * distance, y * distance):
				return { "x": block.x + x * distance, "y": block.y + y * distance }

func logic():
	
	if trigger_time > 0.0:
		if elapsed - trigger_time > data.get_interval():
			trigger_time = 0.0
		elif elapsed - trigger_time > 0.5 and not triggered:
			triggered = true
			on_hit()
			return
		else:
			return
	
	var block = get_block()
	
	target_block = null
	
	for distance in range(2):
		target_block = query_range(block, distance + 1)
		if target_block != null:
			triggered = false
			trigger_time = elapsed
			return
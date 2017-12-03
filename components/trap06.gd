extends "trap.gd"

var current_direction = null
var triggered = false
var current_position = null


func get_interval():
	if triggered:
		return 1
	return 0

func animate(t):
	if not triggered:
		return
	
	if current_position == null:
		return
	
	var block = get_block()
	var offset_x = current_position.x - block.x
	var offset_y = current_position.y - block.y
	
	if t > 0.3 and not current_position.is_neighbor({ "x": current_position.x + current_direction.x, "y": current_position.y + current_direction.y }):
		t = 0.3
	
	animation_node.translation = Vector3(lerp(0, current_direction.x, t) + offset_x, 0, lerp(0, current_direction.y, t) + offset_y)


func get_target(block):
	if block.neighbors.size() == 4:
		return block.neighbors[randi() % 4]
		
	var targets = [ { "x": -1, "y": 0 }, { "x": 1, "y": 0 }, { "x": 0, "y": -1 }, { "x": 0, "y": 1 } ]
	
	for target in targets:
		if not is_neighbor(block, target):
			return { "x": block.x + target.x, "y": block.y + target.y }

func try_move(block, direction):
	var neighbor = block.get

func destroy():
	get_parent().trap = null
	queue_free()

func do_damage():
	for ghost in ghost_query.get_ghosts(current_position.x, current_position.y):
		ghost.change_color(Color(1.0, 0.5, 0.5, 1.0), 0.2)
		ghost.on_hit(data.get_attack())
	
	current_position = current_position.get_neighbor({ "x": current_position.x + current_direction.x, "y": current_position.y + current_direction.y })
	
	if current_position == null:
		destroy()
		return
		
	for ghost in ghost_query.get_ghosts(current_position.x, current_position.y):
		ghost.change_color(Color(1.0, 0.5, 0.5, 1.0), 0.2)
		ghost.on_hit(data.get_attack())

func check_target(block, delta_x, delta_y):
	if not block.is_neighbor({ "x": block.x + delta_x, "y": block.y + delta_y }):
		return false
	return ghost_query.get_ghosts(block.x + delta_x, block.y + delta_y).size() > 0

func logic():
	if triggered:
		do_damage()
		return
	
	var directions = [ { "x": -1, "y": 0 }, { "x": 1, "y": 0 }, { "x": 0, "y": -1 }, { "x": 0, "y": 1 } ]
	
	var block = get_block()
	
	for direction in directions:
		if check_target(block, direction.x, direction.y):
			elapsed = 0
			current_direction = direction
			current_position = block
			triggered = true
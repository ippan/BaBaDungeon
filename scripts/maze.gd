class WallBreaker:
	var linked_blocks = []
	var unlinked_blocks = []
	var maze
	
	func break_walls(maze_to_break):
		maze = maze_to_break
		
		linked_blocks.resize(maze.blocks.size())
		unlinked_blocks.resize(maze.blocks.size())
		for i in range(maze.blocks.size()):
			unlinked_blocks[i] = maze.blocks[i]
		unlinked_blocks = shuffle(unlinked_blocks)
		
		set_linked(unlinked_blocks[0])
		unlinked_blocks.remove(0)
		
		while unlinked_blocks.size() > 0:
			break_wall()
	
	func get_neighbor_blocks(block):
		var neighbors = []
		if block.x > 0:
			neighbors.append(maze.blocks[block.y * maze.width + block.x - 1])
		if block.x < maze.width - 1:
			neighbors.append(maze.blocks[block.y * maze.width + block.x + 1])
		if block.y > 0:
			neighbors.append(maze.blocks[(block.y - 1) * maze.width + block.x])
		if block.y < maze.height - 1:
			neighbors.append(maze.blocks[(block.y + 1) * maze.width + block.x])
		
		return neighbors
	
	func break_wall():
		for i in range(unlinked_blocks.size()):
			var block = unlinked_blocks[i]
			var neighbors = shuffle(get_neighbor_blocks(block))
			
			for neighbor in neighbors:
				if linked_blocks[neighbor.y * maze.width + neighbor.x] == true:
					set_linked(block)
					link(block, neighbor)
					unlinked_blocks.remove(i)
					return
			
	func shuffle(list):
		var new_list = []
		for i in range(list.size()):
			var index = randi() % list.size()
			new_list.append(list[index])
			list.remove(index)
		return new_list
	
	func set_linked(block):
		linked_blocks[block.y * maze.width + block.x] = true
	
	func link(source, target):
		source.neighbors.append(target)
		target.neighbors.append(source)

class Block:
	func _init(position_x, position_y):
		x = position_x
		y = position_y
	
	var x
	var y
	var neighbors = []
	
	func equal(target):
		return x == target.x and y == target.y

	func is_neighbor(target):
		return get_neighbor(target) != null
		
	func get_neighbor(target):
		for neighbor in neighbors:
			if neighbor.equal(target):
				return neighbor
		return null

var blocks
var width
var height

func get_block(x, y):
	if x < 0 or x >= width or y < 0 or y >= height:
		return null
	
	return blocks[y * width + x]

func create(maze_width, maze_height):
	width = maze_width
	height = maze_height
	blocks = []
	blocks.resize(width * height)
	
	for y in range(height):
		for x in range(width):
			blocks[y * width + x] = Block.new(x, y)
	
	break_walls()

func break_walls():
	var wall_breaker = WallBreaker.new()
	wall_breaker.break_walls(self)

func dfs(block, target, path, depths):
	if depths[block.y * width + block.x] < path.size():
		return false
		
	depths[block.y * width + block.x] = path.size()
	path.push_back(block)
	
	if block.equal(target):
		return true
		
	for neighbor in block.neighbors:
		if dfs(neighbor, target, path, depths):
			return true
	
	path.pop_back()

func find_path(start_x, start_y, target_x, target_y):
	var depths = []
	depths.resize(width * height)
	for i in range(depths.size()):
		depths[i] = width * height + 1
	
	var path = []
	
	var block = get_block(start_x, start_y)
	var target = get_block(target_x, target_y)
	
	dfs(block, target, path, depths)
	
	return path
	
	
	
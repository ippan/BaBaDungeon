extends Spatial

const Maze = preload("res://scripts/maze.gd")
const Floor = preload("res://components/floor.tscn")
const Wall = preload("res://components/wall.tscn")
const Ghost = preload("res://components/ghost.tscn")
const Diamond = preload("res://components/diamond.tscn")

const Level = preload("res://scripts/level.gd")

var maze

var floors = []

var paths = {}

onready var scene_node = $scene
onready var floors_node = $scene/floors
onready var walls_node = $scene/walls
onready var ghosts_node = $scene/ghosts
onready var money_node = $hud/money_label

var elapsed = 0

var active_tool = null

var money = 600

var ghost_query

var level = 1
var level_data

class GhostQuery:
	var blocks = []
	var width
	var height
	
	func _init(size_x, size_y):
		width = size_x
		height = size_y
		blocks.resize(width * height)
		for i in range(width * height):
			blocks[i] = []
	
	func update(ghosts):
		for block in blocks:
			block.clear()
		
		for ghost in ghosts:
			var block = ghost.get_block()
			if block != null:
				blocks[block.y * width + block.x].append(ghost)
				
	func get_ghosts(x, y):
		if x < 0 or x >= width or y < 0 or y >= height:
			return []
		
		return blocks[y * width + x]

class State:
	var game
	var start = 0
	
	func get_elapsed():
		return game.elapsed - start
		
	func on_floor_selected(floor_instance):
		pass
	
	func on_trap_selected(trap_button):
		return false
	
	func on_enter():
		start = game.elapsed
	
	func on_update():
		pass

class ReadyState extends State:
	func on_enter():
		.on_enter()
		game.add_diamond()
	
	func on_update():
		return "wave"

class WaveState extends State:
	var wave = 0

	func on_enter():
		.on_enter()
		wave += 1
		game.get_node("hud/wave").show()
		game.get_node("hud/wave/number").set_number(wave)
		game.get_node("hud/wave_top").hide()
		game.get_node("hud/wave_top/number").set_number(wave)
		game.level_data.set_wave(wave)
		game.show_control(false)
	
	func on_update():
		if get_elapsed() < 3.0:
			return null
		
		game.get_node("hud/wave").hide()
		game.get_node("hud/wave_top").show()
		
		return "game_play"

class GamePlayState extends State:
	
	var wave_state
	var start_block
	
	func release_tool():
		if game.active_tool != null:
			game.active_tool.queue_free()
			game.active_tool = null
	
	func on_trap_selected(trap_button):
		release_tool()
		game.active_tool = trap_button.create(true)
		game.active_tool.visible = false
		game.active_tool.data = trap_button
		game.scene_node.add_child(game.active_tool)
		
		game.get_node("trap_detail").set_trap_detail(trap_button)
		game.get_node("trap_detail").show()
		
		return true
	
	func on_floor_selected(floor_instance):
		if not game.can_build(floor_instance):
			return
		
		game.money -= game.active_tool.data.price
		
		var trap = game.active_tool.data.create(false)
		trap.ghost_query = game.ghost_query
		trap.active = true
		floor_instance.add_child(trap)
		floor_instance.trap = trap
		game.active_tool.visible = false
		
		game.get_node("trap_detail").set_trap_detail(game.active_tool.data)
	
	func on_enter():
		.on_enter()
		game.show_control(true)
		start_block = game.maze.get_block(game.maze.width - 1, 0)
	
	func on_ghost_dead(ghost):
		game.money += ghost.price
		if ghost.diamond:
			game.add_diamond()
	
	func on_ghost_arrived(ghost):
		game.change_state("game_over")
	
	func on_ghost_lost(ghost):
		var position = ghost.path[1]
		var block = game.maze.get_block(position.x, position.y)
		if block == null:
			ghost.change_state("dying")
			return
			
		ghost.set_path(find_ghost_path(block))
	
	func find_ghost_path(start_block):
		var target = get_random_diamon_position()
		return game.maze.find_path(start_block.x, start_block.y, target.x, target.y)
	
	func on_update():
		
		if game.level_data.is_wave_end():
			if game.ghosts_node.get_child_count() == 0:
				if game.level_data.is_last_wave():
					return "win"
				return "wave"
			return
		
		var ghost = game.level_data.update(get_elapsed())
		
		if ghost == null:
			return
		
		ghost.event_handler = self
		
		game.ghosts_node.add_child(ghost)
		ghost.set_path(find_ghost_path(start_block))
		
	func get_random_diamon_position():
		var index = randi() % game.diamonds.size()
		return game.diamonds[index].block

class GameOverState extends State:
	func on_enter():
		.on_enter()
		get_hud_node().show()
		game.show_control(false)
	
	func get_hud_node():
		return game.get_node("hud/game_over")
	
	func on_update():
		if get_elapsed() < 5.0:
			return
			
		game.get_tree().change_scene("res://title.tscn")
		
class WinState extends GameOverState:
	func get_hud_node():
		return game.get_node("hud/win")

var states = {}
var current_state = "ready"

func create_states():
	states["ready"] = ReadyState.new()
	states["wave"] = WaveState.new()
	states["game_play"] = GamePlayState.new()
	states["game_play"].wave_state = states["wave"]
	states["game_over"] = GameOverState.new()
	states["win"] = WinState.new()
	
	for name in states:
		states[name].game = self
	
	states[current_state].on_enter()

func _ready():
	randomize()
	maze = Maze.new()
	maze.create(10, 10)
	
	ghost_query = GhostQuery.new(maze.width, maze.height)
	
	var offset_x = -maze.width / 2 - 1
	var offset_y = -maze.height / 2
	
	scene_node.translation = Vector3(offset_x, 0, offset_y)
	
	generate()
	
	create_states()
	
	level_data = Level.new(level)

func change_state(state_name):
	if state_name == null:
		return
	
	if state_name == current_state:
		return
		
	current_state = state_name
	states[current_state].on_enter()

func show_control(value):
	if value:
		$trap_buttons.show()
		if active_tool != null:
			$trap_detail.show()
	else:
		$trap_buttons.hide()
		$trap_detail.hide()

func _physics_process(delta):
	elapsed += delta
	change_state(states[current_state].on_update())
		
	ghost_query.update(ghosts_node.get_children())
	money_node.set_number(money)

var active_color = Color(0.0, 1.0, 0.0)
var normal_color = Color(1.0, 1.0, 1.0)
var error_color = Color(1.0, 0.0, 0.0)

func can_build(floor_instance):
	if active_tool == null:
		return false
	
	if money < active_tool.data.price:
		return false
	
	return floor_instance.trap == null

func on_block_active(value, floor_instance):
	var block = floor_instance.block
	if active_tool != null:
		active_tool.visible = value
		active_tool.translation = Vector3(block.x, 0.05, block.y)
		
		if can_build(floor_instance):
			active_tool.change_color(active_color)
		else:
			active_tool.change_color(error_color)
			
func on_block_click(floor_instance):
	if floor_instance.trap == null:
		states[current_state].on_floor_selected(floor_instance)

func create_floor(x, y):

	var model = Floor.instance()
	floors_node.add_child(model)
	model.translation = Vector3(x, 0, y)
	
	model.connect("on_active", self, "on_block_active", [ model ])
	model.connect("on_click", self, "on_block_click", [ model ])
	
	return model
	
func create_wall(x1, y1, x2, y2):
	var offset_x = (x2 - x1) / 2.0
	var offset_y = (y2 - y1) / 2.0
	
	var model = Wall.instance()
	walls_node.add_child(model)
	if x1 != x2:
		model.rotate_y(PI / 2.0)
	model.translation = Vector3(x1 + offset_x, 0, y1 + offset_y)


func generate():
	floors.resize(maze.width * maze.height)
	var walls = {}
	
	for y in range(maze.height + 1):
		for x in range(maze.width + 1):
			if y < maze.height:
				walls["%s_%s_%s_%s" % [ x - 1, y, x, y ]] = true
			if x < maze.width:
				walls["%s_%s_%s_%s" % [ x, y - 1, x, y ]] = true
	
	for y in range(maze.height):
		for x in range(maze.width):
			var floor_instance = create_floor(x, y)
			floors[y * maze.width + x] = floor_instance
			var block = maze.get_block(x, y)
			floor_instance.block = block
			
			for neighbor in block.neighbors:
				if neighbor.x < x or neighbor.y < y:
					walls["%s_%s_%s_%s" % [ neighbor.x, neighbor.y, x, y ]] = false
			
	for key in walls:
		if not walls[key]:
			continue
		
		var data = key.split("_")
		create_wall(int(data[0]), int(data[1]), int(data[2]), int(data[3]))
	
func on_trap_button_click(trap_button):
	if not states[current_state].on_trap_selected(trap_button):
		trap_button.pressed = false

const diamond_positions = [ { "x": 0, "y": 1024 }, { "x": 0, "y": 0 }, { "x": 1024, "y": 1024 } ]

var diamonds = []
const MAX_DIAMOND = 3

func transform_position(position):
	var transformed_position = {}
	
	if position.x == 1024:
		transformed_position.x = maze.width - 1
	else:
		transformed_position.x = position.x
		
	if position.y == 1024:
		transformed_position.y = maze.height - 1
	else:
		transformed_position.y = position.y
		
	return transformed_position

func add_diamond():
	if diamonds.size() >= MAX_DIAMOND:
		return
		
	var position = transform_position(diamond_positions[diamonds.size()])
	
	var diamond = Diamond.instance()
	scene_node.add_child(diamond)
	diamond.set_block(maze.get_block(position.x, position.y))
	
	diamonds.append(diamond)
	
	return diamond

func on_upgrade():
	var trap_button = active_tool.data
	
	if money < trap_button.get_upgrade_price():
		return
	
	money -= trap_button.get_upgrade_price()
	trap_button.level += 1
	
	$trap_detail.set_trap_detail(trap_button)
	

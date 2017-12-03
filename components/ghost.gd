extends Spatial

const FloatingLabel = preload("res://components/floating_label.tscn")

export var speed = 1.0
export var hp = 5
export var price = 5
export var diamond = false
export var resistant = false

var path = null

var index = 0

var event_handler

onready var sprite_node = $sprite

var color_count_down = 0.0

var normal_color = Color(1.0, 1.0, 1.0)

class Effect:
	var name
	var count_down
	var color
	var damage
	
	func _init(effect_name, duration, effect_color, effect_damage):
		name = effect_name
		count_down = duration
		color = effect_color
		damage = effect_damage

var effects = {}

class State:
	var ghost
	var elapsed = 0.0
	var animation_elapsed = 0.0
	
	func on_enter():
		elapsed = 0.0
		animation_elapsed = 0.0
	
	func on_update(delta):
		elapsed += delta
		
	func on_animation_update(delta):
		animation_elapsed += delta
	
	func on_hit(damage):
		pass
	
	func get_block():
		return null
		
	func on_effect_changed(name, added):
		pass
		
	func on_effect(effect):
		pass

class NormalState extends State:
	var index = 0
	
	func on_enter():
		.on_enter()
		index = 0
	
	func on_update(delta):
		.on_update(delta)
		
		if elapsed * ghost.speed > 1.0:
			elapsed -= 1.0 / ghost.speed
		
			if index < ghost.path.size() - 1:
				index += 1
	
		if index >= ghost.path.size() - 1:
			ghost.event_handler.on_ghost_arrived(ghost)
			return
	
		var block = ghost.path[index]
		var target = ghost.path[index + 1]
		var t = elapsed * ghost.speed
		
		ghost.translation = Vector3(lerp(block.x, target.x, t), 0, lerp(block.y, target.y, t))
		
		return null
	
	func on_animation_update(delta):
		.on_animation_update(delta)
		ghost.sprite_node.translation = Vector3(0, sin(animation_elapsed * ghost.speed * PI * 3.0) / 8.0 + 0.5, 0)
		
	func get_block():
		if ghost.path == null:
			return null
	
		if elapsed * ghost.speed > 0.5 and index < ghost.path.size() - 1:
			return ghost.path[index + 1]
			
		return ghost.path[index]

	func on_effect(effect):
		if effect.damage > 0:
			var damage = effect.damage
			
			if ghost.resistant:
				damage = damage / 2
			
			if damage == 0:
				damage = 1
			
			return on_hit(damage)

	func create_floating_label():
		var label = FloatingLabel.instance()
		label.offset = Vector2(20, -30)
		ghost.add_child(label)
		label.set_color(Color(1.0, 0.5, 0.5))
		label.set_size(18)
		return label

	func on_hit(damage):
		ghost.hp -= damage
		var label = create_floating_label()
		label.set_number(-damage)
		
		if ghost.hp < 0:
			return "dying"

	func on_effect_changed(name, added):
		if name != "paralysis":
			return
			
		if added:
			ghost.speed *= 0.5
			animation_elapsed *= 2.0
			elapsed *= 2.0
		else:
			ghost.speed *= 2.0
			animation_elapsed *= 0.5
			elapsed *= 0.5

class FlyingState extends State:
	
	func on_update(delta):
		.on_update(delta)
		
		var start = ghost.path[0]
		var target = ghost.path[1]
		
		ghost.translation = Vector3(lerp(start.x, target.x, elapsed), 1.0 - pow(2.0 * (elapsed - 0.5), 2), lerp(start.y, target.y, elapsed))
		
		if elapsed > 1.0:
			return "lost"

class LostState extends State:
	func on_enter():
		.on_enter()
		ghost.event_handler.on_ghost_lost(ghost)
		
	func on_update(delta):
		.on_update(delta)
		return "normal"

class DyingState extends State:
	func on_enter():
		.on_enter()
	
	func on_update(delta):
		.on_update(delta)
		
		ghost.get_node("sprite").translation.y += delta
		ghost.get_node("sprite").material_override.albedo_color.a = 1.0 - elapsed
		
		if elapsed > 1.0:
			ghost.event_handler.on_ghost_dead(ghost)
			ghost.queue_free()

var states = {}
var current_state = "normal"

func _ready():
	states["normal"] = NormalState.new()
	states["flying"] = FlyingState.new()
	states["lost"] = LostState.new()
	states["dying"] = DyingState.new()
	
	for name in states:
		states[name].ghost = self
	
	states[current_state].on_enter()
	
	$sprite.material_override = $sprite.material_override.duplicate()

func get_block():
	return states[current_state].get_block()

func set_path(new_path):
	path = new_path
	translation = Vector3(path[0].x, 0, path[0].y)

func change_color(color, duration = -1.0):
	if color_count_down > 0.0:
		return
	
	$sprite.material_override.albedo_color = color
	color_count_down = duration

func add_effect(name, duration, color, damage):
	var is_new = not effects.has(name)
	effects[name] = Effect.new(name, duration, color, damage)
	if is_new:
		states[current_state].on_effect_changed(name, true)

func change_state(state_name):
	if state_name == null:
		return
	current_state = state_name
	states[current_state].on_enter()
	
func on_hit(damage):
	change_state(states[current_state].on_hit(damage))

var effect_timer = 0.0
var effect_flag = 0

const effect_names = [ "poison", "paralysis" ]

func update_effect(delta):
	var new_effects = {}
	for name in effects:
		effects[name].count_down -= delta
		if effects[name].count_down > 0.0:
			new_effects[name] = effects[name]
		else:
			states[current_state].on_effect_changed(name, false)
			
	effects = new_effects
	
	effect_timer += delta
	
	if effect_timer < 0.5:
		return
		
	effect_timer -= 0.5
	effect_flag = (effect_flag + 1) % 2
	
	var effect_name = effect_names[effect_flag]
	
	if effects.has(effect_name):
		change_color(effects[effect_name].color, 0.2)
		change_state(states[current_state].on_effect(effects[effect_name]))

func _physics_process(delta):
	if color_count_down >= 0.0:
		color_count_down -= delta
		
		if color_count_down < 0.0:
			change_color(normal_color)
	
	change_state(states[current_state].on_update(delta))
	
	update_effect(delta)

func _process(delta):
	states[current_state].on_animation_update(delta)
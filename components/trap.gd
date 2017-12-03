extends Spatial

var elapsed = 0

var active = false

onready var animation_node = $animation

var data
var ghost_query

func get_block():
	return get_parent().block

func change_color(color):
	$model.material_override = $model.material_override.duplicate()
	$model.material_override.albedo_color = color
	for child in $animation.get_children():
		child.material_override = child.material_override.duplicate()
		child.material_override.albedo_color = color

func get_interval():
	if data == null:
		return 1.0
	return data.get_interval()

func _physics_process(delta):
	elapsed += delta

	var interval = get_interval()

	if elapsed > interval:
		elapsed -= interval
		
		if active:
			logic()

	var t = 0
	if interval > 0:
		t = elapsed / interval

	animate(t)

func animate(t):
	pass

func logic():
	pass
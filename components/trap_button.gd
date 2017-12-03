extends TextureButton

export(Texture) var trap_image
export(PackedScene) var trap_scene
export(int) var price = 100
export var upgrade_attack = true
export var attack = 1
export var upgrade_interval = true
export var interval = 1.0
export var can_upgrade = true

var level = 1
var have_built = false

signal on_click(trap_button)

func _ready():
	$image.texture = trap_image

func check_can_upgrade():
	if not can_upgrade:
		return false
	
	if level == 5:
		return false
		
	return have_built

func get_interval():
	if upgrade_interval:
		return interval * (1.0 - (level - 1) / 8.0)
	return interval

func get_attack():
	if upgrade_attack:
		return attack * level
	return attack
	
func get_upgrade_price():
	return price * pow(2, level)

func on_button_pressed():
	for child in get_parent().get_children():
		child.disabled = false
		child.pressed = false
	
	disabled = true
	pressed = true
	
	emit_signal("on_click", self)

func create(is_tool = false):
	if not is_tool:
		have_built = true

	var new_instance = trap_scene.instance()
	new_instance.data = self
	return new_instance
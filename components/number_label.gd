extends Control

export(float) var text_size = 30

var numbers = {}

var images = []

var control_size = 0

var last_number = null

func _ready():
	for i in range(10):
		numbers[str(i)] = load("res://images/%s.png" % i)
	
	numbers["."] = load("res://images/dot.png")
	numbers["-"] = load("res://images/minus.png")

func set_number(number):
	if last_number != null and last_number == number:
		return
		
	last_number = number
	
	var text = str(number)
	
	if text.length() > images.size():
		for i in range(text.length() - images.size()):
			var image = TextureRect.new()
			image.expand = true
			image.rect_size = Vector2(text_size, text_size)
			add_child(image)
			images.push_back(image)
	
	if images.size() > text.length():
		for i in range(images.size() - text.length()):
			var image = images.pop_back()
			image.queue_free()

	control_size = 0
	
	for i in range(text.length()):
		var image = images[i]
		var character = text[i]
		
		if character == ".":
			control_size -= text_size / 4.0
		
		image.rect_position = Vector2(control_size, 0)
		image.texture = numbers[character]
		
		if character == ".":
			control_size += text_size / 2.0
		else:
			control_size += text_size
var level = 1
var wave = 1
var index = 0

var waves = []

var ghosts = {}

func _init(game_level):
	level = game_level
	generate_waves()
	
	ghosts["1"] = load("res://components/ghost.tscn")

func set_wave(new_wave):
	wave = new_wave
	index = 0
	
func is_wave_end():
	return index > waves[wave].length() - 1

func update(elapsed):
	if is_wave_end():
		return null
	
	if elapsed / 3.0 > index:
		var key = waves[wave][index]
		var ghost = ghosts[key].instance()
		index += 1
		return ghost
		
	return null
	

func generate_waves():
	# wave 01
	waves.append("1111111111")
	# wave 02
	waves.append("1111111111")
	# wave 03
	waves.append("1111111111")
	# wave 04
	waves.append("1111111111")
	# wave 05
	waves.append("1111111111d")
	# wave 06
	waves.append("1111111111")
	# wave 07
	waves.append("1111111111")
	# wave 08
	waves.append("1111111111")
	# wave 09
	waves.append("1111111111")
	# wave 10
	waves.append("1111111111d")
	# wave 11
	waves.append("1111111111")
	# wave 12
	waves.append("1111111111")
	# wave 13
	waves.append("1111111111")
	# wave 14
	waves.append("1111111111")
	# wave 15
	waves.append("1111111111")
	# wave 16
	waves.append("1111111111")
	# wave 17
	waves.append("1111111111")
	# wave 18
	waves.append("1111111111")
	# wave 19
	waves.append("1111111111")
	# wave 20
	waves.append("1111111111")
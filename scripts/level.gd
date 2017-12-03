var level = 1
var wave = 1
var index = 0

var waves = []

var ghosts = {}

func _init(game_level):
	level = game_level
	generate_waves()
	
	for i in range(6):
		ghosts[str(i + 1)] = load("res://ghosts/ghost0%d.tscn" % (i + 1))

func set_wave(new_wave):
	wave = new_wave
	index = 0
	
func is_wave_end():
	return index > waves[wave - 1].length() - 1

func update(elapsed):
	if is_wave_end():
		return null
	
	var wave_interval = 6 - wave
	if wave_interval < 1.5:
		wave_interval = 1.5
	
	if elapsed / wave_interval > index:
		var key = waves[wave - 1][index]
		index += 1
		
		if key == "0":
			return null
		
		var ghost = ghosts[key].instance()
		return ghost
		
	return null

func is_last_wave():
	return wave == waves.size()

func generate_waves():
	# wave 01
	waves.append("1111101111201112211226")
	# wave 02
	waves.append("1122202222302223322336")
	# wave 03
	waves.append("2223303131301231231234")
	# wave 04
	waves.append("222220333330444440123412340504030201")
	# wave 05
	waves.append("5105205305402222203333304444401234123405040302010666")
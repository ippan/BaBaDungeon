extends TextureRect

func set_trap_detail(trap_button):
	$trap_image.texture = trap_button.trap_image
	$price_label.set_number(trap_button.price)
	$attack_label.set_number(trap_button.get_attack())
	$interval_label.set_number(trap_button.get_interval())
	
	var upgrade_price = trap_button.get_upgrade_price()
	
	if upgrade_price == null or not trap_button.check_can_upgrade():
		$upgrade.hide()
	else:
		$upgrade.show()
		$upgrade/upgrade_price.set_number(trap_button.get_upgrade_price())
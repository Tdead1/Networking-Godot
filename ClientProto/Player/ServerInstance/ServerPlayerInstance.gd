extends KinematicBody

func _ready():
	set_network_master(1);
	pass

sync func set_transform(tf):
	
	if(get_network_master() == 1):
		transform = tf;
	pass;
	
extends Spatial

func init():
	set_network_master(1);
	pass
	
sync func set_rotation(rt):
	if(get_network_master() == 1):
		rotation = rt;
	pass;

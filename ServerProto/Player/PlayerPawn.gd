extends Spatial

func _setup_owner(id):
	set_name("Player#" + str(id));
	set_network_master(id);
	pass;

puppet func set_transform(clienttransform):
	transform = clienttransform;
	pass;


puppet func _process(delta):
	
	pass;
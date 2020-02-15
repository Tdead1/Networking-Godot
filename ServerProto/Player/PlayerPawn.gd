extends Spatial

var health = 100.0;
var id = "";

func SetupOwner(owning_id):
	set_name("Player#" + str(owning_id));
	find_node("PlayerCamera").set_network_master(owning_id);
	set_network_master(owning_id);
	id = owning_id;
	pass;

func set_transform(clienttransform):
	transform = clienttransform;
	pass;

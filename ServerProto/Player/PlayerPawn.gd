extends Spatial

var id = "";
func _setup_owner(owning_id):
	set_name("Player#" + str(owning_id));
	set_network_master(owning_id);
	id = owning_id;
	pass;

slave func set_transform(clienttransform):
	transform = clienttransform;
	pass;
	

extends Spatial

var id = "";
func _setup_owner(owning_id):
	set_name("Player#" + str(owning_id));
	set_network_master(owning_id);
	id = owning_id;
	pass;

puppet func set_transform(clienttransform):
	transform = clienttransform;
	pass;

puppet func remove_player(id):
	pass;
	
puppet func create_player(id):
	pass;

puppet func create_players(ids):
	pass;

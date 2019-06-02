extends Spatial

var health = 100.0;
var id = "";

func _setup_owner(owning_id):
	set_name("Player#" + str(owning_id));
	find_node("PlayerCamera").set_network_master(owning_id);
	set_network_master(owning_id);
	id = owning_id;
	pass;

# A puppet function because the server doesn't own the player object.
puppet func set_transform(clienttransform):
	transform = clienttransform;
	pass;

puppet func remove_player(id):
	pass;
	
puppet func create_player(id):
	pass;

puppet func create_players(ids):
	pass;

	
func GetDamage(ID, damage):
	health -= damage;
	rpc("SetHealth", health);
	pass;
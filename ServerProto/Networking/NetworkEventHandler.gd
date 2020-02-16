extends Node

var players = [];
var ids = [];

var playertemplate = preload("res://Player/PlayerPawn.tscn");

func _ready():
	set_network_master(1);

func ConnectPeer(id):	
	for i in range (ids.size()):
		rpc_id(ids[i], "CreatePlayer", id);
		
	CreatePlayer(id);
	
	rpc_id(id, "CreatePlayers", ids);
	return;

func DisconnectPeer(id):
	rpc("RemovePlayer", id);
	return;

func _physics_process(_delta):
	for i in range (ids.size()):
		for j in range (ids.size()):
			rpc_id(ids[i], "UpdateRemotePlayer", ids[j], players[j].transform, players[j].camera.transform);
	return;

master func CreatePlayer(id):
	get_parent().debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size());
	get_parent().debuglog += "   -> User connected.      ID: " + str(id) + "\n";
	var newplayer = playertemplate.instance();
	newplayer.set_name("Player#" + str(id));
	newplayer.set_network_master(id);
	get_parent().add_child(newplayer);
	players.append(newplayer);
	ids.append(id);
	return;

master func UpdateRemotePlayer(id, playertransform, cameratransform):
	return;

master func RemovePlayer(id):
	var oldplayer = get_node("/root/Root/Player#" + str(id));
	oldplayer.queue_free();
		
	get_parent().debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size()) ;
	get_parent().debuglog += "   -> User disconnected. ID: " + str(id) + "\n";
	players.erase(oldplayer);
	ids.erase(id);
	return;


#func GetDamage(ID, damage):
#	ID;
#	damage;
	#health -= damage;
	#rpc("SetHealth", health);
#	return;

extends Node

var myPlayers = [];
var ids = [];
var myEnemies = [];

var myPlayertemplate = preload("res://Player/PlayerPawn.tscn");
var mySphereEnemyTemplate = preload("res://Enemies/EnemySphere.tscn");

func _ready():
	CreateSphereEnemy(0);
	CreateSphereEnemy(1);	
	set_network_master(1);
	return;

func ConnectPeer(id):	
	for i in range (ids.size()):
		rpc_id(ids[i], "CreatePlayer", id);
		
	CreatePlayer(id);
	rpc_id(id, "CreatePlayers", ids);
	return;

func DisconnectPeer(id):
	for i in range (ids.size()):
		rpc_id(ids[i], "RemovePlayer", id);
	
	RemovePlayer(id);
	return;

func _physics_process(_delta):
	for i in range (ids.size()):
		for j in range (ids.size()):
			rpc_unreliable_id(ids[i], "UpdateRemotePlayer", ids[j], myPlayers[j].transform, myPlayers[j].myCameraTransform);
		for j in range (myEnemies.size()):
			rpc_unreliable_id(ids[i], "UpdateSphereEnemy", myEnemies[j].id, myEnemies[j].transform);
		
	return;

master func CreatePlayer(id):
	get_parent().debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size());
	get_parent().debuglog += "   -> User connected.      ID: " + str(id) + "\n";
	var newPlayer = myPlayertemplate.instance();
	newPlayer.set_name("Player#" + str(id));
	newPlayer.set_network_master(id);
	get_parent().add_child(newPlayer);
	myPlayers.append(newPlayer);
	ids.append(id);
	for i in range (myEnemies.size()):
		rpc_unreliable_id(id, "CreateSphereEnemy", myEnemies[i].id);
	return;

master func RemovePlayer(id):
	var oldPlayer = get_node("/root/Root/Player#" + str(id));
	
	get_parent().debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size()) ;
	get_parent().debuglog += "   -> User disconnected. ID: " + str(id) + "\n";
	myPlayers.erase(oldPlayer);
	ids.erase(id);
	
	oldPlayer.queue_free();
	return;

master func CreateSphereEnemy(id):
	var newEnemy = mySphereEnemyTemplate.instance();
	get_parent().call_deferred("add_child", newEnemy);
	newEnemy.id = id;
	newEnemy.set_name("SphereEnemy" + str(id));
	myEnemies.append(newEnemy);
	return;

#func GetDamage(ID, damage):
#	ID;
#	damage;
	#health -= damage;
	#rpc("SetHealth", health);
#	return;

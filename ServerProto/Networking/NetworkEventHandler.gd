extends Node

var myPlayers = {};
var myEnemies = {};

var myPlayertemplate = preload("res://Player/PlayerPawn.tscn");
var mySphereEnemyTemplate = preload("res://Enemies/EnemySphere.tscn");

func _ready():
	CreateSphereEnemy(0);
	CreateSphereEnemy(1);	
	set_network_master(1);
	return;

func ConnectPeer(id):	
	for existingID in myPlayers:
		rpc_id(existingID, "CreatePlayer", id);
		
	rpc_id(id, "CreatePlayers", myPlayers.keys());
	CreatePlayer(id);
	return;

func DisconnectPeer(id):
	for existingID in myPlayers:
		if (existingID == id):
			continue;
		rpc_id(existingID, "RemovePlayer", id);
	
	RemovePlayer(id);
	return;

func _physics_process(_delta):
	for contactPlayerID in myPlayers:
		for dataPlayerID in myPlayers:
			rpc_unreliable_id(contactPlayerID, "UpdateRemotePlayer", dataPlayerID, myPlayers[dataPlayerID].transform, myPlayers[dataPlayerID].myCameraTransform);
		for enemyID in myEnemies:
			rpc_unreliable_id(contactPlayerID, "UpdateSphereEnemy", enemyID, myEnemies[enemyID].transform);
	return;

master func CreatePlayer(id):
	get_parent().myDebugLog += "Users now online: " + str(get_tree().get_network_connected_peers().size());
	get_parent().myDebugLog += "   -> User connected.      ID: " + str(id) + "\n";
	var newPlayer = myPlayertemplate.instance();
	newPlayer.set_name("Player#" + str(id));
	newPlayer.set_network_master(id);
	get_parent().add_child(newPlayer);
	myPlayers[id] = newPlayer;
	for enemyID in myEnemies:
		rpc_unreliable_id(id, "CreateSphereEnemy", enemyID);
	return;

master func RemovePlayer(id):
	var oldPlayer = get_node("/root/Root/Player#" + str(id));
	get_parent().myDebugLog += "Users now online: " + str(get_tree().get_network_connected_peers().size()) ;
	get_parent().myDebugLog += "   -> User disconnected. ID: " + str(id) + "\n";
	myPlayers.erase(id);
	oldPlayer.queue_free();
	return;

master func CreateSphereEnemy(id):
	var newEnemy = mySphereEnemyTemplate.instance();
	get_parent().call_deferred("add_child", newEnemy);
	newEnemy.set_name("SphereEnemy" + str(id));
	myEnemies[id] = newEnemy;
	return;


func CreateObjective(id):
	var player = myPlayers[id];
	
	var newQuest = Quest.new();
	newQuest.myState = Quest.ObjectiveState.Active;
	newQuest.myName = String(randi() % 20);
	newQuest.myLocation = Vector2(rand_range(-10.0, 10.0), rand_range(-100.0, 100.0));
	player.myObjective = newQuest;
	get_parent().myDebugLog += "Creating new objective for " + myPlayers[id].name + "\n";	
	rpc_id(id, "ReceiveObjective", newQuest.myState, newQuest.myName, newQuest.myLocation);
	return;

func GiveObjectiveReward(id):
	var player = myPlayers[id];
	get_parent().myDebugLog += "Player completed objective and has been sent a reward. \n";
	player.myObjective = Quest.new();
	rpc_id(id, "ReceiveObjectiveRewards");
	return;

# Received requests from Clients
remote func RequestObjective(id):
	var player = myPlayers.get(id);
	if (player == null):
		return;
		 
	get_parent().myDebugLog += "Received objective request from " + myPlayers[id].name + "\n";
	if (player.myObjective.myState != Quest.ObjectiveState.Empty):
		return;
	
	CreateObjective(id);
	return;

remote func SubmitObjectiveCompletion(id):
	var player = myPlayers.get(id);
	if (player == null):
		return;
	
	get_parent().myDebugLog += "Received objective complete from " + myPlayers[id].name + "\n";
	if (player.myObjective.myState != Quest.ObjectiveState.Active):
		return;
	
	var distance = (player.myObjective.myLocation - Vector2(player.transform.origin.x, player.transform.origin.z)).length();
	var shouldSubmitObjective = distance < 5.0 && player.myObjective.myState == Quest.ObjectiveState.Active;
	if (shouldSubmitObjective):
		GiveObjectiveReward(id);
	
	return;

#func GetDamage(ID, damage):
#	ID;
#	damage;
	#myHealth -= damage;
	#rpc("SetHealth", health);
#	return;

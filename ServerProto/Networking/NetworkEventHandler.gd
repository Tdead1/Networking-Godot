extends Node

var myPlayers = {};
var myEnemies = {};

var myPlayertemplate = preload("res://Player/PlayerPawn.tscn");
var mySphereEnemyTemplate = preload("res://Enemies/EnemySphere.tscn");

onready var myServer = get_parent();  

func _ready():
	#CreateSphereEnemy();
	#CreateSphereEnemy();	
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
	myServer.myDebugLog += "Users now online: " + str(get_tree().get_network_connected_peers().size());
	myServer.myDebugLog += "   -> User connected.      ID: " + str(id) + "\n";
	var newPlayer = myPlayertemplate.instance();
	newPlayer.set_name("Player#" + str(id));
	newPlayer.set_network_master(id);
	myServer.add_child(newPlayer);
	myPlayers[id] = newPlayer;
	newPlayer.id = id;
	for enemyID in myEnemies:
		rpc_unreliable_id(id, "CreateSphereEnemy", enemyID);
	return;

master func RemovePlayer(id):
	var oldPlayer = get_node("/root/Root/Player#" + str(id));
	myServer.myDebugLog += "Users now online: " + str(get_tree().get_network_connected_peers().size()) ;
	myServer.myDebugLog += "   -> User disconnected. ID: " + str(id) + "\n";
	myPlayers.erase(id);
	oldPlayer.queue_free();
	return;

master func CreateSphereEnemy(position = Vector3(0,0,0)):
	var newEnemy = mySphereEnemyTemplate.instance();
	var id = newEnemy.get_instance_id();
	myServer.call_deferred("add_child", newEnemy);
	newEnemy.set_name("SphereEnemy" + str(id));
	myEnemies[id] = newEnemy;
	myEnemies[id].transform.origin = position;
	myEnemies[id].mySpawnLocation.x = position.x;
	myEnemies[id].mySpawnLocation.y = position.z;
	
	for playerID in myPlayers:
		rpc_unreliable_id(playerID, "CreateSphereEnemy", id);
	return id;

master func KillSphereEnemy(id):
	for playerID in myPlayers:
		rpc_unreliable_id(playerID, "KillSphereEnemy", id);
	myServer.myQuestManager.OnEnemyKilled(id);
	myServer.remove_child(myEnemies[id]);
	myEnemies[id].queue_free();
	myEnemies.erase(id);
	print("Server Enemy destroyed, sending to clients.");
	return;

func CreateObjective(id):
	var player = myPlayers[id];
	var newQuest = Quest.new();
	newQuest.Randomize();
	match newQuest.myType:
		Quest.Type.GoTo:
			pass;
		Quest.Type.Kill:
			myServer.myQuestManager.CreateKillQuest(newQuest);
	player.myObjective = newQuest;
	myServer.myDebugLog += "Creating new objective for " + myPlayers[id].name + "\n";	
	rpc_id(id, "ReceiveObjective", newQuest.myState, newQuest.myType, newQuest.myName, newQuest.myLocation);
	return;

func GiveObjectiveReward(id):
	var player = myServer.myNetworkEventHandler.myPlayers.get(id);
	myServer.myDebugLog += "Player completed objective and has been sent a reward. \n";
	player.myObjective = Quest.new();
	rpc_id(id, "ReceiveObjectiveRewards");
	return;

# Received requests from Clients
remote func RequestObjective(id):
	var player = myPlayers.get(id);
	if (player == null):
		return;
		 
	myServer.myDebugLog += "Received objective request from " + myPlayers[id].name + "\n";
	if (player.myObjective.myState != Quest.ObjectiveState.Empty):
		return;
	
	CreateObjective(id);
	return;

remote func SubmitObjectiveCompletion(id):
	var player = myPlayers.get(id);
	if (player == null):
		return;
	
	myServer.myQuestManager.VerifyCompletion(player);
	return;

#func GetDamage(ID, damage):
#	ID;
#	damage;
	#myHealth -= damage;
	#rpc("SetHealth", health);
#	return;

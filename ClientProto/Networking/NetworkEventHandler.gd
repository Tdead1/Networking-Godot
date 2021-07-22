extends Node

# Replication variables:
var myServerAdress = "127.0.0.1";
onready var myNetwork = NetworkedMultiplayerENet.new();

var myRemotePlayerScene = preload("res://Player/Remote/RemotePlayerInstance.tscn");
var mySphereEnemyTemplate = preload("res://Prefabs/Enemies/EnemySphere.tscn");
var myRemotePlayers = [];
var myEnemies = [];
var myIsConnected = false;
var myLocalPlayer;
var myID = 0;

func _ready():
	set_network_master(1);
	myLocalPlayer = get_parent().get_node("PlayerPawn");
	
	print("Creating client. \n");
	
	myNetwork.create_client(myServerAdress, 4242);
	myNetwork.connect("connection_failed", self, "_on_connection_failed");
	myNetwork.connect("connection_succeeded", self, "_on_connection_success");
	get_tree().set_network_peer(myNetwork);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	
	myLocalPlayer.name = "Player#" + str(get_tree().multiplayer.get_network_unique_id());
	return;

func _on_connection_failed():
	print("Connection failed (server down?) \n");
	myIsConnected = false;
	return;

func _on_connection_success():
	print("Connected to server.\n");
	print(str(get_tree().get_network_connected_peers().size()));
	myID = get_tree().multiplayer.get_network_unique_id();
	myIsConnected = true;
	return;

puppet func CreatePlayer(id):
	print("Create player was called from the server! \n \n"); 
	if(id != get_tree().get_network_unique_id()):
		var remoteInstance = myRemotePlayerScene.instance();
		get_parent().add_child(remoteInstance);
		myRemotePlayers.push_back(remoteInstance);
		remoteInstance.name = "Player#" + str(id);
		print(remoteInstance.name + " has joined!"); 
	return;

puppet func CreatePlayers(ids):
	for i in range(0, ids.size()):
		if(ids[i] == get_tree().get_network_unique_id()):
			continue;
		var remoteInstance = myRemotePlayerScene.instance();
		get_parent().add_child(remoteInstance);
		myRemotePlayers.push_back(remoteInstance);
		remoteInstance.name = "Player#" + str(ids[i]);
		print("Created " + remoteInstance.name); 
		
	print("Other players loaded. Player amount: " + str(ids.size()));
	return;

puppet func RemovePlayer(id):
	var oldplayer = get_parent().get_node("Player#" + str(id));
	myRemotePlayers.erase(oldplayer);
	oldplayer.queue_free();
	print ("Player#" + str(id) + " left, so we destroyed him.");
	return;

puppet func UpdateRemotePlayer(id, playertransform, cameratransform):
	#print("Received update message from server!");
	if(id == get_tree().get_network_unique_id()):
		return;
		
	var remotePlayer = get_parent().get_node("Player#" + str(id));
	if(remotePlayer == null || playertransform == null || cameratransform == null):
		return;
	
	#print(playertransform.origin);
	var cameraLookAtTransform = cameratransform;# cameratransform.rotated(playertransform.
	var cameraForward = cameraLookAtTransform.basis.z;
	cameraForward.y = 0;
	cameraForward = cameraForward.normalized();
	var cameraPosition = playertransform.origin + cameratransform.origin;
	var cameraLookAt = cameraPosition + cameraForward;
	
	#print(cameraLookAtTransform);
	#var skeletalMesh = remotePlayer.get_node("SK_AnimatedMesh/SM_Robot");
	#skeletalMesh.set_bone_pose(skeletalMesh.find_bone("Head"), cameratransform);
	remotePlayer.look_at_from_position(playertransform.origin, playertransform.origin + cameraLookAt - cameraPosition, Vector3(0,1,0));
	return;

puppet func CreateSphereEnemy(id):
	var newEnemy = mySphereEnemyTemplate.instance();
	newEnemy.set_name("SphereEnemy" + str(id));
	myEnemies.append(newEnemy);
	get_parent().add_child(newEnemy);
	print ("Created enemy! ID: " + str(id));
	return;

puppet func UpdateSphereEnemy(id, transform):
	#print ("Sphere Enemy: Got update from server: " + str(id) + " " + str(transform));
	myEnemies[id].transform = transform;
	return;

func _on_packet_received(_id, packet):
	var command = packet.get_string_from_ascii();
	print(command);
	return;

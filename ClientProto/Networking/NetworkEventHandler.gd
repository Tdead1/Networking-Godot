extends Node

# Replication variables:
var myServerAdress = "127.0.0.1";
onready var myNetwork;
var myConnectionStatus = NetworkedMultiplayerPeer.CONNECTION_CONNECTING;

const myReplyTimeout = 5.0;
var myConnectTimer = 0.0;

var myRemotePlayerScene = preload("res://Player/Remote/RemotePlayerInstance.tscn");
var mySphereEnemyTemplate = preload("res://Prefabs/Enemies/EnemySphere.tscn");
var myObjectiveMarkerTemplate = preload("res://Prefabs/Objects/ObjectiveMarker.tscn");
var myRemotePlayers = [];
var myEnemies = {};
var myObjectiveMarker : MeshInstance = null;
var myLocalPlayer : KinematicBody;
var myID = 0;

func _ready():
	if (get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received") != OK):
		print("Connecting network traffic function failed in event handler!");	
	myNetwork = NetworkedMultiplayerENet.new();
	set_network_master(1);
	myLocalPlayer = get_parent().get_node("PlayerPawn");
	print("Creating client.");
	AttemptConnect();
	return;

func _process(delta):
	var newConnectionStatus = myNetwork.get_connection_status();
	match (myConnectionStatus):
		NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
			myConnectTimer += delta;
			if (myConnectTimer > myReplyTimeout):
				newConnectionStatus = NetworkedMultiplayerPeer.CONNECTION_CONNECTING;
		NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			myConnectTimer += delta;
			if (myConnectTimer > myReplyTimeout):
				newConnectionStatus = NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED;
			continue;
		NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			continue;
	
	if (myConnectionStatus == newConnectionStatus):
		return;
	
	myConnectTimer = 0.0;
	match(newConnectionStatus):
		NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
			if (myConnectionStatus == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
				print("Connection timed out.");
			else:
				print("Server has shut down.");
			Disconnect();
		NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			AttemptConnect();
		NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			ConnectionSuccess();
	#print("Connection status changed from: " + String(myConnectionStatus) + " to " + String(newConnectionStatus));
	myConnectionStatus = newConnectionStatus;
		
	return;

func Disconnect():
	print("We have disconnected from the server.");
	for i in myRemotePlayers:
		i.queue_free();
	myRemotePlayers = [];
	for i in myEnemies:
		myEnemies[i].queue_free();
	myEnemies = {};
	
	if (myObjectiveMarker):
		myObjectiveMarker.queue_free();
	myLocalPlayer.myObjective = Quest.new();
	
	myNetwork.close_connection();
	get_tree().set_network_peer(null);
	return;

func AttemptConnect():
	myNetwork = NetworkedMultiplayerENet.new();
	print("Attempting to connect.");
	myNetwork.create_client(myServerAdress, 4242); 
	get_tree().set_network_peer(myNetwork);
	myLocalPlayer.name = "Player#" + str(get_tree().multiplayer.get_network_unique_id());
	return;

func ConnectionSuccess():
	print("Connected to server.");
	print(str(get_tree().get_network_connected_peers().size()));
	myID = get_tree().multiplayer.get_network_unique_id();
	return;

puppet func CreatePlayer(id):
	print("Create player was called from the server!"); 
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
	myEnemies[id] = newEnemy;
	get_parent().add_child(newEnemy);
	print ("Created enemy! ID: " + str(id));
	return;

puppet func KillSphereEnemy(id):
	get_parent().remove_child(myEnemies[id]);
	myEnemies[id].queue_free();
	myEnemies.erase(id);
	print("Enemy destroyed! Maybe we will receive a reward?");
	return;

puppet func UpdateSphereEnemy(id, transform):
	# enemy might still be getting spawned in from the server.
	if (!myEnemies.has(id)):
		return;
	#print ("Sphere Enemy: Got update from server: " + str(id) + " " + str(transform));
	myEnemies[id].transform = transform;
	if (id == 1):
		myEnemies[id].transform = myEnemies[id].transform.scaled(Vector3(0.5,0.5,0.5));
	return;

puppet func ReceiveObjective(state, type, name, location):
	myLocalPlayer.myObjective.myState = state;
	myLocalPlayer.myObjective.myType = type;
	myLocalPlayer.myObjective.myName = name;
	myLocalPlayer.myObjective.myLocation = location;
	myObjectiveMarker = myObjectiveMarkerTemplate.instance();
	get_parent().add_child(myObjectiveMarker);
	myObjectiveMarker.transform.origin.x = location.x;
	myObjectiveMarker.transform.origin.z = location.y;
	print("Received objective.");
	return;

puppet func ReceiveObjectiveRewards():
	# Rewards go here.
	myObjectiveMarker.queue_free();
	myLocalPlayer.myObjective = Quest.new();
	print("Received reward, completed objective.");
	return;

# Requestable output events below.
func RequestObjective():
	if (myConnectionStatus == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
		print("Requested objective...");
		rpc_id(1, "RequestObjective", get_tree().get_network_unique_id());
	return;

func SubmitObjectiveCompletion():
	if (myConnectionStatus == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
		print("Requesting objective rewards...");
		rpc_id(1, "SubmitObjectiveCompletion", get_tree().get_network_unique_id());
		myLocalPlayer.myObjective.myState = Quest.ObjectiveState.Submitted;
	return;

# Unspecified Package Handling:
func _on_packet_received(_id, packet):
	var command = packet.get_string_from_ascii();
	print(command);
	return;


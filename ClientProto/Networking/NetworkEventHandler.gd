extends Node

# Replication variables:
var server_adress = "127.0.0.1";
onready var network = NetworkedMultiplayerENet.new();

var myRemotePlayerScene = preload("res://Player/Remote/RemotePlayerInstance.tscn");
var myRemotePlayers = [];
var myIsConnected = false;
var myLocalPlayer;
var myID = 0;

func _ready():
	set_network_master(1);
	myLocalPlayer = get_parent().get_node("PlayerPawn");
	
	print("Creating client. \n");
	
	network.create_client(server_adress, 4242);
	network.connect("connection_failed", self, "_on_connection_failed");
	network.connect("connection_succeeded", self, "_on_connection_success");
	get_tree().set_network_peer(network);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	
	myLocalPlayer.name = "Player#" + str(get_tree().multiplayer.get_network_unique_id());
	return;

func _on_connection_failed():
	print("Connection failed (server down?) \n");
	myIsConnected = false;
	return;

func _on_connection_success():
	print("Connected to server.\n");
	#set_network_master(get_tree().get_network_unique_id());
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
	if(id == get_tree().get_network_unique_id()):
		return;
		
	var remotePlayer = get_parent().get_node("Player#" + str(id));
	var playerposition = playertransform.origin;
	var cameraforward = cameratransform.basis.z;
	cameraforward.y = 0;
	cameraforward = playerposition - cameraforward.normalized();	
	remotePlayer.look_at_from_position(playertransform.origin, cameraforward, Vector3(0,1,0));
	return;

func _on_packet_received(_id, packet):
	var command = packet.get_string_from_ascii();
	print(command);
	return;

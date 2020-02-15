extends Node

# Replication variables:
var server_adress = "127.0.0.1";
onready var network = NetworkedMultiplayerENet.new();

var myRemotePlayerScene = preload("res://Player/Remote/RemotePlayerInstance.tscn");
var myRemotePlayers;
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
	return;

func _on_connection_success():
	print("Connected to server.\n");
	#set_network_master(get_tree().get_network_unique_id());
	print(str(get_tree().get_network_connected_peers().size()));
	myID = get_tree().multiplayer.get_network_unique_id();
	myIsConnected = true;
	return;
	
	
puppet func create_players(ids):
	for i in range(0, ids.size()):
		if(ids[i] == get_tree().get_network_unique_id()):
			continue;

		var remoteInstance = myRemotePlayerScene.instance();
		get_parent().add_child(remoteInstance);
		myRemotePlayers.push_back(remoteInstance);
		remoteInstance.name = "Player#" + str(ids[i]);
	
		print("Created " + remoteInstance.name); 
	print("Other players loaded. Player amount: " + str(myRemotePlayers.size()));
	return;

puppet func create_player(id):
	print("Create player was called from the server!"); 
	if(id != get_tree().get_network_unique_id()):
		var remoteInstance = myRemotePlayerScene.instance();
		get_parent().add_child(remoteInstance);
		myRemotePlayers.push_back(remoteInstance);
		remoteInstance.name = "Player#" + str(id);
		print(remoteInstance.name + " has joined!"); 
	return;
	
puppet func remove_player(id):
	var oldplayer = get_parent().get_node("Player#" + str(id));
	myRemotePlayers.erase(oldplayer);
	oldplayer.queue_free();
	print ("Player#" + str(id) + " left, so we destroyed him.");
	return;
	
#master func SetHealth(newhealth):
#	health = newhealth;
#	get_node("PlayerCamera/HUD/HealthBar").value = health;
#	return;

func _on_packet_received(id, packet):
	var command = packet.get_string_from_ascii();
	print(command);
	return;
	
func _physics_process(delta):
	if(myIsConnected):
		# Send the server all the information we need!
		rpc_unreliable("set_player_transform", myID, myLocalPlayer.transform); 
		return;  
	

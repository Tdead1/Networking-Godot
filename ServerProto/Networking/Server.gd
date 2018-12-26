extends Node

var done = false;
var socket = PacketPeerUDP.new();
var connectedplayers = [];
var debuglog = "Server Starting... ";

var network = NetworkedMultiplayerENet.new();


func _ready():
	if(network.create_server(4242, 400) == OK):
		debuglog += "Server running on port 4242. \n";
	else:
		debuglog += "Server setup failed!";
	get_tree().set_network_peer(network);
	network.connect("peer_connected", self, "_peer_connected");
	network.connect("peer_disconnected", self, "_peer_disconnected");
	
	pass;

func _peer_connected(id):
	debuglog += "User connected. ID: " + str(id);
	debuglog += "  Users online: " + str(get_tree().get_network_connected_peers().size()) + "\n";
	pass;

func _peer_disconnected(id):
	debuglog += "User disconnected. ID: " + str(id);
	debuglog += "  Users online: " + str(get_tree().get_network_connected_peers().size()) + "\n";
	pass;





#func _process(delta):
#	if(done != true):
#		if(socket.get_available_packet_count() > 0):
#			var data = socket.get_packet().get_string_from_ascii();
#			if(data == "quit"):
#				done = true;
#			elif(data == "player_login"):
#				player_connect();
#			else:
#				debuglog += "Data received: " + data + "\n";
#	else:
#		socket.close();
#		print("Exiting server application.");
#		queue_free();
#	pass;
#
#func player_connect(var player):
#	connectedplayers.append(player);
#	pass;
#
#func player_disconnect(var player):
#	player.queue_free();
#	connectedplayers.erase(player);
#	pass;
#
#func _on_ConnectClientButton_pressed():
#	var newPlayer = Node.new();
#	newPlayer.set_owner(self);
#	newPlayer.set_name("player#" + str(connectedplayers.size()));
#	player_connect(newPlayer);
#	pass;
#
#
#func _on_KickClientButton_pressed():
#	if(connectedplayers.size() == 0):
#		debuglog += "I'm sorry Dave, I'm afraid I can't let you do that.";
#	else:
#		player_disconnect(connectedplayers[randi() % connectedplayers.size()]);
#	pass

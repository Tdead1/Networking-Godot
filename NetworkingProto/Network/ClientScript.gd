extends Node

var server_adress = "127.0.0.1";
var is_pressed = false;

func _ready():
	print("Creating network. \n");
	var network = NetworkedMultiplayerENet.new();
	network.create_client(server_adress, 4242);
	network.connect("connection_failed", self, "_on_connection_failed");
	
	get_tree().set_network_peer(network);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	print("Finished setting up network connection. \n");
	pass;

func _on_connection_failed():
	print("Connection failed, we'll get 'em next time. \n) ");
	pass;

func _on_packet_received(id, packet):
	print(packet.get_string_from_ascii() + str(id));
	pass;

func _process(delta):
	
	if(Input.is_key_pressed(KEY_Q)):
		if(!is_pressed):
			print("Disconnecting from server.");
			get_tree().set_network_peer(null);
			is_pressed = true;
	else:
		is_pressed = false;
	
	pass;


extends Node

var debuglog = "Server Starting... ";
var network = NetworkedMultiplayerENet.new();
var playertemplate = preload("res://Player/PlayerPawn.tscn");
var players = [];
var ids = [];

func _ready():
	if(network.create_server(4242, 400) == OK):
		debuglog += "Server running on port 4242. \n";
	else:
		debuglog += "Server setup failed!";
	get_tree().set_network_peer(network);
	network.connect("peer_connected", self, "_peer_connected");
	network.connect("peer_disconnected", self, "_peer_disconnected");
	set_network_master(1);
	pass;

func _peer_connected(id):
	debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size());
	debuglog += "   -> User connected.    ID: " + str(id) + "\n";
	
	var newplayer = playertemplate.instance();
	add_child(newplayer);
	newplayer._setup_owner(id);
	
	ids.append(id);
	newplayer.rpc("create_players", ids);
	for i in range(0, players.size()):
		players[i].rpc_id(ids[i], "create_player", id);
	
	players.append(newplayer);
	pass;

func _peer_disconnected(id):
	var oldplayer = get_node("/root/Root/Player#" + str(id));
	#clients remove the disconnected player.
	for i in range(0, players.size()):
		players[i].rpc_id(ids[i], "remove_player", id);
	
	# server then erases the disconnected player.
	players.erase(oldplayer);
	ids.erase(id);
	oldplayer.queue_free();
	debuglog += "Users now online: " + str(get_tree().get_network_connected_peers().size()) ;
	debuglog += "   -> User disconnected. ID: " + str(id) + "\n";
	pass;

#########
# Notes #
#########

# 4 replication options:
# Remote: only on external machines
# Sync  : synchronize with server rpc call.
# Master: run on machine that owns the object (master)
# Slave : run on all connected machines EXCEPT for master.

# is_network_master(): True if this owns the object
# is_network_server(): True if this is the server
# hook up id's to r- calls for making it specific
# rpc_unreliable can be used to "hook up" and call functions on all machines (51:00)
# rpc for tcp, unreliable for udp.
# rset for variables (_unreliable for udp).


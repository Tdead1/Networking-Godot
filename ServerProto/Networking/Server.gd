extends Node

var myDebugLog = "Server Starting... ";
var network = NetworkedMultiplayerENet.new();
var networkEventHandler;
var myCollisionWorld = preload("res://DefaultScene.tscn");

func _ready():
	set_network_master(1);
	networkEventHandler = get_node("NetworkEventHandler");
	
	if(network.create_server(4242, 400) == OK):
		var world = myCollisionWorld.instance();
		world.name = "CollisionWorld";
		get_parent().call_deferred("add_child", world);
		
		myDebugLog += "Server running on port 4242. \n";
	else:
		myDebugLog += "Server setup failed!";
	
	get_tree().set_network_peer(network);
	network.connect("peer_connected", networkEventHandler, "ConnectPeer");
	network.connect("peer_disconnected", networkEventHandler, "DisconnectPeer");
	return;

#########
# Notes #
#########

# 4 replication options:
# Remote: Run only if my machines is not the calling machine
# Remotesync : Run on all machines including this one.
# Master: run on machine that owns the object (master)
# Puppet : run on all connected machines EXCEPT for master.

# is_network_master(): True if this owns the object
# is_network_server(): True if this is the server
# hook up id's to r- calls for making it specific
# rpc_unreliable can be used to "hook up" and call functions on all machines (51:00)
# rpc for tcp, unreliable for udp.
# rset for variables (_unreliable for udp).

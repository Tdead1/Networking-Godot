extends Node

var myDebugLog = "Server Starting... ";
var myNetwork = NetworkedMultiplayerENet.new();
var myNetworkEventHandler;
var myCollisionWorldScene = preload("res://DefaultScene.tscn");
var myQuestManagerScene = preload("res://Gameloop/QuestManager.tscn");

var myQuestManager;
var myCollisionWorld;

func _ready():
	set_network_master(1);
	myNetworkEventHandler = get_node("NetworkEventHandler");
	
	if(myNetwork.create_server(4242, 400) == OK):
		myCollisionWorld = myCollisionWorldScene.instance();
		myCollisionWorld.name = "CollisionWorld";
		call_deferred("add_child", myCollisionWorld);
		
		myQuestManager = myQuestManagerScene.instance();
		myQuestManager.name = "QuestManager";
		call_deferred("add_child", myQuestManager);
		
		myDebugLog += "Server running on port 4242. \n";
	else:
		myDebugLog += "Server setup failed!";
	
	get_tree().set_network_peer(myNetwork);
	myNetwork.connect("peer_connected", myNetworkEventHandler, "ConnectPeer");
	myNetwork.connect("peer_disconnected", myNetworkEventHandler, "DisconnectPeer");
	return;

#########
# Notes #
#########

# 4 replication options:
# Remote: Run only if my machines is not the calling machine
# Remotesync : Run on all machines including this one.
# Master: run on machine that owns the object (master)
# Puppet : run on all connected machines EXCEPT for master.

# is_myNetwork_master(): True if this owns the object
# is_myNetwork_server(): True if this is the server
# hook up id's to r- calls for making it specific
# rpc_unreliable can be used to "hook up" and call functions on all machines (51:00)
# rpc for tcp, unreliable for udp.
# rset for variables (_unreliable for udp).

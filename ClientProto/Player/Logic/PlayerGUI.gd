extends Node

onready var myObjectivesTextBox = get_node("Objectives");
onready var myLocalPlayer = get_node("../..");

func _process(_delta):
	var textToDisplay = "[b]";
	
	textToDisplay = "[b]";
	textToDisplay += "Quest: " + Quest.Type.keys()[myLocalPlayer.myObjective.myType] + "\n";
	#textToDisplay += "No quest active.\n";
	textToDisplay += "Player #" + str(myLocalPlayer.get_instance_id()) + "\n";
	
	match myLocalPlayer.myNetworkEventHandler.myConnectionStatus:
		NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED: 
			textToDisplay += "Disconnected. Retrying.";
		NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
			textToDisplay += "Connecting...";
		NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			textToDisplay += "Connected.";
	
	textToDisplay += "[/b]";
	myObjectivesTextBox.bbcode_text = textToDisplay; 
	return;

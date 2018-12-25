extends Node

func _on_KillServerButton_pressed():
	var packet = PacketPeerUDP.new();
	
	packet.set_dest_address("127.0.0.1", 4242);
	packet.put_packet("quit".to_ascii());
	
	print("Exiting client");
	pass;

func _on_MessageButton_pressed():
	var packet = PacketPeerUDP.new();
	
	packet.set_dest_address("127.0.0.1", 4242);
	packet.put_packet("Hello there, General Kenobi.".to_ascii());

	pass # replace with function body

extends Node

var done = false;
var socket = PacketPeerUDP.new();

func _init():
	
	if(socket.listen(4242, "127.0.0.1") != OK):
		print("An error occurred on port 4242 on localhost!");
	else:
		print("listening on port 4242 on localhost.");
	pass;

func _process(delta):
	
	if(done != true):
		if(socket.get_available_packet_count() > 0):
			var data = socket.get_packet().get_string_from_ascii();
			if(data == "quit"):
				done = true;
			else:
				print("Data received: " + data);
	else:
		socket.close();
		print("Exiting server application.");
		queue_free();
	pass;
extends KinematicBody

# Replication variables:
var server_adress = "127.0.0.1";
onready var network = NetworkedMultiplayerENet.new();

# class member variables:
export var speed = 10.0;
var moveInput = Vector3(0,0,0);
var is_pressed = false;
	
	
func _ready():
	print("Creating client. \n");
	

	network.create_client(server_adress, 4242);
	network.connect("connection_failed", self, "_on_connection_failed");
	
	get_tree().set_network_peer(network);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	name = "Player#" + str(get_tree().multiplayer.get_network_unique_id());
	
	print("Finished setting up client connection. \n");
	pass

func _process(delta):
	moveInput = Vector3(0,0,0);

	if(Input.is_key_pressed(KEY_W)):
		moveInput.x += speed * delta;
	if(Input.is_key_pressed(KEY_S)):
		moveInput.x -= speed * delta;
	if(Input.is_key_pressed(KEY_A)):
		moveInput.z -= speed * delta; 
	if(Input.is_key_pressed(KEY_D)):
		moveInput.z += speed * delta;
		
	if(Input.is_key_pressed(KEY_Q)):
		if(!is_pressed):
			print("Disconnecting from server.");
			get_tree().set_network_peer(null);
			is_pressed = true;
	else:
		is_pressed = false;
	
	if(get_tree().get_network_connected_peers().size() > 0):
		# Tell the other computer about our new position so it can update 
		rpc_unreliable("set_transform", transform);   

	pass

func _physics_process(delta):
	move_and_slide(moveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + 0.5 * PI));
	pass
	
	
func _on_connection_failed():
	print("Connection failed, we'll get 'em next time. \n)");
	queue_free();
	pass;

func _on_packet_received(id, packet):
	print(packet.get_string_from_ascii() + str(id));
	pass;
	
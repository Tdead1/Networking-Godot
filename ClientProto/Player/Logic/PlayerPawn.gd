extends KinematicBody

# Replication variables:
var server_adress = "127.0.0.1";
onready var network = NetworkedMultiplayerENet.new();
var local_playerinstance = preload("res://Player/ServerInstance/ServerPlayerInstance.tscn");
var local_players = [];
# class member variables:
export var speed = 300.0;
export var jumpForce = 150;
var moveInput = Vector3(0,0,0);
var jumpTime = 0.2;
var jumpTimer = 0.0;
var jumping = false;
var canjump = true;
var connected = false;
var health = 100.0;
	
func _ready():
	print("Creating client. \n");
	
	network.create_client(server_adress, 4242);
	network.connect("connection_failed", self, "_on_connection_failed");
	network.connect("connection_succeeded", self, "_on_connection_success");
	get_tree().set_network_peer(network);
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received");
	name = "Player#" + str(get_tree().multiplayer.get_network_unique_id());
	pass

func _process(delta):
	if(connected):
		# Input
		moveInput = Vector3(0,0,0);
		if(Input.is_key_pressed(KEY_W)):
			moveInput.x += speed * delta;
		if(Input.is_key_pressed(KEY_S)):
			moveInput.x -= speed * delta;
		if(Input.is_key_pressed(KEY_A)):
			moveInput.z -= speed * delta; 
		if(Input.is_key_pressed(KEY_D)):
			moveInput.z += speed * delta;
		if(Input.is_action_just_pressed("Jump")):
			if(jumping != true && canjump == true && jumpTimer <= 0.0):
				jumpTimer = jumpTime;
				canjump = false;
		if(Input.is_action_just_pressed("Disconnect")):
			print("Disconnecting from server.");
			get_tree().set_network_peer(null);
		
		# Jumping logic
		if(jumpTimer > 0.0):
			moveInput.y += jumpForce * jumpTimer;
			jumpTimer -= delta;
		
		# Check if grounded
		if(test_move(transform, Vector3(0, -0.001, 0))):
			canjump = true;
		else:
			moveInput.y -= 10.0;
			
		# Connection logic
		if(get_tree().get_network_connected_peers().size() > 0):
			# Tell the other computer about our new position so it can update
			var clienttransform = transform; #.rotated(Vector3(0,1,0), find_node("PlayerCamera").yrotation); 
			rpc_unreliable("set_transform", clienttransform);   
	pass

func _physics_process(delta):
	move_and_slide(moveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + 0.5 * PI));
	pass
	
	
func _on_connection_failed():
	print("Connection failed (server down?) \n");
	pass;

func _on_connection_success():
	print("Connected to server.\n");
	set_network_master(get_tree().get_network_unique_id());
	print(str(get_tree().get_network_connected_peers().size()));
	connected = true;
	pass;

func _on_packet_received(id, packet):
	var command = packet.get_string_from_ascii();
	print(command);
	pass;
	
master func create_players(ids):
	if(is_network_master()):
		for i in range(0, ids.size()):
			if(ids[i] != get_tree().get_network_unique_id()):
				var server_instance = local_playerinstance.instance();
				get_parent().add_child(server_instance);
				local_players.push_back(server_instance);
				server_instance.name = "Player#" + str(ids[i]);
				print("Created " + server_instance.name); 
		print("Other players loaded. Player amount: " + str(local_players.size()));
	pass;

master func create_player(id):
	if(id != get_tree().get_network_unique_id()):
		var server_instance = local_playerinstance.instance();
		get_parent().add_child(server_instance);
		local_players.push_back(server_instance);
		server_instance.name = "Player#" + str(id);
		print(server_instance.name + " has joined!"); 
	pass;
	
master func remove_player(id):
	var oldplayer = get_parent().get_node("Player#" + str(id));
	local_players.erase(oldplayer);
	oldplayer.queue_free();
	print ("Player#" + str(id) + " left, so we destroyed him.");
	pass;
	
master func SetHealth(newhealth):
	health = newhealth;
	pass;
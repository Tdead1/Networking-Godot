extends KinematicBody

# class member variables:
export var speed = 300.0;
var moveInput = Vector3(0,0,0);
var connected = false;
var health = 100.0;
	

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

		if(Input.is_action_just_pressed("Disconnect")):
			print("Disconnecting from server.");
			get_tree().set_network_peer(null);

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
	

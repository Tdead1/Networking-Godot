extends KinematicBody

# class member variables:
export var speed = 300.0;
var moveInput = Vector3(0,0,0);
var health = 100.0;
var camera;

func _ready():
	set_network_master(get_tree().get_network_unique_id());
	camera = get_node("PlayerCamera");
	return;
	

func _process(delta):
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
	return;

func _physics_process(delta):
	# Send the server all the information we need!
	#print("Hitting the physics process delta.");
	move_and_slide(moveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + 0.5 * PI));
	rpc_id(1, "UpdatePlayerTransform", transform, camera.transform); 
	return;  

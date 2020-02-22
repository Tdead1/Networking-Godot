extends KinematicBody

# class member variables:
export var mySpeed = 300.0;
var myMoveInput = Vector3(0,0,0);
var myHealth = 100.0;
var myCamera;
var myNetworkEventHanlder;

func _ready():
	set_network_master(get_tree().get_network_unique_id());
	myCamera = get_node("PlayerCamera");
	myNetworkEventHanlder = get_parent().get_node("NetworkEventHandler");
	return;
	

func _process(delta):
	# Input
	myMoveInput = Vector3(0,0,0);
	if(Input.is_key_pressed(KEY_W)):
		myMoveInput.x += mySpeed * delta;
	if(Input.is_key_pressed(KEY_S)):
		myMoveInput.x -= mySpeed * delta;
	if(Input.is_key_pressed(KEY_A)):
		myMoveInput.z -= mySpeed * delta; 
	if(Input.is_key_pressed(KEY_D)):
		myMoveInput.z += mySpeed * delta;
	if(Input.is_action_just_pressed("Disconnect")):
		print("Disconnecting from server.");
		get_tree().set_network_peer(null);
	else:
		myMoveInput.y -= 10.0;
	return;

func _physics_process(_delta):
	# Send the server all the information we need!
	move_and_slide(myMoveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + 0.5 * PI));
	if(myNetworkEventHanlder.myIsConnected):
		rpc_unreliable_id(1, "UpdatePlayerTransform", transform, myCamera.transform); 
	return;  

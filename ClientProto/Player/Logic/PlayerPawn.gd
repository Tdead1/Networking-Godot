extends KinematicBody

# class member variables:
export var mySpeed = 300.0;
var myMoveInput = Vector3(0,0,0);
var myHealth = 100.0;
var myCamera;
var myNetworkEventHanlder;
var myCollisionShape : CollisionShape;
var myVelocity = Vector3(0,0,0);

func _ready():
	set_network_master(get_tree().get_network_unique_id());
	myCamera = get_node("PlayerCamera");
	myCollisionShape = get_node("CollisionShape");
	myNetworkEventHanlder = get_parent().get_node("NetworkEventHandler");
	return;
	

func _process(delta):
	# Input
	myMoveInput = Vector3(0, 0, 0);
	if(Input.is_key_pressed(KEY_W)):
		myMoveInput.x += 1;
	if(Input.is_key_pressed(KEY_S)):
		myMoveInput.x -= 1;
	if(Input.is_key_pressed(KEY_A)):
		myMoveInput.z -= 1; 
	if(Input.is_key_pressed(KEY_D)):
		myMoveInput.z += 1;
	if(myMoveInput.length() > 0):
		myMoveInput = mySpeed * delta * myMoveInput.normalized();
	if(Input.is_action_just_pressed("Disconnect")):
		print("Disconnecting from server.");
		get_tree().set_network_peer(null);
	return;

func _physics_process(delta):
	# Gravity
	
	var space_state = get_world().direct_space_state;
	var result = space_state.intersect_ray(transform.origin + Vector3(0, 0.3, 0), transform.origin + Vector3(0, -1.0, 0));
	if(!result.empty()):
		if(myVelocity.y <= 0):
			myMoveInput.y = myVelocity.y + (result.position.y - transform.origin.y);
		else:
			myMoveInput.y = result.position.y - transform.origin.y;
		clamp(myVelocity.y, -0.4, 1000);
		print(myMoveInput.y);
	else:
		myMoveInput.y = myVelocity.y - 0.4;
		print("No results");

#	var isOnGround : bool = true;
#	var fallAccelleration = 0.0;
#	if(!test_move(transform, Vector3(0, -0.01, 0))):
#		isOnGround = false;
#		fallAccelleration = 10;
#	if(!isOnGround && !test_move(transform, Vector3(0, -0.10, 0))):
#		fallAccelleration = 100;
#	if(!isOnGround && !test_move(transform, Vector3(0, -0.40, 0))):
#		fallAccelleration = 40;
#	if(!isOnGround):
#		myMoveInput.y = 0.0 if myVelocity.y > 0 else myVelocity.y - (fallAccelleration * delta);
	
	# Send the server all the information we need!
	var forwardMovement = myMoveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + rotation.y + 0.5 * PI);
	var up = Vector3(0,1,0);
	myVelocity = move_and_slide(forwardMovement, up);
		
	if(myNetworkEventHanlder.myIsConnected):
		rpc_unreliable_id(1, "UpdatePlayerTransform", transform, myCamera.transform); 
	
	return;  

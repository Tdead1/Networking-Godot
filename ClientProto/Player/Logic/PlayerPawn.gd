extends KinematicBody

# class member variables:
export var myAcceleration = 100;
export var myMaxSpeed = 15;
export var myFriction = 3;
var myMoveInput = Vector3(0,0,0);
var myHealth = 100.0;
var myCamera;
var myNetworkEventHanlder;
var myCollisionShape : CollisionShape;
var myVelocity = Vector3(0,0,0);
var myGravity = 1;

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
		myMoveInput = myMoveInput.normalized();
	if(Input.is_action_just_pressed("Disconnect")):
		print("Disconnecting from server.");
		get_tree().set_network_peer(null);
	return;

func _physics_process(delta):
	var compensatedMoveInput = myMoveInput;
	if(!is_on_floor()):
		myVelocity.y -= myGravity;
		compensatedMoveInput *= 0.2;
		
	var rotatedInputVector = compensatedMoveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + rotation.y + 0.5 * PI);
	var speedVector = rotatedInputVector * myAcceleration + myVelocity;
	
	speedVector.y = clamp(speedVector.y, -10, 1000);
	var compensatedSpeedVector = Vector2(speedVector.x, speedVector.z).clamped(myMaxSpeed);
	speedVector.x = compensatedSpeedVector.x;	
	speedVector.z = compensatedSpeedVector.y;
	speedVector.x /= myFriction; 
	speedVector.z /= myFriction; 
	
	var up = Vector3(0,1,0);
	myVelocity = move_and_slide(speedVector, up);
	
	# Send the server all the information we need!
	if(myNetworkEventHanlder.myIsConnected):
		rpc_unreliable_id(1, "UpdatePlayerTransform", transform, myCamera.transform); 
	
	return;  

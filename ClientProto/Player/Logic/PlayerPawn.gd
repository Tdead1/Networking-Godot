extends KinematicBody

enum JumpStatus {
	Default,
	HasInput,
	InAir,
}

# class member variables:
export var myAcceleration = 100;
export var mySprintAcceleration = 200;
export var myMaxSpeed = 15;
export var myMaxSprintSpeed = 30;
export var myFriction = 3;
var myIsSprinting = false;
var myMoveInput = Vector3(0,0,0);
var myHealth = 100.0;
var myCamera;
var myNetworkEventHandler;
var myCollisionShape : CollisionShape;
var myVelocity = Vector3(0,0,0);
var myGravity = 0.5;
var myJumpStatus = JumpStatus.Default;

var myObjective = Quest.new();

func _ready():
	get_tree().current_scene.SetLocalPlayer(self); 
	set_network_master(get_tree().get_network_unique_id());
	myCamera = get_node("PlayerCamera");
	myCollisionShape = get_node("PhysicsCollisionShape");
	myNetworkEventHandler = get_parent().get_node("NetworkEventHandler");
	return;

func _process(_delta):
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
	if(is_on_floor() && Input.is_key_pressed(KEY_SPACE)):
		myJumpStatus = JumpStatus.HasInput;
	myIsSprinting = Input.is_key_pressed(KEY_SHIFT);
		
	return;

func _physics_process(_delta):
	# Pre-movement logic
	var maxSpeed = myMaxSprintSpeed if myIsSprinting else myMaxSpeed;
	var acceleration = mySprintAcceleration if myIsSprinting else myAcceleration;
	
	var compensatedMoveInput = myMoveInput;
	if(myJumpStatus == JumpStatus.HasInput):
		myVelocity.y = 10;
	
	if(!is_on_floor()):
		myVelocity.y -= myGravity;
		compensatedMoveInput *= 0.2;
		
	var rotatedInputVector = compensatedMoveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + rotation.y + 0.5 * PI);
	var speedVector = rotatedInputVector * acceleration + myVelocity;
	
	speedVector.y = clamp(speedVector.y, -10, 1000);
	var compensatedSpeedVector = Vector2(speedVector.x, speedVector.z).limit_length(maxSpeed);
	speedVector.x = compensatedSpeedVector.x;	
	speedVector.z = compensatedSpeedVector.y;
	speedVector.x /= myFriction; 
	speedVector.z /= myFriction; 
	# Offset to keep player grounded
	speedVector.y -= 0.001;
	
	var up = Vector3(0,1,0);
	myVelocity = move_and_slide(speedVector, up);
	
	# Post-Movement logic
	if(is_on_floor()):
		if(myJumpStatus == JumpStatus.InAir):
			myJumpStatus = JumpStatus.Default;
	elif(!is_on_floor()):
		myJumpStatus = JumpStatus.InAir;
	
	# Send the server all the information we need!
	if(myNetworkEventHandler.myConnectionStatus == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
		rpc_unreliable_id(1, "UpdatePlayerTransform", transform, myCamera.transform); 
	
	return;  

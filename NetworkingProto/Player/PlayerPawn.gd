extends KinematicBody

# class member variables go here, for example:
export var speed = 10.0;
var moveInput = Vector3(0,0,0);

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
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
	
	
		
	pass

func _physics_process(delta):
	move_and_slide(moveInput.rotated(Vector3(0,1,0), get_node("PlayerCamera").rotation.y + 0.5 * PI));
	pass
extends KinematicBody

# Extremely good ai logic
var myDestination := Vector2(0,0);
var myRandomTimer := float(0.0);
var myIsNotMovingTimer := float(0.0);
var myFrameVelocity := float(0.0);
var myLastFramePosition := Vector3(0,0,0);
var myIsMoving := bool(false);

export var mySpeed := float(4.0);

func _ready():
	rand_seed(0);
	myDestination = Vector2(rand_range(-10.0, 10.0), rand_range(-10.0, 10.0));
	return;
	
func _process(delta):
	if (myIsNotMovingTimer > 3.0 && myRandomTimer > 4.0):
		myRandomTimer = 0.0;
		myIsNotMovingTimer = 0.0;
	
	if (myRandomTimer <= 0.0):
		myDestination = Vector2(rand_range(-10.0, 10.0), rand_range(-10.0, 10.0));
		myRandomTimer = rand_range(4.0, 20.0);
	
	if (myRandomTimer < 4.0):
		myDestination = Vector2(transform.origin.x, transform.origin.y);
	
	
	myRandomTimer -= delta;
	return;

func _physics_process(delta):
	var direction = (myDestination - Vector2(transform.origin.x, transform.origin.y)).normalized();
	move_and_slide(Vector3(direction.x * mySpeed, -9.8, direction.y * mySpeed), Vector3(0,1,0));
	myFrameVelocity = (myLastFramePosition - transform.origin).length();
	myIsMoving = myFrameVelocity > 0.5;
	myIsNotMovingTimer = myIsNotMovingTimer + delta if !myIsMoving else 0.0;
	# Keep this LAST in the physics process!
	myLastFramePosition = transform.origin;
	return;

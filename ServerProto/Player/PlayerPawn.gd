extends Spatial

var health = 100.0;
var id = "";
var camera;
var myCameraTransform;

func _ready():
	camera = get_node("PlayerCamera");
	return;

puppet func UpdatePlayerTransform(aPlayerTransform, aCameraTransform):
	transform = aPlayerTransform;
	myCameraTransform = aCameraTransform;
	#get_parent().debuglog += "Received player transfrom! \n";
	#transform = playertransform;
	#camera.transform = cameratransform;
	return;

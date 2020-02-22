extends Spatial

var health = 100.0;
var id = "";
var camera;

func _ready():
	camera = get_node("PlayerCamera");
	return;

puppet func UpdatePlayerTransform(playertransform, cameratransform):
	#get_parent().debuglog += "Received player transfrom! \n";
	transform = playertransform;
	camera.transform = cameratransform;
	return;

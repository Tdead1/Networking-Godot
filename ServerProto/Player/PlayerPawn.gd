extends Spatial

var health = 100.0;
var id = "";
var camera;

func _ready():
	camera = get_node("PlayerCamera");
	return;

puppet func SetPlayerTransform(id, playertransform, cameratransform):
	transform = playertransform;
	camera.transform = cameratransform;
	return;

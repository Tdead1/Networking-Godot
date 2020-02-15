extends Spatial

var health = 100.0;
var id = "";
var camera;

func _ready():
	camera = get_node("PlayerCamera");
	return;

puppet func set_player_transform(id, playertransform, cameratransform):
	get_parent().debuglog += "Updating player transforms! ";
	transform = playertransform;
	camera.transform = cameratransform;
	return;

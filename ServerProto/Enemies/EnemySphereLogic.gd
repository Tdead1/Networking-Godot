extends Spatial

func _ready():
	rand_seed(0);
	transform.origin = Vector3(0.0, 0.5, 0.0);
	return;
	
func _process(delta):
	transform.origin.x += rand_range(-0.05, 0.05);
	transform.origin.z += rand_range(-0.05, 0.05);
	return;

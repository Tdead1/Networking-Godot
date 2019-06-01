extends RayCast

var objectInAim = Object();

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	#gives the third column of the transform, which is the forward.
	#cast_to = get_global_transform().basis.z * 1;

	if(Input.get_mouse_button_mask() == BUTTON_LEFT):
		if is_colliding():
			#returns object.
			objectInAim = get_collider();
			print(objectInAim.name);
			#if(objectInAim.has_method("GetDamage")):
			#	objectInAim.queue_free();
	
	pass

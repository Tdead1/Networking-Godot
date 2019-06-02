extends RayCast
# bullets per second.
export var fireRate = 10.0;
var fireTimer = 0.0;
var fireTimerReset = 1.0 / fireRate;
var objectInAim;
var playerID;

func _ready():
	set_network_master(1);
	pass

func _process(delta):
	#gives the third column of the transform, which is the forward.
	#cast_to = get_global_transform().basis.z * 1;

	if(Input.get_mouse_button_mask() == BUTTON_LEFT):
		if is_colliding():
			if(fireTimer <= 0.0):
				playerID = get_tree().get_network_unique_id();
				fireTimer = fireTimerReset;
				objectInAim = get_collider();
				print(objectInAim.get_path());
				print(playerID);
				rpc("FireGun", objectInAim.get_path(), playerID);
			
			#if(objectInAim.has_method("GetDamage")):
			#	objectInAim.queue_free();
			
	if(fireTimer > 0.0):
		fireTimer -= delta;
	pass

extends RayCast
# bullets per second.
export var myFireRate = 10.0;
var myFireTimer = 0.0;
var myFireTimerReset = 1.0 / myFireRate;
var myObjectInAim;
var myPlayerID;

func _ready():
	set_network_master(1);
	pass

func _process(delta):
	#gives the third column of the transform, which is the forward.
	#cast_to = get_global_transform().basis.z * 1;

	if(Input.get_mouse_button_mask() == BUTTON_LEFT):
		if is_colliding():
			if (myFireTimer <= 0.0):
				myPlayerID = get_tree().get_network_unique_id();
				myFireTimer = myFireTimerReset;
				myObjectInAim = get_collider();
				print(myObjectInAim.get_path());
				print(myPlayerID);
				if (get_parent().get_parent().myNetworkEventHanlder.myConnectionStatus == NetworkedMultiplayerPeer.CONNECTION_CONNECTED):
					rpc("FireGun", myObjectInAim.get_path(), myPlayerID);
			
			#if(myObjectInAim.has_method("GetDamage")):
			#	myObjectInAim.queue_free();
			
	if(myFireTimer > 0.0):
		myFireTimer -= delta;
	pass

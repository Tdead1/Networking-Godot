extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var camInput = Vector2(0,0);
var mouseMode = Input.MOUSE_MODE_VISIBLE;
var yrotation = 0.0;
export var mouseSensitivity = 0.1;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	pass

func _process(delta):
	#show mouse when pressing escape.
	if(Input.is_key_pressed(KEY_ESCAPE)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		mouseMode = Input.MOUSE_MODE_VISIBLE;

	#when mouse is visible.
	if(mouseMode == Input.MOUSE_MODE_VISIBLE):
		if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			mouseMode = Input.MOUSE_MODE_CAPTURED;

	#when mouse is captured.
	if(mouseMode == Input.MOUSE_MODE_CAPTURED):
		var rot = Vector3(0,0,0);
		rot.x = clamp(rotation.x - camInput.y * mouseSensitivity * delta, -0.5 * PI, 0.5 * PI);
		rot.y = rotation.y - camInput.x * mouseSensitivity * delta;
		yrotation = rot.y;
		rot.z = rotation.z;
		set_rotation(rot);

	#gives the third column of the transform, which is the forward.
	#get_global_transform().basis.z;
	
	camInput = Vector2(0,0);
	pass

func _input(event):
	#is is actually is of type.
	if event is InputEventMouseMotion:
		camInput = event.relative;
	pass
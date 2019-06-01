extends Camera

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var camInput = Vector2(0.0, 0.0);
var mouseMode = Input.MOUSE_MODE_VISIBLE;
export var mouseSensitivity = 2;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	get_node("Crosshair").position.x = ProjectSettings.get_setting("display/window/size/width") / 2;
	get_node("Crosshair").position.y = ProjectSettings.get_setting("display/window/size/height") / 2;
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
	
	if(get_parent().connected == true):
		#when mouse is captured.
		if(mouseMode == Input.MOUSE_MODE_CAPTURED):
			var rot = Vector3(0.0,0.0,0.0);
			rot.x = clamp(rotation.x - camInput.y / 10 * mouseSensitivity * delta, -0.5 * PI, 0.5 * PI);
			rot.y = rotation.y - camInput.x / 10 * mouseSensitivity * delta;
			rot.z = rotation.z;
			set_rotation(rot);
			camInput = Vector2(camInput.x / 10, camInput.y / 10);
			
		rpc_unreliable("set_rotation", rotation);
	pass

func _input(event):
	#is is actually is of type.
	if event is InputEventMouseMotion:
		camInput += event.relative;
	pass
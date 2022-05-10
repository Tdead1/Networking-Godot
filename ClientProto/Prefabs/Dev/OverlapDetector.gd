extends Area

signal LocalPlayerEnter;
signal LocalPlayerExit;

func _ready():
	if (connect("area_entered", self, "AreaEnter") != OK):
		print("Connect failed on overlap detector script!");
	return;

func AreaEnter(body):
	if (get_tree().current_scene.myLocalPlayer == body.get_parent()):
		emit_signal("LocalPlayerEnter");
	return;

func AreaExit(body):
	if (get_tree().current_scene.myLocalPlayer == body.get_parent()):
		emit_signal("LocalPlayerExit");
	return;

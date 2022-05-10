extends RichTextLabel

onready var servernode = get_parent();

func _process(_delta):
	text = servernode.myDebugLog;
	
	pass

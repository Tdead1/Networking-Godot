extends RichTextLabel

onready var servernode = get_parent();

func _process(delta):
	text = servernode.debuglog;
	
	pass

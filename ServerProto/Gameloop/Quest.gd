class_name Quest
extends Object

# Keep in sync with identical file on the client!
enum ObjectiveState { Empty, Inactive, Active, Submitted };
var myState = ObjectiveState.Empty;
var myName = "Empty";
var myLocation = Vector2(0,0);

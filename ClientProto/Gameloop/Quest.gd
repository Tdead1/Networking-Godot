class_name Quest
extends Object

# Keep in sync with identical file on the client!
enum ObjectiveState { Empty, Inactive, Active, Submitted };
enum Type { Empty, GoTo, Kill }; 
var myState = ObjectiveState.Empty;
var myType = Type.Empty;
var myName = "Empty";
var myLocation = Vector2(0,0);

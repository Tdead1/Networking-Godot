class_name Quest
extends Object

# Keep in sync with identical file on the client!
enum ObjectiveState { Empty, Inactive, Active, Submitted };
enum Type { Empty, GoTo, Kill }; 
var myState = ObjectiveState.Empty;
var myType = Type.Empty;
var myName = "Empty";
var myLocation = Vector2(0,0);

func Randomize():
	myType = self.Type.Kill;#1 + randi() % (Quest.QuestType.size() - 1);
	myState = self.ObjectiveState.Active;
	myName = String(randi() % 20);
	myLocation = Vector2(rand_range(-10.0, 10.0), rand_range(-100.0, 100.0));
	return;

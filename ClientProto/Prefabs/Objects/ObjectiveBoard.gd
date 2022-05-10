extends Spatial

enum ObjectiveRequestState {Idle, Requested, OnGoing};
var myObjectiveRequestState = ObjectiveRequestState.Idle;

var questRequestTimer = 0.0;
var myQuestSubmitTimer = 0.0;
const requestTimeMax = 5.0;

onready var myLocalPlayer = get_tree().current_scene.myLocalPlayer;
onready var OverlapDetector = get_node("Area");

func _ready():
	OverlapDetector.connect("LocalPlayerEnter", self, "RequestObjective");
	return;

func _process(delta):
	var distance = (myLocalPlayer.myObjective.myLocation - Vector2(myLocalPlayer.transform.origin.x, myLocalPlayer.transform.origin.z)).length();
	var shouldSubmitObjective = distance < 5.0 && myLocalPlayer.myObjective.myState == Quest.ObjectiveState.Active;
	if (shouldSubmitObjective):
		myLocalPlayer.myNetworkEventHandler.SubmitObjectiveCompletion();
	
	if (myLocalPlayer.myObjective.myState == Quest.ObjectiveState.Submitted):
		myQuestSubmitTimer += delta;
		if (myQuestSubmitTimer > requestTimeMax):
			print("Quest Reward Request timed out.");
			myLocalPlayer.myObjective.myState = Quest.ObjectiveState.Active;
			myQuestSubmitTimer = 0.0;
	
	match (myObjectiveRequestState):
		ObjectiveRequestState.Requested:
			if (myLocalPlayer.myObjective.myState == Quest.ObjectiveState.Active):
				myObjectiveRequestState = ObjectiveRequestState.OnGoing;
				questRequestTimer = 0.0;
				return;
			questRequestTimer += delta;
			if (questRequestTimer > requestTimeMax):
				print("Quest Objective Request timed out!");
				questRequestTimer = 0.0;
				myObjectiveRequestState = ObjectiveRequestState.Idle;
				return;
		ObjectiveRequestState.OnGoing:
			if (myLocalPlayer.myObjective.myState == Quest.ObjectiveState.Empty):
				myObjectiveRequestState = ObjectiveRequestState.Idle;
				return;
	
	return;

func RequestObjective():
	if (myObjectiveRequestState != ObjectiveRequestState.Idle):
		return;
		
	if (myLocalPlayer.myObjective.myState != Quest.ObjectiveState.Empty):
		return;
	
	print("Requesting objective from server...");
	myObjectiveRequestState = ObjectiveRequestState.Requested;
	myLocalPlayer.myNetworkEventHandler.RequestObjective();
	return;

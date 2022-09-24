extends Node

onready var myRayCast = get_node("RayCast");
var myEnemiesByQuest = {};
onready var myServer = get_parent();

func LocationToWorldPosition(location):
	myRayCast.global_transform.origin.x = location.x;
	myRayCast.global_transform.origin.z = location.y;
	myRayCast.force_raycast_update();
	if (!myRayCast.is_colliding()):
		return Vector3(0,0,0);
	var collisionPoint = myRayCast.get_collision_point();
	return collisionPoint;

func CreateKillQuest(quest):
	quest.get_instance_id();
	var enemySpawnPosition = LocationToWorldPosition(quest.myLocation)
	enemySpawnPosition.y += 1.0;
	var enemyID = myServer.myNetworkEventHandler.CreateSphereEnemy(enemySpawnPosition);
	myEnemiesByQuest[quest.get_instance_id()] = [enemyID];
	return;

func OnEnemyKilled(id):
	for quest in myEnemiesByQuest:
		var enemyArray = myEnemiesByQuest[quest];
		var enemyCount = enemyArray.size();
		for i in enemyCount:
			if (enemyArray[enemyCount - (i + 1)] == id):
				enemyArray.remove(enemyCount - (i + 1));
	return;

func VerifyCompletion(player):
	if (player == null):
		return;
	
	myServer.myDebugLog += "Received objective complete from " + player.name + "\n";
	if (player.myObjective.myState != Quest.ObjectiveState.Active):
		return;
	
	var distance = (player.myObjective.myLocation - Vector2(player.transform.origin.x, player.transform.origin.z)).length();
	var shouldSubmitObjective = false;
	match player.myObjective.myType:
		Quest.Type.GoTo:
			 shouldSubmitObjective = distance < 5.0 && player.myObjective.myState == Quest.ObjectiveState.Active;
		Quest.Type.Kill:
			shouldSubmitObjective = distance < 5.0 && player.myObjective.myState == Quest.ObjectiveState.Active && myEnemiesByQuest[player.myObjective.get_instance_id()].empty();
			
	if (shouldSubmitObjective):
		myServer.myNetworkEventHandler.GiveObjectiveReward(player.id);
	
	return;

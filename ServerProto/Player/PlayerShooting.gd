extends Spatial
var hit_object;

puppet func FireGun(pathToObject, playerID):
	print(String(pathToObject) + " was shot by Player#" + String(playerID));
	if (has_node(pathToObject)):
		hit_object = get_node(pathToObject);	
		if(hit_object.has_method("GetDamage")):
			print("object HAS method for applying damage!");
			hit_object.GetDamage(playerID, 35.0);
	pass;

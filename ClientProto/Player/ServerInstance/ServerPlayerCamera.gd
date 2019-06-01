extends Spatial

var skel;
var head_bone;

func _ready():
	set_network_master(1);
	skel = get_parent().get_node("SK_AnimatedMesh/SM_Robot");
	head_bone = skel.find_bone("Head");
	pass
	
sync func set_rotation(rt):
	if(get_network_master() == 1):
		get_parent().rotation.y = rt.y;
		var added_rotation = rt - get_parent().rotation;
		var head_bone_pose = skel.get_bone_rest(head_bone);
		head_bone_pose = Transform(Basis(added_rotation), Vector3(0,0,0));
		skel.set_bone_pose(head_bone, head_bone_pose);
	pass;

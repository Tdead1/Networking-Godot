extends Spatial
	
puppet func set_rotation(clientrotation):
	rotation = clientrotation; 
	get_parent().get_node("PlayerMesh").rotation = clientrotation; 
	pass

extends MeshInstance

export var rotation_speed : float = 0.5

func _physics_process(delta):
	self.rotate_y(delta * rotation_speed)

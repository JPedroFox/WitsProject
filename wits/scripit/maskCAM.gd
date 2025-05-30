extends Node2D

@export var CAM_linked : Node2D

func _physics_process(_delta):
	self.position = CAM_linked.position
	

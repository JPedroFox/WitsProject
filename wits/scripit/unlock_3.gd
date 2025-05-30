extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		$Block3.queue_free()
		get_node("/root/Game/visibilityMask/block3").queue_free()

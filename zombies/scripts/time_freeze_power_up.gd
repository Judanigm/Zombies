extends PowerUp

@export var effect_duration: float = 10.0


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	var scene_root := get_tree().current_scene
	if scene_root == null or not scene_root.has_method("activate_time_freeze"):
		return

	scene_root.activate_time_freeze(effect_duration)
	_finish_pickup(collector)

extends PowerUp

@export var effect_duration: float = 7.0


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	if not collector.has_method("activate_homing_bullets"):
		return

	collector.activate_homing_bullets(effect_duration)
	_finish_pickup(collector)

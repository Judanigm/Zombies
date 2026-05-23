extends PowerUp

@export var grenade_amount: int = 1


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	if collector.has_method("add_grenades"):
		collector.add_grenades(grenade_amount)

	_finish_pickup(collector)

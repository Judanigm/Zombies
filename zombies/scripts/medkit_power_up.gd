extends PowerUp

@export var medkit_amount: int = 1


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	var added_amount := 0
	if collector.has_method("add_medkit"):
		added_amount = collector.add_medkit(medkit_amount)

	if added_amount <= 0:
		return

	_finish_pickup(collector)

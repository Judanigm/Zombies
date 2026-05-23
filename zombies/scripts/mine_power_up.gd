extends PowerUp

@export var mine_amount: int = 1


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	var added_amount := 0
	if collector.has_method("add_mines"):
		added_amount = collector.add_mines(mine_amount)

	if added_amount <= 0:
		return

	_finish_pickup(collector)

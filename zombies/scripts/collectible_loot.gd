extends Area2D

@export var loot_id: StringName = &"loot"


func _ready() -> void:
	add_to_group("collectible_loot")
	monitoring = false
	collision_mask = 0

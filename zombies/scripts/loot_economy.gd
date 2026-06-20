extends Node

## Global loot economy model (autoload "LootEconomy").
##
## Owns the expedition loot the player is currently carrying, the loot stored at the
## base, their persistence to user://base_loot.cfg, and the base-building cost rules.
## Contains NO UI: it emits base_loot_changed and main.gd refreshes the loot display.
##
## main.gd keeps thin delegators (register_collected_loot, save_base_loot, ...) so other
## scripts that call into the current scene stay unchanged.

signal base_loot_changed

const BASE_LOOT_SAVE_PATH := "user://base_loot.cfg"
const BASE_BUILD_WOOD_COST := 35
const BASE_BUILD_IRON_COST := 10
const LOOT_TEXTURES := {
	&"oil": preload("res://assets/Objetos de la base/Loot/Bote de petróleo.png"),
	&"wood": preload("res://assets/Objetos de la base/Loot/Cacho de madera.png"),
	&"iron": preload("res://assets/Objetos de la base/Loot/Lingote de hierro.png"),
	&"copper": preload("res://assets/Objetos de la base/Loot/Lámina de cobre.png"),
}
const LOOT_DISPLAY_NAMES := {
	&"oil": "Petroleo",
	&"wood": "Madera",
	&"iron": "Hierro",
	&"copper": "Cobre",
}
const LOOT_DISPLAY_ORDER := [&"wood", &"iron", &"copper", &"oil"]

var expedition_loot_counts: Dictionary = {}
var stored_base_loot_counts: Dictionary = {}


func _ready() -> void:
	_load()


func add_expedition_loot(loot_id: StringName) -> void:
	if not LOOT_TEXTURES.has(loot_id):
		return
	expedition_loot_counts[loot_id] = int(expedition_loot_counts.get(loot_id, 0)) + 1


func commit_expedition_to_base() -> void:
	for loot_id_variant in expedition_loot_counts.keys():
		var loot_id: StringName = StringName(loot_id_variant)
		var amount := int(expedition_loot_counts.get(loot_id, 0))
		if amount <= 0:
			continue

		stored_base_loot_counts[loot_id] = int(stored_base_loot_counts.get(loot_id, 0)) + amount

	expedition_loot_counts.clear()
	save_base_loot()
	emit_signal("base_loot_changed")


func clear_expedition() -> void:
	expedition_loot_counts.clear()


func get_base_loot_count(loot_id: StringName) -> int:
	return int(stored_base_loot_counts.get(loot_id, 0))


func get_expedition_loot_count(loot_id: StringName) -> int:
	return int(expedition_loot_counts.get(loot_id, 0))


func has_building_cost() -> bool:
	return (
		int(stored_base_loot_counts.get(&"wood", 0)) >= BASE_BUILD_WOOD_COST
		and int(stored_base_loot_counts.get(&"iron", 0)) >= BASE_BUILD_IRON_COST
	)


func spend_building_cost() -> bool:
	if not has_building_cost():
		return false

	stored_base_loot_counts[&"wood"] = int(stored_base_loot_counts.get(&"wood", 0)) - BASE_BUILD_WOOD_COST
	stored_base_loot_counts[&"iron"] = int(stored_base_loot_counts.get(&"iron", 0)) - BASE_BUILD_IRON_COST
	save_base_loot()
	return true


func _load() -> void:
	stored_base_loot_counts.clear()
	var config := ConfigFile.new()
	var load_result := config.load(BASE_LOOT_SAVE_PATH)

	for loot_id_variant in LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		var amount := 0
		if load_result == OK:
			amount = maxi(int(config.get_value("loot", String(loot_id), 0)), 0)
		stored_base_loot_counts[loot_id] = amount


func save_base_loot() -> void:
	var config := ConfigFile.new()
	for loot_id_variant in LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		config.set_value("loot", String(loot_id), int(stored_base_loot_counts.get(loot_id, 0)))

	config.save(BASE_LOOT_SAVE_PATH)

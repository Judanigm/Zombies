extends Node

## Global achievement + stats model (autoload "AchievementManager").
##
## Owns achievement unlock state, per-type kill counts, discovered zombie types and
## the wave record, plus their persistence to user://achievements.cfg. It contains NO
## UI: unlock() emits achievement_unlocked(id) and main.gd drives the on-screen popup.
##
## main.gd keeps thin delegator methods (unlock_achievement, register_grenade_stock, ...)
## so the other scripts that call into the current scene stay unchanged.

signal achievement_unlocked(achievement_id: StringName)

const ACHIEVEMENT_SAVE_PATH := "user://achievements.cfg"

const ACHIEVEMENT_TWO_ZOMBIES_ONE_BULLET := &"two_zombies_one_bullet"
const ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE := &"three_strong_zombies_one_grenade"
const ACHIEVEMENT_TEN_GRENADES := &"ten_grenades"
const ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON := &"defeat_michael_jackson"
const ACHIEVEMENT_DISCOVER_ALL_ZOMBIES := &"discover_all_zombies"
const ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES := &"kill_100_normal_zombies"
const ACHIEVEMENT_KILL_100_FAST_ZOMBIES := &"kill_100_fast_zombies"
const ACHIEVEMENT_KILL_100_STRONG_ZOMBIES := &"kill_100_strong_zombies"
const ACHIEVEMENT_TEN_ACTIVE_MINES := &"ten_active_mines"
const ACHIEVEMENT_CLOSE_ZOMBIE_KILL := &"close_zombie_kill"

const ACHIEVEMENT_IMAGE_TEXTURES := {
	&"two_zombies_one_bullet": preload("res://assets/Texto/Logros/Double shoot 2.png"),
	&"three_strong_zombies_one_grenade": preload("res://assets/Texto/Logros/Bomba 2.png"),
	&"ten_grenades": preload("res://assets/Texto/Logros/Ahorros explosivos 2.png"),
	&"defeat_michael_jackson": preload("res://assets/Texto/Logros/Aguafiestas 2.png"),
	&"discover_all_zombies": preload("res://assets/Texto/Logros/Zombiólogo 2.png"),
	&"kill_100_normal_zombies": preload("res://assets/Texto/Logros/Verde asesino 2.png"),
	&"kill_100_fast_zombies": preload("res://assets/Texto/Logros/Rápido asesino 2.png"),
	&"kill_100_strong_zombies": preload("res://assets/Texto/Logros/Asesino por fuerza bruta 2.png"),
	&"ten_active_mines": preload("res://assets/Texto/Logros/Mala suerte 2.png"),
	&"close_zombie_kill": preload("res://assets/Texto/Logros/Sigilo 101 2.png"),
}

const ACHIEVEMENT_DEFINITIONS := [
	{
		"id": ACHIEVEMENT_TWO_ZOMBIES_ONE_BULLET,
		"title": "Double Kill",
		"description": "Kill 2 zombies with the same bullet without using power-ups.",
	},
	{
		"id": ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE,
		"title": "Boom!!!",
		"description": "Kill three strong zombies with one grenade.",
	},
	{
		"id": ACHIEVEMENT_TEN_GRENADES,
		"title": "Explosive Savings",
		"description": "Stockpile 10 grenades.",
	},
	{
		"id": ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON,
		"title": "Party Pooper",
		"description": "Defeat the Michael Jackson zombie.",
	},
	{
		"id": ACHIEVEMENT_DISCOVER_ALL_ZOMBIES,
		"title": "Zombiologist",
		"description": "Discover every zombie type.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES,
		"title": "Green Slayer",
		"description": "Kill 100 or more normal zombies.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_FAST_ZOMBIES,
		"title": "Speed Slayer",
		"description": "Kill 100 or more fast zombies.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_STRONG_ZOMBIES,
		"title": "Brute Force Slayer",
		"description": "Kill 100 or more strong zombies.",
	},
	{
		"id": ACHIEVEMENT_TEN_ACTIVE_MINES,
		"title": "Very Bad Luck",
		"description": "Have 10 armed mines on the ground at the same time.",
	},
	{
		"id": ACHIEVEMENT_CLOSE_ZOMBIE_KILL,
		"title": "Stealth 101",
		"description": "Kill a zombie that is very close to you.",
	},
]

const ZOMBIE_TYPES_FOR_ZOMBIOLOGO := [
	Zombie.TYPE_NORMAL,
	Zombie.TYPE_ATOMIC,
	Zombie.TYPE_FAST,
	Zombie.TYPE_STRONG,
	Zombie.TYPE_MINER,
	Zombie.TYPE_MICHAEL_JACKSON,
]
const ZOMBIE_KILL_MILESTONE := 100
const ACTIVE_MINES_ACHIEVEMENT_TARGET := 10
const CLOSE_ZOMBIE_KILL_DISTANCE := 96.0

var unlocked_achievements: Dictionary = {}
var zombie_kill_counts: Dictionary = {}
var discovered_zombie_types: Dictionary = {}
var wave_record: int = 0


func _ready() -> void:
	_load()


func unlock(achievement_id: StringName) -> bool:
	if not _has_definition(achievement_id):
		return false
	if bool(unlocked_achievements.get(achievement_id, false)):
		return false

	unlocked_achievements[achievement_id] = true
	_save()
	emit_signal("achievement_unlocked", achievement_id)
	return true


func get_achievements_text() -> String:
	var lines: Array[String] = []

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var unlocked := bool(unlocked_achievements.get(achievement_id, false))
		var status := "UNLOCKED" if unlocked else "LOCKED"
		lines.append("[%s] %s" % [status, String(achievement["title"])])
		lines.append(String(achievement["description"]))
		lines.append("")

	return "\n".join(lines).strip_edges()


func get_achievements_data() -> Array[Dictionary]:
	var achievements: Array[Dictionary] = []

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var achievement_data: Dictionary = achievement.duplicate()
		achievement_data["unlocked"] = bool(unlocked_achievements.get(achievement_id, false))
		achievements.append(achievement_data)

	return achievements


func get_definition(achievement_id: StringName) -> Dictionary:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		if achievement.get("id", &"") == achievement_id:
			return achievement
	return {}


func get_wave_record() -> int:
	return wave_record


func register_wave_record(wave: int) -> void:
	if wave <= wave_record:
		return

	wave_record = wave
	_save()


func register_grenade_stock(grenade_count: int) -> void:
	if grenade_count >= 10:
		unlock(ACHIEVEMENT_TEN_GRENADES)


func register_grenade_strong_zombie_kills(kill_count: int) -> void:
	if kill_count >= 3:
		unlock(ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE)


func check_active_mine_achievement() -> void:
	if bool(unlocked_achievements.get(ACHIEVEMENT_TEN_ACTIVE_MINES, false)):
		return
	if _get_active_placed_mine_count() >= ACTIVE_MINES_ACHIEVEMENT_TARGET:
		unlock(ACHIEVEMENT_TEN_ACTIVE_MINES)


func register_zombie_kill(zombie: Node) -> void:
	var zombie_type := _get_zombie_type(zombie)
	if zombie_type == &"":
		return

	zombie_kill_counts[zombie_type] = int(zombie_kill_counts.get(zombie_type, 0)) + 1
	_register_type_discovered(zombie_type)
	_register_close_kill(zombie)

	_sync_progress()
	_save()


func register_zombie_discovery(zombie: Node) -> void:
	var zombie_type := _get_zombie_type(zombie)
	if zombie_type != &"":
		_register_type_discovered(zombie_type)


func clear() -> void:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		unlocked_achievements[achievement_id] = false

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		zombie_kill_counts[zombie_type] = 0
		discovered_zombie_types[zombie_type] = false

	_save()


func _register_type_discovered(zombie_type: StringName) -> void:
	if bool(discovered_zombie_types.get(zombie_type, false)):
		return

	discovered_zombie_types[zombie_type] = true
	if _has_discovered_all_types():
		unlock(ACHIEVEMENT_DISCOVER_ALL_ZOMBIES)
	_save()


func _sync_progress() -> void:
	if int(zombie_kill_counts.get(Zombie.TYPE_NORMAL, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock(ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES)
	if int(zombie_kill_counts.get(Zombie.TYPE_FAST, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock(ACHIEVEMENT_KILL_100_FAST_ZOMBIES)
	if int(zombie_kill_counts.get(Zombie.TYPE_STRONG, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock(ACHIEVEMENT_KILL_100_STRONG_ZOMBIES)
	if _has_discovered_all_types():
		unlock(ACHIEVEMENT_DISCOVER_ALL_ZOMBIES)


func _get_zombie_type(zombie: Node) -> StringName:
	if zombie == null:
		return &""
	if zombie.has_method("get_zombie_type"):
		return StringName(zombie.call("get_zombie_type"))
	if zombie.has_method("is_strong_zombie") and bool(zombie.call("is_strong_zombie")):
		return Zombie.TYPE_STRONG
	return &""


func _register_close_kill(zombie: Node) -> void:
	if bool(unlocked_achievements.get(ACHIEVEMENT_CLOSE_ZOMBIE_KILL, false)):
		return
	var player := get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player) or not (zombie is Node2D):
		return

	var zombie_position := (zombie as Node2D).global_position
	if (player as Node2D).global_position.distance_to(zombie_position) <= CLOSE_ZOMBIE_KILL_DISTANCE:
		unlock(ACHIEVEMENT_CLOSE_ZOMBIE_KILL)


func _get_active_placed_mine_count() -> int:
	var active_mines := 0
	for mine in get_tree().get_nodes_in_group("placed_mines"):
		if not is_instance_valid(mine):
			continue
		if mine.has_method("is_active_for_achievement"):
			if bool(mine.call("is_active_for_achievement")):
				active_mines += 1
			continue
		if bool(mine.get("is_armed")) and not bool(mine.get("has_detonated")):
			active_mines += 1

	return active_mines


func _has_discovered_all_types() -> bool:
	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		if not bool(discovered_zombie_types.get(zombie_type, false)):
			return false
	return true


func _has_definition(achievement_id: StringName) -> bool:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		if achievement["id"] == achievement_id:
			return true
	return false


func _load() -> void:
	unlocked_achievements.clear()
	zombie_kill_counts.clear()
	discovered_zombie_types.clear()
	var config := ConfigFile.new()
	var load_result := config.load(ACHIEVEMENT_SAVE_PATH)
	wave_record = 0
	if load_result == OK:
		wave_record = maxi(int(config.get_value("stats", "wave_record", 0)), 0)

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var unlocked := false
		if load_result == OK:
			unlocked = bool(config.get_value("achievements", String(achievement_id), false))
		unlocked_achievements[achievement_id] = unlocked

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		var kill_count := 0
		var discovered := false
		if load_result == OK:
			kill_count = int(config.get_value("zombie_kills", String(zombie_type), 0))
			discovered = bool(config.get_value("discovered_zombies", String(zombie_type), kill_count > 0))
		zombie_kill_counts[zombie_type] = kill_count
		discovered_zombie_types[zombie_type] = discovered

	_sync_progress()


func _save() -> void:
	var config := ConfigFile.new()

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		config.set_value(
			"achievements",
			String(achievement_id),
			bool(unlocked_achievements.get(achievement_id, false))
		)

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		config.set_value(
			"zombie_kills",
			String(zombie_type),
			int(zombie_kill_counts.get(zombie_type, 0))
		)
		config.set_value(
			"discovered_zombies",
			String(zombie_type),
			bool(discovered_zombie_types.get(zombie_type, false))
		)

	config.set_value("stats", "wave_record", wave_record)

	config.save(ACHIEVEMENT_SAVE_PATH)

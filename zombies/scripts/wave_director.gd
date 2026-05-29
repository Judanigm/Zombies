class_name WaveDirector
extends Node

## Wave progression and zombie spawning, extracted from main.gd.
##
## Owns the wave number, the per-type spawn counters/timers, the wave tuning
## (@export, editable via the wave-settings text), wave composition, zombie
## selection + spawn positioning, the Michael Jackson boss, power-up drops and
## the extraction wave. main.gd creates this as a child, sets `main`, and drives
## it from _process via tick(delta); it reaches back into main for shared state
## (player, spawn_area, player_dead, is_in_base_zone, hard mode) and to refresh
## the wave label / fog (main._update_wave_label / _update_fog_effect_for_wave).

const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const ATOMIC_ZOMBIE_SCENE := preload("res://scenes/atomic_zombie.tscn")
const FAST_ZOMBIE_SCENE := preload("res://scenes/fast_zombie.tscn")
const STRONG_ZOMBIE_SCENE := preload("res://scenes/strong_zombie.tscn")
const MINER_ZOMBIE_SCENE := preload("res://scenes/miner_zombie.tscn")
const MICHAEL_JACKSON_ZOMBIE_SCENE := preload("res://scenes/zombie_michael_jackson.tscn")
const GRENADE_POWER_UP_SCENE := preload("res://scenes/power_ups/grenade_power_up.tscn")
const HOMING_BULLETS_POWER_UP_SCENE := preload("res://scenes/power_ups/homing_bullets_power_up.tscn")
const MEDKIT_POWER_UP_SCENE := preload("res://scenes/power_ups/medkit_power_up.tscn")
const MINE_POWER_UP_SCENE := preload("res://scenes/power_ups/mine_power_up.tscn")
const TELEPORT_ORB_POWER_UP_SCENE := preload("res://scenes/power_ups/teleport_orb_power_up.tscn")
const ANTI_COOLDOWN_POWER_UP_SCENE := preload("res://scenes/power_ups/anti_cooldown_power_up.tscn")
const TRIPLE_BULLET_POWER_UP_SCENE := preload("res://scenes/power_ups/triple_bullet_power_up.tscn")
const TIME_FREEZE_POWER_UP_SCENE := preload("res://scenes/power_ups/time_freeze_power_up.tscn")

const HARD_MODE_STRONG_ZOMBIE_START_WAVE := 1
const HARD_MODE_FAST_ZOMBIE_START_WAVE := 3
const HARD_MODE_FAST_ZOMBIES_ADDED_PER_WAVE := 2
const HARD_MODE_MINER_ZOMBIE_START_WAVE := 7
const HARD_MODE_ZOMBIE_SPEED_MULTIPLIER := 1.12
const HARD_MODE_POWER_UP_DROP_MULTIPLIER := 0.55
const EXTRACTION_WAVE_ZOMBIE_MULTIPLIER := 1.65
const EXTRACTION_WAVE_MIN_EXTRA_ZOMBIES := 5
const EXTRACTION_WAVE_FAST_BONUS := 2
const EXTRACTION_WAVE_STRONG_BONUS := 1
const LATE_WAVE_SOFTEN_START := 13
const LATE_WAVE_ZOMBIE_REDUCTION_STEP := 2
const LATE_WAVE_ZOMBIES_REMOVED_ON_START := 1
const LATE_WAVE_EXTRA_SPAWN_INTERVAL := 0.15
const LATE_WAVE_EXTRA_SPAWN_INTERVAL_PER_WAVE := 0.02
const LATE_WAVE_MAX_EXTRA_SPAWN_INTERVAL := 0.35
const LATE_WAVE_FAST_RATIO_CAP := 0.40
const LATE_WAVE_STRONG_RATIO_CAP := 0.22
const LATE_WAVE_MINER_RATIO_CAP := 0.12
const MICHAEL_JACKSON_HEALTH_ADDED_PER_RETURN := 3
const WAVE_SETTING_ORDER := [
	"first_wave_delay",
	"time_between_waves",
	"base_zombies_per_wave",
	"zombies_added_per_wave",
	"base_spawn_interval",
	"min_spawn_interval",
	"spawn_interval_reduction_per_wave",
	"fast_zombie_start_wave",
	"max_fast_zombies_on_start_wave",
	"fast_zombies_added_per_wave",
	"strong_zombie_start_wave",
	"max_strong_zombies_on_start_wave",
	"strong_zombies_added_per_wave",
	"atomic_zombie_start_wave",
	"max_atomic_zombies_on_start_wave",
	"atomic_zombies_added_per_wave",
	"miner_zombie_start_wave",
	"max_miner_zombies_on_start_wave",
	"miner_zombies_added_per_wave",
	"michael_jackson_start_wave",
	"michael_jackson_wave_interval",
	"minimum_normal_zombies_after_wave_ten",
	"michael_jackson_initial_zombie_delay",
	"michael_jackson_spawn_interval_bonus",
	"medkit_drop_start_wave",
	"medkit_drop_chance",
	"grenade_drop_start_wave",
	"grenade_drop_chance",
	"homing_bullets_drop_start_wave",
	"homing_bullets_drop_chance",
	"mine_drop_start_wave",
	"mine_drop_chance",
	"teleport_orb_drop_start_wave",
	"teleport_orb_drop_chance",
	"anti_cooldown_drop_start_wave",
	"anti_cooldown_drop_chance",
	"triple_bullet_drop_start_wave",
	"triple_bullet_drop_chance",
	"time_freeze_drop_start_wave",
	"time_freeze_drop_chance",
]
const WAVE_SETTING_TYPES := {
	"first_wave_delay": TYPE_FLOAT,
	"time_between_waves": TYPE_FLOAT,
	"base_zombies_per_wave": TYPE_INT,
	"zombies_added_per_wave": TYPE_INT,
	"base_spawn_interval": TYPE_FLOAT,
	"min_spawn_interval": TYPE_FLOAT,
	"spawn_interval_reduction_per_wave": TYPE_FLOAT,
	"fast_zombie_start_wave": TYPE_INT,
	"max_fast_zombies_on_start_wave": TYPE_INT,
	"fast_zombies_added_per_wave": TYPE_INT,
	"strong_zombie_start_wave": TYPE_INT,
	"max_strong_zombies_on_start_wave": TYPE_INT,
	"strong_zombies_added_per_wave": TYPE_INT,
	"atomic_zombie_start_wave": TYPE_INT,
	"max_atomic_zombies_on_start_wave": TYPE_INT,
	"atomic_zombies_added_per_wave": TYPE_INT,
	"miner_zombie_start_wave": TYPE_INT,
	"max_miner_zombies_on_start_wave": TYPE_INT,
	"miner_zombies_added_per_wave": TYPE_INT,
	"michael_jackson_start_wave": TYPE_INT,
	"michael_jackson_wave_interval": TYPE_INT,
	"minimum_normal_zombies_after_wave_ten": TYPE_INT,
	"michael_jackson_initial_zombie_delay": TYPE_FLOAT,
	"michael_jackson_spawn_interval_bonus": TYPE_FLOAT,
	"medkit_drop_start_wave": TYPE_INT,
	"medkit_drop_chance": TYPE_FLOAT,
	"grenade_drop_start_wave": TYPE_INT,
	"grenade_drop_chance": TYPE_FLOAT,
	"homing_bullets_drop_start_wave": TYPE_INT,
	"homing_bullets_drop_chance": TYPE_FLOAT,
	"mine_drop_start_wave": TYPE_INT,
	"mine_drop_chance": TYPE_FLOAT,
	"teleport_orb_drop_start_wave": TYPE_INT,
	"teleport_orb_drop_chance": TYPE_FLOAT,
	"anti_cooldown_drop_start_wave": TYPE_INT,
	"anti_cooldown_drop_chance": TYPE_FLOAT,
	"triple_bullet_drop_start_wave": TYPE_INT,
	"triple_bullet_drop_chance": TYPE_FLOAT,
	"time_freeze_drop_start_wave": TYPE_INT,
	"time_freeze_drop_chance": TYPE_FLOAT,
}

@export var first_wave_delay: float = 1.0
@export var time_between_waves: float = 2.5
@export var base_zombies_per_wave: int = 3
@export var zombies_added_per_wave: int = 1
@export var base_spawn_interval: float = 1.2
@export var min_spawn_interval: float = 0.35
@export var spawn_interval_reduction_per_wave: float = 0.08
@export var edge_margin: float = 72.0
@export var min_spawn_distance_from_player: float = 420.0
@export var fast_zombie_start_wave: int = 5
@export var max_fast_zombies_on_start_wave: int = 2
@export var fast_zombies_added_per_wave: int = 1
@export var strong_zombie_start_wave: int = 7
@export var max_strong_zombies_on_start_wave: int = 1
@export var strong_zombies_added_per_wave: int = 1
@export var atomic_zombie_start_wave: int = 8
@export var max_atomic_zombies_on_start_wave: int = 1
@export var atomic_zombies_added_per_wave: int = 1
@export var miner_zombie_start_wave: int = 12
@export var max_miner_zombies_on_start_wave: int = 1
@export var miner_zombies_added_per_wave: int = 1
@export var michael_jackson_start_wave: int = 10
@export var michael_jackson_wave_interval: int = 10
@export var minimum_normal_zombies_after_wave_ten: int = 5
@export var michael_jackson_initial_zombie_delay: float = 4.5
@export var michael_jackson_spawn_interval_bonus: float = 1.1
@export var medkit_drop_start_wave: int = 4
@export_range(0.0, 1.0, 0.01) var medkit_drop_chance: float = 0.05
@export var grenade_drop_start_wave: int = 3
@export_range(0.0, 1.0, 0.01) var grenade_drop_chance: float = 0.08
@export var homing_bullets_drop_start_wave: int = 6
@export_range(0.0, 1.0, 0.01) var homing_bullets_drop_chance: float = 0.04
@export var mine_drop_start_wave: int = 3
@export_range(0.0, 1.0, 0.01) var mine_drop_chance: float = 0.05
@export var teleport_orb_drop_start_wave: int = 5
@export_range(0.0, 1.0, 0.01) var teleport_orb_drop_chance: float = 0.04
@export var anti_cooldown_drop_start_wave: int = 5
@export_range(0.0, 1.0, 0.01) var anti_cooldown_drop_chance: float = 0.035
@export var triple_bullet_drop_start_wave: int = 4
@export_range(0.0, 1.0, 0.01) var triple_bullet_drop_chance: float = 0.045
@export var time_freeze_drop_start_wave: int = 6
@export_range(0.0, 1.0, 0.01) var time_freeze_drop_chance: float = 0.035

var main: Node = null

var current_wave: int = 0
var wave_active: bool = false
var wave_timer: float = 0.0
var spawn_timer: float = 0.0
var zombies_left_to_spawn: int = 0
var normal_zombies_left_to_spawn: int = 0
var atomic_zombies_left_to_spawn: int = 0
var fast_zombies_left_to_spawn: int = 0
var strong_zombies_left_to_spawn: int = 0
var miner_zombies_left_to_spawn: int = 0
var extraction_requested: bool = false
var extraction_wave_active: bool = false


## Per-frame wave update; main.gd calls this from _process once the time-freeze /
## death / base / menu gates have passed.
func tick(delta: float) -> void:
	if not wave_active:
		if _get_alive_zombie_count() > 0:
			return
		if extraction_requested:
			_start_extraction_wave()
			return

		wave_timer = maxf(wave_timer - delta, 0.0)
		main._update_wave_label()
		if wave_timer == 0.0:
			_start_next_wave()
		return

	spawn_timer = maxf(spawn_timer - delta, 0.0)
	if zombies_left_to_spawn > 0 and spawn_timer == 0.0:
		_spawn_next_zombie()
		spawn_timer = _get_spawn_interval_for_wave()

	if zombies_left_to_spawn == 0 and _get_alive_zombie_count() == 0:
		if extraction_wave_active:
			_complete_expedition_to_base()
			return
		if extraction_requested:
			_start_extraction_wave()
			return

		wave_active = false
		wave_timer = time_between_waves
		main._update_wave_label()


## Resets the active wave when the player dies (counts cleared so the next run
## starts fresh). The surviving zombies are freed by main on restart.
func reset_for_death() -> void:
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0


func skip_to_wave(target_wave: int) -> void:
	if main.player_dead:
		return

	target_wave = maxi(target_wave, 1)
	_clear_current_wave_for_skip()
	current_wave = target_wave - 1
	wave_timer = 0.0
	_start_next_wave()


func _start_next_wave() -> void:
	current_wave += 1
	wave_active = true
	AchievementManager.register_wave_record(current_wave)
	var base_zombies_for_wave := _get_total_zombies_for_wave(current_wave)
	zombies_left_to_spawn = base_zombies_for_wave
	strong_zombies_left_to_spawn = _get_strong_zombies_for_wave(current_wave, zombies_left_to_spawn)
	strong_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		strong_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_STRONG_RATIO_CAP
	)
	var zombies_remaining_after_strong := zombies_left_to_spawn - strong_zombies_left_to_spawn
	fast_zombies_left_to_spawn = _get_fast_zombies_for_wave(current_wave, zombies_remaining_after_strong)
	fast_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		fast_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_FAST_RATIO_CAP
	)
	normal_zombies_left_to_spawn = base_zombies_for_wave - fast_zombies_left_to_spawn - strong_zombies_left_to_spawn
	miner_zombies_left_to_spawn = _get_miner_zombies_for_wave(current_wave)
	miner_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		miner_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_MINER_RATIO_CAP
	)
	zombies_left_to_spawn += miner_zombies_left_to_spawn
	_ensure_minimum_normal_zombies()
	atomic_zombies_left_to_spawn = _get_atomic_zombies_for_wave(current_wave, normal_zombies_left_to_spawn)
	spawn_timer = 0.0
	if _should_spawn_michael_jackson(current_wave):
		_spawn_michael_jackson_zombie()
		spawn_timer = michael_jackson_initial_zombie_delay
	main._update_wave_label()
	main._update_fog_effect_for_wave()


func _clear_current_wave_for_skip() -> void:
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	spawn_timer = 0.0

	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(zombie_node):
			zombie_node.queue_free()


func _start_extraction_wave() -> void:
	if main.player_dead or main.is_in_base_zone or extraction_wave_active:
		return

	extraction_requested = false
	extraction_wave_active = true
	wave_active = true
	current_wave += 1
	AchievementManager.register_wave_record(current_wave)

	var base_zombies_for_wave := _get_total_zombies_for_wave(current_wave)
	var extraction_total := maxi(
		int(ceil(float(base_zombies_for_wave) * EXTRACTION_WAVE_ZOMBIE_MULTIPLIER)),
		base_zombies_for_wave + EXTRACTION_WAVE_MIN_EXTRA_ZOMBIES
	)
	strong_zombies_left_to_spawn = mini(
		_get_strong_zombies_for_wave(current_wave, extraction_total) + EXTRACTION_WAVE_STRONG_BONUS,
		extraction_total
	)
	var remaining_after_strong := maxi(extraction_total - strong_zombies_left_to_spawn, 0)
	fast_zombies_left_to_spawn = mini(
		_get_fast_zombies_for_wave(current_wave, remaining_after_strong) + EXTRACTION_WAVE_FAST_BONUS,
		remaining_after_strong
	)
	miner_zombies_left_to_spawn = mini(
		_get_miner_zombies_for_wave(current_wave),
		maxi(extraction_total - strong_zombies_left_to_spawn - fast_zombies_left_to_spawn, 0)
	)
	normal_zombies_left_to_spawn = maxi(
		extraction_total - strong_zombies_left_to_spawn - fast_zombies_left_to_spawn - miner_zombies_left_to_spawn,
		0
	)
	atomic_zombies_left_to_spawn = _get_atomic_zombies_for_wave(current_wave, normal_zombies_left_to_spawn)
	zombies_left_to_spawn = extraction_total
	spawn_timer = 0.0
	main._update_wave_label()
	main._update_fog_effect_for_wave()
	main._update_expedition_ui()


func _complete_expedition_to_base() -> void:
	extraction_wave_active = false
	extraction_requested = false
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	LootEconomy.commit_expedition_to_base()
	main._clear_collectible_loot_nodes()
	main._update_expedition_ui()
	main.go_to_base()


func _spawn_next_zombie() -> void:
	var zombie_scene := _get_next_zombie_scene()
	if zombie_scene == null:
		return

	var zombie := zombie_scene.instantiate()
	zombie.global_position = _get_spawn_position_for_scene(zombie_scene)
	_apply_hard_mode_to_zombie(zombie)
	_register_zombie(zombie)
	main.add_child(zombie)
	zombies_left_to_spawn -= 1


func _get_next_zombie_scene() -> PackedScene:
	if (
		fast_zombies_left_to_spawn <= 0
		and strong_zombies_left_to_spawn <= 0
		and miner_zombies_left_to_spawn <= 0
		and normal_zombies_left_to_spawn <= 0
	):
		return null

	if strong_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		return _get_next_normal_zombie_scene()

	if strong_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0:
		if strong_zombies_left_to_spawn > 0 and randf() < float(strong_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		if fast_zombies_left_to_spawn > 0 and randf() < float(fast_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			fast_zombies_left_to_spawn -= 1
			return FAST_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		if normal_zombies_left_to_spawn > 0 and randf() < float(normal_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			return _get_next_normal_zombie_scene()
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0:
		var strong_or_miner_total := strong_zombies_left_to_spawn + miner_zombies_left_to_spawn
		if strong_or_miner_total > 0 and randf() < float(strong_zombies_left_to_spawn) / float(strong_or_miner_total):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		if miner_zombies_left_to_spawn > 0:
			miner_zombies_left_to_spawn -= 1
			return MINER_ZOMBIE_SCENE
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0:
		var strong_or_miner_total := strong_zombies_left_to_spawn + miner_zombies_left_to_spawn
		if strong_or_miner_total > 0 and randf() < float(strong_zombies_left_to_spawn) / float(strong_or_miner_total):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0:
		if randf() < float(fast_zombies_left_to_spawn) / float(fast_zombies_left_to_spawn + miner_zombies_left_to_spawn):
			fast_zombies_left_to_spawn -= 1
			return FAST_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	var random_pick := randf()
	var strong_ratio := float(strong_zombies_left_to_spawn) / float(zombies_left_to_spawn)
	var fast_ratio := float(fast_zombies_left_to_spawn) / float(zombies_left_to_spawn)
	var miner_ratio := float(miner_zombies_left_to_spawn) / float(zombies_left_to_spawn)

	if random_pick < strong_ratio:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if random_pick < strong_ratio + fast_ratio:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if random_pick < strong_ratio + fast_ratio + miner_ratio:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	return _get_next_normal_zombie_scene()


func _get_next_normal_zombie_scene() -> PackedScene:
	var normal_like_zombies_left := normal_zombies_left_to_spawn
	normal_zombies_left_to_spawn -= 1
	if (
		normal_like_zombies_left > 0
		and atomic_zombies_left_to_spawn > 0
		and randf() < float(atomic_zombies_left_to_spawn) / float(normal_like_zombies_left)
	):
		atomic_zombies_left_to_spawn -= 1
		return ATOMIC_ZOMBIE_SCENE
	return ZOMBIE_SCENE


func _get_fast_zombies_for_wave(wave: int, total_zombies: int) -> int:
	var start_wave := HARD_MODE_FAST_ZOMBIE_START_WAVE if main.hard_mode_enabled else fast_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_fast_intro := wave - start_wave
	var added_per_wave := HARD_MODE_FAST_ZOMBIES_ADDED_PER_WAVE if main.hard_mode_enabled else fast_zombies_added_per_wave
	var fast_zombie_count := max_fast_zombies_on_start_wave + (waves_since_fast_intro * added_per_wave)
	var max_fast_by_total := maxi(total_zombies if main.hard_mode_enabled else total_zombies - 1, 0)
	return mini(fast_zombie_count, max_fast_by_total)


func _get_strong_zombies_for_wave(wave: int, total_zombies: int) -> int:
	var start_wave := HARD_MODE_STRONG_ZOMBIE_START_WAVE if main.hard_mode_enabled else strong_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_strong_intro := wave - start_wave
	var strong_zombie_count := max_strong_zombies_on_start_wave + (waves_since_strong_intro * strong_zombies_added_per_wave)
	var max_strong_by_total := maxi(total_zombies - 2, 0)
	return mini(strong_zombie_count, max_strong_by_total)


func _get_atomic_zombies_for_wave(wave: int, normal_like_zombies: int) -> int:
	if wave < atomic_zombie_start_wave:
		return 0

	var waves_since_atomic_intro := wave - atomic_zombie_start_wave
	var atomic_zombie_count := max_atomic_zombies_on_start_wave + (waves_since_atomic_intro * atomic_zombies_added_per_wave)
	return mini(atomic_zombie_count, normal_like_zombies)


func _get_miner_zombies_for_wave(wave: int) -> int:
	var start_wave := HARD_MODE_MINER_ZOMBIE_START_WAVE if main.hard_mode_enabled else miner_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_miner_intro := wave - start_wave
	return max_miner_zombies_on_start_wave + (waves_since_miner_intro * miner_zombies_added_per_wave)


func _get_total_zombies_for_wave(wave: int) -> int:
	var total_zombies := base_zombies_per_wave + (wave - 1) * zombies_added_per_wave
	if not _is_late_wave_softened(wave):
		return total_zombies

	var softened_total := total_zombies - _get_late_wave_zombie_reduction(wave)
	return maxi(softened_total, minimum_normal_zombies_after_wave_ten + 2)


func _get_spawn_interval_for_wave() -> float:
	var spawn_interval := maxf(
		base_spawn_interval - (current_wave - 1) * spawn_interval_reduction_per_wave,
		min_spawn_interval
	)
	if _is_late_wave_softened(current_wave):
		spawn_interval += _get_late_wave_spawn_interval_bonus(current_wave)
	if _should_spawn_michael_jackson(current_wave):
		spawn_interval += michael_jackson_spawn_interval_bonus
	return spawn_interval


func _get_spawn_position_for_scene(zombie_scene: PackedScene) -> Vector2:
	if zombie_scene == FAST_ZOMBIE_SCENE:
		return _get_random_spawn_position_inside_area()
	return _get_edge_spawn_position()


func _should_spawn_michael_jackson(wave: int) -> bool:
	if wave < michael_jackson_start_wave:
		return false
	if michael_jackson_wave_interval <= 0:
		return false
	return wave % michael_jackson_wave_interval == 0


func _spawn_michael_jackson_zombie() -> void:
	var zombie := MICHAEL_JACKSON_ZOMBIE_SCENE.instantiate()
	var base_health := int(zombie.get("max_health"))
	zombie.set("max_health", _get_michael_jackson_health_for_wave(current_wave, base_health))
	zombie.global_position = _get_spawn_position_for_scene(MICHAEL_JACKSON_ZOMBIE_SCENE)
	_apply_hard_mode_to_zombie(zombie)
	_register_zombie(zombie)
	if zombie.has_signal("died"):
		zombie.died.connect(_on_michael_jackson_died)
	main.add_child(zombie)


func _apply_hard_mode_to_zombie(zombie: Node) -> void:
	if not main.hard_mode_enabled or zombie == null:
		return
	if not _node_has_property(zombie, "move_speed"):
		return

	var base_speed := float(zombie.get("move_speed"))
	zombie.set("move_speed", base_speed * HARD_MODE_ZOMBIE_SPEED_MULTIPLIER)


func _node_has_property(node: Object, property_name: String) -> bool:
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _get_michael_jackson_health_for_wave(wave: int, base_health: int) -> int:
	if michael_jackson_wave_interval <= 0 or wave <= michael_jackson_start_wave:
		return base_health

	var previous_appearances := int((wave - michael_jackson_start_wave) / michael_jackson_wave_interval)
	return base_health + previous_appearances * MICHAEL_JACKSON_HEALTH_ADDED_PER_RETURN


func _register_zombie(zombie: Node) -> void:
	if zombie == null or not zombie.has_signal("died"):
		return

	zombie.died.connect(_on_spawned_zombie_died.bind(zombie))
	AchievementManager.register_zombie_discovery(zombie)


func _on_spawned_zombie_died(zombie: Node) -> void:
	if (
		main.player_dead
		or not is_instance_valid(zombie)
		or not (zombie is Node2D)
	):
		return

	var drop_position := (zombie as Node2D).global_position
	AchievementManager.register_zombie_kill(zombie)

	_spawn_single_power_up_drop(drop_position)


func _spawn_single_power_up_drop(drop_position: Vector2) -> void:
	var drop_options: Array[Dictionary] = []
	_append_drop_option(drop_options, MEDKIT_POWER_UP_SCENE, medkit_drop_start_wave, medkit_drop_chance)
	_append_drop_option(drop_options, GRENADE_POWER_UP_SCENE, grenade_drop_start_wave, grenade_drop_chance)
	_append_drop_option(drop_options, HOMING_BULLETS_POWER_UP_SCENE, homing_bullets_drop_start_wave, homing_bullets_drop_chance)
	_append_drop_option(drop_options, MINE_POWER_UP_SCENE, mine_drop_start_wave, mine_drop_chance)
	_append_drop_option(drop_options, TELEPORT_ORB_POWER_UP_SCENE, teleport_orb_drop_start_wave, teleport_orb_drop_chance)
	_append_drop_option(drop_options, ANTI_COOLDOWN_POWER_UP_SCENE, anti_cooldown_drop_start_wave, anti_cooldown_drop_chance)
	_append_drop_option(drop_options, TRIPLE_BULLET_POWER_UP_SCENE, triple_bullet_drop_start_wave, triple_bullet_drop_chance)
	_append_drop_option(drop_options, TIME_FREEZE_POWER_UP_SCENE, time_freeze_drop_start_wave, time_freeze_drop_chance)

	if drop_options.is_empty():
		return

	var total_weight := 0.0
	for option in drop_options:
		total_weight += float(option.get("weight", 0.0))

	if total_weight <= 0.0 or randf() >= minf(total_weight, 1.0):
		return

	var roll := randf() * total_weight
	for option in drop_options:
		roll -= float(option.get("weight", 0.0))
		if roll > 0.0:
			continue

		var power_up_scene := option.get("scene", null) as PackedScene
		if power_up_scene != null:
			var power_up := power_up_scene.instantiate()
			power_up.global_position = drop_position
			main.add_child(power_up)
		return


func _append_drop_option(drop_options: Array[Dictionary], scene: PackedScene, start_wave: int, chance: float) -> void:
	var effective_chance := chance * _get_power_up_drop_chance_multiplier()
	if scene == null or current_wave < start_wave or effective_chance <= 0.0:
		return

	drop_options.append({
		"scene": scene,
		"weight": effective_chance,
	})


func _get_power_up_drop_chance_multiplier() -> float:
	return HARD_MODE_POWER_UP_DROP_MULTIPLIER if main.hard_mode_enabled else 1.0


func _ensure_minimum_normal_zombies() -> void:
	if current_wave <= 10:
		return
	if normal_zombies_left_to_spawn >= minimum_normal_zombies_after_wave_ten:
		return

	var missing_normals := minimum_normal_zombies_after_wave_ten - normal_zombies_left_to_spawn
	normal_zombies_left_to_spawn += missing_normals
	zombies_left_to_spawn += missing_normals


func _is_late_wave_softened(wave: int) -> bool:
	return wave >= LATE_WAVE_SOFTEN_START


func _get_late_wave_zombie_reduction(wave: int) -> int:
	if not _is_late_wave_softened(wave):
		return 0

	var waves_since_softening := wave - LATE_WAVE_SOFTEN_START
	return LATE_WAVE_ZOMBIES_REMOVED_ON_START + int(
		floor(float(waves_since_softening) / float(LATE_WAVE_ZOMBIE_REDUCTION_STEP))
	)


func _get_late_wave_spawn_interval_bonus(wave: int) -> float:
	if not _is_late_wave_softened(wave):
		return 0.0

	var waves_since_softening := wave - LATE_WAVE_SOFTEN_START
	return minf(
		LATE_WAVE_EXTRA_SPAWN_INTERVAL + (float(waves_since_softening) * LATE_WAVE_EXTRA_SPAWN_INTERVAL_PER_WAVE),
		LATE_WAVE_MAX_EXTRA_SPAWN_INTERVAL
	)


func _apply_late_wave_special_cap(wave: int, count: int, total_zombies: int, ratio_cap: float) -> int:
	if not _is_late_wave_softened(wave):
		return count

	var capped_count := int(floor(float(total_zombies) * ratio_cap))
	return mini(count, maxi(capped_count, 0))


func _get_edge_spawn_position() -> Vector2:
	var player_position: Vector2 = main.player.global_position if is_instance_valid(main.player) else Vector2.ZERO

	for _attempt in range(32):
		var candidate := _get_random_edge_position()
		if _is_valid_zombie_spawn_position(candidate, player_position):
			return candidate

	for _attempt in range(32):
		var candidate := _get_random_edge_position()
		if not _is_near_battle_loot_container(candidate):
			return candidate

	return _get_fallback_spawn_position_away_from_container()


func _get_random_spawn_position_inside_area() -> Vector2:
	var player_position: Vector2 = main.player.global_position if is_instance_valid(main.player) else Vector2.ZERO
	var left: float = main.spawn_area.position.x + edge_margin
	var right: float = main.spawn_area.end.x - edge_margin
	var top: float = main.spawn_area.position.y + edge_margin
	var bottom: float = main.spawn_area.end.y - edge_margin

	for _attempt in range(32):
		var candidate := Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		if _is_valid_zombie_spawn_position(candidate, player_position):
			return candidate

	for _attempt in range(32):
		var candidate := Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		if not _is_near_battle_loot_container(candidate):
			return candidate

	return _get_fallback_spawn_position_away_from_container()


func _is_valid_zombie_spawn_position(candidate: Vector2, player_position: Vector2) -> bool:
	return (
		candidate.distance_to(player_position) >= min_spawn_distance_from_player
		and not _is_near_battle_loot_container(candidate)
	)


func _is_near_battle_loot_container(candidate: Vector2) -> bool:
	var exclusion_rect := Rect2(
		main.BATTLE_LOOT_CONTAINER_POSITION - main.BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE * 0.5,
		main.BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE
	)
	return exclusion_rect.has_point(candidate)


func _get_fallback_spawn_position_away_from_container() -> Vector2:
	return main.spawn_area.position + Vector2.ONE * edge_margin


func _get_random_edge_position() -> Vector2:
	var left: float = main.spawn_area.position.x + edge_margin
	var right: float = main.spawn_area.end.x - edge_margin
	var top: float = main.spawn_area.position.y + edge_margin
	var bottom: float = main.spawn_area.end.y - edge_margin
	var edge := randi_range(0, 3)

	match edge:
		0:
			return Vector2(randf_range(left, right), top)
		1:
			return Vector2(randf_range(left, right), bottom)
		2:
			return Vector2(left, randf_range(top, bottom))
		_:
			return Vector2(right, randf_range(top, bottom))


func _get_alive_zombie_count() -> int:
	return get_tree().get_nodes_in_group("zombies").size()


func _on_michael_jackson_died() -> void:
	AchievementManager.unlock(AchievementManager.ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON)
	main._update_fog_effect_for_wave()

	if not wave_active:
		return

	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	spawn_timer = 0.0

	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if zombie_node.has_method("die"):
			zombie_node.die()


func get_wave_settings_text() -> String:
	var lines: Array[String] = []
	lines.append("# Edit these values and press Apply")
	lines.append("# Format: key=value")
	for key_variant in WAVE_SETTING_ORDER:
		var key := String(key_variant)
		lines.append("%s=%s" % [key, str(get(key))])
	return "\n".join(lines)


func apply_wave_settings_text(settings_text: String) -> Dictionary:
	var parsed_values := {}
	var line_number := 0

	for raw_line in settings_text.split("\n"):
		line_number += 1
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var separator_index := line.find("=")
		if separator_index == -1:
			return {"ok": false, "error": "Invalid line %d" % line_number}

		var key := line.substr(0, separator_index).strip_edges()
		var value_text := line.substr(separator_index + 1).strip_edges()
		if not WAVE_SETTING_TYPES.has(key):
			return {"ok": false, "error": "Unknown key: %s" % key}
		if value_text.is_empty():
			return {"ok": false, "error": "Empty value for %s" % key}

		var value_type: int = WAVE_SETTING_TYPES[key]
		if value_type == TYPE_INT:
			if not value_text.is_valid_int() and not value_text.is_valid_float():
				return {"ok": false, "error": "Invalid value for %s" % key}
			parsed_values[key] = maxi(int(round(value_text.to_float())), 0)
		elif value_type == TYPE_FLOAT:
			if not value_text.is_valid_float() and not value_text.is_valid_int():
				return {"ok": false, "error": "Invalid value for %s" % key}
			parsed_values[key] = maxf(value_text.to_float(), 0.0)

	for key_variant in WAVE_SETTING_ORDER:
		var key := String(key_variant)
		if parsed_values.has(key):
			set(key, parsed_values[key])

	if not wave_active:
		if current_wave == 0:
			wave_timer = first_wave_delay
		else:
			wave_timer = minf(wave_timer, time_between_waves)
		main._update_wave_label()

	return {"ok": true}

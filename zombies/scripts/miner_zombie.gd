extends Zombie

## Miner zombie: burrows underground, relocates near the player, then surfaces


@export var burrow_sprite_scale: float = 0.3
@export var burrow_sprite_offset: Vector2 = Vector2(0, 14)
@export var burrow_hidden_duration: float = 2.0
@export var dizzy_duration: float = 3.0
@export var relocation_area: Rect2 = Rect2(-1320, -980, 2640, 1960)
@export var relocation_edge_margin: float = 72.0
@export var min_relocation_distance_from_player: float = 420.0
@export_range(0.0, 1.0, 0.01) var near_player_relocation_chance: float = 0.35
@export_range(0.0, 1.0, 0.01) var below_player_relocation_chance: float = 0.25
@export var near_player_min_distance: float = 90.0
@export var near_player_max_distance: float = 220.0
@export var below_player_min_vertical_offset: float = 160.0
@export var below_player_max_vertical_offset: float = 320.0
@export var below_player_horizontal_offset: float = 120.0
@export_range(0.0, 1.0, 0.01) var one_shot_probability: float = 0.5

const BURROW_ANIMATION := &"Enterrarse"
const REAPPEAR_ANIMATION := &"Salir"
const DIZZY_ANIMATION := &"Mareado"
const DEAD_FRAME_SIZE := Vector2(457, 279)
const DIZZY_FRAME_SIZE := Vector2(447, 608)
const DIZZY_FRAME_COUNT := 2
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const BURROW_FRAME_REGIONS := [
	Rect2(0, 0, 437, 608),
	Rect2(437, 0, 437, 608),
	Rect2(874, 0, 437, 608),
	Rect2(1311, 0, 437, 608),
	Rect2(1748, 0, 437, 608),
	Rect2(2185, 0, 438, 608),
]
const DEAD_TEXTURE := preload("res://assets/Zombies/Minero/Die.png")
const DIZZY_TEXTURE := preload("res://assets/Zombies/Minero/Mareado.png")
const BURROW_TEXTURE := preload("res://assets/Zombies/Minero/Enterrarse.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Minero/Spawn.png")

var is_burrowing: bool = false
var is_hidden: bool = false
var is_reappearing: bool = false
var is_dizzy: bool = false
var hidden_timer: float = 0.0
var dizzy_timer: float = 0.0


func _init() -> void:
	sprite_scale = 0.3
	spawn_sprite_scale = 0.24
	dead_sprite_scale = 0.34
	dead_sprite_offset = Vector2(0, 20)
	corpse_duration = 0.95
	spawn_duration = 1.8


func get_zombie_type() -> StringName:
	return TYPE_MINER


func _on_ready() -> void:
	animated_sprite.animation_finished.connect(_on_animated_sprite_animation_finished)
	current_health = 1 if randf() < one_shot_probability else 2
	_disable_interactions()
	animated_sprite.visible = true
	animated_sprite.flip_h = false


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	if is_dead:
		corpse_timer = maxf(corpse_timer - delta, 0.0)
		if corpse_timer == 0.0:
			queue_free()
		return

	if is_hidden:
		hidden_timer = maxf(hidden_timer - delta, 0.0)
		if hidden_timer == 0.0:
			_start_reappear()
		return

	if is_spawning:
		spawn_timer = maxf(spawn_timer - delta, 0.0)
		if animated_sprite.animation != SPAWN_ANIMATION:
			animated_sprite.play(SPAWN_ANIMATION)
			animated_sprite.stop()
		animated_sprite.frame = 0
		_update_visuals()
		if spawn_timer == 0.0:
			_finish_spawn()
		return

	if is_burrowing or is_reappearing:
		_update_visuals()
		return

	if is_dizzy:
		dizzy_timer = maxf(dizzy_timer - delta, 0.0)
		_update_sound_timer(delta)
		if animated_sprite.animation != DIZZY_ANIMATION:
			animated_sprite.play(DIZZY_ANIMATION)
		elif not animated_sprite.is_playing():
			animated_sprite.play()
		if dizzy_timer == 0.0:
			_start_burrow()


func _on_touch_area_body_entered(body: Node) -> void:
	if not _can_harm_player():
		return
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func _can_take_damage() -> bool:
	return not (is_hidden or is_burrowing or is_reappearing)


func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_spawning = false
	is_burrowing = false
	is_hidden = false
	is_reappearing = false
	is_dizzy = false
	corpse_timer = corpse_duration
	remove_from_group("zombies")
	_disable_interactions()
	animated_sprite.visible = true
	animated_sprite.flip_h = false
	animated_sprite.rotation_degrees = 0.0
	emit_signal("died")
	animated_sprite.play(DEAD_ANIMATION)
	animated_sprite.stop()
	animated_sprite.frame = 0
	_update_visuals()


func _update_visuals() -> void:
	var current_scale := sprite_scale
	var current_offset := sprite_offset

	if is_dead:
		current_scale = dead_sprite_scale
		current_offset = dead_sprite_offset
	elif is_spawning:
		current_scale = spawn_sprite_scale
		current_offset += _get_spawn_shake_offset()
	elif is_burrowing or is_reappearing:
		current_scale = burrow_sprite_scale
		current_offset = burrow_sprite_offset

	animated_sprite.scale = Vector2.ONE * current_scale
	animated_sprite.position = current_offset


func _finish_spawn() -> void:
	is_spawning = false
	_start_burrow()


func _start_burrow() -> void:
	if is_dead or is_spawning or is_burrowing or is_hidden or is_reappearing:
		return

	is_dizzy = false
	is_burrowing = true
	dizzy_timer = 0.0
	_disable_interactions()
	animated_sprite.visible = true
	animated_sprite.flip_h = false
	animated_sprite.play(BURROW_ANIMATION)
	_update_visuals()


func _finish_burrow() -> void:
	is_burrowing = false
	is_hidden = true
	hidden_timer = burrow_hidden_duration
	animated_sprite.visible = false


func _start_reappear() -> void:
	is_hidden = false
	is_reappearing = true
	global_position = _get_random_relocation_position()
	animated_sprite.visible = true
	animated_sprite.flip_h = false
	animated_sprite.play(REAPPEAR_ANIMATION)
	_update_visuals()


func _finish_reappear() -> void:
	is_reappearing = false
	is_dizzy = true
	dizzy_timer = dizzy_duration
	zombie_sound_timer = zombie_sound_check_interval
	_enable_interactions()
	animated_sprite.play(DIZZY_ANIMATION)
	_update_visuals()


func _get_random_relocation_position() -> Vector2:
	var player_position := player.global_position if is_instance_valid(player) else Vector2.ZERO
	var left := relocation_area.position.x + relocation_edge_margin
	var right := relocation_area.end.x - relocation_edge_margin
	var top := relocation_area.position.y + relocation_edge_margin
	var bottom := relocation_area.end.y - relocation_edge_margin
	var placement_roll := randf()

	if is_instance_valid(player):
		if placement_roll < below_player_relocation_chance:
			return _get_position_below_player(left, right, top, bottom)
		if placement_roll < below_player_relocation_chance + near_player_relocation_chance:
			return _get_position_near_player(left, right, top, bottom)

	for _attempt in range(12):
		var candidate := Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		if candidate.distance_to(player_position) >= min_relocation_distance_from_player:
			return candidate

	return Vector2(
		randf_range(left, right),
		randf_range(top, bottom)
	)


func _get_position_near_player(left: float, right: float, top: float, bottom: float) -> Vector2:
	var player_position := player.global_position

	for _attempt in range(8):
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(near_player_min_distance, near_player_max_distance)
		var candidate := player_position + Vector2.RIGHT.rotated(angle) * distance
		if candidate.x < left or candidate.x > right or candidate.y < top or candidate.y > bottom:
			continue
		return candidate

	return Vector2(
		clampf(player_position.x, left, right),
		clampf(player_position.y + near_player_min_distance, top, bottom)
	)


func _get_position_below_player(left: float, right: float, top: float, bottom: float) -> Vector2:
	var player_position := player.global_position

	for _attempt in range(8):
		var horizontal_offset := randf_range(-below_player_horizontal_offset, below_player_horizontal_offset)
		var vertical_offset := randf_range(below_player_min_vertical_offset, below_player_max_vertical_offset)
		var candidate := player_position + Vector2(horizontal_offset, vertical_offset)
		if candidate.x < left or candidate.x > right or candidate.y < top or candidate.y > bottom:
			continue
		return candidate

	return Vector2(
		clampf(player_position.x, left, right),
		clampf(player_position.y + below_player_min_vertical_offset, top, bottom)
	)


func _disable_interactions() -> void:
	collision_layer = 0
	collision_mask = 0
	body_collision.disabled = true
	touch_collision.disabled = true
	touch_area.monitoring = false
	touch_area.monitorable = false


func _enable_interactions() -> void:
	collision_layer = 2
	collision_mask = 1
	body_collision.disabled = false
	touch_collision.disabled = false
	touch_area.monitoring = true
	touch_area.monitorable = true


func _can_harm_player() -> bool:
	return is_dizzy and not is_dead and not is_spawning and not is_burrowing and not is_hidden and not is_reappearing


func _on_animated_sprite_animation_finished() -> void:
	if is_dead:
		return
	if is_burrowing and animated_sprite.animation == BURROW_ANIMATION:
		_finish_burrow()
	elif is_reappearing and animated_sprite.animation == REAPPEAR_ANIMATION:
		_finish_reappear()


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_burrow_animation(frames)
	_add_reappear_animation(frames)
	_add_dizzy_animation(frames)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	return frames


static func _add_dizzy_animation(frames: SpriteFrames) -> void:
	frames.add_animation(DIZZY_ANIMATION)
	frames.set_animation_loop(DIZZY_ANIMATION, true)
	frames.set_animation_speed(DIZZY_ANIMATION, 7.0)

	for frame_index in range(DIZZY_FRAME_COUNT):
		var frame_region := Rect2(
			DIZZY_FRAME_SIZE.x * frame_index,
			0,
			DIZZY_FRAME_SIZE.x,
			DIZZY_FRAME_SIZE.y
		)
		frames.add_frame(DIZZY_ANIMATION, _make_atlas_texture(DIZZY_TEXTURE, frame_region))


static func _add_burrow_animation(frames: SpriteFrames) -> void:
	frames.add_animation(BURROW_ANIMATION)
	frames.set_animation_loop(BURROW_ANIMATION, false)
	frames.set_animation_speed(BURROW_ANIMATION, 9.0)

	for frame_region in BURROW_FRAME_REGIONS:
		frames.add_frame(BURROW_ANIMATION, _make_atlas_texture(BURROW_TEXTURE, frame_region))


static func _add_reappear_animation(frames: SpriteFrames) -> void:
	frames.add_animation(REAPPEAR_ANIMATION)
	frames.set_animation_loop(REAPPEAR_ANIMATION, false)
	frames.set_animation_speed(REAPPEAR_ANIMATION, 9.0)

	for frame_index in range(BURROW_FRAME_REGIONS.size() - 1, -1, -1):
		frames.add_frame(
			REAPPEAR_ANIMATION,
			_make_atlas_texture(BURROW_TEXTURE, BURROW_FRAME_REGIONS[frame_index])
		)

extends Zombie

## Atomic zombie: chases the player but stops to spit acid from range.

@export var spit_min_distance: float = 240.0
@export var spit_max_distance: float = 620.0
@export var spit_cooldown: float = 4.0
@export var spit_windup_duration: float = 0.45
@export var spit_origin_offset: float = 42.0

const DEAD_FRAME_SIZE := Vector2(685, 501)
const WALK_FRAME_SIZE := Vector2(447, 608)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const DEAD_TEXTURE := preload("res://assets/Zombies/Atómico/Dead.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Atómico/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Atómico/Andar arriba.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Atómico/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Atómico/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Atómico/Spawn.png")
const ACID_SPIT_SCRIPT := preload("res://scripts/atomic_acid_spit.gd")

var spit_cooldown_timer: float = 0.0
var spit_windup_timer: float = 0.0
var spit_direction: Vector2 = Vector2.DOWN
var spit_target_position: Vector2 = Vector2.ZERO


func _init() -> void:
	move_speed = 105.0


func get_zombie_type() -> StringName:
	return TYPE_ATOMIC


func _process_active(delta: float) -> void:
	spit_cooldown_timer = maxf(spit_cooldown_timer - delta, 0.0)
	var direction := global_position.direction_to(player.global_position)

	if spit_windup_timer > 0.0:
		spit_windup_timer = maxf(spit_windup_timer - delta, 0.0)
		velocity = Vector2.ZERO
		move_and_slide()
		_update_visuals()
		_play_walk_animation(spit_direction)
		if spit_windup_timer == 0.0:
			_spawn_acid_spit()
		return

	var distance_to_player := global_position.distance_to(player.global_position)
	if _can_spit_at_player(distance_to_player):
		_start_spit(direction)
		return

	velocity = direction * move_speed
	move_and_slide()
	_update_visuals()
	_update_animation()


func _can_spit_at_player(distance_to_player: float) -> bool:
	return (
		spit_cooldown_timer == 0.0
		and distance_to_player >= spit_min_distance
		and distance_to_player <= spit_max_distance
	)


func _start_spit(direction: Vector2) -> void:
	spit_direction = direction.normalized()
	if spit_direction == Vector2.ZERO:
		spit_direction = Vector2.DOWN
	spit_target_position = player.global_position
	spit_windup_timer = spit_windup_duration
	spit_cooldown_timer = spit_cooldown
	velocity = Vector2.ZERO
	move_and_slide()
	_update_visuals()
	_play_walk_animation(spit_direction)


func _spawn_acid_spit() -> void:
	var spit := ACID_SPIT_SCRIPT.new()
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	scene_root.add_child(spit)
	spit.setup(
		global_position + spit_direction * spit_origin_offset,
		spit_target_position
	)


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	return frames

class_name Zombie
extends CharacterBody2D

## Shared base for every zombie type.
##
## Holds the common spawn / chase / death / animation / sound state machine and
## the static SpriteFrames builders. Subclasses customise behaviour through the
## virtual hooks below instead of re-implementing the whole flow:
##   _on_ready()             extra setup at the end of _ready()
##   _process_active(delta)  per-frame logic once spawned and alive
##   _on_death()             extra cleanup inside die() (e.g. stop particles)
##   _on_corpse_expired()    runs right before queue_free()
##   _can_take_damage()      gate damage during special states
##   _build_sprite_frames()  build this type's SpriteFrames (cached per type)
##   get_zombie_type()       unique StringName id, also used as the frame cache key
##
## Tunables that differ per subclass are overridden in the subclass _init().

signal died

@export var move_speed: float = 90.0
@export_range(0.1, 2.0, 0.01) var sprite_scale: float = 0.28
@export_range(0.1, 2.0, 0.01) var spawn_sprite_scale: float = 0.2
@export var sprite_offset: Vector2 = Vector2(0, 14)
@export var dead_sprite_scale: float = 0.38
@export var dead_sprite_offset: Vector2 = Vector2(0, 14)
@export var corpse_duration: float = 0.9
@export var spawn_duration: float = 2.0
@export var spawn_shake_distance: float = 12.0
@export var spawn_shake_speed: float = 32.0
@export var max_health: int = 1
@export_range(0.0, 1.0, 0.01) var zombie_sound_chance: float = 0.18
@export var zombie_sound_volume_db: float = 20.0
@export var zombie_sound_check_interval: float = 2.5

## Canonical zombie-type ids returned by get_zombie_type(). Shared so that main.gd
## wave logic and AchievementManager agree on the same StringNames.
const TYPE_NORMAL := &"normal"
const TYPE_FAST := &"fast"
const TYPE_STRONG := &"strong"
const TYPE_MINER := &"miner"
const TYPE_ATOMIC := &"atomic"
const TYPE_MICHAEL_JACKSON := &"michael_jackson"

const DEAD_ANIMATION := &"Dead"
const SPAWN_ANIMATION := &"Spawn"
const WALK_UP_ANIMATION := &"Andar arr"
const WALK_DOWN_ANIMATION := &"Andar abj"
const WALK_LEFT_ANIMATION := &"Andar izq"
const WALK_RIGHT_ANIMATION := &"Andar der"
const ZOMBIE_SOUND := preload("res://assets/Sonido/Efectos/Sonido zombie.mp3")

## Cached SpriteFrames shared by every zombie, keyed by get_zombie_type().
static var _sprite_frames_cache: Dictionary = {}

@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_area: Area2D = $TouchArea
@onready var touch_collision: CollisionShape2D = $TouchArea/CollisionShape2D

var player: Node2D = null
var is_dead: bool = false
var is_spawning: bool = true
var corpse_timer: float = 0.0
var spawn_timer: float = 0.0
var current_health: int = 0
var zombie_sound_player: AudioStreamPlayer2D = null
var zombie_sound_timer: float = 0.0


func _ready() -> void:
	add_to_group("zombies")
	_ensure_sprite_frames()
	_setup_zombie_sound()
	touch_area.body_entered.connect(_on_touch_area_body_entered)
	touch_area.monitoring = false
	animated_sprite.rotation = 0.0
	spawn_timer = spawn_duration
	current_health = max_health
	animated_sprite.play(SPAWN_ANIMATION)
	animated_sprite.stop()
	animated_sprite.frame = 0
	player = get_tree().get_first_node_in_group("player") as Node2D
	zombie_sound_timer = zombie_sound_check_interval
	_on_ready()
	_update_visuals()


func _physics_process(delta: float) -> void:
	if is_dead:
		corpse_timer = maxf(corpse_timer - delta, 0.0)
		velocity = Vector2.ZERO
		if corpse_timer == 0.0:
			_on_corpse_expired()
			queue_free()
		return

	if is_spawning:
		spawn_timer = maxf(spawn_timer - delta, 0.0)
		velocity = Vector2.ZERO
		move_and_slide()
		if animated_sprite.animation != SPAWN_ANIMATION:
			animated_sprite.play(SPAWN_ANIMATION)
			animated_sprite.stop()
		animated_sprite.frame = 0
		_update_visuals()
		if spawn_timer == 0.0:
			_finish_spawn()
		return

	_update_sound_timer(delta)

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			velocity = Vector2.ZERO
			move_and_slide()
			return

	_process_active(delta)


# --- Virtual hooks (override in subclasses) ---------------------------------

## Extra setup run at the end of _ready().
func _on_ready() -> void:
	pass


## Per-frame behaviour once the zombie has spawned and is alive. The base
## implementation chases the player in a straight line.
func _process_active(_delta: float) -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	_update_visuals()
	_update_animation()


## Extra cleanup performed inside die() before the death signal is emitted.
func _on_death() -> void:
	pass


## Runs immediately before queue_free() when the corpse timer expires.
func _on_corpse_expired() -> void:
	pass


## Whether the zombie can currently receive damage (beyond the base
## is_dead / is_spawning checks). Override to block damage during special states.
func _can_take_damage() -> bool:
	return true


## Builds this zombie type's SpriteFrames. Called once per type, then cached.
func _build_sprite_frames() -> SpriteFrames:
	return SpriteFrames.new()


func get_zombie_type() -> StringName:
	return TYPE_NORMAL


func is_strong_zombie() -> bool:
	return false


## Optional damage cap for area-of-effect sources (grenades/mines). Override to
## reduce the damage a single blast deals to this zombie.
func get_explosion_damage_amount(default_damage: int) -> int:
	return default_damage


# --- Shared behaviour -------------------------------------------------------

func _on_touch_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func take_damage(amount: int = 1) -> void:
	if is_dead or is_spawning or not _can_take_damage():
		return

	current_health = maxi(current_health - amount, 0)
	if current_health == 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_spawning = false
	corpse_timer = corpse_duration
	remove_from_group("zombies")
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	body_collision.disabled = true
	touch_collision.disabled = true
	touch_area.monitoring = false
	touch_area.monitorable = false
	_on_death()
	emit_signal("died")
	animated_sprite.play(DEAD_ANIMATION)
	animated_sprite.stop()
	animated_sprite.frame = 0
	animated_sprite.rotation_degrees = 90.0
	_update_visuals()


func _finish_spawn() -> void:
	is_spawning = false
	touch_area.monitoring = true
	_update_visuals()
	_update_animation()


func _update_animation() -> void:
	if is_spawning or is_dead:
		return

	_play_walk_animation(velocity)


func _play_walk_animation(direction: Vector2) -> void:
	var next_animation := _get_walk_animation_name(direction)
	if animated_sprite.animation != next_animation:
		animated_sprite.play(next_animation)
	elif not animated_sprite.is_playing():
		animated_sprite.play()


func _update_visuals() -> void:
	var current_scale := sprite_scale
	var current_offset := sprite_offset

	if is_dead:
		current_scale = dead_sprite_scale
		current_offset = dead_sprite_offset
	elif is_spawning:
		current_scale = spawn_sprite_scale
		current_offset += _get_spawn_shake_offset()

	animated_sprite.scale = Vector2.ONE * current_scale
	animated_sprite.position = current_offset


func _get_walk_animation_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return WALK_RIGHT_ANIMATION if direction.x > 0.0 else WALK_LEFT_ANIMATION
	return WALK_DOWN_ANIMATION if direction.y > 0.0 else WALK_UP_ANIMATION


func _get_spawn_shake_offset() -> Vector2:
	if not is_spawning:
		return Vector2.ZERO

	return _get_shake_offset((spawn_duration - spawn_timer) * spawn_shake_speed)


func _get_shake_offset(shake_phase: float) -> Vector2:
	return Vector2(
		sin(shake_phase * 1.3) * spawn_shake_distance,
		absf(sin(shake_phase * 0.9)) * -spawn_shake_distance * 0.35
	)


func _update_sound_timer(delta: float) -> void:
	zombie_sound_timer = maxf(zombie_sound_timer - delta, 0.0)
	if zombie_sound_timer == 0.0:
		_try_play_zombie_sound()
		zombie_sound_timer = zombie_sound_check_interval


func _setup_zombie_sound() -> void:
	zombie_sound_player = AudioStreamPlayer2D.new()
	zombie_sound_player.stream = ZOMBIE_SOUND
	zombie_sound_player.volume_db = zombie_sound_volume_db
	add_child(zombie_sound_player)


func _try_play_zombie_sound() -> void:
	if zombie_sound_player == null:
		return
	if randf() > zombie_sound_chance:
		return
	zombie_sound_player.play()


func _ensure_sprite_frames() -> void:
	if animated_sprite.sprite_frames != null:
		return

	var type_key := get_zombie_type()
	if not _sprite_frames_cache.has(type_key):
		_sprite_frames_cache[type_key] = _build_sprite_frames()
	animated_sprite.sprite_frames = _sprite_frames_cache[type_key]


# --- Static SpriteFrames builders (shared by every subclass) ----------------

static func _add_strip_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	frame_size: Vector2,
	frame_count: int,
	speed: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, speed)

	for frame_index in range(frame_count):
		var frame_region := Rect2(
			frame_size.x * frame_index,
			0,
			frame_size.x,
			frame_size.y
		)
		frames.add_frame(animation_name, _make_atlas_texture(texture, frame_region))


static func _add_single_frame_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	frame_size: Vector2,
	speed: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, false)
	frames.set_animation_speed(animation_name, speed)
	frames.add_frame(animation_name, _make_atlas_texture(texture, Rect2(Vector2.ZERO, frame_size)))


static func _make_atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = region
	return atlas_texture

extends CharacterBody2D

signal died

@export var move_speed: float = 72.0
@export_range(0.1, 2.0, 0.01) var sprite_scale: float = 0.36
@export_range(0.1, 2.0, 0.01) var spawn_sprite_scale: float = 0.26
@export var sprite_offset: Vector2 = Vector2(0, 18)
@export var dead_sprite_scale: float = 0.46
@export var dead_sprite_offset: Vector2 = Vector2(0, 18)
@export var corpse_duration: float = 1.1
@export var spawn_duration: float = 2.0
@export var spawn_shake_distance: float = 10.0
@export var spawn_shake_speed: float = 28.0
@export var max_health: int = 2
@export_range(0.0, 1.0, 0.01) var zombie_sound_chance: float = 0.18
@export var zombie_sound_volume_db: float = 20.0
@export var zombie_sound_check_interval: float = 2.5

const DEAD_ANIMATION := &"Dead"
const SPAWN_ANIMATION := &"Spawn"
const WALK_UP_ANIMATION := &"Andar arr"
const WALK_DOWN_ANIMATION := &"Andar abj"
const WALK_LEFT_ANIMATION := &"Andar izq"
const WALK_RIGHT_ANIMATION := &"Andar der"
const DEAD_FRAME_SIZE := Vector2(394, 536)
const WALK_FRAME_SIZE := Vector2(447, 708)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const DEAD_TEXTURE := preload("res://assets/Zombies/Fuerte/Dead.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar alante.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Fuerte/Spawn.png")
const ZOMBIE_SOUND := preload("res://assets/Sonido/Efectos/Sonido zombie.mp3")

static var sprite_frames_cache: SpriteFrames

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
	_update_visuals()


func _physics_process(delta: float) -> void:
	if is_dead:
		corpse_timer = maxf(corpse_timer - delta, 0.0)
		velocity = Vector2.ZERO
		if corpse_timer == 0.0:
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

	zombie_sound_timer = maxf(zombie_sound_timer - delta, 0.0)
	if zombie_sound_timer == 0.0:
		_try_play_zombie_sound()
		zombie_sound_timer = zombie_sound_check_interval

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			velocity = Vector2.ZERO
			move_and_slide()
			return

	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	_update_visuals()
	_update_animation()


func _on_touch_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func take_damage(amount: int = 1) -> void:
	if is_dead or is_spawning:
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
	emit_signal("died")
	animated_sprite.play(DEAD_ANIMATION)
	animated_sprite.stop()
	animated_sprite.frame = 0
	animated_sprite.rotation_degrees = 90.0
	_update_visuals()


func is_strong_zombie() -> bool:
	return true


func get_zombie_type() -> StringName:
	return &"strong"


func _update_animation() -> void:
	if is_spawning or is_dead:
		return

	var next_animation := _get_walk_animation_name(velocity)
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

	var shake_phase := (spawn_duration - spawn_timer) * spawn_shake_speed
	return Vector2(
		sin(shake_phase * 1.3) * spawn_shake_distance,
		absf(sin(shake_phase * 0.9)) * -spawn_shake_distance * 0.35
	)


func _finish_spawn() -> void:
	is_spawning = false
	touch_area.monitoring = true
	_update_visuals()
	_update_animation()


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
	if animated_sprite.sprite_frames == null:
		animated_sprite.sprite_frames = _get_sprite_frames()


static func _get_sprite_frames() -> SpriteFrames:
	if sprite_frames_cache != null:
		return sprite_frames_cache

	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, 6.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, 6.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, 6.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, 6.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	sprite_frames_cache = frames
	return sprite_frames_cache


static func _add_strip_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	speed: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, speed)

	for frame_index in range(WALK_FRAME_COUNT):
		var frame_region := Rect2(
			WALK_FRAME_SIZE.x * frame_index,
			0,
			WALK_FRAME_SIZE.x,
			WALK_FRAME_SIZE.y
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

extends CharacterBody2D

signal died

@export var move_speed: float = 135.0
@export_range(0.1, 2.0, 0.01) var sprite_scale: float = 0.28
@export_range(0.1, 2.0, 0.01) var spawn_sprite_scale: float = 0.2
@export var sprite_offset: Vector2 = Vector2(0, 14)
@export var dead_sprite_scale: float = 0.26
@export var dead_sprite_offset: Vector2 = Vector2(0, 14)
@export var max_health: int = 9
@export var corpse_duration: float = 1.1
@export var spawn_duration: float = 2.0
@export var spawn_shake_distance: float = 12.0
@export var spawn_shake_speed: float = 32.0
@export var wander_area: Rect2 = Rect2(-1320, -980, 2640, 1960)
@export var target_reached_distance: float = 36.0
@export var min_idle_time: float = 0.1
@export var max_idle_time: float = 0.35
@export var min_dance_interval: float = 5.0
@export var max_dance_interval: float = 9.0
@export var dance_duration: float = 0.9
@export_range(0.0, 1.0, 0.01) var zombie_sound_chance: float = 0.18
@export var zombie_sound_volume_db: float = 20.0
@export var zombie_sound_check_interval: float = 2.5

const DANCE_ANIMATION := &"Baile"
const SPAWN_ANIMATION := &"Spawn"
const WALK_UP_ANIMATION := &"Andar arr"
const WALK_DOWN_ANIMATION := &"Andar abj"
const WALK_LEFT_ANIMATION := &"Andar izq"
const WALK_RIGHT_ANIMATION := &"Andar der"
const DANCE_FRAME_SIZE := Vector2(457, 608)
const DANCE_FRAME_COUNT := 2
const WALK_FRAME_SIZE := Vector2(447, 608)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const MICHAEL_JACKSON_MUSIC := preload("res://assets/Sonido/Música/Michael Jackson.mp3")
const DANCE_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Baile.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Andar arriba.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Michael Jackson/Spawn.png")
const ZOMBIE_SOUND := preload("res://assets/Sonido/Efectos/Sonido zombie.mp3")

static var sprite_frames_cache: SpriteFrames

@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_area: Area2D = $TouchArea
@onready var touch_collision: CollisionShape2D = $TouchArea/CollisionShape2D

var player: Node2D = null
var is_dead: bool = false
var is_spawning: bool = true
var is_dancing: bool = false
var is_death_spawning: bool = false
var health: int = 0
var corpse_timer: float = 0.0
var spawn_timer: float = 0.0
var dance_timer: float = 0.0
var next_dance_timer: float = 0.0
var idle_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO
var mj_music_player: AudioStreamPlayer = null
var zombie_sound_player: AudioStreamPlayer2D = null
var zombie_sound_timer: float = 0.0
var brightness_registered: bool = false


func _ready() -> void:
	add_to_group("zombies")
	_ensure_sprite_frames()
	_setup_zombie_sound()
	_setup_music_override()
	_apply_brightness_override()
	touch_area.body_entered.connect(_on_touch_area_body_entered)
	touch_area.monitoring = false
	animated_sprite.rotation = 0.0
	health = max_health
	spawn_timer = spawn_duration
	animated_sprite.play(SPAWN_ANIMATION)
	animated_sprite.stop()
	animated_sprite.frame = 0
	player = get_tree().get_first_node_in_group("player") as Node2D
	wander_target = global_position
	next_dance_timer = _get_random_dance_interval()
	zombie_sound_timer = zombie_sound_check_interval
	_update_visuals()


func _physics_process(delta: float) -> void:
	if is_dead:
		corpse_timer = maxf(corpse_timer - delta, 0.0)
		velocity = Vector2.ZERO
		if corpse_timer == 0.0:
			_restore_default_music()
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

	if is_dancing:
		dance_timer = maxf(dance_timer - delta, 0.0)
		velocity = Vector2.ZERO
		if animated_sprite.animation != DANCE_ANIMATION:
			animated_sprite.play(DANCE_ANIMATION)
		elif not animated_sprite.is_playing():
			animated_sprite.play()
		move_and_slide()
		if dance_timer == 0.0:
			_finish_dance()
		_update_visuals()
		return

	next_dance_timer = maxf(next_dance_timer - delta, 0.0)
	if next_dance_timer == 0.0:
		_start_dance()
		_update_visuals()
		return

	idle_timer = maxf(idle_timer - delta, 0.0)
	if idle_timer > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_visuals()
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	var target_position := wander_target
	if is_instance_valid(player):
		target_position = player.global_position
	elif global_position.distance_to(wander_target) <= target_reached_distance:
		_pick_new_wander_target()
		target_position = wander_target

	var direction := global_position.direction_to(target_position)
	velocity = direction * move_speed
	move_and_slide()
	_update_visuals()
	_update_animation()


func _on_touch_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_spawning = false
	is_dancing = false
	is_death_spawning = true
	corpse_timer = corpse_duration
	remove_from_group("zombies")
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	body_collision.disabled = true
	touch_collision.disabled = true
	touch_area.monitoring = false
	touch_area.monitorable = false
	_restore_brightness_override()
	emit_signal("died")
	animated_sprite.play(SPAWN_ANIMATION)
	animated_sprite.rotation_degrees = 0.0
	_update_visuals()


func take_damage(amount: int = 1) -> void:
	if is_dead or is_spawning:
		return

	health = maxi(health - amount, 0)
	if health == 0:
		die()


func get_explosion_damage_amount(_default_damage: int) -> int:
	return 2


func get_zombie_type() -> StringName:
	return &"michael_jackson"


func _update_animation() -> void:
	if is_spawning or is_dead or is_dancing:
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
		if is_death_spawning:
			current_scale = spawn_sprite_scale
			current_offset += _get_death_spawn_shake_offset()
		else:
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


func _get_death_spawn_shake_offset() -> Vector2:
	if not is_death_spawning:
		return Vector2.ZERO

	return _get_shake_offset((corpse_duration - corpse_timer) * spawn_shake_speed)


func _get_shake_offset(shake_phase: float) -> Vector2:
	return Vector2(
		sin(shake_phase * 1.3) * spawn_shake_distance,
		absf(sin(shake_phase * 0.9)) * -spawn_shake_distance * 0.35
	)


func _finish_spawn() -> void:
	is_spawning = false
	touch_area.monitoring = true
	_pick_new_wander_target()
	_update_visuals()
	_update_animation()


func _start_dance() -> void:
	is_dancing = true
	dance_timer = dance_duration
	velocity = Vector2.ZERO
	animated_sprite.play(DANCE_ANIMATION)


func _finish_dance() -> void:
	is_dancing = false
	next_dance_timer = _get_random_dance_interval()
	_pick_new_wander_target()
	_update_animation()


func _pick_new_wander_target() -> void:
	wander_target = Vector2(
		randf_range(wander_area.position.x, wander_area.end.x),
		randf_range(wander_area.position.y, wander_area.end.y)
	)
	idle_timer = randf_range(min_idle_time, max_idle_time)


func _get_random_dance_interval() -> float:
	return randf_range(min_dance_interval, max_dance_interval)


func _setup_zombie_sound() -> void:
	zombie_sound_player = AudioStreamPlayer2D.new()
	zombie_sound_player.stream = ZOMBIE_SOUND
	zombie_sound_player.volume_db = zombie_sound_volume_db
	add_child(zombie_sound_player)


func _setup_music_override() -> void:
	mj_music_player = AudioStreamPlayer.new()
	mj_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	mj_music_player.bus = &"Master"
	mj_music_player.stream = MICHAEL_JACKSON_MUSIC
	if mj_music_player.stream is AudioStreamMP3:
		mj_music_player.stream.loop = true
	add_child(mj_music_player)
	_stop_current_music_players()
	mj_music_player.play()


func _stop_current_music_players() -> void:
	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	for node_name in [&"GameMusic", &"MenuMusic", &"DeathSound"]:
		var direct_player := root.get_node_or_null(NodePath(node_name)) as AudioStreamPlayer
		if direct_player != null and direct_player.playing:
			direct_player.stop()

	for node in root.find_children("*", "AudioStreamPlayer", true, false):
		var player_instance := node as AudioStreamPlayer
		if player_instance == null or player_instance == mj_music_player:
			continue
		if player_instance.playing:
			player_instance.stop()


func _restore_default_music() -> void:
	if mj_music_player != null and mj_music_player.playing:
		mj_music_player.stop()

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	var menu_layer := root.get_node_or_null("Menu") as CanvasLayer
	if menu_layer != null and menu_layer.visible:
		return

	if root.has_method("restore_music_after_priority_audio"):
		root.restore_music_after_priority_audio()
		return

	var game_music := root.get_node_or_null("GameMusic") as AudioStreamPlayer
	if game_music != null and not game_music.playing:
		if game_music.stream is AudioStreamMP3:
			game_music.stream.loop = true
		elif game_music.stream is AudioStreamWAV:
			game_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		game_music.play()


func _exit_tree() -> void:
	_restore_brightness_override()


func _apply_brightness_override() -> void:
	if brightness_registered:
		return

	brightness_registered = true
	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	if root.has_method("apply_michael_jackson_brightness_override"):
		root.call("apply_michael_jackson_brightness_override")


func _restore_brightness_override() -> void:
	if not brightness_registered:
		return

	brightness_registered = false
	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	if root.has_method("restore_michael_jackson_brightness_override"):
		root.call("restore_michael_jackson_brightness_override")


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
	_add_custom_strip_animation(frames, DANCE_ANIMATION, DANCE_TEXTURE, DANCE_FRAME_SIZE, DANCE_FRAME_COUNT, 6.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, 7.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, 7.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, 7.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, 7.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	sprite_frames_cache = frames
	return sprite_frames_cache


static func _add_custom_strip_animation(
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

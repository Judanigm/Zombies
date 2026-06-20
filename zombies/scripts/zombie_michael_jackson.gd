extends Zombie

## Michael Jackson boss zombie: wanders and periodically dances, hijacks the
## soundtrack and dims the scene while alive, and takes many hits to kill.

@export var wander_area: Rect2 = Rect2(-1320, -980, 2640, 1960)
@export var target_reached_distance: float = 36.0
@export var min_idle_time: float = 0.1
@export var max_idle_time: float = 0.35
@export var min_dance_interval: float = 5.0
@export var max_dance_interval: float = 9.0
@export var dance_duration: float = 0.9

const DANCE_ANIMATION := &"Baile"
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

var is_dancing: bool = false
var is_death_spawning: bool = false
var dance_timer: float = 0.0
var next_dance_timer: float = 0.0
var idle_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO
var mj_music_player: AudioStreamPlayer = null
var brightness_registered: bool = false


func _init() -> void:
	move_speed = 135.0
	dead_sprite_scale = 0.26
	corpse_duration = 1.1
	max_health = 9


func get_zombie_type() -> StringName:
	return TYPE_MICHAEL_JACKSON


func get_explosion_damage_amount(_default_damage: int) -> int:
	return 2


func _on_ready() -> void:
	_setup_music_override()
	_apply_brightness_override()
	wander_target = global_position
	next_dance_timer = _get_random_dance_interval()


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

	_update_sound_timer(delta)

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


func _update_animation() -> void:
	if is_spawning or is_dead or is_dancing:
		return

	_play_walk_animation(velocity)


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


func _get_death_spawn_shake_offset() -> Vector2:
	if not is_death_spawning:
		return Vector2.ZERO

	return _get_shake_offset((corpse_duration - corpse_timer) * spawn_shake_speed)


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


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_strip_animation(frames, DANCE_ANIMATION, DANCE_TEXTURE, DANCE_FRAME_SIZE, DANCE_FRAME_COUNT, 6.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	return frames

class_name AtmosphereController
extends Node

## Wave fog, environment brightness, drifting hard-fog particles and the music
## state machine (game / fog / base / menu), extracted from main.gd.
##
## main.gd creates this as a child, sets `main`, and calls setup() once the spawn
## area is known. The fog/music nodes are parented under main (not this node) so
## their z-ordering and transforms are identical to before. It reaches back into
## main for shared state (current_wave, is_in_base_zone, player_dead, hard mode,
## the time-freeze controller, menu visibility) and for the GameMusic node.

const FOG_TEXTURE := preload("res://assets/Texto/Particulas de niebla.png")
const HARD_FOG_TEXTURE := preload("res://assets/Texto/Particulas de niebla duras.png")
const FOG_MUSIC_STREAM := preload("res://assets/Sonido/Música/Niebla.mp3")
const BASE_MUSIC_STREAM := preload("res://assets/Sonido/Música/Musica de la expalnada de la base.mp3")
const FOG_START_WAVE := 15
const FOG_WAVE_PERIOD := 20
const FOG_WAVE_DURATION := 10
const FOG_BRIGHTNESS := Color(0.72, 0.72, 0.72, 1.0)
const MICHAEL_JACKSON_BRIGHTNESS := Color(0.72, 0.72, 0.72, 1.0)
const HARD_MODE_FOG_START_WAVE := 10
const HARD_FOG_MIN_COUNT := 5
const HARD_FOG_MAX_COUNT := 6
const HARD_FOG_EXTRA_PER_PERIOD := 1
const HARD_FOG_MAX_TOTAL_COUNT := 14
const HARD_FOG_ALPHA := 0.58
const HARD_FOG_DRIFT_DISTANCE := 34.0
const HARD_FOG_MIN_DRIFT_SPEED := 0.18
const HARD_FOG_MAX_DRIFT_SPEED := 0.34

var main: Node = null

var fog_overlay: Sprite2D = null
var fog_brightness_modulate: CanvasModulate = null
var fog_music: AudioStreamPlayer = null
var base_music: AudioStreamPlayer = null
var hard_fog_particles: Array[Dictionary] = []
var hard_fog_time: float = 0.0
var hard_fog_period_start: int = -1


func setup() -> void:
	fog_overlay = Sprite2D.new()
	fog_overlay.name = "WaveFogOverlay"
	fog_overlay.texture = FOG_TEXTURE
	fog_overlay.centered = true
	fog_overlay.z_index = 900
	fog_overlay.visible = false
	fog_overlay.modulate = Color(1.0, 1.0, 1.0, 0.48)
	var fog_area: Rect2 = main.spawn_area.grow(160.0)
	fog_overlay.position = fog_area.get_center()
	if FOG_TEXTURE != null and FOG_TEXTURE.get_width() > 0 and FOG_TEXTURE.get_height() > 0:
		var fog_scale := maxf(
			fog_area.size.x / float(FOG_TEXTURE.get_width()),
			fog_area.size.y / float(FOG_TEXTURE.get_height())
		)
		fog_overlay.scale = Vector2.ONE * fog_scale * 1.08
	main.add_child(fog_overlay)

	fog_brightness_modulate = CanvasModulate.new()
	fog_brightness_modulate.name = "WaveFogBrightness"
	fog_brightness_modulate.color = Color.WHITE
	main.add_child(fog_brightness_modulate)

	fog_music = AudioStreamPlayer.new()
	fog_music.name = "FogMusic"
	fog_music.process_mode = Node.PROCESS_MODE_ALWAYS
	fog_music.bus = &"Master"
	fog_music.stream = FOG_MUSIC_STREAM
	fog_music.volume_db = -8.0
	if fog_music.stream is AudioStreamMP3:
		fog_music.stream.loop = true
	elif fog_music.stream is AudioStreamWAV:
		fog_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	main.add_child(fog_music)

	base_music = AudioStreamPlayer.new()
	base_music.name = "BaseMusic"
	base_music.process_mode = Node.PROCESS_MODE_ALWAYS
	base_music.bus = &"Master"
	base_music.stream = BASE_MUSIC_STREAM
	base_music.volume_db = -8.0
	if base_music.stream is AudioStreamMP3:
		base_music.stream.loop = true
	elif base_music.stream is AudioStreamWAV:
		base_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	main.add_child(base_music)


func update_for_wave() -> void:
	if main.is_in_base_zone:
		if is_instance_valid(fog_overlay):
			fog_overlay.hide()
		if is_instance_valid(fog_brightness_modulate):
			fog_brightness_modulate.color = Color.WHITE
		set_hard_fog_particles_visible(false)
		_update_fog_music_for_state(false)
		return

	var fog_active := _should_show_fog_for_wave(main.wave_director.current_wave)
	if is_instance_valid(fog_overlay):
		fog_overlay.visible = fog_active
	_update_environment_brightness(fog_active)
	_update_fog_music_for_state(fog_active)
	if fog_active:
		var period_start := _get_fog_period_start_wave(main.wave_director.current_wave)
		if hard_fog_period_start != period_start or hard_fog_particles.is_empty():
			_spawn_hard_fog_particles(period_start)
		else:
			set_hard_fog_particles_visible(true)
	else:
		_clear_hard_fog_particles()
		hard_fog_period_start = -1


func restore_music_after_priority_audio() -> void:
	_update_fog_music_for_state(false if main.is_in_base_zone else _should_show_fog_for_wave(main.wave_director.current_wave))


func get_music_players() -> Array[AudioStreamPlayer]:
	var music_players: Array[AudioStreamPlayer] = []
	for node_name in [&"GameMusic", &"MenuMusic"]:
		var player_node := main.get_node_or_null(NodePath(node_name)) as AudioStreamPlayer
		if player_node != null:
			music_players.append(player_node)

	if is_instance_valid(fog_music):
		music_players.append(fog_music)
	if is_instance_valid(base_music):
		music_players.append(base_music)

	return music_players


func _update_environment_brightness(fog_active: bool) -> void:
	if not is_instance_valid(fog_brightness_modulate):
		return

	if _has_active_michael_jackson():
		fog_brightness_modulate.color = MICHAEL_JACKSON_BRIGHTNESS
		return

	fog_brightness_modulate.color = FOG_BRIGHTNESS if fog_active else Color.WHITE


func _should_show_fog_for_wave(wave: int) -> bool:
	if main.hard_mode_enabled:
		return wave >= HARD_MODE_FOG_START_WAVE

	if wave < FOG_START_WAVE or FOG_WAVE_PERIOD <= 0:
		return false

	var waves_since_start := wave - FOG_START_WAVE
	return waves_since_start % FOG_WAVE_PERIOD < FOG_WAVE_DURATION


func _update_fog_music_for_state(fog_active: bool) -> void:
	var game_music := main.get_node_or_null("GameMusic") as AudioStreamPlayer

	if main.time_freeze.is_active():
		main.time_freeze.pause_music()
		return

	if main._is_menu_visible() or main.player_dead:
		_stop_audio_player(fog_music)
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		return
	if _has_active_michael_jackson():
		_stop_audio_player(fog_music)
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		return

	if main.is_in_base_zone:
		_stop_audio_player(fog_music)
		_stop_audio_player(game_music)
		_play_audio_player(base_music)
		return

	if fog_active:
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		_play_audio_player(fog_music)
		return

	_stop_audio_player(fog_music)
	_stop_audio_player(base_music)
	_play_audio_player(game_music)


func _has_active_michael_jackson() -> bool:
	for zombie_node in main.get_tree().get_nodes_in_group("zombies"):
		if zombie_node == null:
			continue
		if zombie_node.has_method("get_zombie_type") and StringName(zombie_node.call("get_zombie_type")) == Zombie.TYPE_MICHAEL_JACKSON:
			return true
	return false


func _play_audio_player(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	if not player.playing:
		player.play()


func _stop_audio_player(player: AudioStreamPlayer) -> void:
	if player != null and player.playing:
		player.stop()


func _get_fog_period_start_wave(wave: int) -> int:
	if not _should_show_fog_for_wave(wave):
		return -1

	var completed_periods := int((wave - FOG_START_WAVE) / FOG_WAVE_PERIOD)
	return FOG_START_WAVE + completed_periods * FOG_WAVE_PERIOD


func _spawn_hard_fog_particles(period_start: int) -> void:
	_clear_hard_fog_particles()
	hard_fog_period_start = period_start
	hard_fog_time = 0.0

	var particle_count := _get_hard_fog_particle_count(period_start)
	var fog_area: Rect2 = main.spawn_area.grow(160.0)
	var hard_fog_target_size := fog_area.size / 3.0
	var hard_fog_center_area := Rect2(
		fog_area.position + hard_fog_target_size * 0.5,
		fog_area.size - hard_fog_target_size
	)
	for index in range(particle_count):
		var particle := Sprite2D.new()
		particle.name = "HardFogParticle%d" % (index + 1)
		particle.texture = HARD_FOG_TEXTURE
		particle.centered = true
		particle.z_index = 920
		particle.modulate = Color(1.0, 1.0, 1.0, HARD_FOG_ALPHA)
		particle.position = main._get_random_point_in_rect(hard_fog_center_area)
		particle.rotation = randf_range(-0.18, 0.18)
		if HARD_FOG_TEXTURE != null and HARD_FOG_TEXTURE.get_width() > 0 and HARD_FOG_TEXTURE.get_height() > 0:
			var particle_scale := maxf(
				hard_fog_target_size.x / float(HARD_FOG_TEXTURE.get_width()),
				hard_fog_target_size.y / float(HARD_FOG_TEXTURE.get_height())
			)
			particle.scale = Vector2.ONE * particle_scale

		main.add_child(particle)
		hard_fog_particles.append({
			"sprite": particle,
			"base_position": particle.position,
			"phase": randf() * TAU,
			"speed": randf_range(HARD_FOG_MIN_DRIFT_SPEED, HARD_FOG_MAX_DRIFT_SPEED),
			"drift": randf_range(HARD_FOG_DRIFT_DISTANCE * 0.65, HARD_FOG_DRIFT_DISTANCE),
		})


func _get_hard_fog_particle_count(period_start: int) -> int:
	var completed_periods := maxi(int((period_start - FOG_START_WAVE) / FOG_WAVE_PERIOD), 0)
	var extra_particles := completed_periods * HARD_FOG_EXTRA_PER_PERIOD
	var min_count := mini(HARD_FOG_MIN_COUNT + extra_particles, HARD_FOG_MAX_TOTAL_COUNT)
	var max_count := mini(HARD_FOG_MAX_COUNT + extra_particles, HARD_FOG_MAX_TOTAL_COUNT)
	return randi_range(min_count, max_count)


func set_hard_fog_particles_visible(particles_visible: bool) -> void:
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if is_instance_valid(sprite):
			sprite.visible = particles_visible


func _clear_hard_fog_particles() -> void:
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if is_instance_valid(sprite):
			sprite.queue_free()
	hard_fog_particles.clear()


func update_hard_fog_particles(delta: float) -> void:
	if hard_fog_particles.is_empty():
		return

	hard_fog_time += delta
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if not is_instance_valid(sprite) or not sprite.visible:
			continue

		var base_position: Vector2 = particle_data.get("base_position", Vector2.ZERO)
		var phase := float(particle_data.get("phase", 0.0))
		var speed := float(particle_data.get("speed", 0.0))
		var drift := float(particle_data.get("drift", HARD_FOG_DRIFT_DISTANCE))
		var movement_time := hard_fog_time * speed
		sprite.position = base_position + Vector2(
			cos(movement_time + phase),
			sin(movement_time * 0.8 + phase)
		) * drift

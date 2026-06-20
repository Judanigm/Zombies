class_name TimeFreezeController
extends Node

## Time-freeze power-up logic, extracted from main.gd.
##
## Pauses every zombie and time-freezable object (process, physics, animations,
## particles, audio) plus the music for the duration, then restores their captured
## state. main.gd creates this as a child, sets `main`, and drives it from _process.
## It reaches back into main for shared state (player_dead / is_in_base_zone), the
## music players, and the fog music state machine (restore_music_after_priority_audio).

var main: Node = null

var time_freeze_timer: float = 0.0
var time_frozen_zombie_states: Dictionary = {}
var time_frozen_object_states: Dictionary = {}
var time_frozen_music_states: Array[Dictionary] = []


func activate(duration: float = 10.0) -> void:
	if main.player_dead or main.is_in_base_zone or duration <= 0.0:
		return

	time_freeze_timer = maxf(time_freeze_timer, duration)
	pause_music()
	_freeze_current_zombies()
	_freeze_current_time_freezable_objects()


func update(delta: float) -> void:
	if not is_active():
		return

	if main.player_dead or main.is_in_base_zone:
		_end()
		return

	_freeze_current_time_freezable_objects()
	time_freeze_timer = maxf(time_freeze_timer - delta, 0.0)
	if time_freeze_timer == 0.0:
		_end()


func is_active() -> bool:
	return time_freeze_timer > 0.0


func _freeze_current_zombies() -> void:
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie_node):
			continue

		var zombie_id := zombie_node.get_instance_id()
		if not time_frozen_zombie_states.has(zombie_id):
			time_frozen_zombie_states[zombie_id] = _capture_state(zombie_node)

		zombie_node.set_process(false)
		zombie_node.set_physics_process(false)
		_pause_visuals(zombie_node)


func _freeze_current_time_freezable_objects() -> void:
	for object_node in get_tree().get_nodes_in_group("time_freezable_objects"):
		if not is_instance_valid(object_node) or object_node.is_in_group("player"):
			continue

		var object_id := object_node.get_instance_id()
		if not time_frozen_object_states.has(object_id):
			time_frozen_object_states[object_id] = _capture_state(object_node)

		object_node.set_process(false)
		object_node.set_physics_process(false)
		_pause_visuals(object_node)


func _capture_state(zombie_node: Node) -> Dictionary:
	var animated_sprites: Array[Dictionary] = []
	for child in zombie_node.find_children("*", "AnimatedSprite2D", true, false):
		var animated_sprite := child as AnimatedSprite2D
		if animated_sprite == null:
			continue

		animated_sprites.append({
			"node": animated_sprite,
			"was_playing": animated_sprite.is_playing(),
		})

	var particles: Array[Dictionary] = []
	for child in zombie_node.find_children("*", "GPUParticles2D", true, false):
		var particle_node := child as GPUParticles2D
		if particle_node == null:
			continue

		particles.append({
			"node": particle_node,
			"was_emitting": particle_node.emitting,
		})

	var audio_players: Array[Dictionary] = []
	for audio_2d_child in zombie_node.find_children("*", "AudioStreamPlayer2D", true, false):
		var audio_player_2d := audio_2d_child as AudioStreamPlayer2D
		if audio_player_2d == null:
			continue

		audio_players.append({
			"node": audio_player_2d,
			"was_playing": audio_player_2d.playing,
		})

	for audio_child in zombie_node.find_children("*", "AudioStreamPlayer", true, false):
		var audio_player := audio_child as AudioStreamPlayer
		if audio_player == null:
			continue

		audio_players.append({
			"node": audio_player,
			"was_playing": audio_player.playing,
		})

	return {
		"node": zombie_node,
		"was_processing": zombie_node.is_processing(),
		"was_physics_processing": zombie_node.is_physics_processing(),
		"animated_sprites": animated_sprites,
		"particles": particles,
		"audio_players": audio_players,
	}


func _pause_visuals(zombie_node: Node) -> void:
	for child in zombie_node.find_children("*", "AnimatedSprite2D", true, false):
		var animated_sprite := child as AnimatedSprite2D
		if animated_sprite != null:
			animated_sprite.stop()

	for child in zombie_node.find_children("*", "GPUParticles2D", true, false):
		var particle_node := child as GPUParticles2D
		if particle_node != null:
			particle_node.emitting = false

	for audio_2d_child in zombie_node.find_children("*", "AudioStreamPlayer2D", true, false):
		var audio_player_2d := audio_2d_child as AudioStreamPlayer2D
		if audio_player_2d != null and audio_player_2d.playing:
			audio_player_2d.stream_paused = true

	for audio_child in zombie_node.find_children("*", "AudioStreamPlayer", true, false):
		var audio_player := audio_child as AudioStreamPlayer
		if audio_player != null and audio_player.playing:
			audio_player.stream_paused = true


func _end() -> void:
	time_freeze_timer = 0.0
	_resume_zombies()
	_resume_music()


func _resume_zombies() -> void:
	for state_variant in time_frozen_zombie_states.values():
		var state := state_variant as Dictionary
		var zombie_node_variant = state.get("node", null)
		if not is_instance_valid(zombie_node_variant):
			continue
		var zombie_node := zombie_node_variant as Node

		if not main.is_in_base_zone:
			zombie_node.set_process(true)
			zombie_node.set_physics_process(true)

		if zombie_node.is_in_group("zombies"):
			for sprite_state_variant in state.get("animated_sprites", []):
				var sprite_state := sprite_state_variant as Dictionary
				var animated_sprite_variant = sprite_state.get("node", null)
				if not is_instance_valid(animated_sprite_variant):
					continue
				var animated_sprite := animated_sprite_variant as AnimatedSprite2D
				if animated_sprite != null and bool(sprite_state.get("was_playing", false)):
					animated_sprite.play()

			for particle_state_variant in state.get("particles", []):
				var particle_state := particle_state_variant as Dictionary
				var particle_node_variant = particle_state.get("node", null)
				if not is_instance_valid(particle_node_variant):
					continue
				var particle_node := particle_node_variant as GPUParticles2D
				if particle_node != null:
					particle_node.emitting = bool(particle_state.get("was_emitting", false))

			for audio_state_variant in state.get("audio_players", []):
				var audio_state := audio_state_variant as Dictionary
				var audio_player_variant = audio_state.get("node", null)
				if not is_instance_valid(audio_player_variant):
					continue
				var audio_player := audio_player_variant as Node
				if audio_player != null and bool(audio_state.get("was_playing", false)):
					audio_player.set("stream_paused", false)

	time_frozen_zombie_states.clear()
	_resume_objects()


func _resume_objects() -> void:
	for state_variant in time_frozen_object_states.values():
		var state := state_variant as Dictionary
		var object_node_variant = state.get("node", null)
		if not is_instance_valid(object_node_variant):
			continue
		var object_node := object_node_variant as Node

		object_node.set_process(bool(state.get("was_processing", true)))
		object_node.set_physics_process(bool(state.get("was_physics_processing", true)))

		for sprite_state_variant in state.get("animated_sprites", []):
			var sprite_state := sprite_state_variant as Dictionary
			var animated_sprite_variant = sprite_state.get("node", null)
			if not is_instance_valid(animated_sprite_variant):
				continue
			var animated_sprite := animated_sprite_variant as AnimatedSprite2D
			if animated_sprite != null and bool(sprite_state.get("was_playing", false)):
				animated_sprite.play()

		for particle_state_variant in state.get("particles", []):
			var particle_state := particle_state_variant as Dictionary
			var particle_node_variant = particle_state.get("node", null)
			if not is_instance_valid(particle_node_variant):
				continue
			var particle_node := particle_node_variant as GPUParticles2D
			if particle_node != null:
				particle_node.emitting = bool(particle_state.get("was_emitting", false))

		for audio_state_variant in state.get("audio_players", []):
			var audio_state := audio_state_variant as Dictionary
			var audio_player_variant = audio_state.get("node", null)
			if not is_instance_valid(audio_player_variant):
				continue
			var audio_player := audio_player_variant as Node
			if audio_player != null and bool(audio_state.get("was_playing", false)):
				audio_player.set("stream_paused", false)

	time_frozen_object_states.clear()


func pause_music() -> void:
	for music_player in _get_music_players():
		if not is_instance_valid(music_player) or not music_player.playing:
			continue

		var already_tracked := false
		for state in time_frozen_music_states:
			var tracked_player = state.get("node", null)
			if is_instance_valid(tracked_player) and tracked_player == music_player:
				already_tracked = true
				break

		if not already_tracked:
			time_frozen_music_states.append({
				"node": music_player,
				"was_playing": true,
			})

		music_player.stream_paused = true


func _resume_music() -> void:
	for state in time_frozen_music_states:
		var music_player_variant = state.get("node", null)
		if not is_instance_valid(music_player_variant):
			continue

		var music_player := music_player_variant as AudioStreamPlayer
		if music_player != null and bool(state.get("was_playing", false)):
			music_player.stream_paused = false

	time_frozen_music_states.clear()
	main.restore_music_after_priority_audio()


func _get_music_players() -> Array[AudioStreamPlayer]:
	return main.atmosphere.get_music_players()

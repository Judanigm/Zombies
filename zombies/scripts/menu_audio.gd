class_name MenuAudio
extends Node

## Menu music, button-touch SFX, death sound and controller rumble, extracted
## from menu.gd. menu.gd creates this as a child, sets `menu`, and calls setup()
## then drives it with the semantic play_*/stop_* methods. The shared DeathSound /
## MenuMusic / GameMusic players live under the main scene (siblings of the Menu
## node) and are resolved from there; the achievements music and button sound are
## created here.

const GAME_MUSIC_STREAM := preload("res://assets/Sonido/Música/en el juego.mp3")
const ACHIEVEMENTS_MUSIC_STREAM := preload("res://assets/Sonido/Música/Música de pantalla de logros.mp3")
const BUTTON_TOUCH_SOUND_STREAM := preload("res://assets/Sonido/Música/Sonido tocar botón.mp3")
const DEATH_RUMBLE_WEAK := 0.65
const DEATH_RUMBLE_STRONG := 1.0

var menu: Node = null

var death_sound: AudioStreamPlayer = null
var menu_music: AudioStreamPlayer = null
var game_music: AudioStreamPlayer = null
var achievements_music: AudioStreamPlayer = null
var button_touch_sound: AudioStreamPlayer = null
var paused_music_players: Array[AudioStreamPlayer] = []


func setup() -> void:
	death_sound = menu.get_node_or_null("../DeathSound") as AudioStreamPlayer
	menu_music = menu.get_node_or_null("../MenuMusic") as AudioStreamPlayer
	game_music = menu.get_node_or_null("../GameMusic") as AudioStreamPlayer
	if death_sound != null:
		death_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	if menu_music != null:
		menu_music.process_mode = Node.PROCESS_MODE_ALWAYS
	if game_music != null:
		game_music.process_mode = Node.PROCESS_MODE_ALWAYS
		game_music.stream = GAME_MUSIC_STREAM

	achievements_music = AudioStreamPlayer.new()
	achievements_music.name = "AchievementsMusic"
	achievements_music.process_mode = Node.PROCESS_MODE_ALWAYS
	achievements_music.bus = &"Master"
	achievements_music.stream = ACHIEVEMENTS_MUSIC_STREAM
	add_child(achievements_music)

	button_touch_sound = AudioStreamPlayer.new()
	button_touch_sound.name = "ButtonTouchSound"
	button_touch_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	button_touch_sound.bus = &"Master"
	button_touch_sound.stream = BUTTON_TOUCH_SOUND_STREAM
	add_child(button_touch_sound)

	_enable_music_loop(menu_music)
	_enable_music_loop(game_music)
	_enable_music_loop(achievements_music)


func connect_button_touch_sounds() -> void:
	for node in menu.find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		var play_sound := Callable(self, "_play_button_touch_sound")
		if not button.button_down.is_connected(play_sound):
			button.button_down.connect(play_sound)


func play_menu_music() -> void:
	_play_player(menu_music)


func stop_menu_music() -> void:
	_stop_player(menu_music)


func play_achievements_music() -> void:
	_play_player(achievements_music)


func stop_achievements_music() -> void:
	_stop_player(achievements_music)


func stop_game_music() -> void:
	_stop_player(game_music)


func play_death_sound() -> void:
	_play_player(death_sound)


func clear_paused_music() -> void:
	paused_music_players.clear()


func stop_gameplay_music() -> void:
	_stop_player(game_music)

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	var fog_music := root.get_node_or_null("FogMusic") as AudioStreamPlayer
	_stop_player(fog_music)

	var base_music := root.get_node_or_null("BaseMusic") as AudioStreamPlayer
	_stop_player(base_music)


func pause_active_music() -> void:
	paused_music_players.clear()

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	for node in root.find_children("*", "AudioStreamPlayer", true, false):
		var player := node as AudioStreamPlayer
		if player == null or player == death_sound or not player.playing:
			continue
		paused_music_players.append(player)
		player.stop()


func resume_paused_music() -> void:
	var resumed_any := false

	for player in paused_music_players:
		if not is_instance_valid(player):
			continue
		if player == death_sound or player.stream == null:
			continue
		if not player.playing:
			player.play()
			resumed_any = true

	paused_music_players.clear()

	if not resumed_any:
		_play_player(game_music)


func stop_active_scene_audio() -> void:
	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	for node in root.find_children("*", "AudioStreamPlayer", true, false):
		var player := node as AudioStreamPlayer
		if player == null or player == death_sound:
			continue
		if player.playing:
			player.stop()

	for node in root.find_children("*", "AudioStreamPlayer2D", true, false):
		var player_2d := node as AudioStreamPlayer2D
		if player_2d != null and player_2d.playing:
			player_2d.stop()


func play_death_rumble() -> void:
	if death_sound == null or death_sound.stream == null:
		return

	var duration := death_sound.stream.get_length()
	if duration <= 0.0:
		return

	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, DEATH_RUMBLE_WEAK, DEATH_RUMBLE_STRONG, duration)


func stop_death_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)


func _play_button_touch_sound() -> void:
	if button_touch_sound == null or button_touch_sound.stream == null:
		return
	if button_touch_sound.playing:
		button_touch_sound.stop()
	button_touch_sound.play()


func _play_player(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	if not player.playing:
		player.play()


func _stop_player(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	if player.playing:
		player.stop()


func _enable_music_loop(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	if player.stream is AudioStreamMP3:
		player.stream.loop = true
	elif player.stream is AudioStreamWAV:
		player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

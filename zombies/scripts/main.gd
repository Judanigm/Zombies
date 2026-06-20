extends Node2D

const LOOT_CONTAINER_SCRIPT := preload("res://scripts/loot_container.gd")
const LOOT_MINECART_SCRIPT := preload("res://scripts/loot_minecart.gd")
const ACHIEVEMENT_NOTIFICATION_SOUND := preload("res://assets/Sonido/Efectos/Xbox sonido logro inusual [VFQ27MdSyFU].mp3")
const ACHIEVEMENT_NOTIFICATION_TARGET_HEIGHT := 400.0
const ACHIEVEMENT_NOTIFICATION_MARGIN := 20.0
const ACHIEVEMENT_NOTIFICATION_HIDDEN_OFFSET := 24.0
const ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION := 0.34
const ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION := 0.28
const ACHIEVEMENT_NOTIFICATION_VISIBLE_TIME := 9.0
const ACHIEVEMENT_NOTIFICATION_FALLBACK_WIDTH := 420.0
const ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE := Vector2(140, 112)
const ACHIEVEMENT_NOTIFICATION_HEADING_HEIGHT := 30.0
const ACHIEVEMENT_NOTIFICATION_TITLE_HEIGHT := 38.0
const ACHIEVEMENT_NOTIFICATION_TITLE_MAX_CHARS := 15
const ACHIEVEMENT_NOTIFICATION_DESCRIPTION_MAX_CHARS := 24
const ACHIEVEMENT_NOTIFICATION_LETTER_SPACING := -18.0
const BATTLE_LOOT_CONTAINER_POSITION := Vector2(950, -840)
const BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE := Vector2(1120, 1120)
const BATTLE_LOOT_MINECART_POSITION := Vector2(0, -1120)
const BATTLE_LOOT_MINECART_MIN_SPAWN_TIME := 18.0
const BATTLE_LOOT_MINECART_MAX_SPAWN_TIME := 36.0

@export var spawn_area: Rect2 = Rect2(-1320, -980, 2640, 1960)
@export var teleport_minimum_distance_from_zombies: float = 320.0
@export var teleport_minimum_travel_distance: float = 220.0
@export var teleport_search_attempts: int = 30
@export var teleport_wall_padding: float = 96.0

@onready var player: Node2D = $Player
@onready var menu: CanvasLayer = $Menu
@onready var player_camera: Camera2D = $Player/Camera2D

var base_zone: BaseZoneController = null
var atmosphere: AtmosphereController = null
var hud: HudController = null
var wave_director: WaveDirector = null
var achievement_feedback_enabled: bool = false
var achievement_notification_queue: Array[StringName] = []
var achievement_notification_active: bool = false
var achievement_notification_logo: Control = null
var achievement_notification_sound_player: AudioStreamPlayer = null
var achievement_notification_tween: Tween = null

var player_dead: bool = false
var hard_mode_enabled: bool = false
var is_in_base_zone: bool = false
var return_from_base_position: Vector2 = Vector2.ZERO
var battle_camera_limit_left: int = 0
var battle_camera_limit_top: int = 0
var battle_camera_limit_right: int = 0
var battle_camera_limit_bottom: int = 0
var loot_minecart_spawn_timer: float = 0.0
var time_freeze: TimeFreezeController = null


func _init() -> void:
	# Created in _init (not _ready) so they are never null: child nodes such as the
	# menu run _ready before this node and can reach back into the music code.
	time_freeze = TimeFreezeController.new()
	time_freeze.name = "TimeFreezeController"
	time_freeze.main = self
	atmosphere = AtmosphereController.new()
	atmosphere.name = "AtmosphereController"
	atmosphere.main = self
	hud = HudController.new()
	hud.name = "HudController"
	hud.main = self
	base_zone = BaseZoneController.new()
	base_zone.name = "BaseZoneController"
	base_zone.main = self
	wave_director = WaveDirector.new()
	wave_director.name = "WaveDirector"
	wave_director.main = self


func _ready() -> void:
	randomize()
	add_child(time_freeze)
	add_child(atmosphere)
	add_child(hud)
	add_child(base_zone)
	add_child(wave_director)
	_reset_loot_minecart_spawn_timer()
	_cache_battle_camera_limits()
	_setup_battle_loot_container()
	atmosphere.setup()
	hud.setup()
	base_zone.setup()
	_setup_expedition_ui()
	_setup_achievement_feedback()
	AchievementManager.achievement_unlocked.connect(_queue_achievement_feedback)
	LootEconomy.base_loot_changed.connect(base_zone.update_loot_display)
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	if player.has_signal("selected_power_up_changed"):
		player.selected_power_up_changed.connect(hud.set_selected_power_up)
	if player.has_signal("stamina_changed"):
		player.stamina_changed.connect(hud.update_stamina_bar)
	if player.has_signal("medkit_count_changed"):
		player.medkit_count_changed.connect(hud.update_medkit_icon)
	if player.has_signal("grenade_count_changed"):
		player.grenade_count_changed.connect(hud.update_grenade_icon)
	if player.has_signal("mine_count_changed"):
		player.mine_count_changed.connect(hud.update_mine_icon)
	if player.has_signal("teleport_orb_count_changed"):
		player.teleport_orb_count_changed.connect(hud.update_teleport_orb_icon)
	if player.has_method("get_medkit_count"):
		hud.update_medkit_icon(player.get_medkit_count())
	if player.has_method("get_grenade_count"):
		hud.update_grenade_icon(player.get_grenade_count())
	if player.has_method("get_mine_count"):
		hud.update_mine_icon(player.get_mine_count())
	if player.has_method("get_teleport_orb_count"):
		hud.update_teleport_orb_icon(player.get_teleport_orb_count())
	if player.has_method("get_stamina") and player.has_method("get_max_stamina"):
		hud.update_stamina_bar(float(player.call("get_stamina")), float(player.call("get_max_stamina")))
	hud.update_selected_power_up_ui()
	wave_director.wave_timer = wave_director.first_wave_delay
	_update_wave_label()
	_update_fog_effect_for_wave()
	_update_base_travel_ui()
	achievement_feedback_enabled = true


func set_hard_mode_enabled(enabled: bool) -> void:
	hard_mode_enabled = enabled
	_update_fog_effect_for_wave()


func is_hard_mode_enabled() -> bool:
	return hard_mode_enabled


# --- Achievement delegators (model lives in the AchievementManager autoload) ---

func unlock_achievement(achievement_id: StringName) -> bool:
	return AchievementManager.unlock(achievement_id)


func get_achievements_text() -> String:
	return AchievementManager.get_achievements_text()


func get_achievements_data() -> Array[Dictionary]:
	return AchievementManager.get_achievements_data()


func get_wave_record() -> int:
	return AchievementManager.get_wave_record()


# --- Wave delegators (logic lives in the WaveDirector child node) ---

func skip_to_wave(target_wave: int) -> void:
	wave_director.skip_to_wave(target_wave)


func get_wave_settings_text() -> String:
	return wave_director.get_wave_settings_text()


func apply_wave_settings_text(settings_text: String) -> Dictionary:
	return wave_director.apply_wave_settings_text(settings_text)


func go_to_base() -> void:
	if player_dead or is_in_base_zone or not is_instance_valid(player):
		return

	return_from_base_position = player.global_position
	is_in_base_zone = true
	_set_zombies_paused_for_base(true)
	_move_player_to(base_zone.BASE_ZONE_ORIGIN + base_zone.BASE_ZONE_PLAYER_SPAWN_OFFSET)
	_set_camera_limits_to_rect(Rect2(base_zone.BASE_ZONE_ORIGIN - base_zone.BASE_ZONE_SIZE * 0.5, base_zone.BASE_ZONE_SIZE))
	base_zone.show_zone()
	hud.set_wave_display_visible(false)
	_update_fog_effect_for_wave()
	base_zone.update_loot_display()
	_update_base_travel_ui()
	_update_expedition_ui()


func return_from_base() -> void:
	if player_dead or not is_in_base_zone or not is_instance_valid(player):
		return

	base_zone.cancel_build_preview()
	is_in_base_zone = false
	_move_player_to(return_from_base_position)
	_restore_battle_camera_limits()
	_set_zombies_paused_for_base(false)
	base_zone.hide_zone()
	_update_wave_label()
	_update_fog_effect_for_wave()
	_update_base_travel_ui()
	_update_expedition_ui()


func return_from_base_to_menu() -> void:
	if player_dead:
		return

	if is_in_base_zone:
		return_from_base()

	if is_instance_valid(menu) and menu.has_method("show_main_menu"):
		menu.call("show_main_menu")


func toggle_base_zone() -> void:
	if is_in_base_zone:
		return_from_base_to_menu()
	else:
		go_to_base()


func is_player_in_base_zone() -> bool:
	return is_in_base_zone


func register_grenade_stock(grenade_count: int) -> void:
	AchievementManager.register_grenade_stock(grenade_count)


func register_grenade_strong_zombie_kills(kill_count: int) -> void:
	AchievementManager.register_grenade_strong_zombie_kills(kill_count)


func check_active_mine_achievement() -> void:
	AchievementManager.check_active_mine_achievement()


func clear_achievements() -> void:
	AchievementManager.clear()


# --- Loot economy delegators (model lives in the LootEconomy autoload) ---

func save_base_loot() -> void:
	LootEconomy.save_base_loot()


func _process(delta: float) -> void:
	atmosphere.update_hard_fog_particles(delta)
	_update_base_travel_ui()
	_update_expedition_ui()
	time_freeze.update(delta)

	if time_freeze.is_active():
		return

	if player_dead:
		return

	if is_in_base_zone:
		return

	if not _is_menu_visible():
		_update_loot_minecart_spawn(delta)

	wave_director.tick(delta)


func _cache_battle_camera_limits() -> void:
	if not is_instance_valid(player_camera):
		return

	battle_camera_limit_left = player_camera.limit_left
	battle_camera_limit_top = player_camera.limit_top
	battle_camera_limit_right = player_camera.limit_right
	battle_camera_limit_bottom = player_camera.limit_bottom


func _setup_battle_loot_container() -> void:
	if get_node_or_null("BattleLootContainer") != null:
		return

	var container := StaticBody2D.new()
	container.name = "BattleLootContainer"
	container.set_script(LOOT_CONTAINER_SCRIPT)
	container.global_position = BATTLE_LOOT_CONTAINER_POSITION
	add_child(container)


func _setup_expedition_ui() -> void:
	_update_expedition_ui()


func _update_loot_minecart_spawn(delta: float) -> void:
	if get_node_or_null("BattleLootMinecart") != null:
		return

	loot_minecart_spawn_timer = maxf(loot_minecart_spawn_timer - delta, 0.0)
	if loot_minecart_spawn_timer > 0.0:
		return

	_spawn_loot_minecart()


func _spawn_loot_minecart() -> void:
	if get_node_or_null("BattleLootMinecart") != null:
		return

	var minecart := StaticBody2D.new()
	minecart.name = "BattleLootMinecart"
	minecart.set_script(LOOT_MINECART_SCRIPT)
	minecart.global_position = BATTLE_LOOT_MINECART_POSITION
	minecart.tree_exited.connect(_reset_loot_minecart_spawn_timer)
	add_child(minecart)


func _reset_loot_minecart_spawn_timer() -> void:
	loot_minecart_spawn_timer = randf_range(
		BATTLE_LOOT_MINECART_MIN_SPAWN_TIME,
		BATTLE_LOOT_MINECART_MAX_SPAWN_TIME
	)


func register_collected_loot(loot_id: StringName) -> void:
	if player_dead or is_in_base_zone:
		return

	LootEconomy.add_expedition_loot(loot_id)


func _clear_expedition_loot() -> void:
	LootEconomy.clear_expedition()
	wave_director.extraction_requested = false
	wave_director.extraction_wave_active = false
	_clear_collectible_loot_nodes()
	_update_expedition_ui()


func _clear_collectible_loot_nodes() -> void:
	for loot_node in get_tree().get_nodes_in_group("collectible_loot"):
		if is_instance_valid(loot_node):
			loot_node.queue_free()


func _update_expedition_ui() -> void:
	pass


func _move_player_to(target_position: Vector2) -> void:
	player.global_position = target_position
	var player_body := player as CharacterBody2D
	if player_body != null:
		player_body.velocity = Vector2.ZERO


func _set_camera_limits_to_rect(rect: Rect2) -> void:
	if not is_instance_valid(player_camera):
		return

	player_camera.limit_left = floori(rect.position.x)
	player_camera.limit_top = floori(rect.position.y)
	player_camera.limit_right = ceili(rect.end.x)
	player_camera.limit_bottom = ceili(rect.end.y)
	player_camera.reset_smoothing()


func _restore_battle_camera_limits() -> void:
	if not is_instance_valid(player_camera):
		return

	player_camera.limit_left = battle_camera_limit_left
	player_camera.limit_top = battle_camera_limit_top
	player_camera.limit_right = battle_camera_limit_right
	player_camera.limit_bottom = battle_camera_limit_bottom
	player_camera.reset_smoothing()


func _set_zombies_paused_for_base(paused: bool) -> void:
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie_node):
			continue

		zombie_node.set_process(not paused and not time_freeze.is_active())
		zombie_node.set_physics_process(not paused and not time_freeze.is_active())


func activate_time_freeze(duration: float = 10.0) -> void:
	time_freeze.activate(duration)


func get_safe_teleport_position(from_position: Vector2) -> Vector2:
	if is_in_base_zone:
		return _get_safe_base_teleport_position(from_position)

	var zombie_positions := _get_alive_zombie_positions()
	var candidate_positions := _get_teleport_candidate_positions(from_position, zombie_positions)
	var best_position := from_position
	var best_score := -INF

	for candidate in candidate_positions:
		if not _is_valid_teleport_position(candidate):
			continue

		var nearest_zombie_distance := _get_nearest_zombie_distance(candidate, zombie_positions)
		var travel_distance := candidate.distance_to(from_position)
		if travel_distance < teleport_minimum_travel_distance:
			nearest_zombie_distance -= (teleport_minimum_travel_distance - travel_distance) * 0.6

		var candidate_score := nearest_zombie_distance + travel_distance * 0.35
		if nearest_zombie_distance >= teleport_minimum_distance_from_zombies:
			candidate_score += 1000.0

		if candidate_score > best_score:
			best_score = candidate_score
			best_position = candidate

	return best_position


func _get_safe_base_teleport_position(from_position: Vector2) -> Vector2:
	var base_rect := Rect2(
		base_zone.BASE_ZONE_ORIGIN - base_zone.BASE_ZONE_SIZE * 0.5 + Vector2.ONE * base_zone.BASE_ZONE_WALL_THICKNESS,
		base_zone.BASE_ZONE_SIZE - Vector2.ONE * base_zone.BASE_ZONE_WALL_THICKNESS * 2.0
	)
	var best_position := from_position
	var best_distance := 0.0

	for _attempt in range(teleport_search_attempts):
		var candidate := _get_random_point_in_rect(base_rect)
		if not _is_valid_teleport_position(candidate):
			continue

		var travel_distance := candidate.distance_to(from_position)
		if travel_distance > best_distance:
			best_distance = travel_distance
			best_position = candidate

	return best_position


func _get_alive_zombie_positions() -> Array[Vector2]:
	var zombie_positions: Array[Vector2] = []
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if zombie_node is Node2D:
			zombie_positions.append((zombie_node as Node2D).global_position)
	return zombie_positions


func _get_teleport_candidate_positions(
	from_position: Vector2,
	zombie_positions: Array[Vector2]
) -> Array[Vector2]:
	var teleport_rect := _get_teleport_rect()
	var candidate_positions: Array[Vector2] = []
	var rect_center := teleport_rect.get_center()
	var nearest_zombie_position := _get_nearest_zombie_position(from_position, zombie_positions)

	candidate_positions.append(rect_center)
	candidate_positions.append(Vector2(teleport_rect.position.x, teleport_rect.position.y))
	candidate_positions.append(Vector2(teleport_rect.end.x, teleport_rect.position.y))
	candidate_positions.append(Vector2(teleport_rect.position.x, teleport_rect.end.y))
	candidate_positions.append(Vector2(teleport_rect.end.x, teleport_rect.end.y))

	if nearest_zombie_position != Vector2.INF:
		var away_direction := nearest_zombie_position.direction_to(from_position)
		if away_direction == Vector2.ZERO:
			away_direction = Vector2.RIGHT.rotated(randf() * TAU)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction * teleport_minimum_travel_distance,
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction * (teleport_minimum_travel_distance * 1.8),
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction.rotated(0.7) * (teleport_minimum_travel_distance * 1.4),
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction.rotated(-0.7) * (teleport_minimum_travel_distance * 1.4),
				teleport_rect
			)
		)

	for _attempt in range(teleport_search_attempts):
		candidate_positions.append(_get_random_point_in_rect(teleport_rect))

	return candidate_positions


func _get_nearest_zombie_position(from_position: Vector2, zombie_positions: Array[Vector2]) -> Vector2:
	var nearest_position := Vector2.INF
	var nearest_distance := INF

	for zombie_position in zombie_positions:
		var distance := from_position.distance_to(zombie_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_position = zombie_position

	return nearest_position


func _get_nearest_zombie_distance(from_position: Vector2, zombie_positions: Array[Vector2]) -> float:
	if zombie_positions.is_empty():
		return teleport_minimum_distance_from_zombies + from_position.distance_to(player.global_position)

	var nearest_distance := INF
	for zombie_position in zombie_positions:
		nearest_distance = minf(nearest_distance, from_position.distance_to(zombie_position))
	return nearest_distance


func _get_teleport_rect() -> Rect2:
	var rect_position := spawn_area.position + Vector2.ONE * teleport_wall_padding
	var rect_size := spawn_area.size - Vector2.ONE * teleport_wall_padding * 2.0
	return Rect2(rect_position, rect_size)


func _get_random_point_in_rect(rect: Rect2) -> Vector2:
	return Vector2(
		randf_range(rect.position.x, rect.end.x),
		randf_range(rect.position.y, rect.end.y)
	)


func _clamp_to_teleport_rect(point: Vector2, rect: Rect2) -> Vector2:
	return Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)


func _is_valid_teleport_position(position: Vector2) -> bool:
	if not is_instance_valid(player):
		return true

	var player_body := player as PhysicsBody2D
	if player_body == null:
		return true

	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return true

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(0.0, position + collision_shape.position)
	query.collision_mask = player_body.collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [player_body.get_rid()]

	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _update_wave_label() -> void:
	hud.update_wave_label()


func _update_base_travel_ui() -> void:
	base_zone.update_travel_ui()


func _on_player_died() -> void:
	player_dead = true
	_clear_expedition_loot()
	base_zone.cancel_build_preview()
	is_in_base_zone = false
	_restore_battle_camera_limits()
	_set_zombies_paused_for_base(false)
	base_zone.hide_zone()
	wave_director.reset_for_death()
	_update_base_travel_ui()
	hud.hide_for_game_over()
	if is_instance_valid(menu) and menu.has_method("show_game_over"):
		menu.show_game_over()


func _update_fog_effect_for_wave() -> void:
	atmosphere.update_for_wave()


func restore_music_after_priority_audio() -> void:
	atmosphere.restore_music_after_priority_audio()


func apply_michael_jackson_brightness_override() -> void:
	atmosphere.update_for_wave()


func restore_michael_jackson_brightness_override() -> void:
	atmosphere.update_for_wave()


func _is_menu_visible() -> bool:
	return is_instance_valid(menu) and menu.visible


func _setup_achievement_feedback() -> void:
	achievement_notification_sound_player = AudioStreamPlayer.new()
	achievement_notification_sound_player.name = "AchievementNotificationSound"
	achievement_notification_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	achievement_notification_sound_player.stream = ACHIEVEMENT_NOTIFICATION_SOUND
	add_child(achievement_notification_sound_player)

	var notification := PanelContainer.new()
	notification.name = "AchievementNotification"
	notification.process_mode = Node.PROCESS_MODE_ALWAYS
	notification.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notification.z_index = 100
	notification.visible = false
	notification.modulate = Color(1.0, 1.0, 1.0, 0.0)
	notification.size = _get_achievement_notification_size()
	notification.add_theme_stylebox_override("panel", _create_notification_stylebox())

	var margin := MarginContainer.new()
	margin.name = "NotificationMargin"
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notification.add_child(margin)

	var content := HBoxContainer.new()
	content.name = "Content"
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(content)

	var image := TextureRect.new()
	image.name = "Image"
	image.custom_minimum_size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	image.size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(image)

	var text_content := VBoxContainer.new()
	text_content.name = "TextContent"
	text_content.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_content.add_theme_constant_override("separation", 4)
	content.add_child(text_content)

	var heading := VBoxContainer.new()
	heading.name = "Heading"
	heading.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.add_child(heading)

	var title := VBoxContainer.new()
	title.name = "Title"
	title.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.add_child(title)

	achievement_notification_logo = notification
	achievement_notification_logo.position = _get_achievement_notification_hidden_position(achievement_notification_logo.size)
	$CanvasLayer.add_child(achievement_notification_logo)


func _queue_achievement_feedback(achievement_id: StringName) -> void:
	if not achievement_feedback_enabled:
		return

	achievement_notification_queue.append(achievement_id)
	if achievement_notification_active:
		return

	_show_next_achievement_notification()


func _create_notification_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.86, 0.72, 0.42, 0.96)
	stylebox.border_color = Color(0.20, 0.09, 0.04, 0.95)
	stylebox.set_border_width_all(5)
	stylebox.set_corner_radius_all(10)
	stylebox.shadow_color = Color(0, 0, 0, 0.35)
	stylebox.shadow_size = 8
	return stylebox


func _show_next_achievement_notification() -> void:
	if achievement_notification_queue.is_empty() or not is_instance_valid(achievement_notification_logo):
		return

	var achievement_id: StringName = StringName(achievement_notification_queue.pop_front())
	var achievement_data := _get_achievement_definition(achievement_id)
	achievement_notification_active = true
	_populate_achievement_notification(achievement_data)
	achievement_notification_logo.size = _get_achievement_notification_size()
	var hidden_position := _get_achievement_notification_hidden_position(achievement_notification_logo.size)
	var visible_position := _get_achievement_notification_visible_position(achievement_notification_logo.size)
	achievement_notification_logo.position = hidden_position
	achievement_notification_logo.modulate = Color(1.0, 1.0, 1.0, 0.0)
	achievement_notification_logo.visible = true
	_play_achievement_notification_sound()

	if achievement_notification_tween != null:
		achievement_notification_tween.kill()

	achievement_notification_tween = achievement_notification_logo.create_tween()
	achievement_notification_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"position",
		visible_position,
		ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION
	)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"modulate:a",
		1.0,
		ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION
	)
	achievement_notification_tween.tween_interval(_get_achievement_notification_visible_time())
	achievement_notification_tween.tween_callback(_start_achievement_notification_exit.bind(hidden_position))


func _start_achievement_notification_exit(hidden_position: Vector2) -> void:
	if not is_instance_valid(achievement_notification_logo):
		_on_achievement_notification_finished()
		return

	if achievement_notification_tween != null:
		achievement_notification_tween.kill()

	achievement_notification_tween = achievement_notification_logo.create_tween()
	achievement_notification_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"position",
		hidden_position,
		ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION
	)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"modulate:a",
		0.0,
		ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION
	)
	achievement_notification_tween.finished.connect(_on_achievement_notification_finished)


func _on_achievement_notification_finished() -> void:
	achievement_notification_active = false
	achievement_notification_tween = null
	if is_instance_valid(achievement_notification_logo):
		achievement_notification_logo.visible = false

	if not achievement_notification_queue.is_empty():
		_show_next_achievement_notification()


func _play_achievement_notification_sound() -> void:
	if achievement_notification_sound_player == null or achievement_notification_sound_player.stream == null:
		return

	if achievement_notification_sound_player.playing:
		achievement_notification_sound_player.stop()
	achievement_notification_sound_player.play()


func _get_achievement_notification_visible_time() -> float:
	return ACHIEVEMENT_NOTIFICATION_VISIBLE_TIME


func _get_achievement_definition(achievement_id: StringName) -> Dictionary:
	return AchievementManager.get_definition(achievement_id)


func _populate_achievement_notification(achievement_data: Dictionary) -> void:
	if not is_instance_valid(achievement_notification_logo):
		return

	var image := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/Image") as TextureRect
	var heading := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/TextContent/Heading") as VBoxContainer
	var title := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/TextContent/Title") as VBoxContainer
	var achievement_id: StringName = StringName(achievement_data.get("id", &""))
	if image != null:
		image.texture = AchievementManager.ACHIEVEMENT_IMAGE_TEXTURES.get(achievement_id) as Texture2D
		image.visible = image.texture != null
		image.custom_minimum_size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
		image.size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	if heading != null:
		_set_achievement_sprite_text_block(
			heading,
			"ACHIEVEMENT UNLOCKED",
			ACHIEVEMENT_NOTIFICATION_HEADING_HEIGHT,
			ACHIEVEMENT_NOTIFICATION_DESCRIPTION_MAX_CHARS,
			ACHIEVEMENT_NOTIFICATION_LETTER_SPACING
		)
	if title != null:
		_set_achievement_sprite_text_block(
			title,
			String(achievement_data.get("title", "Achievement")),
			ACHIEVEMENT_NOTIFICATION_TITLE_HEIGHT,
			ACHIEVEMENT_NOTIFICATION_TITLE_MAX_CHARS,
			ACHIEVEMENT_NOTIFICATION_LETTER_SPACING
		)

func _get_achievement_notification_size(_texture: Texture2D = null) -> Vector2:
	return Vector2(780.0, 190.0)


func _get_achievement_notification_visible_position(notification_size: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		ACHIEVEMENT_NOTIFICATION_MARGIN,
		maxf(viewport_size.y - notification_size.y - ACHIEVEMENT_NOTIFICATION_MARGIN, ACHIEVEMENT_NOTIFICATION_MARGIN)
	)


func _get_achievement_notification_hidden_position(notification_size: Vector2) -> Vector2:
	var visible_position := _get_achievement_notification_visible_position(notification_size)
	return Vector2(-notification_size.x - ACHIEVEMENT_NOTIFICATION_HIDDEN_OFFSET, visible_position.y)


func _set_achievement_sprite_text_block(
	container: VBoxContainer,
	text: String,
	target_height: float,
	max_line_characters: int,
	letter_spacing: float
) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for line in SpriteFont.wrap_lines(text, max_line_characters):
		var row := _create_achievement_sprite_text_row(line, target_height, letter_spacing)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(row)


func _create_achievement_sprite_text_row(text: String, target_height: float, letter_spacing: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", int(letter_spacing))
	row.custom_minimum_size = Vector2(0.0, target_height + 4.0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var normalized_text := SpriteFont.sanitize_text(text)
	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		if character == " ":
			var space := Control.new()
			space.custom_minimum_size = Vector2(target_height * 0.5, target_height)
			space.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(space)
			continue

		var glyph_texture := SpriteFont.get_glyph_texture(character)
		if glyph_texture == null:
			continue

		var glyph_height := target_height * 0.7 if character.is_valid_int() else target_height
		var glyph_width := glyph_height
		if glyph_texture.get_height() > 0:
			glyph_width = float(glyph_texture.get_width()) * glyph_height / float(glyph_texture.get_height())

		var glyph_rect := TextureRect.new()
		glyph_rect.custom_minimum_size = Vector2(glyph_width, target_height)
		glyph_rect.size = glyph_rect.custom_minimum_size
		glyph_rect.texture = glyph_texture
		glyph_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(glyph_rect)

	return row


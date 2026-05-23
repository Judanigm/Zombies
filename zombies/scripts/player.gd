extends CharacterBody2D

signal died
signal grenade_count_changed(grenade_count: int)
signal medkit_count_changed(medkit_count: int)
signal mine_count_changed(mine_count: int)
signal teleport_orb_count_changed(teleport_orb_count: int)
signal stamina_changed(stamina: float, max_stamina: float)
signal selected_power_up_changed(power_up_id: StringName)

@export var max_speed: float = 170.0
@export var medkit_boosted_speed: float = 230.0
@export_range(0.0, 1.0, 0.01) var wounded_move_speed_multiplier: float = 0.65
@export var sprint_speed_multiplier: float = 1.55
@export var max_stamina: float = 100.0
@export var stamina_drain_per_second: float = 34.0
@export var stamina_recovery_per_second: float = 6.0
@export_range(0.0, 1.0, 0.01) var wounded_stamina_recovery_multiplier: float = 0.5
@export_range(0.0, 1.0, 0.01) var wounded_stamina_limit_ratio: float = 0.5
@export var acceleration: float = 900.0
@export var friction: float = 1200.0
@export var fire_rate: float = 0.5
@export var joypad_mouse_speed: float = 720.0
@export_range(0.0, 1.0, 0.01) var joypad_mouse_deadzone: float = 0.22
@export var grenade_throw_offset: float = 26.0
@export var revive_invulnerability_duration: float = 1.0
@export var medkit_repel_radius: float = 360.0
@export var medkit_repel_distance: float = 260.0
@export var teleport_invulnerability_duration: float = 0.35
@export var teleport_particles_scale: float = 1.4
@export var teleport_particles_offset: Vector2 = Vector2(0, 18)
@export var teleport_particles_animation_speed: float = 10.0
@export var teleport_particles_color: Color = Color(0.45, 0.85, 1.0, 1.0)
@export_range(0.1, 2.0, 0.01) var idle_animation_scale: float = 0.62
@export_range(0.1, 2.0, 0.01) var walk_animation_scale: float = 0.28
@export_range(0.1, 2.0, 0.01) var shoot_animation_scale: float = 0.36
@export var shoot_animation_duration: float = 0.12
@export_range(0.0, 45.0, 0.1) var triple_bullet_spread_degrees: float = 14.0

@onready var body: Polygon2D = $Body
@onready var shadow: Polygon2D = $Shadow
@onready var facing_marker: Polygon2D = $FacingMarker
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const THROWN_GRENADE_SCENE := preload("res://scenes/power_ups/thrown_grenade.tscn")
const PLACED_MINE_SCENE := preload("res://scenes/power_ups/placed_mine.tscn")
const TELEPORT_SOUND := preload("res://assets/Sonido/Efectos/Enderman's Teleport - Sound Effect.mp3")
const TELEPORT_PARTICLES_TEXTURE := preload("res://assets/Texto/Pariculas de TP.png")
const IDLE_ANIMATION := &"Idle"
const SHOOT_UP_ANIMATION := &"Shoot up"
const SHOOT_DOWN_ANIMATION := &"Shoot down"
const SHOOT_LEFT_ANIMATION := &"Shoot left"
const SHOOT_RIGHT_ANIMATION := &"Shoot right"
const WALK_UP_ANIMATION := &"Walk up"
const WALK_DOWN_ANIMATION := &"Walk down"
const WALK_LEFT_ANIMATION := &"Walk left"
const WALK_RIGHT_ANIMATION := &"Walk right"
const TELEPORT_PARTICLES_ANIMATION := &"teleport_particles"
const TELEPORT_PARTICLES_COLUMNS := 3
const TELEPORT_PARTICLES_ROWS := 3
const TELEPORT_PARTICLES_MIN_VISIBLE_FRAMES := 6
const FIRST_HIT_DAMAGE_STAGE := 1
const SECOND_HIT_DAMAGE_STAGE := 2
const DEATH_DAMAGE_STAGE := 3
const HIT_RUMBLE_WEAK := 0.55
const HIT_RUMBLE_STRONG := 0.85
const HIT_RUMBLE_DURATION := 0.5
const TELEPORT_RUMBLE_WEAK := 0.45
const TELEPORT_RUMBLE_STRONG := 0.75
const TELEPORT_RUMBLE_DURATION := 0.5
const SHOOT_JOYPAD_TRIGGER_THRESHOLD := 0.5
const CLICK_JOYPAD_TRIGGER_THRESHOLD := 0.5
const SWITCH_SHOOT_JOYPAD_BUTTONS: Array[int] = [
	JOY_BUTTON_B,
	JOY_BUTTON_X,
]
const SWITCH_SPRINT_JOYPAD_BUTTON := JOY_BUTTON_A
const SWITCH_POWER_UP_JOYPAD_BUTTON := JOY_BUTTON_Y
const POWER_UP_MEDKIT := &"medkit"
const POWER_UP_TELEPORT_ORB := &"teleport_orb"
const POWER_UP_GRENADE := &"grenade"
const POWER_UP_MINE := &"mine"
const POWER_UP_ORDER: Array[StringName] = [
	POWER_UP_MEDKIT,
	POWER_UP_TELEPORT_ORB,
	POWER_UP_GRENADE,
	POWER_UP_MINE,
]

var facing_direction: Vector2 = Vector2.DOWN
var sprite_rest_position: Vector2 = Vector2(0, -10)
var walk_time: float = 0.0
var fire_cooldown: float = 0.0
var shoot_animation_timer: float = 0.0
var sprite_frame_offsets: Dictionary = {}
var sprite_reference_anchor: Vector2 = Vector2.ZERO
var is_dead: bool = false
var damage_stage: int = 0
var stamina: float = 0.0
var grenade_count: int = 0
var medkit_count: int = 0
var mine_count: int = 0
var teleport_orb_count: int = 0
var revive_invulnerability_timer: float = 0.0
var medkit_speed_boost_timer: float = 0.0
var homing_bullets_timer: float = 0.0
var anti_cooldown_timer: float = 0.0
var triple_bullet_timer: float = 0.0
var teleport_sound_player: AudioStreamPlayer2D = null
var teleport_particles_frames: SpriteFrames = null
var selected_power_up_id: StringName = &""
var joypad_left_trigger_click_pressed: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	stamina = max_stamina
	_setup_teleport_sound()
	body.hide()
	facing_marker.hide()
	_cache_sprite_frame_offsets()
	_update_animation()
	_update_visuals()
	emit_signal("medkit_count_changed", medkit_count)
	emit_signal("grenade_count_changed", grenade_count)
	emit_signal("mine_count_changed", mine_count)
	emit_signal("teleport_orb_count_changed", teleport_orb_count)
	_emit_stamina_changed()
	_ensure_selected_power_up()


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	_update_joypad_mouse(delta)
	_update_joypad_left_trigger_click()
	revive_invulnerability_timer = maxf(revive_invulnerability_timer - delta, 0.0)
	medkit_speed_boost_timer = maxf(medkit_speed_boost_timer - delta, 0.0)
	homing_bullets_timer = maxf(homing_bullets_timer - delta, 0.0)
	anti_cooldown_timer = maxf(anti_cooldown_timer - delta, 0.0)
	triple_bullet_timer = maxf(triple_bullet_timer - delta, 0.0)
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	shoot_animation_timer = maxf(shoot_animation_timer - delta, 0.0)

	if _locks_movement_for_shooting():
		velocity = Vector2.ZERO
		walk_time = 0.0
	else:
		var input_direction := _get_input_direction()
		var current_move_speed := _get_current_move_speed()
		var sprinting := _can_sprint(input_direction)

		if input_direction != Vector2.ZERO:
			if sprinting:
				current_move_speed *= sprint_speed_multiplier
			velocity = velocity.move_toward(input_direction * current_move_speed, acceleration * delta)
			facing_direction = input_direction.normalized()
			walk_time += delta * 10.0
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			walk_time = 0.0

		_update_stamina(delta, sprinting)

	if _wants_to_shoot():
		_shoot()

	move_and_slide()
	_update_animation()
	_update_visuals()


func _get_input_direction() -> Vector2:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_physical_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		input_direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_direction.y += 1.0

	return input_direction.limit_length(1.0)


func _update_visuals() -> void:
	var bob_offset := 0.0

	if velocity.length() > 5.0:
		bob_offset = sin(walk_time) * 1.5

	var current_scale := _get_animation_scale(animated_sprite.animation)
	animated_sprite.scale = Vector2.ONE * current_scale
	animated_sprite.position = (
		sprite_rest_position
		+ Vector2(0.0, bob_offset)
		+ sprite_reference_anchor * (1.0 - current_scale)
	)
	if revive_invulnerability_timer > 0.0:
		var blink_phase := sin(Time.get_ticks_msec() * 0.03)
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45 if blink_phase > 0.0 else 1.0)
	else:
		animated_sprite.modulate = Color.WHITE
	shadow.scale = Vector2(1.0 - abs(bob_offset) * 0.015, 1.0 - abs(bob_offset) * 0.03)
	_apply_sprite_frame_offset()


func _update_animation() -> void:
	var next_animation := IDLE_ANIMATION

	if _is_shooting():
		next_animation = _get_shoot_animation_name(facing_direction)
	elif velocity.length() > 5.0:
		next_animation = _get_walk_animation_name(facing_direction)

	if animated_sprite.animation != next_animation:
		animated_sprite.play(next_animation)
	elif not animated_sprite.is_playing():
		animated_sprite.play()

	_apply_sprite_frame_offset()


func _get_walk_animation_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return WALK_RIGHT_ANIMATION if direction.x > 0.0 else WALK_LEFT_ANIMATION

	return WALK_DOWN_ANIMATION if direction.y > 0.0 else WALK_UP_ANIMATION


func _get_shoot_animation_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return SHOOT_RIGHT_ANIMATION if direction.x > 0.0 else SHOOT_LEFT_ANIMATION

	return SHOOT_DOWN_ANIMATION if direction.y > 0.0 else SHOOT_UP_ANIMATION


func _cache_sprite_frame_offsets() -> void:
	sprite_frame_offsets.clear()

	if animated_sprite.sprite_frames == null:
		return

	sprite_reference_anchor = _get_frame_anchor(IDLE_ANIMATION, 0)

	for animation_name in animated_sprite.sprite_frames.get_animation_names():
		var frame_offsets := {}
		for frame_index in animated_sprite.sprite_frames.get_frame_count(animation_name):
			var frame_anchor := _get_frame_anchor(animation_name, frame_index)
			frame_offsets[frame_index] = sprite_reference_anchor - frame_anchor
		sprite_frame_offsets[animation_name] = frame_offsets


func _get_frame_anchor(animation_name: StringName, frame_index: int) -> Vector2:
	var frame_texture := animated_sprite.sprite_frames.get_frame_texture(animation_name, frame_index)
	if frame_texture == null:
		return Vector2.ZERO

	var frame_image := frame_texture.get_image()
	if frame_image == null:
		return Vector2.ZERO

	var used_rect := frame_image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Vector2.ZERO

	return Vector2(
		used_rect.position.x + used_rect.size.x * 0.5 - frame_image.get_width() * 0.5,
		used_rect.position.y + used_rect.size.y - frame_image.get_height() * 0.5
	)


func _apply_sprite_frame_offset() -> void:
	var frame_offsets: Dictionary = sprite_frame_offsets.get(animated_sprite.animation, {})
	animated_sprite.offset = frame_offsets.get(animated_sprite.frame, Vector2.ZERO)


func _get_animation_scale(animation_name: StringName) -> float:
	if animation_name == IDLE_ANIMATION:
		return idle_animation_scale
	if (
		animation_name == SHOOT_UP_ANIMATION
		or animation_name == SHOOT_DOWN_ANIMATION
		or animation_name == SHOOT_LEFT_ANIMATION
		or animation_name == SHOOT_RIGHT_ANIMATION
	):
		return shoot_animation_scale
	return walk_animation_scale


func _is_shooting() -> bool:
	return shoot_animation_timer > 0.0


func _locks_movement_for_shooting() -> bool:
	return shoot_animation_timer > 0.0 and anti_cooldown_timer <= 0.0


func _can_sprint(input_direction: Vector2) -> bool:
	return (
		input_direction != Vector2.ZERO
		and stamina > 0.0
		and _is_sprint_input_pressed()
	)


func _get_current_move_speed() -> float:
	if medkit_speed_boost_timer > 0.0:
		return medkit_boosted_speed
	if damage_stage >= SECOND_HIT_DAMAGE_STAGE:
		return max_speed * wounded_move_speed_multiplier
	return max_speed


func _update_stamina(delta: float, sprinting: bool) -> void:
	var previous_stamina := stamina
	var stamina_limit := _get_current_stamina_limit()
	if sprinting:
		stamina = maxf(stamina - stamina_drain_per_second * delta, 0.0)
	elif not _is_sprint_input_pressed():
		stamina = minf(stamina + _get_current_stamina_recovery_per_second() * delta, stamina_limit)

	if stamina > stamina_limit:
		stamina = stamina_limit

	if not is_equal_approx(previous_stamina, stamina):
		_emit_stamina_changed()


func _get_current_stamina_recovery_per_second() -> float:
	if damage_stage >= FIRST_HIT_DAMAGE_STAGE:
		return stamina_recovery_per_second * wounded_stamina_recovery_multiplier
	return stamina_recovery_per_second


func _get_current_stamina_limit() -> float:
	if damage_stage >= SECOND_HIT_DAMAGE_STAGE:
		return max_stamina * wounded_stamina_limit_ratio
	return max_stamina


func _emit_stamina_changed() -> void:
	emit_signal("stamina_changed", stamina, max_stamina)


func _wants_to_shoot() -> bool:
	if fire_cooldown > 0.0 and anti_cooldown_timer <= 0.0:
		return false

	return (
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		or Input.is_physical_key_pressed(KEY_SPACE)
		or _is_shoot_joypad_input_pressed()
	)


func _is_shoot_joypad_input_pressed() -> bool:
	for device_id in Input.get_connected_joypads():
		for button in SWITCH_SHOOT_JOYPAD_BUTTONS:
			if Input.is_joy_button_pressed(device_id, button):
				return true
		if Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT) >= SHOOT_JOYPAD_TRIGGER_THRESHOLD:
			return true

	return false


func _is_sprint_input_pressed() -> bool:
	if Input.is_physical_key_pressed(KEY_SHIFT):
		return true

	for device_id in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(device_id, SWITCH_SPRINT_JOYPAD_BUTTON):
			return true

	return false


func _update_joypad_mouse(delta: float) -> void:
	var mouse_direction := Vector2.ZERO
	for device_id in Input.get_connected_joypads():
		var right_stick := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)
		if right_stick.length() > mouse_direction.length():
			mouse_direction = right_stick

	if mouse_direction.length() <= joypad_mouse_deadzone:
		return

	var strength := inverse_lerp(joypad_mouse_deadzone, 1.0, minf(mouse_direction.length(), 1.0))
	var viewport := get_viewport()
	var viewport_size := viewport.get_visible_rect().size
	var next_mouse_position := (
		viewport.get_mouse_position()
		+ mouse_direction.normalized() * joypad_mouse_speed * strength * delta
	)
	next_mouse_position.x = clampf(next_mouse_position.x, 0.0, viewport_size.x)
	next_mouse_position.y = clampf(next_mouse_position.y, 0.0, viewport_size.y)
	Input.warp_mouse(next_mouse_position)


func _update_joypad_left_trigger_click() -> void:
	var pressed := false
	for device_id in Input.get_connected_joypads():
		if Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT) >= CLICK_JOYPAD_TRIGGER_THRESHOLD:
			pressed = true
			break

	if pressed == joypad_left_trigger_click_pressed:
		return

	joypad_left_trigger_click_pressed = pressed
	_send_left_mouse_button_event(pressed)


func _send_left_mouse_button_event(pressed: bool) -> void:
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = pressed
	mouse_event.position = get_viewport().get_mouse_position()
	mouse_event.global_position = mouse_event.position
	Input.parse_input_event(mouse_event)


func _shoot() -> void:
	fire_cooldown = 0.0 if anti_cooldown_timer > 0.0 else fire_rate
	shoot_animation_timer = shoot_animation_duration
	if anti_cooldown_timer <= 0.0:
		velocity = Vector2.ZERO
	var homing_active := homing_bullets_timer > 0.0
	var achievement_eligible := _is_clean_shot_for_achievement()
	var shot_direction := facing_direction
	if homing_active:
		var target_direction := _get_direction_to_nearest_zombie()
		if target_direction != Vector2.ZERO:
			shot_direction = target_direction
			facing_direction = target_direction

	if triple_bullet_timer > 0.0:
		var spread_radians := deg_to_rad(triple_bullet_spread_degrees)
		_spawn_bullet(shot_direction.rotated(-spread_radians), homing_active, achievement_eligible)
		_spawn_bullet(shot_direction, homing_active, achievement_eligible)
		_spawn_bullet(shot_direction.rotated(spread_radians), homing_active, achievement_eligible)
		return

	_spawn_bullet(shot_direction, homing_active, achievement_eligible)


func _spawn_bullet(shot_direction: Vector2, homing_active: bool, achievement_eligible: bool) -> void:
	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.setup(
		global_position,
		shot_direction,
		self,
		homing_active,
		achievement_eligible
	)


func _is_clean_shot_for_achievement() -> bool:
	return (
		homing_bullets_timer <= 0.0
		and anti_cooldown_timer <= 0.0
		and triple_bullet_timer <= 0.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return

	if _is_power_up_joypad_event(event):
		_activate_selected_power_up()
		get_viewport().set_input_as_handled()
		return

	if _is_select_power_up_joypad_event(event):
		_select_power_up(_get_power_up_selection_step(event))
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed and not mouse_event.is_echo():
			_throw_grenade()
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.physical_keycode == KEY_F and key_event.pressed and not key_event.echo:
			_throw_grenade()
		elif key_event.physical_keycode == KEY_C and key_event.pressed and not key_event.echo:
			_place_mine()
		elif key_event.physical_keycode == KEY_E and key_event.pressed and not key_event.echo:
			_use_teleport_orb()
		elif key_event.physical_keycode == KEY_Q and key_event.pressed and not key_event.echo:
			_use_medkit()


func _is_power_up_joypad_event(event: InputEvent) -> bool:
	if not event is InputEventJoypadButton:
		return false

	var joypad_event := event as InputEventJoypadButton
	return joypad_event.button_index == SWITCH_POWER_UP_JOYPAD_BUTTON and joypad_event.pressed


func _is_select_power_up_joypad_event(event: InputEvent) -> bool:
	if not event is InputEventJoypadButton:
		return false

	var joypad_event := event as InputEventJoypadButton
	return (
		joypad_event.pressed
		and (
			joypad_event.button_index == JOY_BUTTON_DPAD_LEFT
			or joypad_event.button_index == JOY_BUTTON_DPAD_RIGHT
			or joypad_event.button_index == JOY_BUTTON_DPAD_UP
			or joypad_event.button_index == JOY_BUTTON_DPAD_DOWN
		)
	)


func _get_power_up_selection_step(event: InputEvent) -> int:
	var joypad_event := event as InputEventJoypadButton
	if joypad_event.button_index == JOY_BUTTON_DPAD_LEFT or joypad_event.button_index == JOY_BUTTON_DPAD_UP:
		return -1
	return 1


func _select_power_up(step: int) -> void:
	var available_power_ups := _get_available_power_up_ids()
	if available_power_ups.is_empty():
		_set_selected_power_up(&"")
		return

	var current_index := available_power_ups.find(selected_power_up_id)
	if current_index < 0:
		current_index = 0 if step >= 0 else available_power_ups.size() - 1
	else:
		current_index = wrapi(current_index + step, 0, available_power_ups.size())
	_set_selected_power_up(available_power_ups[current_index])


func _activate_selected_power_up() -> void:
	_ensure_selected_power_up()

	match selected_power_up_id:
		POWER_UP_MEDKIT:
			_use_medkit()
		POWER_UP_TELEPORT_ORB:
			_use_teleport_orb()
		POWER_UP_GRENADE:
			_throw_grenade()
		POWER_UP_MINE:
			_place_mine()


func _ensure_selected_power_up() -> void:
	if _has_power_up(selected_power_up_id):
		_set_selected_power_up(selected_power_up_id)
		return

	var available_power_ups := _get_available_power_up_ids()
	_set_selected_power_up(&"" if available_power_ups.is_empty() else available_power_ups[0])


func _get_available_power_up_ids() -> Array[StringName]:
	var available_power_ups: Array[StringName] = []
	for power_up_id in POWER_UP_ORDER:
		if _has_power_up(power_up_id):
			available_power_ups.append(power_up_id)
	return available_power_ups


func _has_power_up(power_up_id: StringName) -> bool:
	match power_up_id:
		POWER_UP_MEDKIT:
			return medkit_count > 0
		POWER_UP_TELEPORT_ORB:
			return teleport_orb_count > 0
		POWER_UP_GRENADE:
			return grenade_count > 0
		POWER_UP_MINE:
			return mine_count > 0
	return false


func _set_selected_power_up(power_up_id: StringName) -> void:
	if selected_power_up_id == power_up_id:
		emit_signal("selected_power_up_changed", selected_power_up_id)
		return

	selected_power_up_id = power_up_id
	emit_signal("selected_power_up_changed", selected_power_up_id)


func add_grenades(amount: int = 1) -> void:
	grenade_count = maxi(grenade_count + amount, 0)
	emit_signal("grenade_count_changed", grenade_count)
	_register_grenade_stock_for_achievement()
	_ensure_selected_power_up()


func add_mines(amount: int = 1) -> int:
	if is_dead or amount <= 0:
		return 0

	mine_count += amount
	emit_signal("mine_count_changed", mine_count)
	_ensure_selected_power_up()
	return amount


func add_teleport_orbs(amount: int = 1) -> int:
	if is_dead or amount <= 0:
		return 0

	teleport_orb_count += amount
	emit_signal("teleport_orb_count_changed", teleport_orb_count)
	_ensure_selected_power_up()
	return amount


func add_medkit(amount: int = 1) -> int:
	if is_dead or amount <= 0:
		return 0

	var previous_count := medkit_count
	medkit_count = mini(medkit_count + amount, 1)
	var added_amount := medkit_count - previous_count
	if added_amount > 0:
		emit_signal("medkit_count_changed", medkit_count)
		_ensure_selected_power_up()
	return added_amount


func activate_homing_bullets(duration: float = 7.0) -> void:
	if is_dead or duration <= 0.0:
		return

	homing_bullets_timer = duration


func activate_anti_cooldown(duration: float = 7.0) -> void:
	if is_dead or duration <= 0.0:
		return

	anti_cooldown_timer = duration
	fire_cooldown = 0.0


func activate_triple_bullet(duration: float = 7.0) -> void:
	if is_dead or duration <= 0.0:
		return

	triple_bullet_timer = duration


func has_anti_cooldown() -> bool:
	return anti_cooldown_timer > 0.0


func has_triple_bullet() -> bool:
	return triple_bullet_timer > 0.0


func has_homing_bullets() -> bool:
	return homing_bullets_timer > 0.0


func get_medkit_count() -> int:
	return medkit_count


func get_mine_count() -> int:
	return mine_count


func get_teleport_orb_count() -> int:
	return teleport_orb_count


func get_stamina() -> float:
	return stamina


func get_max_stamina() -> float:
	return max_stamina


func take_damage(_amount: int = 1) -> void:
	if is_dead or revive_invulnerability_timer > 0.0:
		return

	_receive_hit()


func get_grenade_count() -> int:
	return grenade_count


func _get_direction_to_nearest_zombie() -> Vector2:
	var nearest_direction := Vector2.ZERO
	var nearest_distance := INF

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not (zombie is Node2D):
			continue

		var zombie_node := zombie as Node2D
		var offset := zombie_node.global_position - global_position
		var distance := offset.length()
		if distance == 0.0 or distance >= nearest_distance:
			continue

		nearest_distance = distance
		nearest_direction = offset / distance

	return nearest_direction


func _place_mine() -> void:
	if mine_count <= 0:
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	var mine := PLACED_MINE_SCENE.instantiate()
	scene_root.add_child(mine)
	mine.global_position = global_position
	mine_count -= 1
	emit_signal("mine_count_changed", mine_count)
	_ensure_selected_power_up()


func _throw_grenade() -> void:
	if grenade_count <= 0:
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	var target_position := get_global_mouse_position()
	var throw_direction := global_position.direction_to(target_position)
	if throw_direction == Vector2.ZERO:
		throw_direction = facing_direction

	var grenade := THROWN_GRENADE_SCENE.instantiate()
	scene_root.add_child(grenade)
	grenade.setup(
		global_position + throw_direction * grenade_throw_offset,
		target_position
	)
	grenade_count -= 1
	emit_signal("grenade_count_changed", grenade_count)
	_ensure_selected_power_up()


func _use_teleport_orb() -> void:
	if teleport_orb_count <= 0:
		return

	var scene_root := get_tree().current_scene
	if scene_root == null or not scene_root.has_method("get_safe_teleport_position"):
		return

	var target_position_variant: Variant = scene_root.call("get_safe_teleport_position", global_position)
	if typeof(target_position_variant) != TYPE_VECTOR2:
		return

	var target_position := target_position_variant as Vector2
	if target_position.distance_to(global_position) < 24.0:
		return

	var start_position := global_position
	global_position = target_position
	velocity = Vector2.ZERO
	walk_time = 0.0
	shoot_animation_timer = 0.0
	revive_invulnerability_timer = maxf(revive_invulnerability_timer, teleport_invulnerability_duration)
	teleport_orb_count -= 1
	emit_signal("teleport_orb_count_changed", teleport_orb_count)
	_ensure_selected_power_up()
	_play_teleport_rumble()
	_play_teleport_sound()
	_spawn_teleport_particles(start_position)
	_spawn_teleport_particles(target_position)
	_update_animation()
	_update_visuals()


func _use_medkit() -> void:
	if medkit_count <= 0 or damage_stage == 0:
		return

	medkit_count -= 1
	damage_stage = 0
	stamina = max_stamina
	revive_invulnerability_timer = revive_invulnerability_duration
	medkit_speed_boost_timer = revive_invulnerability_duration
	_repel_nearby_zombies_with_medkit()
	emit_signal("medkit_count_changed", medkit_count)
	_emit_stamina_changed()
	_ensure_selected_power_up()


func _setup_teleport_sound() -> void:
	teleport_sound_player = AudioStreamPlayer2D.new()
	teleport_sound_player.stream = TELEPORT_SOUND
	add_child(teleport_sound_player)


func _play_teleport_sound() -> void:
	if teleport_sound_player == null or teleport_sound_player.stream == null:
		return
	if teleport_sound_player.playing:
		teleport_sound_player.stop()
	teleport_sound_player.play()


func _play_teleport_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, TELEPORT_RUMBLE_WEAK, TELEPORT_RUMBLE_STRONG, TELEPORT_RUMBLE_DURATION)


func _spawn_teleport_particles(effect_position: Vector2) -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	var final_position := effect_position + teleport_particles_offset

	if teleport_particles_frames == null:
		teleport_particles_frames = _build_teleport_particles_sprite_frames()
	if teleport_particles_frames == null:
		return

	var particles := AnimatedSprite2D.new()
	particles.name = "TeleportParticles"
	particles.sprite_frames = teleport_particles_frames
	particles.animation = TELEPORT_PARTICLES_ANIMATION
	particles.scale = Vector2.ONE * teleport_particles_scale
	particles.z_index = z_index + 4
	particles.animation_finished.connect(particles.queue_free)
	scene_root.add_child(particles)
	particles.global_position = final_position
	particles.play(TELEPORT_PARTICLES_ANIMATION)


func _build_teleport_particles_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(TELEPORT_PARTICLES_ANIMATION)
	frames.set_animation_loop(TELEPORT_PARTICLES_ANIMATION, false)
	frames.set_animation_speed(TELEPORT_PARTICLES_ANIMATION, teleport_particles_animation_speed)

	var texture_size := TELEPORT_PARTICLES_TEXTURE.get_size()
	var frame_width := int(texture_size.x / TELEPORT_PARTICLES_COLUMNS)
	var frame_height := int(texture_size.y / TELEPORT_PARTICLES_ROWS)
	var particles_texture: Texture2D = TELEPORT_PARTICLES_TEXTURE
	var visible_regions: Array[Rect2] = []
	var source_image := TELEPORT_PARTICLES_TEXTURE.get_image()

	if source_image != null:
		particles_texture = _build_visible_teleport_particles_texture(source_image)
		for row in range(TELEPORT_PARTICLES_ROWS):
			for column in range(TELEPORT_PARTICLES_COLUMNS):
				var cell_position := Vector2i(column * frame_width, row * frame_height)
				var cell_image := source_image.get_region(Rect2i(cell_position, Vector2i(frame_width, frame_height)))
				var used_rect := cell_image.get_used_rect()
				if used_rect.size == Vector2i.ZERO:
					continue

				visible_regions.append(Rect2(
					Vector2(cell_position.x, cell_position.y),
					Vector2(frame_width, frame_height)
				))

	if visible_regions.is_empty():
		for row in range(TELEPORT_PARTICLES_ROWS):
			for column in range(TELEPORT_PARTICLES_COLUMNS):
				visible_regions.append(Rect2(
					column * frame_width,
					row * frame_height,
					frame_width,
					frame_height
				))

	var repeats := TELEPORT_PARTICLES_MIN_VISIBLE_FRAMES if visible_regions.size() == 1 else 1
	for region in visible_regions:
		for _repeat in range(repeats):
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = particles_texture
			atlas_texture.region = region
			frames.add_frame(TELEPORT_PARTICLES_ANIMATION, atlas_texture)

	return frames


func _build_visible_teleport_particles_texture(source_image: Image) -> ImageTexture:
	var particle_image := Image.create(
		source_image.get_width(),
		source_image.get_height(),
		false,
		Image.FORMAT_RGBA8
	)

	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			var source_pixel := source_image.get_pixel(x, y)
			if source_pixel.a <= 0.0:
				continue

			var particle_color := teleport_particles_color
			particle_color.a *= source_pixel.a
			particle_image.set_pixel(x, y, particle_color)

	return ImageTexture.create_from_image(particle_image)


func _register_grenade_stock_for_achievement() -> void:
	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("register_grenade_stock"):
		scene_root.register_grenade_stock(grenade_count)


func _repel_nearby_zombies_with_medkit() -> void:
	if medkit_repel_radius <= 0.0 or medkit_repel_distance <= 0.0:
		return

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not (zombie is Node2D):
			continue

		var zombie_node := zombie as Node2D
		var offset := zombie_node.global_position - global_position
		var distance := offset.length()
		if distance > medkit_repel_radius:
			continue

		var repel_direction := offset.normalized()
		if repel_direction == Vector2.ZERO:
			repel_direction = Vector2.RIGHT.rotated(randf() * TAU)

		var distance_ratio := 1.0 - (distance / medkit_repel_radius)
		var repel_strength := medkit_repel_distance * maxf(distance_ratio, 0.35)
		var repel_offset := repel_direction * repel_strength
		var zombie_body := zombie_node as CharacterBody2D
		if zombie_body != null:
			zombie_body.move_and_collide(repel_offset)
		else:
			zombie_node.global_position += repel_offset


func die() -> void:
	if is_dead:
		return
	if revive_invulnerability_timer > 0.0:
		return

	_receive_hit()


func _receive_hit() -> void:
	damage_stage += 1
	_play_hit_rumble()
	if damage_stage >= DEATH_DAMAGE_STAGE:
		_die_for_real()
		return

	revive_invulnerability_timer = revive_invulnerability_duration
	_apply_damage_stage_stamina_effect()


func _play_hit_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, HIT_RUMBLE_WEAK, HIT_RUMBLE_STRONG, HIT_RUMBLE_DURATION)


func _apply_damage_stage_stamina_effect() -> void:
	if damage_stage < SECOND_HIT_DAMAGE_STAGE:
		return

	var previous_stamina := stamina
	stamina = minf(stamina, _get_current_stamina_limit())
	if not is_equal_approx(previous_stamina, stamina):
		_emit_stamina_changed()


func _die_for_real() -> void:
	is_dead = true
	damage_stage = DEATH_DAMAGE_STAGE
	medkit_count = 0
	grenade_count = 0
	mine_count = 0
	teleport_orb_count = 0
	homing_bullets_timer = 0.0
	anti_cooldown_timer = 0.0
	triple_bullet_timer = 0.0
	medkit_speed_boost_timer = 0.0
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	collision_layer = 0
	collision_mask = 0
	animated_sprite.modulate = Color.WHITE
	emit_signal("medkit_count_changed", medkit_count)
	emit_signal("grenade_count_changed", grenade_count)
	emit_signal("mine_count_changed", mine_count)
	emit_signal("teleport_orb_count_changed", teleport_orb_count)
	_ensure_selected_power_up()
	emit_signal("died")

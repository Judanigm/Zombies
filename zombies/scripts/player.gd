extends CharacterBody2D

signal died
signal grenade_count_changed(cantidad_granadas: int)
signal medkit_count_changed(cantidad_botiquines: int)
signal mine_count_changed(cantidad_minas: int)
signal teleport_orb_count_changed(cantidad_orbes_teletransporte: int)
signal stamina_changed(resistencia: float, resistencia_maxima: float)
signal selected_power_up_changed(power_up_id: StringName)

@export var velocidad_maxima: float = 170.0
@export var velocidad_mejorada_botiquin: float = 230.0
@export_range(0.0, 1.0, 0.01) var multiplicador_velocidad_herido: float = 0.65
@export var multiplicador_velocidad_sprint: float = 1.55
@export var resistencia_maxima: float = 100.0
@export var drenaje_resistencia_por_segundo: float = 34.0
@export var recuperacion_resistencia_por_segundo: float = 6.0
@export_range(0.0, 1.0, 0.01) var multiplicador_recuperacion_resistencia_herido: float = 0.5
@export_range(0.0, 1.0, 0.01) var proporcion_limite_resistencia_herido: float = 0.5
@export var aceleracion: float = 900.0
@export var friccion: float = 1200.0
@export var cadencia_disparo: float = 0.5
@export var velocidad_raton_mando: float = 720.0
@export_range(0.0, 1.0, 0.01) var zona_muerta_raton_mando: float = 0.22
@export var desplazamiento_lanzamiento_granada: float = 26.0
@export var duracion_invulnerabilidad_revivir: float = 1.0
@export var radio_repelente_botiquin: float = 360.0
@export var distancia_repelente_botiquin: float = 260.0
@export var duracion_invulnerabilidad_teletransporte: float = 0.35
@export var escala_particulas_teletransporte: float = 1.4
@export var desplazamiento_particulas_teletransporte: Vector2 = Vector2(0, 18)
@export var velocidad_animacion_particulas_teletransporte: float = 10.0
@export var color_particulas_teletransporte: Color = Color(0.45, 0.85, 1.0, 1.0)
@export_range(0.1, 2.0, 0.01) var escala_animacion_reposo: float = 0.62
@export_range(0.1, 2.0, 0.01) var escala_animacion_caminar: float = 0.28
@export_range(0.1, 2.0, 0.01) var escala_animacion_disparo: float = 0.36
@export var duracion_animacion_disparo: float = 0.12
@export_range(0.0, 45.0, 0.1) var grados_dispersion_bala_triple: float = 14.0

@onready var cuerpo: Polygon2D = $Body
@onready var sombra: Polygon2D = $Shadow
@onready var marcador_direccion: Polygon2D = $FacingMarker
@onready var sprite_animado: AnimatedSprite2D = $AnimatedSprite2D

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

var direccion_mirada: Vector2 = Vector2.DOWN
var direccion_apuntado: Vector2 = Vector2.DOWN
var posicion_reposo_sprite: Vector2 = Vector2(0, -10)
var tiempo_caminata: float = 0.0
var enfriamiento_disparo: float = 0.0
var temporizador_animacion_disparo: float = 0.0
var desplazamientos_frames_sprite: Dictionary = {}
var ancla_referencia_sprite: Vector2 = Vector2.ZERO
var esta_muerto: bool = false
var fase_dano: int = 0
var resistencia: float = 0.0
var cantidad_granadas: int = 0
var cantidad_botiquines: int = 0
var cantidad_minas: int = 0
var cantidad_orbes_teletransporte: int = 0
var temporizador_invulnerabilidad_revivir: float = 0.0
var temporizador_velocidad_botiquin: float = 0.0
var temporizador_balas_teledirigidas: float = 0.0
var temporizador_anti_enfriamiento: float = 0.0
var temporizador_bala_triple: float = 0.0
var reproductor_sonido_teletransporte: AudioStreamPlayer2D = null
var frames_particulas_teletransporte: SpriteFrames = null
var id_power_up_seleccionado: StringName = &""
var gatillo_izquierdo_mando_pulsado: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	resistencia = resistencia_maxima
	_setup_teleport_sound()
	cuerpo.hide()
	marcador_direccion.hide()
	_cache_sprite_frame_offsets()
	_update_animation()
	_update_visuals()
	emit_signal("medkit_count_changed", cantidad_botiquines)
	emit_signal("grenade_count_changed", cantidad_granadas)
	emit_signal("mine_count_changed", cantidad_minas)
	emit_signal("teleport_orb_count_changed", cantidad_orbes_teletransporte)
	_emit_stamina_changed()
	_ensure_selected_power_up()


func _physics_process(delta: float) -> void:
	if esta_muerto:
		velocity = Vector2.ZERO
		return

	_update_joypad_mouse(delta)
	_update_joypad_left_trigger_click()
	temporizador_invulnerabilidad_revivir = maxf(temporizador_invulnerabilidad_revivir - delta, 0.0)
	temporizador_velocidad_botiquin = maxf(temporizador_velocidad_botiquin - delta, 0.0)
	temporizador_balas_teledirigidas = maxf(temporizador_balas_teledirigidas - delta, 0.0)
	temporizador_anti_enfriamiento = maxf(temporizador_anti_enfriamiento - delta, 0.0)
	temporizador_bala_triple = maxf(temporizador_bala_triple - delta, 0.0)
	enfriamiento_disparo = maxf(enfriamiento_disparo - delta, 0.0)
	temporizador_animacion_disparo = maxf(temporizador_animacion_disparo - delta, 0.0)

	if _locks_movement_for_shooting():
		velocity = Vector2.ZERO
		tiempo_caminata = 0.0
	else:
		var direccion_entrada := _get_input_direction()
		var velocidad_movimiento_actual := _get_current_move_speed()
		var corriendo := _can_sprint(direccion_entrada)

		if direccion_entrada != Vector2.ZERO:
			if corriendo:
				velocidad_movimiento_actual *= multiplicador_velocidad_sprint
			velocity = velocity.move_toward(direccion_entrada * velocidad_movimiento_actual, aceleracion * delta)
			direccion_mirada = direccion_entrada.normalized()
			tiempo_caminata += delta * 10.0
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friccion * delta)
			tiempo_caminata = 0.0

		_update_stamina(delta, corriendo)

	if _wants_to_shoot():
		_shoot()

	move_and_slide()
	_update_animation()
	_update_visuals()


func _get_input_direction() -> Vector2:
	var direccion_entrada := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_physical_key_pressed(KEY_A):
		direccion_entrada.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direccion_entrada.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		direccion_entrada.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direccion_entrada.y += 1.0

	return direccion_entrada.limit_length(1.0)


func _update_visuals() -> void:
	var desplazamiento_balanceo := 0.0

	if velocity.length() > 5.0:
		desplazamiento_balanceo = sin(tiempo_caminata) * 1.5

	var escala_actual := _get_animation_scale(sprite_animado.animation)
	sprite_animado.scale = Vector2.ONE * escala_actual
	sprite_animado.position = (
		posicion_reposo_sprite
		+ Vector2(0.0, desplazamiento_balanceo)
		+ ancla_referencia_sprite * (1.0 - escala_actual)
	)
	if temporizador_invulnerabilidad_revivir > 0.0:
		var fase_parpadeo := sin(Time.get_ticks_msec() * 0.03)
		sprite_animado.modulate = Color(1.0, 1.0, 1.0, 0.45 if fase_parpadeo > 0.0 else 1.0)
	else:
		sprite_animado.modulate = Color.WHITE
	sombra.scale = Vector2(1.0 - abs(desplazamiento_balanceo) * 0.015, 1.0 - abs(desplazamiento_balanceo) * 0.03)
	_apply_sprite_frame_offset()


func _update_animation() -> void:
	var siguiente_animacion := IDLE_ANIMATION

	if _is_shooting():
		siguiente_animacion = _get_shoot_animation_name(direccion_apuntado)
	elif velocity.length() > 5.0:
		siguiente_animacion = _get_walk_animation_name(direccion_mirada)

	if sprite_animado.animation != siguiente_animacion:
		sprite_animado.play(siguiente_animacion)
	elif not sprite_animado.is_playing():
		sprite_animado.play()

	_apply_sprite_frame_offset()


func _get_walk_animation_name(direccion: Vector2) -> StringName:
	if absf(direccion.x) > absf(direccion.y):
		return WALK_RIGHT_ANIMATION if direccion.x > 0.0 else WALK_LEFT_ANIMATION

	return WALK_DOWN_ANIMATION if direccion.y > 0.0 else WALK_UP_ANIMATION


func _get_shoot_animation_name(direccion: Vector2) -> StringName:
	if absf(direccion.x) > absf(direccion.y):
		return SHOOT_RIGHT_ANIMATION if direccion.x > 0.0 else SHOOT_LEFT_ANIMATION

	return SHOOT_DOWN_ANIMATION if direccion.y > 0.0 else SHOOT_UP_ANIMATION


func _cache_sprite_frame_offsets() -> void:
	desplazamientos_frames_sprite.clear()

	if sprite_animado.sprite_frames == null:
		return

	ancla_referencia_sprite = _get_frame_anchor(IDLE_ANIMATION, 0)

	for nombre_animacion in sprite_animado.sprite_frames.get_animation_names():
		var desplazamientos_frame := {}
		for indice_frame in sprite_animado.sprite_frames.get_frame_count(nombre_animacion):
			var frame_anchor := _get_frame_anchor(nombre_animacion, indice_frame)
			desplazamientos_frame[indice_frame] = ancla_referencia_sprite - frame_anchor
		desplazamientos_frames_sprite[nombre_animacion] = desplazamientos_frame


func _get_frame_anchor(nombre_animacion: StringName, indice_frame: int) -> Vector2:
	var textura_frame := sprite_animado.sprite_frames.get_frame_texture(nombre_animacion, indice_frame)
	if textura_frame == null:
		return Vector2.ZERO

	var imagen_frame := textura_frame.get_image()
	if imagen_frame == null:
		return Vector2.ZERO

	var rect_usado := imagen_frame.get_used_rect()
	if rect_usado.size == Vector2i.ZERO:
		return Vector2.ZERO

	return Vector2(
		rect_usado.position.x + rect_usado.size.x * 0.5 - imagen_frame.get_width() * 0.5,
		rect_usado.position.y + rect_usado.size.y - imagen_frame.get_height() * 0.5
	)


func _apply_sprite_frame_offset() -> void:
	var desplazamientos_frame: Dictionary = desplazamientos_frames_sprite.get(sprite_animado.animation, {})
	sprite_animado.offset = desplazamientos_frame.get(sprite_animado.frame, Vector2.ZERO)


func _get_animation_scale(nombre_animacion: StringName) -> float:
	if nombre_animacion == IDLE_ANIMATION:
		return escala_animacion_reposo
	if (
		nombre_animacion == SHOOT_UP_ANIMATION
		or nombre_animacion == SHOOT_DOWN_ANIMATION
		or nombre_animacion == SHOOT_LEFT_ANIMATION
		or nombre_animacion == SHOOT_RIGHT_ANIMATION
	):
		return escala_animacion_disparo
	return escala_animacion_caminar


func _is_shooting() -> bool:
	return temporizador_animacion_disparo > 0.0


func _locks_movement_for_shooting() -> bool:
	return temporizador_animacion_disparo > 0.0 and temporizador_anti_enfriamiento <= 0.0


func _can_sprint(direccion_entrada: Vector2) -> bool:
	return (
		direccion_entrada != Vector2.ZERO
		and resistencia > 0.0
		and _is_sprint_input_pressed()
	)


func _get_current_move_speed() -> float:
	if temporizador_velocidad_botiquin > 0.0:
		return velocidad_mejorada_botiquin
	if fase_dano >= SECOND_HIT_DAMAGE_STAGE:
		return velocidad_maxima * multiplicador_velocidad_herido
	return velocidad_maxima


func _update_stamina(delta: float, corriendo: bool) -> void:
	var resistencia_anterior := resistencia
	var limite_resistencia := _get_current_stamina_limit()
	if corriendo:
		resistencia = maxf(resistencia - drenaje_resistencia_por_segundo * delta, 0.0)
	elif not _is_sprint_input_pressed():
		resistencia = minf(resistencia + _get_current_stamina_recovery_per_second() * delta, limite_resistencia)

	if resistencia > limite_resistencia:
		resistencia = limite_resistencia

	if not is_equal_approx(resistencia_anterior, resistencia):
		_emit_stamina_changed()


func _get_current_stamina_recovery_per_second() -> float:
	if fase_dano >= FIRST_HIT_DAMAGE_STAGE:
		return recuperacion_resistencia_por_segundo * multiplicador_recuperacion_resistencia_herido
	return recuperacion_resistencia_por_segundo


func _get_current_stamina_limit() -> float:
	if fase_dano >= SECOND_HIT_DAMAGE_STAGE:
		return resistencia_maxima * proporcion_limite_resistencia_herido
	return resistencia_maxima


func _emit_stamina_changed() -> void:
	emit_signal("stamina_changed", resistencia, resistencia_maxima)


func _wants_to_shoot() -> bool:
	if enfriamiento_disparo > 0.0 and temporizador_anti_enfriamiento <= 0.0:
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
	var direccion_raton := Vector2.ZERO
	for device_id in Input.get_connected_joypads():
		var stick_derecho := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)
		if stick_derecho.length() > direccion_raton.length():
			direccion_raton = stick_derecho

	if direccion_raton.length() <= zona_muerta_raton_mando:
		return

	var fuerza := inverse_lerp(zona_muerta_raton_mando, 1.0, minf(direccion_raton.length(), 1.0))
	var viewport := get_viewport()
	var tamano_viewport := viewport.get_visible_rect().size
	var siguiente_posicion_raton := (
		viewport.get_mouse_position()
		+ direccion_raton.normalized() * velocidad_raton_mando * fuerza * delta
	)
	siguiente_posicion_raton.x = clampf(siguiente_posicion_raton.x, 0.0, tamano_viewport.x)
	siguiente_posicion_raton.y = clampf(siguiente_posicion_raton.y, 0.0, tamano_viewport.y)
	Input.warp_mouse(siguiente_posicion_raton)


func _update_joypad_left_trigger_click() -> void:
	var pulsado := false
	for device_id in Input.get_connected_joypads():
		if Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT) >= CLICK_JOYPAD_TRIGGER_THRESHOLD:
			pulsado = true
			break

	if pulsado == gatillo_izquierdo_mando_pulsado:
		return

	gatillo_izquierdo_mando_pulsado = pulsado
	_send_left_mouse_button_event(pulsado)


func _send_left_mouse_button_event(pulsado: bool) -> void:
	var evento_raton := InputEventMouseButton.new()
	evento_raton.button_index = MOUSE_BUTTON_LEFT
	evento_raton.pressed = pulsado
	evento_raton.position = get_viewport().get_mouse_position()
	evento_raton.global_position = evento_raton.position
	Input.parse_input_event(evento_raton)


func _shoot() -> void:
	enfriamiento_disparo = 0.0 if temporizador_anti_enfriamiento > 0.0 else cadencia_disparo
	temporizador_animacion_disparo = duracion_animacion_disparo
	if temporizador_anti_enfriamiento <= 0.0:
		velocity = Vector2.ZERO
	var teledirigidas_activas := temporizador_balas_teledirigidas > 0.0
	var apto_logro := _is_clean_shot_for_achievement()
	var direccion_disparo := _obtener_direccion_disparo()
	if teledirigidas_activas:
		var direccion_objetivo := _get_direction_to_nearest_zombie()
		if direccion_objetivo != Vector2.ZERO:
			direccion_disparo = direccion_objetivo
			direccion_apuntado = direccion_objetivo
			direccion_mirada = direccion_objetivo

	if temporizador_bala_triple > 0.0:
		var dispersion_radianes := deg_to_rad(grados_dispersion_bala_triple)
		_spawn_bullet(direccion_disparo.rotated(-dispersion_radianes), teledirigidas_activas, apto_logro)
		_spawn_bullet(direccion_disparo, teledirigidas_activas, apto_logro)
		_spawn_bullet(direccion_disparo.rotated(dispersion_radianes), teledirigidas_activas, apto_logro)
		return

	_spawn_bullet(direccion_disparo, teledirigidas_activas, apto_logro)


func _obtener_direccion_disparo() -> Vector2:
	var direccion_disparo := global_position.direction_to(get_global_mouse_position())
	if direccion_disparo == Vector2.ZERO:
		direccion_disparo = direccion_mirada
	if direccion_disparo == Vector2.ZERO:
		direccion_disparo = Vector2.DOWN

	direccion_apuntado = direccion_disparo.normalized()
	direccion_mirada = direccion_apuntado
	return direccion_apuntado


func _spawn_bullet(direccion_disparo: Vector2, teledirigidas_activas: bool, apto_logro: bool) -> void:
	var raiz_escena := get_tree().current_scene
	if raiz_escena == null:
		raiz_escena = get_tree().root

	var bala := BULLET_SCENE.instantiate()
	raiz_escena.add_child(bala)
	bala.setup(
		global_position,
		direccion_disparo,
		self,
		teledirigidas_activas,
		apto_logro
	)


func _is_clean_shot_for_achievement() -> bool:
	return (
		temporizador_balas_teledirigidas <= 0.0
		and temporizador_anti_enfriamiento <= 0.0
		and temporizador_bala_triple <= 0.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if esta_muerto:
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
		var evento_raton := event as InputEventMouseButton
		if evento_raton.button_index == MOUSE_BUTTON_RIGHT and evento_raton.pressed and not evento_raton.is_echo():
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
	var power_ups_disponibles := _get_available_power_up_ids()
	if power_ups_disponibles.is_empty():
		_set_selected_power_up(&"")
		return

	var indice_actual := power_ups_disponibles.find(id_power_up_seleccionado)
	if indice_actual < 0:
		indice_actual = 0 if step >= 0 else power_ups_disponibles.size() - 1
	else:
		indice_actual = wrapi(indice_actual + step, 0, power_ups_disponibles.size())
	_set_selected_power_up(power_ups_disponibles[indice_actual])


func _activate_selected_power_up() -> void:
	_ensure_selected_power_up()

	match id_power_up_seleccionado:
		POWER_UP_MEDKIT:
			_use_medkit()
		POWER_UP_TELEPORT_ORB:
			_use_teleport_orb()
		POWER_UP_GRENADE:
			_throw_grenade()
		POWER_UP_MINE:
			_place_mine()


func _ensure_selected_power_up() -> void:
	if _has_power_up(id_power_up_seleccionado):
		_set_selected_power_up(id_power_up_seleccionado)
		return

	var power_ups_disponibles := _get_available_power_up_ids()
	_set_selected_power_up(&"" if power_ups_disponibles.is_empty() else power_ups_disponibles[0])


func _get_available_power_up_ids() -> Array[StringName]:
	var power_ups_disponibles: Array[StringName] = []
	for power_up_id in POWER_UP_ORDER:
		if _has_power_up(power_up_id):
			power_ups_disponibles.append(power_up_id)
	return power_ups_disponibles


func _has_power_up(power_up_id: StringName) -> bool:
	match power_up_id:
		POWER_UP_MEDKIT:
			return cantidad_botiquines > 0
		POWER_UP_TELEPORT_ORB:
			return cantidad_orbes_teletransporte > 0
		POWER_UP_GRENADE:
			return cantidad_granadas > 0
		POWER_UP_MINE:
			return cantidad_minas > 0
	return false


func _set_selected_power_up(power_up_id: StringName) -> void:
	if id_power_up_seleccionado == power_up_id:
		emit_signal("selected_power_up_changed", id_power_up_seleccionado)
		return

	id_power_up_seleccionado = power_up_id
	emit_signal("selected_power_up_changed", id_power_up_seleccionado)


func add_grenades(amount: int = 1) -> void:
	cantidad_granadas = maxi(cantidad_granadas + amount, 0)
	emit_signal("grenade_count_changed", cantidad_granadas)
	_register_grenade_stock_for_achievement()
	_ensure_selected_power_up()


func add_mines(amount: int = 1) -> int:
	if esta_muerto or amount <= 0:
		return 0

	cantidad_minas += amount
	emit_signal("mine_count_changed", cantidad_minas)
	_ensure_selected_power_up()
	return amount


func add_teleport_orbs(amount: int = 1) -> int:
	if esta_muerto or amount <= 0:
		return 0

	cantidad_orbes_teletransporte += amount
	emit_signal("teleport_orb_count_changed", cantidad_orbes_teletransporte)
	_ensure_selected_power_up()
	return amount


func add_medkit(amount: int = 1) -> int:
	if esta_muerto or amount <= 0:
		return 0

	var cantidad_anterior := cantidad_botiquines
	cantidad_botiquines = mini(cantidad_botiquines + amount, 1)
	var cantidad_agregada := cantidad_botiquines - cantidad_anterior
	if cantidad_agregada > 0:
		emit_signal("medkit_count_changed", cantidad_botiquines)
		_ensure_selected_power_up()
	return cantidad_agregada


func activate_homing_bullets(duration: float = 7.0) -> void:
	if esta_muerto or duration <= 0.0:
		return

	temporizador_balas_teledirigidas = duration


func activate_anti_cooldown(duration: float = 7.0) -> void:
	if esta_muerto or duration <= 0.0:
		return

	temporizador_anti_enfriamiento = duration
	enfriamiento_disparo = 0.0


func activate_triple_bullet(duration: float = 7.0) -> void:
	if esta_muerto or duration <= 0.0:
		return

	temporizador_bala_triple = duration


func has_anti_cooldown() -> bool:
	return temporizador_anti_enfriamiento > 0.0


func has_triple_bullet() -> bool:
	return temporizador_bala_triple > 0.0


func has_homing_bullets() -> bool:
	return temporizador_balas_teledirigidas > 0.0


func get_medkit_count() -> int:
	return cantidad_botiquines


func get_mine_count() -> int:
	return cantidad_minas


func get_teleport_orb_count() -> int:
	return cantidad_orbes_teletransporte


func get_stamina() -> float:
	return resistencia


func get_max_stamina() -> float:
	return resistencia_maxima


func take_damage(_amount: int = 1) -> void:
	if esta_muerto or temporizador_invulnerabilidad_revivir > 0.0:
		return

	_receive_hit()


func get_grenade_count() -> int:
	return cantidad_granadas


func _get_direction_to_nearest_zombie() -> Vector2:
	var direccion_mas_cercana := Vector2.ZERO
	var distancia_mas_cercana := INF

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not (zombie is Node2D):
			continue

		var nodo_zombie := zombie as Node2D
		var desplazamiento := nodo_zombie.global_position - global_position
		var distancia := desplazamiento.length()
		if distancia == 0.0 or distancia >= distancia_mas_cercana:
			continue

		distancia_mas_cercana = distancia
		direccion_mas_cercana = desplazamiento / distancia

	return direccion_mas_cercana


func _place_mine() -> void:
	if cantidad_minas <= 0:
		return

	var raiz_escena := get_tree().current_scene
	if raiz_escena == null:
		raiz_escena = get_tree().root

	var mina := PLACED_MINE_SCENE.instantiate()
	raiz_escena.add_child(mina)
	mina.global_position = global_position
	cantidad_minas -= 1
	emit_signal("mine_count_changed", cantidad_minas)
	_ensure_selected_power_up()


func _throw_grenade() -> void:
	if cantidad_granadas <= 0:
		return

	var raiz_escena := get_tree().current_scene
	if raiz_escena == null:
		raiz_escena = get_tree().root

	var posicion_objetivo := get_global_mouse_position()
	var direccion_lanzamiento := global_position.direction_to(posicion_objetivo)
	if direccion_lanzamiento == Vector2.ZERO:
		direccion_lanzamiento = direccion_mirada

	var granada := THROWN_GRENADE_SCENE.instantiate()
	raiz_escena.add_child(granada)
	granada.setup(
		global_position + direccion_lanzamiento * desplazamiento_lanzamiento_granada,
		posicion_objetivo
	)
	cantidad_granadas -= 1
	emit_signal("grenade_count_changed", cantidad_granadas)
	_ensure_selected_power_up()


func _use_teleport_orb() -> void:
	if cantidad_orbes_teletransporte <= 0:
		return

	var raiz_escena := get_tree().current_scene
	if raiz_escena == null or not raiz_escena.has_method("get_safe_teleport_position"):
		return

	var variante_posicion_objetivo: Variant = raiz_escena.call("get_safe_teleport_position", global_position)
	if typeof(variante_posicion_objetivo) != TYPE_VECTOR2:
		return

	var posicion_objetivo := variante_posicion_objetivo as Vector2
	if posicion_objetivo.distance_to(global_position) < 24.0:
		return

	var posicion_inicial := global_position
	global_position = posicion_objetivo
	velocity = Vector2.ZERO
	tiempo_caminata = 0.0
	temporizador_animacion_disparo = 0.0
	temporizador_invulnerabilidad_revivir = maxf(temporizador_invulnerabilidad_revivir, duracion_invulnerabilidad_teletransporte)
	cantidad_orbes_teletransporte -= 1
	emit_signal("teleport_orb_count_changed", cantidad_orbes_teletransporte)
	_ensure_selected_power_up()
	_play_teleport_rumble()
	_play_teleport_sound()
	_spawn_teleport_particles(posicion_inicial)
	_spawn_teleport_particles(posicion_objetivo)
	_update_animation()
	_update_visuals()


func _use_medkit() -> void:
	if cantidad_botiquines <= 0 or fase_dano == 0:
		return

	cantidad_botiquines -= 1
	fase_dano = 0
	resistencia = resistencia_maxima
	temporizador_invulnerabilidad_revivir = duracion_invulnerabilidad_revivir
	temporizador_velocidad_botiquin = duracion_invulnerabilidad_revivir
	_repel_nearby_zombies_with_medkit()
	emit_signal("medkit_count_changed", cantidad_botiquines)
	_emit_stamina_changed()
	_ensure_selected_power_up()


func _setup_teleport_sound() -> void:
	reproductor_sonido_teletransporte = AudioStreamPlayer2D.new()
	reproductor_sonido_teletransporte.stream = TELEPORT_SOUND
	add_child(reproductor_sonido_teletransporte)


func _play_teleport_sound() -> void:
	if reproductor_sonido_teletransporte == null or reproductor_sonido_teletransporte.stream == null:
		return
	if reproductor_sonido_teletransporte.playing:
		reproductor_sonido_teletransporte.stop()
	reproductor_sonido_teletransporte.play()


func _play_teleport_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, TELEPORT_RUMBLE_WEAK, TELEPORT_RUMBLE_STRONG, TELEPORT_RUMBLE_DURATION)


func _spawn_teleport_particles(posicion_efecto: Vector2) -> void:
	var raiz_escena := get_tree().current_scene
	if raiz_escena == null:
		raiz_escena = get_tree().root

	var posicion_final := posicion_efecto + desplazamiento_particulas_teletransporte

	if frames_particulas_teletransporte == null:
		frames_particulas_teletransporte = _build_teleport_particles_sprite_frames()
	if frames_particulas_teletransporte == null:
		return

	var particulas := AnimatedSprite2D.new()
	particulas.name = "TeleportParticles"
	particulas.sprite_frames = frames_particulas_teletransporte
	particulas.animation = TELEPORT_PARTICLES_ANIMATION
	particulas.scale = Vector2.ONE * escala_particulas_teletransporte
	particulas.z_index = z_index + 4
	particulas.animation_finished.connect(particulas.queue_free)
	raiz_escena.add_child(particulas)
	particulas.global_position = posicion_final
	particulas.play(TELEPORT_PARTICLES_ANIMATION)


func _build_teleport_particles_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(TELEPORT_PARTICLES_ANIMATION)
	frames.set_animation_loop(TELEPORT_PARTICLES_ANIMATION, false)
	frames.set_animation_speed(TELEPORT_PARTICLES_ANIMATION, velocidad_animacion_particulas_teletransporte)

	var tamano_textura := TELEPORT_PARTICLES_TEXTURE.get_size()
	var ancho_frame := int(tamano_textura.x / TELEPORT_PARTICLES_COLUMNS)
	var alto_frame := int(tamano_textura.y / TELEPORT_PARTICLES_ROWS)
	var textura_particulas: Texture2D = TELEPORT_PARTICLES_TEXTURE
	var regiones_visibles: Array[Rect2] = []
	var imagen_origen := TELEPORT_PARTICLES_TEXTURE.get_image()

	if imagen_origen != null:
		textura_particulas = _build_visible_teleport_particles_texture(imagen_origen)
		for fila in range(TELEPORT_PARTICLES_ROWS):
			for columna in range(TELEPORT_PARTICLES_COLUMNS):
				var posicion_celda := Vector2i(columna * ancho_frame, fila * alto_frame)
				var imagen_celda := imagen_origen.get_region(Rect2i(posicion_celda, Vector2i(ancho_frame, alto_frame)))
				var rect_usado := imagen_celda.get_used_rect()
				if rect_usado.size == Vector2i.ZERO:
					continue

				regiones_visibles.append(Rect2(
					Vector2(posicion_celda.x, posicion_celda.y),
					Vector2(ancho_frame, alto_frame)
				))

	if regiones_visibles.is_empty():
		for fila in range(TELEPORT_PARTICLES_ROWS):
			for columna in range(TELEPORT_PARTICLES_COLUMNS):
				regiones_visibles.append(Rect2(
					columna * ancho_frame,
					fila * alto_frame,
					ancho_frame,
					alto_frame
				))

	var repeticiones := TELEPORT_PARTICLES_MIN_VISIBLE_FRAMES if regiones_visibles.size() == 1 else 1
	for region in regiones_visibles:
		for _repeat in range(repeticiones):
			var textura_atlas := AtlasTexture.new()
			textura_atlas.atlas = textura_particulas
			textura_atlas.region = region
			frames.add_frame(TELEPORT_PARTICLES_ANIMATION, textura_atlas)

	return frames


func _build_visible_teleport_particles_texture(imagen_origen: Image) -> ImageTexture:
	var imagen_particula := Image.create(
		imagen_origen.get_width(),
		imagen_origen.get_height(),
		false,
		Image.FORMAT_RGBA8
	)

	for y in range(imagen_origen.get_height()):
		for x in range(imagen_origen.get_width()):
			var pixel_origen := imagen_origen.get_pixel(x, y)
			if pixel_origen.a <= 0.0:
				continue

			var color_particula := color_particulas_teletransporte
			color_particula.a *= pixel_origen.a
			imagen_particula.set_pixel(x, y, color_particula)

	return ImageTexture.create_from_image(imagen_particula)


func _register_grenade_stock_for_achievement() -> void:
	var raiz_escena := get_tree().current_scene
	if raiz_escena != null and raiz_escena.has_method("register_grenade_stock"):
		raiz_escena.register_grenade_stock(cantidad_granadas)


func _repel_nearby_zombies_with_medkit() -> void:
	if radio_repelente_botiquin <= 0.0 or distancia_repelente_botiquin <= 0.0:
		return

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not (zombie is Node2D):
			continue

		var nodo_zombie := zombie as Node2D
		var desplazamiento := nodo_zombie.global_position - global_position
		var distancia := desplazamiento.length()
		if distancia > radio_repelente_botiquin:
			continue

		var direccion_repulsion := desplazamiento.normalized()
		if direccion_repulsion == Vector2.ZERO:
			direccion_repulsion = Vector2.RIGHT.rotated(randf() * TAU)

		var proporcion_distancia := 1.0 - (distancia / radio_repelente_botiquin)
		var fuerza_repulsion := distancia_repelente_botiquin * maxf(proporcion_distancia, 0.35)
		var desplazamiento_repulsion := direccion_repulsion * fuerza_repulsion
		var cuerpo_zombie := nodo_zombie as CharacterBody2D
		if cuerpo_zombie != null:
			cuerpo_zombie.move_and_collide(desplazamiento_repulsion)
		else:
			nodo_zombie.global_position += desplazamiento_repulsion


func die() -> void:
	if esta_muerto:
		return
	if temporizador_invulnerabilidad_revivir > 0.0:
		return

	_receive_hit()


func _receive_hit() -> void:
	fase_dano += 1
	_play_hit_rumble()
	if fase_dano >= DEATH_DAMAGE_STAGE:
		_die_for_real()
		return

	temporizador_invulnerabilidad_revivir = duracion_invulnerabilidad_revivir
	_apply_damage_stage_stamina_effect()


func _play_hit_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, HIT_RUMBLE_WEAK, HIT_RUMBLE_STRONG, HIT_RUMBLE_DURATION)


func _apply_damage_stage_stamina_effect() -> void:
	if fase_dano < SECOND_HIT_DAMAGE_STAGE:
		return

	var resistencia_anterior := resistencia
	resistencia = minf(resistencia, _get_current_stamina_limit())
	if not is_equal_approx(resistencia_anterior, resistencia):
		_emit_stamina_changed()


func _die_for_real() -> void:
	esta_muerto = true
	fase_dano = DEATH_DAMAGE_STAGE
	cantidad_botiquines = 0
	cantidad_granadas = 0
	cantidad_minas = 0
	cantidad_orbes_teletransporte = 0
	temporizador_balas_teledirigidas = 0.0
	temporizador_anti_enfriamiento = 0.0
	temporizador_bala_triple = 0.0
	temporizador_velocidad_botiquin = 0.0
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	collision_layer = 0
	collision_mask = 0
	sprite_animado.modulate = Color.WHITE
	emit_signal("medkit_count_changed", cantidad_botiquines)
	emit_signal("grenade_count_changed", cantidad_granadas)
	emit_signal("mine_count_changed", cantidad_minas)
	emit_signal("teleport_orb_count_changed", cantidad_orbes_teletransporte)
	_ensure_selected_power_up()
	emit_signal("died")

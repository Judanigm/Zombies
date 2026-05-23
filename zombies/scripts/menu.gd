extends CanvasLayer

const ACHIEVEMENT_CARD_SIZE := Vector2(560, 470)
const ACHIEVEMENT_IMAGE_SIZE := Vector2(250, 198)
const ACHIEVEMENT_GRID_SPACING := 20
const ACHIEVEMENT_STATUS_TEXT_HEIGHT := 30.0
const ACHIEVEMENT_TITLE_TEXT_HEIGHT := 40.0
const ACHIEVEMENT_DESCRIPTION_TEXT_HEIGHT := 50.0
const ACHIEVEMENT_TITLE_MAX_LINE_CHARS := 10
const ACHIEVEMENT_DESCRIPTION_MAX_LINE_CHARS := 14
const ACHIEVEMENT_DESCRIPTION_LETTER_SPACING := -30
const ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON := &"defeat_michael_jackson"
const ACHIEVEMENT_IMAGE_TEXTURES := {
	&"two_zombies_one_bullet": preload("res://assets/Texto/Logros/Double shoot 2.png"),
	&"three_strong_zombies_one_grenade": preload("res://assets/Texto/Logros/Bomba 2.png"),
	&"ten_grenades": preload("res://assets/Texto/Logros/Ahorros explosivos 2.png"),
	&"defeat_michael_jackson": preload("res://assets/Texto/Logros/Aguafiestas 2.png"),
	&"discover_all_zombies": preload("res://assets/Texto/Logros/Zombi\u00f3logo 2.png"),
	&"kill_100_normal_zombies": preload("res://assets/Texto/Logros/Verde asesino 2.png"),
	&"kill_100_fast_zombies": preload("res://assets/Texto/Logros/R\u00e1pido asesino 2.png"),
	&"kill_100_strong_zombies": preload("res://assets/Texto/Logros/Asesino por fuerza bruta 2.png"),
	&"ten_active_mines": preload("res://assets/Texto/Logros/Mala suerte 2.png"),
	&"close_zombie_kill": preload("res://assets/Texto/Logros/Sigilo 101 2.png"),
}
const MENU_BUTTONS_BACKGROUND_TEXTURE := preload("res://assets/Texto/Fondo de botones del men\u00fa.png")
const ACHIEVEMENTS_BACKGROUND_TEXTURE := preload("res://assets/Texto/Fondo de los logros.png")
const RECORD_TITLE_SIZE := Vector2(340, 86)
const RECORD_DIGIT_TARGET_HEIGHT := 70.0
const RECORD_DIGIT_SPACING := 5
const LETTER_FONT_TEXTURE := preload("res://assets/Texto/Fuente de letras.png")
const LETTER_FONT_COLUMNS := 13
const LETTER_FONT_ROWS := 2
const LETTER_FONT_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const SPRITE_TEXT_LETTER_SPACING := -26
const SPRITE_TEXT_DIGIT_HEIGHT_MULTIPLIER := 0.6
const SPRITE_TEXT_DIGIT_MIN_GAP := 3.0
const SPRITE_TEXT_DIGIT_WORD_GAP := 34.0
const RESET_BUTTON_LETTER_SPACING := -8
const SPRITE_TEXT_WORD_SPACING_MULTIPLIER := 0.78
const DIGIT_TEXTURES := {
	"0": preload("res://assets/Texto/0.png"),
	"1": preload("res://assets/Texto/1.png"),
	"2": preload("res://assets/Texto/2.png"),
	"3": preload("res://assets/Texto/3.png"),
	"4": preload("res://assets/Texto/4.png"),
	"5": preload("res://assets/Texto/5.png"),
	"6": preload("res://assets/Texto/6.png"),
	"7": preload("res://assets/Texto/7.png"),
	"8": preload("res://assets/Texto/8.png"),
	"9": preload("res://assets/Texto/9.png"),
}
const GAME_MUSIC_STREAM := preload("res://assets/Sonido/Música/en el juego.mp3")
const ACHIEVEMENTS_MUSIC_STREAM := preload("res://assets/Sonido/Música/Música de pantalla de logros.mp3")
const BUTTON_TOUCH_SOUND_STREAM := preload("res://assets/Sonido/Música/Sonido tocar botón.mp3")
const TUTORIAL_BUTTON_TEXTURE := preload("res://assets/Texto/Tutorial/Ir Tutorial.png")
const TUTORIAL_PAGE_TEXTS := [
	{
		"title": "TUTORIAL",
		"lines": ["KILL ZOMBIES", "DO NOT LET", "THEM TOUCH YOU"],
	},
	{
		"title": "MOVE",
		"lines": ["USE W A S D", "OR ARROWS", "SHIFT TO RUN"],
	},
	{
		"title": "SHOOT",
		"lines": ["SPACE", "OR CLICK", "GRENADE F", "OR RIGHT CLICK"],
	},
	{
		"title": "POWER UPS",
		"lines": ["ORB PRESS E", "MINE PRESS C", "MEDKIT PRESS Q", "PICK UP ITEMS"],
	},
]
const TUTORIAL_BUTTON_SIZE := Vector2(92, 92)
const TUTORIAL_PAGE_SIZE := Vector2(600, 600)
const TUTORIAL_TITLE_TEXT_HEIGHT := 76.0
const TUTORIAL_BODY_TEXT_HEIGHT := 58.0
const TUTORIAL_TEXT_LETTER_SPACING := -18
const TUTORIAL_NAV_TEXT_COLOR := Color.WHITE
const SETTINGS_SAVE_PATH := "user://settings.cfg"
const SKIP_WAVE_TARGETS := [5, 10, 15, 20]
const SKIP_WAVE_BUTTON_TEXT_HEIGHT := 42.0
const SKIP_WAVE_BUTTON_LETTER_SPACING := -12

@export var logo_offset: Vector2 = Vector2.ZERO
@export var button_hover_scale: Vector2 = Vector2(1.06, 1.06)
@export var button_hover_modulate: Color = Color(1.12, 1.12, 1.12, 1)
@export var joypad_mouse_speed: float = 720.0
@export_range(0.0, 1.0, 0.01) var joypad_mouse_deadzone: float = 0.22

@onready var title_label: Label = $MenuRoot/Panel/MarginContainer/VBoxContainer/Title
@onready var main_panel: PanelContainer = $MenuRoot/Panel
@onready var pause_title_graphic: TextureRect = $MenuRoot/Panel/MarginContainer/VBoxContainer/PauseTitleGraphic
@onready var game_over_title_graphic: TextureRect = $MenuRoot/Panel/MarginContainer/VBoxContainer/GameOverTitleGraphic
@onready var start_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/StartButton
@onready var achievements_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/AchievementsButton
@onready var resume_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/RestartButton
@onready var wave_editor_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/WaveEditorButton
@onready var exit_button: Button = $MenuRoot/Panel/MarginContainer/VBoxContainer/ExitButton
@onready var wave_editor_panel: PanelContainer = $MenuRoot/WaveEditorPanel
@onready var wave_editor_text: TextEdit = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/WaveSettingsText
@onready var wave_editor_feedback: Label = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/FeedbackLabel
@onready var logo_area: Control = $MenuRoot/LogoArea
@onready var logo: TextureRect = $MenuRoot/LogoArea/Logo
@onready var menu_background: TextureRect = $MenuRoot/ColorRect
@onready var death_background: TextureRect = $MenuRoot/DeathBackground
@onready var pause_overlay: ColorRect = $MenuRoot/PauseOverlay
@onready var achievements_panel: PanelContainer = $MenuRoot/AchievementsPanel
@onready var achievements_content: VBoxContainer = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer
@onready var achievements_title_graphic: TextureRect = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer/Title
@onready var achievements_info_label: Label = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer/InfoLabel
@onready var achievements_warning_label: Label = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer/WarningLabel
@onready var achievements_reset_button: Button = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer/Buttons/ResetButton
@onready var achievements_close_button: Button = $MenuRoot/AchievementsPanel/MarginContainer/VBoxContainer/Buttons/CloseButton
@onready var wave_editor_title_label: Label = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/Title
@onready var wave_editor_help_label: Label = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/HelpLabel
@onready var wave_editor_apply_button: Button = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/Buttons/ApplyButton
@onready var wave_editor_close_button: Button = $MenuRoot/WaveEditorPanel/MarginContainer/VBoxContainer/Buttons/CloseButton
@onready var death_sound: AudioStreamPlayer = $"../DeathSound"
@onready var menu_music: AudioStreamPlayer = $"../MenuMusic"
@onready var game_music: AudioStreamPlayer = $"../GameMusic"

var is_in_main_menu := true
var is_game_over := false
var menu_buttons: Array[Button] = []
var hard_mode_button: Button = null
var hard_mode_enabled: bool = false
var achievements_reset_confirmation_step: int = 0
var achievements_record_row: HBoxContainer = null
var achievements_record_digits: HBoxContainer = null
var achievements_scroll: ScrollContainer = null
var achievements_cards_list: GridContainer = null
var paused_music_players: Array[AudioStreamPlayer] = []
var achievements_music: AudioStreamPlayer = null
var button_touch_sound: AudioStreamPlayer = null
var skip_wave_buttons_panel: PanelContainer = null
var skip_wave_buttons_row: HBoxContainer = null
var skip_wave_buttons: Array[Button] = []
var tutorial_button: Button = null
var tutorial_panel: PanelContainer = null
var tutorial_text_content: VBoxContainer = null
var tutorial_previous_button: Button = null
var tutorial_next_button: Button = null
var tutorial_close_button: Button = null
var tutorial_page_index: int = 0

const SWITCH_MENU_JOYPAD_BUTTON := JOY_BUTTON_START
const CLICK_JOYPAD_TRIGGER_THRESHOLD := 0.5
const DEATH_RUMBLE_WEAK := 0.65
const DEATH_RUMBLE_STRONG := 1.0

var joypad_left_trigger_click_pressed: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	death_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_music.process_mode = Node.PROCESS_MODE_ALWAYS
	game_music.process_mode = Node.PROCESS_MODE_ALWAYS
	game_music.stream = GAME_MUSIC_STREAM
	_setup_achievements_music()
	_setup_button_touch_sound()
	_load_hard_mode_setting()
	_enable_music_loop(menu_music)
	_enable_music_loop(game_music)
	_enable_music_loop(achievements_music)
	_setup_hard_mode_button()
	_setup_skip_wave_buttons()
	_setup_tutorial_ui()
	_clear_button_selection_visuals()
	menu_buttons = [
		start_button,
		hard_mode_button,
		tutorial_button,
		achievements_button,
		resume_button,
		restart_button,
		exit_button,
		tutorial_previous_button,
		tutorial_next_button,
		tutorial_close_button,
		achievements_reset_button,
		achievements_close_button,
	]
	menu_buttons.append_array(skip_wave_buttons)
	for button in menu_buttons:
		if button == null:
			continue
		button.mouse_entered.connect(_on_button_hovered.bind(button))
		button.mouse_exited.connect(_on_button_unhovered.bind(button))
		button.focus_entered.connect(_on_button_hovered.bind(button))
		button.focus_exited.connect(_on_button_unhovered.bind(button))
		_set_button_highlight(button, false)
	_connect_button_touch_sounds()
	_setup_panel_backgrounds()
	_setup_achievements_cards_view()
	_setup_sprite_texts()
	logo_area.resized.connect(_update_logo_position)
	call_deferred("_update_logo_position")
	visible = true
	_show_main_menu()
	_apply_hard_mode_to_main()


func _process(delta: float) -> void:
	_update_joypad_mouse(delta)
	_update_joypad_left_trigger_click()


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over:
		return

	var wants_menu := event.is_action_pressed("ui_cancel") or _is_menu_joypad_event(event)

	if wants_menu and _is_tutorial_panel_visible():
		_hide_tutorial_panel()
		get_viewport().set_input_as_handled()
		return

	if wants_menu and wave_editor_panel.visible:
		_hide_wave_editor()
		get_viewport().set_input_as_handled()
		return

	if wants_menu and achievements_panel.visible:
		_hide_achievements_panel()
		get_viewport().set_input_as_handled()
		return

	if wants_menu and not is_in_main_menu:
		if get_tree().paused:
			_resume_game()
		else:
			_show_pause_menu()
		get_viewport().set_input_as_handled()


func _is_menu_joypad_event(event: InputEvent) -> bool:
	if not event is InputEventJoypadButton:
		return false

	var joypad_event := event as InputEventJoypadButton
	return joypad_event.button_index == SWITCH_MENU_JOYPAD_BUTTON and joypad_event.pressed


func _update_joypad_mouse(delta: float) -> void:
	if not visible:
		return

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
	if not visible:
		joypad_left_trigger_click_pressed = false
		return

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


func _on_start_button_pressed() -> void:
	_apply_hard_mode_to_main()
	_resume_game()


func _on_resume_button_pressed() -> void:
	_resume_game()


func _on_hard_mode_button_pressed() -> void:
	if hard_mode_button != null:
		hard_mode_enabled = hard_mode_button.button_pressed
	_update_hard_mode_button_text()
	_save_hard_mode_setting()
	_apply_hard_mode_to_main()


func _on_achievements_button_pressed() -> void:
	_show_achievements_panel()


func show_main_menu() -> void:
	_show_main_menu()


func _on_tutorial_button_pressed() -> void:
	_show_tutorial_panel()


func _on_tutorial_previous_button_pressed() -> void:
	tutorial_page_index = maxi(tutorial_page_index - 1, 0)
	_update_tutorial_page()


func _on_tutorial_next_button_pressed() -> void:
	tutorial_page_index = mini(tutorial_page_index + 1, TUTORIAL_PAGE_TEXTS.size() - 1)
	_update_tutorial_page()


func _on_tutorial_close_button_pressed() -> void:
	_hide_tutorial_panel()


func _on_skip_wave_button_pressed(target_wave: int) -> void:
	var main_node := _get_main_node()
	if main_node == null or not main_node.has_method("skip_to_wave"):
		return

	main_node.call("skip_to_wave", target_wave)
	paused_music_players.clear()
	_resume_game()
	if main_node.has_method("restore_music_after_priority_audio"):
		main_node.call("restore_music_after_priority_audio")


func _on_restart_button_pressed() -> void:
	_hide_wave_editor()
	_stop_death_rumble()
	var main_node := _get_main_node()
	if main_node != null and main_node.has_method("save_base_loot"):
		main_node.call("save_base_loot")
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	_stop_death_rumble()
	get_tree().quit()


func _on_wave_editor_button_pressed() -> void:
	_hide_tutorial_panel(false)
	var main_node := _get_main_node()
	if main_node == null or not main_node.has_method("get_wave_settings_text"):
		_set_label_sprite_text(wave_editor_feedback, "COULD NOT LOAD", 44.0)
		wave_editor_feedback.modulate = Color(1.0, 0.7, 0.7, 1.0)
		wave_editor_panel.show()
		return

	_set_label_sprite_text(wave_editor_feedback, "", 44.0)
	wave_editor_feedback.modulate = Color(1, 1, 1, 1)
	wave_editor_text.text = main_node.get_wave_settings_text()
	wave_editor_panel.show()
	wave_editor_text.grab_focus()


func _on_wave_editor_apply_button_pressed() -> void:
	var main_node := _get_main_node()
	if main_node == null or not main_node.has_method("apply_wave_settings_text"):
		_set_label_sprite_text(wave_editor_feedback, "COULD NOT APPLY", 44.0)
		wave_editor_feedback.modulate = Color(1.0, 0.7, 0.7, 1.0)
		return

	var result: Dictionary = main_node.apply_wave_settings_text(wave_editor_text.text)
	if result.get("ok", false):
		wave_editor_text.text = main_node.get_wave_settings_text()
		_set_label_sprite_text(wave_editor_feedback, "WAVES UPDATED", 44.0)
		wave_editor_feedback.modulate = Color(0.8, 1.0, 0.8, 1.0)
		return

	_set_label_sprite_text(wave_editor_feedback, "COULD NOT APPLY", 44.0)
	wave_editor_feedback.modulate = Color(1.0, 0.7, 0.7, 1.0)


func _on_wave_editor_close_button_pressed() -> void:
	_hide_wave_editor()


func _on_achievements_close_button_pressed() -> void:
	_hide_achievements_panel()


func _on_achievements_reset_button_pressed() -> void:
	if achievements_reset_confirmation_step == 0:
		achievements_reset_confirmation_step = 1
		_set_label_sprite_text(achievements_warning_label, "SURE PRESS AGAIN", 46.0)
		_set_button_sprite_text(achievements_reset_button, "CONFIRM", 54.0, RESET_BUTTON_LETTER_SPACING)
		return

	if achievements_reset_confirmation_step == 1:
		achievements_reset_confirmation_step = 2
		_set_label_sprite_text(achievements_warning_label, "FINAL CONFIRMATION", 46.0)
		_set_button_sprite_text(achievements_reset_button, "FOREVER", 54.0, RESET_BUTTON_LETTER_SPACING)
		return

	var main_node := _get_main_node()
	if main_node == null or not main_node.has_method("clear_achievements"):
		_reset_achievement_delete_confirmation()
		_set_label_sprite_text(achievements_warning_label, "COULD NOT DELETE", 46.0)
		achievements_warning_label.modulate = Color(1.0, 0.7, 0.7, 1.0)
		return

	main_node.clear_achievements()
	_reset_achievement_delete_confirmation()
	_set_label_sprite_text(achievements_warning_label, "ACHIEVEMENTS DELETED", 46.0)
	achievements_warning_label.modulate = Color(0.8, 1.0, 0.8, 1.0)
	_refresh_achievements_panel()


func _update_logo_position() -> void:
	logo.size = logo.custom_minimum_size
	logo.position = (
		Vector2(
			(logo_area.size.x - logo.size.x) * 0.5,
			0.0
		)
		+ logo_offset
	)


func _on_button_hovered(button: Button) -> void:
	_set_button_highlight(button, true)


func _on_button_unhovered(button: Button) -> void:
	if button.has_focus():
		return
	_set_button_highlight(button, false)


func _clear_button_selection_visuals() -> void:
	for node in find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _setup_hard_mode_button() -> void:
	if hard_mode_button != null or start_button == null or achievements_button == null:
		return

	hard_mode_button = achievements_button.duplicate(0) as Button
	if hard_mode_button == null:
		return

	hard_mode_button.name = "HardModeButton"
	hard_mode_button.text = "Hard Mode OFF"
	hard_mode_button.custom_minimum_size = Vector2(0, 82)
	hard_mode_button.toggle_mode = true
	hard_mode_button.button_pressed = hard_mode_enabled
	hard_mode_button.pressed.connect(_on_hard_mode_button_pressed)

	var buttons_parent := start_button.get_parent()
	if buttons_parent == null:
		return

	buttons_parent.add_child(hard_mode_button)
	buttons_parent.move_child(hard_mode_button, start_button.get_index() + 1)
	_update_hard_mode_button_text()


func _setup_tutorial_ui() -> void:
	var menu_root := get_node_or_null("MenuRoot") as Control
	if menu_root == null:
		return

	tutorial_button = Button.new()
	tutorial_button.name = "TutorialButton"
	tutorial_button.custom_minimum_size = TUTORIAL_BUTTON_SIZE
	tutorial_button.tooltip_text = "Tutorial"
	tutorial_button.flat = true
	tutorial_button.focus_mode = Control.FOCUS_ALL
	tutorial_button.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_button.offset_left = 334.0
	tutorial_button.offset_top = -250.0
	tutorial_button.offset_right = tutorial_button.offset_left + TUTORIAL_BUTTON_SIZE.x
	tutorial_button.offset_bottom = tutorial_button.offset_top + TUTORIAL_BUTTON_SIZE.y
	tutorial_button.z_index = 20
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	menu_root.add_child(tutorial_button)

	var tutorial_button_graphic := TextureRect.new()
	tutorial_button_graphic.name = "Graphic"
	tutorial_button_graphic.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_button_graphic.texture = TUTORIAL_BUTTON_TEXTURE
	tutorial_button_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tutorial_button_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tutorial_button_graphic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_button.add_child(tutorial_button_graphic)

	tutorial_panel = PanelContainer.new()
	tutorial_panel.name = "TutorialPanel"
	tutorial_panel.visible = false
	tutorial_panel.custom_minimum_size = Vector2(760, 820)
	tutorial_panel.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_panel.offset_left = -380.0
	tutorial_panel.offset_top = -410.0
	tutorial_panel.offset_right = 380.0
	tutorial_panel.offset_bottom = 410.0
	tutorial_panel.z_index = 30
	tutorial_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	menu_root.add_child(tutorial_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 0)
	tutorial_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	margin.add_child(content)

	var image_center := CenterContainer.new()
	image_center.custom_minimum_size = Vector2(0, TUTORIAL_PAGE_SIZE.y)
	content.add_child(image_center)

	var page_visual := Control.new()
	page_visual.custom_minimum_size = TUTORIAL_PAGE_SIZE
	image_center.add_child(page_visual)

	var page_card := PanelContainer.new()
	page_card.name = "TutorialTextCard"
	page_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_card.add_theme_stylebox_override("panel", _create_tutorial_stylebox())
	page_visual.add_child(page_card)

	var page_margin := MarginContainer.new()
	page_margin.add_theme_constant_override("margin_left", 28)
	page_margin.add_theme_constant_override("margin_top", 32)
	page_margin.add_theme_constant_override("margin_right", 28)
	page_margin.add_theme_constant_override("margin_bottom", 108)
	page_card.add_child(page_margin)

	tutorial_text_content = VBoxContainer.new()
	tutorial_text_content.alignment = BoxContainer.ALIGNMENT_CENTER
	tutorial_text_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutorial_text_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tutorial_text_content.add_theme_constant_override("separation", 14)
	page_margin.add_child(tutorial_text_content)

	var buttons_row := HBoxContainer.new()
	buttons_row.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	buttons_row.offset_left = -315.0
	buttons_row.offset_top = -86.0
	buttons_row.offset_right = 315.0
	buttons_row.offset_bottom = -16.0
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 14)
	page_visual.add_child(buttons_row)

	tutorial_previous_button = _create_tutorial_action_button("PreviousButton")
	tutorial_previous_button.pressed.connect(_on_tutorial_previous_button_pressed)
	buttons_row.add_child(tutorial_previous_button)

	tutorial_close_button = _create_tutorial_action_button("CloseButton")
	tutorial_close_button.pressed.connect(_on_tutorial_close_button_pressed)
	buttons_row.add_child(tutorial_close_button)

	tutorial_next_button = _create_tutorial_action_button("NextButton")
	tutorial_next_button.pressed.connect(_on_tutorial_next_button_pressed)
	buttons_row.add_child(tutorial_next_button)


func _setup_skip_wave_buttons() -> void:
	if skip_wave_buttons_panel != null or restart_button == null:
		return

	var menu_root := get_node_or_null("MenuRoot") as Control
	if menu_root == null:
		return

	skip_wave_buttons_panel = PanelContainer.new()
	skip_wave_buttons_panel.name = "SkipWavePanel"
	skip_wave_buttons_panel.custom_minimum_size = Vector2(760, 168)
	skip_wave_buttons_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	skip_wave_buttons_panel.offset_left = -380.0
	skip_wave_buttons_panel.offset_top = -188.0
	skip_wave_buttons_panel.offset_right = 380.0
	skip_wave_buttons_panel.offset_bottom = -20.0
	skip_wave_buttons_panel.z_index = 60
	skip_wave_buttons_panel.add_theme_stylebox_override("panel", _create_skip_wave_panel_stylebox())
	menu_root.add_child(skip_wave_buttons_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	skip_wave_buttons_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "SKIP WAVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.93, 0.36, 1.0))
	title.custom_minimum_size = Vector2(0, 36)
	content.add_child(title)

	skip_wave_buttons_row = HBoxContainer.new()
	skip_wave_buttons_row.name = "SkipWaveButtons"
	skip_wave_buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	skip_wave_buttons_row.add_theme_constant_override("separation", 10)
	skip_wave_buttons_row.custom_minimum_size = Vector2(0, 118)
	skip_wave_buttons_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(skip_wave_buttons_row)

	for target_wave in SKIP_WAVE_TARGETS:
		var skip_button := restart_button.duplicate(0) as Button
		if skip_button == null:
			continue

		skip_button.name = "SkipWave%dButton" % int(target_wave)
		skip_button.visible = true
		skip_button.text = "Wave %d" % int(target_wave)
		skip_button.tooltip_text = "Skip to wave %d" % int(target_wave)
		skip_button.custom_minimum_size = Vector2(116, 106)
		skip_button.focus_mode = Control.FOCUS_ALL
		skip_button.flat = false
		skip_button.add_theme_stylebox_override("normal", _create_skip_wave_button_stylebox(false))
		skip_button.add_theme_stylebox_override("pressed", _create_skip_wave_button_stylebox(true))
		skip_button.add_theme_stylebox_override("hover", _create_skip_wave_button_stylebox(true))
		skip_button.add_theme_stylebox_override("focus", _create_skip_wave_button_stylebox(true))
		skip_button.pressed.connect(_on_skip_wave_button_pressed.bind(int(target_wave)))
		skip_wave_buttons_row.add_child(skip_button)
		skip_wave_buttons.append(skip_button)

	_set_skip_wave_buttons_visible(false)


func _create_tutorial_action_button(button_name: String) -> Button:
	var button := Button.new()
	button.name = button_name
	button.custom_minimum_size = Vector2(190, 64)
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.modulate = TUTORIAL_NAV_TEXT_COLOR
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button


func _create_skip_wave_button_stylebox(active: bool) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.85, 0.12, 0.08, 0.96) if active else Color(0.45, 0.04, 0.03, 0.94)
	stylebox.border_color = Color(1.0, 0.93, 0.36, 1.0)
	stylebox.set_border_width_all(5)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.55)
	stylebox.shadow_size = 8
	return stylebox


func _create_skip_wave_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.05, 0.02, 0.02, 0.92)
	stylebox.border_color = Color(1.0, 0.93, 0.36, 1.0)
	stylebox.set_border_width_all(5)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.65)
	stylebox.shadow_size = 12
	return stylebox


func _create_tutorial_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.27, 0.20, 0.15, 0.94)
	stylebox.border_color = Color(0.76, 0.58, 0.36, 0.95)
	stylebox.set_border_width_all(5)
	stylebox.set_corner_radius_all(8)
	return stylebox


func _set_button_highlight(button: Button, active: bool) -> void:
	var target := button.get_node_or_null("Graphic") as Control
	if target == null or not target.visible:
		target = button.get_node_or_null("SpriteTextRoot") as Control
	if target == null:
		return
	target.pivot_offset = target.size * 0.5
	target.scale = button_hover_scale if active else Vector2.ONE
	target.modulate = button_hover_modulate if active else Color.WHITE


func _show_main_menu() -> void:
	is_in_main_menu = true
	is_game_over = false
	get_tree().paused = true
	visible = true
	_hide_wave_editor()
	_hide_tutorial_panel(false)
	_hide_achievements_panel()
	_stop_player(achievements_music)
	_stop_gameplay_music()
	_play_player(menu_music)
	menu_background.show()
	death_background.hide()
	pause_overlay.hide()
	main_panel.show()
	logo_area.show()
	logo.show()
	title_label.hide()
	pause_title_graphic.hide()
	game_over_title_graphic.hide()
	title_label.text = "ZOMBIES"
	_sync_hard_mode_button_state()
	start_button.show()
	if hard_mode_button != null:
		hard_mode_button.show()
	achievements_button.show()
	if tutorial_button != null:
		tutorial_button.show()
	resume_button.hide()
	restart_button.hide()
	wave_editor_button.hide()
	_set_skip_wave_buttons_visible(true)
	exit_button.show()
	start_button.grab_focus()


func _show_pause_menu() -> void:
	is_game_over = false
	visible = true
	get_tree().paused = true
	_hide_wave_editor()
	_hide_tutorial_panel(false)
	_hide_achievements_panel()
	_pause_active_music()
	menu_background.hide()
	death_background.hide()
	pause_overlay.show()
	main_panel.show()
	logo_area.hide()
	logo.hide()
	title_label.hide()
	pause_title_graphic.show()
	game_over_title_graphic.hide()
	start_button.hide()
	if hard_mode_button != null:
		hard_mode_button.hide()
	if tutorial_button != null:
		tutorial_button.hide()
	achievements_button.hide()
	resume_button.show()
	restart_button.show()
	wave_editor_button.hide()
	_set_skip_wave_buttons_visible(false)
	exit_button.show()
	resume_button.grab_focus()


func _resume_game() -> void:
	_hide_wave_editor()
	_hide_tutorial_panel(false)
	_hide_achievements_panel()
	_stop_death_rumble()
	_stop_player(achievements_music)
	_stop_player(menu_music)
	is_game_over = false
	is_in_main_menu = false
	get_tree().paused = false
	visible = false
	_resume_paused_music()


func show_game_over() -> void:
	is_in_main_menu = false
	is_game_over = true
	get_tree().paused = true
	visible = true
	_hide_wave_editor()
	_hide_tutorial_panel(false)
	_hide_achievements_panel()
	_stop_player(achievements_music)
	_stop_player(menu_music)
	_stop_player(game_music)
	_stop_active_scene_audio()
	_play_player(death_sound)
	_play_death_rumble()
	menu_background.hide()
	death_background.show()
	pause_overlay.hide()
	main_panel.show()
	logo_area.hide()
	logo.hide()
	title_label.hide()
	pause_title_graphic.hide()
	game_over_title_graphic.show()
	start_button.hide()
	if hard_mode_button != null:
		hard_mode_button.hide()
	if tutorial_button != null:
		tutorial_button.hide()
	achievements_button.hide()
	resume_button.hide()
	restart_button.show()
	wave_editor_button.hide()
	_set_skip_wave_buttons_visible(false)
	exit_button.show()
	restart_button.grab_focus()


func _enable_music_loop(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	if player.stream is AudioStreamMP3:
		player.stream.loop = true
	elif player.stream is AudioStreamWAV:
		player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func _setup_achievements_music() -> void:
	achievements_music = AudioStreamPlayer.new()
	achievements_music.name = "AchievementsMusic"
	achievements_music.process_mode = Node.PROCESS_MODE_ALWAYS
	achievements_music.bus = &"Master"
	achievements_music.stream = ACHIEVEMENTS_MUSIC_STREAM
	add_child(achievements_music)


func _setup_button_touch_sound() -> void:
	button_touch_sound = AudioStreamPlayer.new()
	button_touch_sound.name = "ButtonTouchSound"
	button_touch_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	button_touch_sound.bus = &"Master"
	button_touch_sound.stream = BUTTON_TOUCH_SOUND_STREAM
	add_child(button_touch_sound)


func _connect_button_touch_sounds() -> void:
	for node in find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		var play_sound := Callable(self, "_play_button_touch_sound")
		if not button.button_down.is_connected(play_sound):
			button.button_down.connect(play_sound)


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


func _play_death_rumble() -> void:
	if death_sound == null or death_sound.stream == null:
		return

	var duration := death_sound.stream.get_length()
	if duration <= 0.0:
		return

	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)
		Input.start_joy_vibration(device_id, DEATH_RUMBLE_WEAK, DEATH_RUMBLE_STRONG, duration)


func _stop_death_rumble() -> void:
	for device_id in Input.get_connected_joypads():
		Input.stop_joy_vibration(device_id)


func _stop_gameplay_music() -> void:
	_stop_player(game_music)

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	var fog_music := root.get_node_or_null("FogMusic") as AudioStreamPlayer
	_stop_player(fog_music)

	var base_music := root.get_node_or_null("BaseMusic") as AudioStreamPlayer
	_stop_player(base_music)


func _pause_active_music() -> void:
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


func _resume_paused_music() -> void:
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


func _stop_active_scene_audio() -> void:
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


func _hide_wave_editor() -> void:
	wave_editor_panel.hide()
	_set_label_sprite_text(wave_editor_feedback, "", 44.0)


func _show_tutorial_panel() -> void:
	_hide_wave_editor()
	_hide_achievements_panel()
	_set_skip_wave_buttons_visible(false)
	tutorial_page_index = 0
	_update_tutorial_page()
	main_panel.hide()
	logo_area.hide()
	logo.hide()
	if tutorial_button != null:
		tutorial_button.hide()
	if tutorial_panel != null:
		tutorial_panel.show()
	if tutorial_close_button != null:
		tutorial_close_button.grab_focus()


func _hide_tutorial_panel(restore_menu: bool = true) -> void:
	if tutorial_panel != null:
		tutorial_panel.hide()

	if not restore_menu:
		return
	if is_in_main_menu and not is_game_over and visible:
		main_panel.show()
		logo_area.show()
		logo.show()
		if tutorial_button != null:
			tutorial_button.show()
		_set_skip_wave_buttons_visible(true)
		if start_button != null:
			start_button.grab_focus()


func _is_tutorial_panel_visible() -> bool:
	return tutorial_panel != null and tutorial_panel.visible


func _update_tutorial_page() -> void:
	if TUTORIAL_PAGE_TEXTS.is_empty():
		return

	tutorial_page_index = clampi(tutorial_page_index, 0, TUTORIAL_PAGE_TEXTS.size() - 1)
	_update_tutorial_sprite_text(TUTORIAL_PAGE_TEXTS[tutorial_page_index])

	var previous_enabled := tutorial_page_index > 0
	var next_enabled := tutorial_page_index < TUTORIAL_PAGE_TEXTS.size() - 1
	if tutorial_previous_button != null:
		tutorial_previous_button.disabled = not previous_enabled
		tutorial_previous_button.modulate = TUTORIAL_NAV_TEXT_COLOR
	if tutorial_next_button != null:
		tutorial_next_button.disabled = not next_enabled
		tutorial_next_button.modulate = TUTORIAL_NAV_TEXT_COLOR


func _update_tutorial_sprite_text(page_data: Dictionary) -> void:
	if tutorial_text_content == null:
		return

	for child in tutorial_text_content.get_children():
		tutorial_text_content.remove_child(child)
		child.queue_free()

	var title_row := _create_sprite_text(
		String(page_data.get("title", "TUTORIAL")),
		TUTORIAL_TITLE_TEXT_HEIGHT,
		TUTORIAL_TEXT_LETTER_SPACING
	)
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tutorial_text_content.add_child(title_row)

	var page_lines := page_data.get("lines", []) as Array
	for line in page_lines:
		var body_row := _create_sprite_text(
			String(line),
			TUTORIAL_BODY_TEXT_HEIGHT,
			TUTORIAL_TEXT_LETTER_SPACING
		)
		body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body_row.alignment = BoxContainer.ALIGNMENT_CENTER
		tutorial_text_content.add_child(body_row)


func _show_achievements_panel() -> void:
	_hide_wave_editor()
	_hide_tutorial_panel(false)
	_set_skip_wave_buttons_visible(false)
	main_panel.hide()
	logo_area.hide()
	logo.hide()
	if tutorial_button != null:
		tutorial_button.hide()
	_stop_player(menu_music)
	_play_player(achievements_music)
	_reset_achievement_delete_confirmation()
	_refresh_achievements_panel()
	achievements_panel.show()
	achievements_close_button.grab_focus()


func _hide_achievements_panel() -> void:
	var was_visible := achievements_panel.visible
	achievements_panel.hide()
	_reset_achievement_delete_confirmation()
	if was_visible:
		_stop_player(achievements_music)
	if is_in_main_menu and not is_game_over:
		_play_player(menu_music)
		main_panel.show()
		logo_area.show()
		logo.show()
		if tutorial_button != null:
			tutorial_button.show()
		_set_skip_wave_buttons_visible(true)
		achievements_button.grab_focus()


func _refresh_achievements_panel() -> void:
	var main_node := _get_main_node()
	if main_node == null:
		_update_wave_record_label(null)
		_set_label_sprite_text(achievements_info_label, "COULD NOT LOAD", 24.0)
		achievements_info_label.show()
		if achievements_scroll != null:
			achievements_scroll.hide()
		return

	_update_wave_record_label(main_node)
	if main_node.has_method("get_achievements_data"):
		_refresh_achievement_cards(main_node.get_achievements_data())
		return

	if not main_node.has_method("get_achievements_text"):
		_set_label_sprite_text(achievements_info_label, "COULD NOT LOAD", 24.0)
		achievements_info_label.show()
		if achievements_scroll != null:
			achievements_scroll.hide()
		return

	_set_label_sprite_text(achievements_info_label, "ACHIEVEMENTS", 24.0)
	achievements_info_label.show()
	if achievements_scroll != null:
		achievements_scroll.hide()


func _reset_achievement_delete_confirmation() -> void:
	achievements_reset_confirmation_step = 0
	_set_button_sprite_text(achievements_reset_button, "DELETE", 58.0, RESET_BUTTON_LETTER_SPACING)
	_set_label_sprite_text(achievements_warning_label, "", 46.0)
	achievements_warning_label.modulate = Color(1.0, 0.78, 0.78, 1.0)


func _setup_sprite_texts() -> void:
	_update_hard_mode_button_text()
	_set_button_sprite_text(start_button, "PLAY", 92.0)
	_set_button_sprite_text(resume_button, "RESUME", 82.0)
	_set_button_sprite_text(restart_button, "RESTART", 78.0)
	_set_button_sprite_text(achievements_button, "ACHIEVEMENTS", 54.0)
	_set_button_sprite_text(exit_button, "EXIT", 82.0)
	_set_button_sprite_text(wave_editor_button, "EDIT WAVES", 68.0)
	_set_button_sprite_text(tutorial_previous_button, "PREVIOUS", 44.0)
	_set_button_sprite_text(tutorial_next_button, "NEXT", 50.0)
	_set_button_sprite_text(tutorial_close_button, "BACK", 56.0)
	_set_button_sprite_text(achievements_reset_button, "DELETE", 58.0, RESET_BUTTON_LETTER_SPACING)
	_set_button_sprite_text(achievements_close_button, "BACK", 84.0)
	_set_button_sprite_text(wave_editor_apply_button, "APPLY", 62.0)
	_set_button_sprite_text(wave_editor_close_button, "CLOSE", 62.0)
	for index in range(skip_wave_buttons.size()):
		var skip_button := skip_wave_buttons[index]
		var target_text := "%d" % int(SKIP_WAVE_TARGETS[index])
		_set_button_sprite_text(
			skip_button,
			target_text,
			SKIP_WAVE_BUTTON_TEXT_HEIGHT,
			SKIP_WAVE_BUTTON_LETTER_SPACING
		)
	_replace_texture_with_sprite_text(achievements_title_graphic, "ACHIEVEMENTS", 82.0, true)
	_replace_label_with_sprite_text(wave_editor_title_label, "WAVE EDITOR", 88.0, true)
	_replace_label_with_sprite_text(wave_editor_help_label, "CHANGE VALUES AND PRESS APPLY", 40.0, false)


func _set_skip_wave_buttons_visible(visible: bool) -> void:
	if skip_wave_buttons_panel != null:
		skip_wave_buttons_panel.visible = visible


func _update_hard_mode_button_text() -> void:
	if hard_mode_button == null:
		return

	var mode_text := "HARD MODE ON" if hard_mode_enabled else "HARD MODE OFF"
	_set_button_sprite_text(hard_mode_button, mode_text, 68.0)


func _sync_hard_mode_button_state() -> void:
	if hard_mode_button == null:
		return

	hard_mode_button.button_pressed = hard_mode_enabled
	_update_hard_mode_button_text()


func _apply_hard_mode_to_main() -> void:
	var main_node := _get_main_node()
	if main_node == null or not main_node.has_method("set_hard_mode_enabled"):
		return

	main_node.set_hard_mode_enabled(hard_mode_enabled)


func _load_hard_mode_setting() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_SAVE_PATH) != OK:
		hard_mode_enabled = false
		return

	hard_mode_enabled = bool(config.get_value("gameplay", "hard_mode_enabled", false))


func _save_hard_mode_setting() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_SAVE_PATH)
	config.set_value("gameplay", "hard_mode_enabled", hard_mode_enabled)
	config.save(SETTINGS_SAVE_PATH)


func _set_button_sprite_text(
	button: Button,
	text: String,
	target_height: float,
	letter_spacing: int = SPRITE_TEXT_LETTER_SPACING
) -> void:
	if button == null:
		return

	button.text = ""
	var graphic := button.get_node_or_null("Graphic") as Control
	if graphic != null:
		graphic.hide()
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, target_height + 18.0)
	var previous_text := button.get_node_or_null("SpriteTextRoot")
	if previous_text != null:
		button.remove_child(previous_text)
		previous_text.queue_free()

	var center := CenterContainer.new()
	center.name = "SpriteTextRoot"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 0.0
	center.offset_top = 0.0
	center.offset_right = 0.0
	center.offset_bottom = 0.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_create_sprite_text(text, target_height, letter_spacing))
	button.add_child(center)


func _replace_label_with_sprite_text(label: Label, text: String, target_height: float, centered: bool) -> void:
	if label == null:
		return

	var parent := label.get_parent()
	if parent == null:
		return

	var sprite_text := _create_sprite_text(text, target_height)
	sprite_text.name = "%sSpriteText" % label.name
	sprite_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_text.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
	sprite_text.custom_minimum_size = Vector2(0, maxf(label.custom_minimum_size.y, target_height + 6.0))
	parent.add_child(sprite_text)
	parent.move_child(sprite_text, label.get_index())
	label.hide()


func _replace_texture_with_sprite_text(texture_rect: TextureRect, text: String, target_height: float, centered: bool) -> void:
	if texture_rect == null:
		return

	var parent := texture_rect.get_parent()
	if parent == null:
		return

	var sprite_text := _create_sprite_text(text, target_height)
	sprite_text.name = "%sSpriteText" % texture_rect.name
	sprite_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_text.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
	sprite_text.custom_minimum_size = Vector2(0, maxf(texture_rect.custom_minimum_size.y, target_height + 6.0))
	parent.add_child(sprite_text)
	parent.move_child(sprite_text, texture_rect.get_index())
	texture_rect.hide()


func _set_label_sprite_text(label: Label, text: String, target_height: float) -> void:
	if label == null:
		return

	label.text = ""
	label.custom_minimum_size = Vector2(
		label.custom_minimum_size.x,
		maxf(label.custom_minimum_size.y, target_height + 8.0)
	)
	var previous_text := label.get_node_or_null("SpriteTextRoot")
	if previous_text != null:
		label.remove_child(previous_text)
		previous_text.queue_free()
	if text.is_empty():
		return

	var center := CenterContainer.new()
	center.name = "SpriteTextRoot"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 0.0
	center.offset_top = 0.0
	center.offset_right = 0.0
	center.offset_bottom = 0.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_create_sprite_text(text, target_height))
	label.add_child(center)


func _create_sprite_text(
	text: String,
	target_height: float,
	letter_spacing: int = SPRITE_TEXT_LETTER_SPACING
) -> HBoxContainer:
	var text_row := HBoxContainer.new()
	text_row.alignment = BoxContainer.ALIGNMENT_CENTER
	text_row.add_theme_constant_override("separation", letter_spacing)
	text_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var normalized_text := text.to_upper()
	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		if character == " ":
			var space := Control.new()
			space.custom_minimum_size = Vector2(target_height * SPRITE_TEXT_WORD_SPACING_MULTIPLIER, target_height)
			text_row.add_child(space)
			continue

		var glyph_texture := _get_sprite_font_texture(character)
		if glyph_texture == null:
			continue

		var is_digit := character.is_valid_int()
		var previous_character := normalized_text.substr(index - 1, 1) if index > 0 else ""
		var next_character := normalized_text.substr(index + 1, 1) if index < normalized_text.length() - 1 else ""
		var digit_left_gap := SPRITE_TEXT_DIGIT_WORD_GAP if is_digit and previous_character == " " else 0.0
		var digit_right_gap := SPRITE_TEXT_DIGIT_WORD_GAP if is_digit and next_character == " " else 0.0
		var glyph_height := target_height * SPRITE_TEXT_DIGIT_HEIGHT_MULTIPLIER if is_digit else target_height
		var glyph_width := glyph_height
		if glyph_texture.get_height() > 0:
			glyph_width = float(glyph_texture.get_width()) * glyph_height / float(glyph_texture.get_height())

		var glyph_advance := glyph_width + digit_left_gap + digit_right_gap
		if is_digit and letter_spacing < 0:
			glyph_advance = glyph_width + absf(float(letter_spacing)) + SPRITE_TEXT_DIGIT_MIN_GAP
			glyph_advance += digit_left_gap + digit_right_gap

		var glyph_container := Control.new()
		glyph_container.custom_minimum_size = Vector2(
			glyph_advance,
			glyph_height + _get_sprite_font_accent_height(target_height)
		)
		glyph_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var glyph_rect := TextureRect.new()
		glyph_rect.position = Vector2(
			digit_left_gap,
			_get_sprite_font_accent_height(target_height) + (target_height - glyph_height) * 0.5
		)
		glyph_rect.custom_minimum_size = Vector2(glyph_width, glyph_height)
		glyph_rect.size = glyph_rect.custom_minimum_size
		glyph_rect.texture = glyph_texture
		glyph_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glyph_container.add_child(glyph_rect)

		if _has_sprite_font_accent(character):
			glyph_container.add_child(_create_sprite_font_accent(glyph_width, target_height))

		text_row.add_child(glyph_container)

	return text_row


func _create_sprite_text_block(
	text: String,
	target_height: float,
	max_line_characters: int,
	line_separation: int = 2,
	letter_spacing: int = SPRITE_TEXT_LETTER_SPACING
) -> VBoxContainer:
	var block := VBoxContainer.new()
	block.alignment = BoxContainer.ALIGNMENT_CENTER
	block.add_theme_constant_override("separation", line_separation)
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for line in _wrap_sprite_text_lines(text, max_line_characters):
		var row := _create_sprite_text(line, target_height, letter_spacing)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		block.add_child(row)

	return block


func _wrap_sprite_text_lines(text: String, max_line_characters: int) -> Array[String]:
	var lines: Array[String] = []
	var words := _sanitize_sprite_text(text).split(" ", false)
	var current_line := ""

	for word in words:
		if current_line.is_empty():
			current_line = word
			continue

		var candidate := "%s %s" % [current_line, word]
		if candidate.length() > max_line_characters:
			lines.append(current_line)
			current_line = word
		else:
			current_line = candidate

	if not current_line.is_empty():
		lines.append(current_line)

	if lines.is_empty():
		lines.append("")

	return lines


func _sanitize_sprite_text(text: String) -> String:
	var sanitized := text.to_upper()
	var replacements := {
		".": " ",
		",": " ",
		":": " ",
		";": " ",
		"!": " ",
		"?": " ",
		"-": " ",
		"'": "",
		"\"": "",
		"/": " ",
		"(": " ",
		")": " ",
	}

	for character in replacements:
		sanitized = sanitized.replace(character, String(replacements[character]))

	return sanitized.strip_edges()


func _get_sprite_font_texture(character: String) -> Texture2D:
	if DIGIT_TEXTURES.has(character):
		return DIGIT_TEXTURES[character] as Texture2D

	var normalized_character := _normalize_sprite_font_character(character)
	var character_index := LETTER_FONT_CHARS.find(normalized_character)
	if character_index < 0:
		return null

	var texture_size := LETTER_FONT_TEXTURE.get_size()
	var cell_width := texture_size.x / float(LETTER_FONT_COLUMNS)
	var cell_height := texture_size.y / float(LETTER_FONT_ROWS)
	var column := character_index % LETTER_FONT_COLUMNS
	var row := int(character_index / LETTER_FONT_COLUMNS)
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = LETTER_FONT_TEXTURE
	atlas_texture.region = Rect2(
		column * cell_width,
		row * cell_height,
		cell_width,
		cell_height
	)
	return atlas_texture


func _has_sprite_font_accent(character: String) -> bool:
	return character in ["Á", "É", "Í", "Ó", "Ú"]


func _get_sprite_font_accent_height(target_height: float) -> float:
	return target_height * 0.22


func _create_sprite_font_accent(glyph_width: float, target_height: float) -> Control:
	var accent := ColorRect.new()
	var accent_width := maxf(target_height * 0.22, 6.0)
	var accent_height := maxf(target_height * 0.08, 3.0)
	accent.color = Color.BLACK
	accent.size = Vector2(accent_width, accent_height)
	accent.position = Vector2(
		(glyph_width - accent_width) * 0.5 + target_height * 0.08,
		target_height * 0.03
	)
	accent.rotation = -0.45
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return accent


func _normalize_sprite_font_character(character: String) -> String:
	match character:
		"Á", "À", "Ä", "Â":
			return "A"
		"É", "È", "Ë", "Ê":
			return "E"
		"Í", "Ì", "Ï", "Î":
			return "I"
		"Ó", "Ò", "Ö", "Ô":
			return "O"
		"Ú", "Ù", "Ü", "Û":
			return "U"
		"Ñ":
			return "N"
		_:
			return character


func _setup_achievements_cards_view() -> void:
	achievements_info_label.hide()

	achievements_record_row = HBoxContainer.new()
	achievements_record_row.name = "WaveRecordRow"
	achievements_record_row.custom_minimum_size = Vector2(0, 96)
	achievements_record_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_record_row.alignment = BoxContainer.ALIGNMENT_CENTER
	achievements_record_row.add_theme_constant_override("separation", 10)

	var record_title := _create_sprite_text("RECORD", 70.0)
	record_title.name = "WaveRecordTitle"
	record_title.custom_minimum_size = RECORD_TITLE_SIZE
	record_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	achievements_record_row.add_child(record_title)

	achievements_record_digits = HBoxContainer.new()
	achievements_record_digits.name = "WaveRecordDigits"
	achievements_record_digits.custom_minimum_size = Vector2(80, RECORD_DIGIT_TARGET_HEIGHT)
	achievements_record_digits.alignment = BoxContainer.ALIGNMENT_CENTER
	achievements_record_digits.add_theme_constant_override("separation", RECORD_DIGIT_SPACING)
	achievements_record_row.add_child(achievements_record_digits)

	achievements_content.add_child(achievements_record_row)
	achievements_content.move_child(achievements_record_row, achievements_info_label.get_index())

	achievements_scroll = ScrollContainer.new()
	achievements_scroll.name = "AchievementCardsScroll"
	achievements_scroll.custom_minimum_size = Vector2(0, 450)
	achievements_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	achievements_cards_list = GridContainer.new()
	achievements_cards_list.name = "AchievementCardsList"
	achievements_cards_list.columns = 2
	achievements_cards_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_cards_list.add_theme_constant_override("h_separation", ACHIEVEMENT_GRID_SPACING)
	achievements_cards_list.add_theme_constant_override("v_separation", ACHIEVEMENT_GRID_SPACING)
	achievements_scroll.add_child(achievements_cards_list)

	achievements_content.add_child(achievements_scroll)
	achievements_content.move_child(achievements_scroll, achievements_info_label.get_index())


func _update_wave_record_label(main_node: Node) -> void:
	if achievements_record_digits == null:
		return

	var wave_record := 0
	if main_node != null and main_node.has_method("get_wave_record"):
		wave_record = int(main_node.get_wave_record())

	_render_record_digits(wave_record)
	if achievements_record_row != null:
		achievements_record_row.show()


func _render_record_digits(value: int) -> void:
	for child in achievements_record_digits.get_children():
		achievements_record_digits.remove_child(child)
		child.queue_free()

	for digit_char in str(maxi(value, 0)):
		var digit_texture: Texture2D = DIGIT_TEXTURES.get(str(digit_char))
		if digit_texture == null:
			continue

		var digit_height := RECORD_DIGIT_TARGET_HEIGHT
		var digit_width := digit_height
		if digit_texture.get_height() > 0:
			digit_width = float(digit_texture.get_width()) * digit_height / float(digit_texture.get_height())

		var digit_rect := TextureRect.new()
		digit_rect.custom_minimum_size = Vector2(digit_width, digit_height)
		digit_rect.texture = digit_texture
		digit_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		digit_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		digit_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		achievements_record_digits.add_child(digit_rect)


func _refresh_achievement_cards(achievements: Array) -> void:
	if achievements_cards_list == null:
		_set_label_sprite_text(achievements_info_label, "COULD NOT LOAD", 24.0)
		achievements_info_label.show()
		if achievements_scroll != null:
			achievements_scroll.hide()
		return

	achievements_info_label.hide()
	if achievements_scroll != null:
		achievements_scroll.show()
	for child in achievements_cards_list.get_children():
		achievements_cards_list.remove_child(child)
		child.queue_free()

	for achievement in achievements:
		if not (achievement is Dictionary):
			continue

		var achievement_data: Dictionary = achievement
		var unlocked := bool(achievement_data.get("unlocked", false))
		achievements_cards_list.add_child(_create_achievement_card(achievement_data, unlocked))


func _create_achievement_card(achievement_data: Dictionary, unlocked: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = ACHIEVEMENT_CARD_SIZE
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _create_achievement_card_stylebox(unlocked))
	card.modulate = Color.WHITE if unlocked else Color(0.72, 0.72, 0.72, 0.9)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)

	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	margin.add_child(content)

	var achievement_id := StringName(achievement_data.get("id", &""))
	var achievement_texture := ACHIEVEMENT_IMAGE_TEXTURES.get(achievement_id) as Texture2D
	var image_holder := CenterContainer.new()
	image_holder.custom_minimum_size = Vector2(ACHIEVEMENT_IMAGE_SIZE.x, 0)
	image_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(image_holder)

	if achievement_texture != null:
		var image := TextureRect.new()
		image.custom_minimum_size = ACHIEVEMENT_IMAGE_SIZE
		image.texture = achievement_texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image_holder.add_child(image)

	var text_content := VBoxContainer.new()
	text_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_content.add_theme_constant_override("separation", 10)
	content.add_child(text_content)

	var show_secret := achievement_id == ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON and not unlocked
	var title_text := "Secret" if show_secret else String(achievement_data.get("title", "Achievement"))
	var description_text := (
		"Unlock this achievement to reveal it."
		if show_secret
		else String(achievement_data.get("description", ""))
	)

	var status_text := _create_sprite_text(
		"UNLOCKED" if unlocked else "LOCKED",
		ACHIEVEMENT_STATUS_TEXT_HEIGHT,
		-8
	)
	status_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_text.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.add_child(status_text)

	var title_block := _create_sprite_text_block(
		title_text,
		ACHIEVEMENT_TITLE_TEXT_HEIGHT,
		ACHIEVEMENT_TITLE_MAX_LINE_CHARS,
		2,
		-12
	)
	title_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_content.add_child(title_block)

	var description_block := _create_sprite_text_block(
		description_text,
		ACHIEVEMENT_DESCRIPTION_TEXT_HEIGHT,
		ACHIEVEMENT_DESCRIPTION_MAX_LINE_CHARS,
		1,
		ACHIEVEMENT_DESCRIPTION_LETTER_SPACING
	)
	description_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_content.add_child(description_block)

	return card


func _create_achievement_card_stylebox(unlocked: bool) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.22, 0.15, 0.09, 0.94) if unlocked else Color(0.13, 0.13, 0.13, 0.92)
	stylebox.border_color = Color(0.76, 0.58, 0.36, 0.9) if unlocked else Color(0.42, 0.42, 0.42, 0.8)
	stylebox.set_border_width_all(4)
	stylebox.set_corner_radius_all(8)
	return stylebox


func _setup_panel_backgrounds() -> void:
	_ensure_panel_background(main_panel, MENU_BUTTONS_BACKGROUND_TEXTURE, "MenuButtonsBackground")
	_clear_panel_visual(main_panel)
	_ensure_panel_background(achievements_panel, ACHIEVEMENTS_BACKGROUND_TEXTURE, "AchievementsBackground")
	_clear_panel_visual(achievements_panel)


func _ensure_panel_background(
	panel: PanelContainer,
	texture: Texture2D,
	background_name: StringName
) -> void:
	if panel == null or texture == null:
		return

	var existing_background := panel.get_node_or_null(String(background_name)) as TextureRect
	if existing_background != null:
		existing_background.texture = texture
		existing_background.z_index = 0
		return

	var background := TextureRect.new()
	background.name = String(background_name)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0.0
	background.offset_top = 0.0
	background.offset_right = 0.0
	background.offset_bottom = 0.0
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture = texture
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(background)
	panel.move_child(background, 0)


func _clear_panel_visual(panel: PanelContainer) -> void:
	if panel == null:
		return

	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())


func _get_main_node() -> Node:
	return get_parent()

class_name HudController
extends Node

## In-game HUD, extracted from main.gd: the WAVE label + number, the power-up
## count icons/digits, the selected-power-up highlight, and the stamina bar.
##
## main.gd creates this as a child, sets `main`, and calls setup() after the
## CanvasLayer exists; it then connects the player's signals straight to the
## update_* methods. HUD nodes from main.tscn live under main/CanvasLayer, and
## the widgets this builds are added there too, so layout is unchanged. Reads
## main.wave_director.current_wave / main.wave_director.wave_active for the wave label.

const WAVE_TITLE_TEXT := "WAVE"
const WAVE_TITLE_TEXT_HEIGHT := 66.0
const WAVE_TITLE_LETTER_SPACING := -17.0
const COUNT_MULTIPLIER_TEXTURE := preload("res://assets/Texto/x.png")
const SELECTED_POWER_UP_ICON_SCALE := 1.14
const POWER_UP_MEDKIT := &"medkit"
const POWER_UP_TELEPORT_ORB := &"teleport_orb"
const POWER_UP_GRENADE := &"grenade"
const POWER_UP_MINE := &"mine"

var main: Node = null

var canvas_layer: CanvasLayer = null
var wave_label: Label = null
var grenade_icon: TextureRect = null
var grenade_count_label: Label = null
var medkit_icon: TextureRect = null
var medkit_count_label: Label = null
var mine_icon: TextureRect = null
var mine_count_label: Label = null
var teleport_orb_icon: TextureRect = null
var teleport_orb_count_label: Label = null

var wave_display_root: Node2D = null
var wave_number_root: Node2D = null
var grenade_count_digits_root: Node2D = null
var medkit_count_digits_root: Node2D = null
var mine_count_digits_root: Node2D = null
var teleport_orb_count_digits_root: Node2D = null
var stamina_bar_panel: PanelContainer = null
var stamina_bar: ProgressBar = null

var displayed_number_cache: Dictionary = {}
var white_sprite_text_material: ShaderMaterial = null
var selected_power_up_id: StringName = &""
var power_up_icon_base_scales: Dictionary = {}


func setup() -> void:
	canvas_layer = main.get_node_or_null("CanvasLayer") as CanvasLayer
	wave_label = main.get_node_or_null("CanvasLayer/WaveLabel") as Label
	grenade_icon = main.get_node_or_null("CanvasLayer/GrenadeIcon") as TextureRect
	grenade_count_label = main.get_node_or_null("CanvasLayer/GrenadeCountLabel") as Label
	medkit_icon = main.get_node_or_null("CanvasLayer/MedkitIcon") as TextureRect
	medkit_count_label = main.get_node_or_null("CanvasLayer/MedkitCountLabel") as Label
	mine_icon = main.get_node_or_null("CanvasLayer/MineIcon") as TextureRect
	mine_count_label = main.get_node_or_null("CanvasLayer/MineCountLabel") as Label
	teleport_orb_icon = main.get_node_or_null("CanvasLayer/TeleportOrbIcon") as TextureRect
	teleport_orb_count_label = main.get_node_or_null("CanvasLayer/TeleportOrbCountLabel") as Label

	_setup_number_displays()
	_setup_stamina_bar()
	_setup_power_up_selection()


func update_wave_label() -> void:
	if not is_instance_valid(wave_display_root):
		return

	wave_display_root.show()
	var wave_number: int = main.wave_director.current_wave if main.wave_director.wave_active else main.wave_director.current_wave + 1
	_render_number_as_sprites("wave", wave_number_root, wave_number, 44.0, 5.0)


func set_wave_display_visible(value: bool) -> void:
	if is_instance_valid(wave_display_root):
		wave_display_root.visible = value


func hide_for_game_over() -> void:
	if is_instance_valid(wave_label):
		wave_label.hide()
	if is_instance_valid(wave_display_root):
		wave_display_root.hide()
	if is_instance_valid(stamina_bar_panel):
		stamina_bar_panel.hide()


func set_selected_power_up(power_up_id: StringName) -> void:
	selected_power_up_id = power_up_id
	update_selected_power_up_ui()


func update_stamina_bar(stamina: float, max_stamina: float) -> void:
	if not is_instance_valid(stamina_bar):
		return

	var safe_max_stamina := maxf(max_stamina, 1.0)
	var stamina_ratio := clampf(stamina / safe_max_stamina, 0.0, 1.0)
	stamina_bar.max_value = safe_max_stamina
	stamina_bar.value = clampf(stamina, 0.0, safe_max_stamina)

	var fill_color := Color(0.22, 0.92, 0.38, 1.0)
	if stamina_ratio <= 0.25:
		fill_color = Color(0.95, 0.12, 0.08, 1.0)
	elif stamina_ratio <= 0.55:
		fill_color = Color(1.0, 0.78, 0.16, 1.0)
	stamina_bar.add_theme_stylebox_override("fill", _create_stamina_bar_fill_stylebox(fill_color))


func update_grenade_icon(grenade_count: int) -> void:
	if not is_instance_valid(grenade_icon) or not is_instance_valid(grenade_count_label):
		return

	var has_grenades := grenade_count > 0
	grenade_icon.visible = has_grenades
	update_selected_power_up_ui()
	grenade_count_label.hide()
	if is_instance_valid(grenade_count_digits_root):
		grenade_count_digits_root.visible = has_grenades
		_render_number_as_sprites("grenades", grenade_count_digits_root, grenade_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func update_medkit_icon(medkit_count: int) -> void:
	if not is_instance_valid(medkit_icon) or not is_instance_valid(medkit_count_label):
		return

	var has_medkits := medkit_count > 0
	medkit_icon.visible = has_medkits
	update_selected_power_up_ui()
	medkit_count_label.hide()
	if is_instance_valid(medkit_count_digits_root):
		medkit_count_digits_root.hide()


func update_mine_icon(mine_count: int) -> void:
	if not is_instance_valid(mine_icon) or not is_instance_valid(mine_count_label):
		return

	var has_mines := mine_count > 0
	mine_icon.visible = has_mines
	update_selected_power_up_ui()
	mine_count_label.hide()
	if is_instance_valid(mine_count_digits_root):
		mine_count_digits_root.visible = has_mines
		_render_number_as_sprites("mines", mine_count_digits_root, mine_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func update_teleport_orb_icon(teleport_orb_count: int) -> void:
	if not is_instance_valid(teleport_orb_icon) or not is_instance_valid(teleport_orb_count_label):
		return

	var has_teleport_orbs := teleport_orb_count > 0
	teleport_orb_icon.visible = has_teleport_orbs
	update_selected_power_up_ui()
	teleport_orb_count_label.hide()
	if is_instance_valid(teleport_orb_count_digits_root):
		teleport_orb_count_digits_root.visible = has_teleport_orbs
		_render_number_as_sprites("teleport_orbs", teleport_orb_count_digits_root, teleport_orb_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func _setup_power_up_selection() -> void:
	var icon_by_power_up := _get_power_up_icons()
	for power_up_id in icon_by_power_up:
		var icon := icon_by_power_up[power_up_id] as TextureRect
		if not is_instance_valid(icon):
			continue
		power_up_icon_base_scales[power_up_id] = icon.scale
		icon.pivot_offset = icon.size * 0.5


func update_selected_power_up_ui() -> void:
	var icon_by_power_up := _get_power_up_icons()
	for power_up_id in icon_by_power_up:
		var icon := icon_by_power_up[power_up_id] as TextureRect
		if not is_instance_valid(icon):
			continue
		if icon.pivot_offset == Vector2.ZERO:
			icon.pivot_offset = icon.size * 0.5
		var base_scale: Vector2 = power_up_icon_base_scales.get(power_up_id, Vector2.ONE)
		icon.scale = base_scale * (SELECTED_POWER_UP_ICON_SCALE if power_up_id == selected_power_up_id and icon.visible else 1.0)


func _get_power_up_icons() -> Dictionary:
	return {
		POWER_UP_GRENADE: grenade_icon,
		POWER_UP_MEDKIT: medkit_icon,
		POWER_UP_TELEPORT_ORB: teleport_orb_icon,
		POWER_UP_MINE: mine_icon,
	}


func _setup_number_displays() -> void:
	if not is_instance_valid(wave_label):
		return

	wave_label.hide()
	wave_display_root = Node2D.new()
	wave_display_root.name = "WaveDisplayRoot"
	wave_display_root.position = Vector2(wave_label.offset_left, wave_label.offset_top)
	canvas_layer.add_child(wave_display_root)

	var wave_title_root := _create_sprite_word_root(
		WAVE_TITLE_TEXT,
		WAVE_TITLE_TEXT_HEIGHT,
		WAVE_TITLE_LETTER_SPACING
	)
	wave_title_root.name = "WaveTitleRoot"
	wave_display_root.add_child(wave_title_root)

	wave_number_root = Node2D.new()
	wave_number_root.name = "WaveNumberRoot"
	wave_number_root.position = Vector2(226.0, 8.0)
	wave_display_root.add_child(wave_number_root)

	grenade_count_digits_root = _create_count_digits_root("GrenadeCountDigits", grenade_count_label)
	medkit_count_digits_root = _create_count_digits_root("MedkitCountDigits", medkit_count_label)
	mine_count_digits_root = _create_count_digits_root("MineCountDigits", mine_count_label)
	teleport_orb_count_digits_root = _create_count_digits_root("TeleportOrbCountDigits", teleport_orb_count_label)


func _setup_stamina_bar() -> void:
	if canvas_layer == null:
		return

	stamina_bar_panel = PanelContainer.new()
	stamina_bar_panel.name = "StaminaBarPanel"
	stamina_bar_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	stamina_bar_panel.offset_left = -620.0
	stamina_bar_panel.offset_top = -74.0
	stamina_bar_panel.offset_right = -80.0
	stamina_bar_panel.offset_bottom = -24.0
	stamina_bar_panel.add_theme_stylebox_override("panel", _create_stamina_panel_stylebox())
	canvas_layer.add_child(stamina_bar_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	stamina_bar_panel.add_child(margin)

	var content := HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)

	var label := _create_white_sprite_text_row("STAMINA", 40.0, -18.0)
	label.custom_minimum_size = Vector2(190, 46)
	label.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(label)

	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(340, 28)
	stamina_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamina_bar.min_value = 0.0
	stamina_bar.max_value = 100.0
	stamina_bar.value = 100.0
	stamina_bar.show_percentage = false
	stamina_bar.add_theme_stylebox_override("background", _create_stamina_bar_background_stylebox())
	stamina_bar.add_theme_stylebox_override("fill", _create_stamina_bar_fill_stylebox(Color(0.22, 0.92, 0.38, 1.0)))
	content.add_child(stamina_bar)


func _create_stamina_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.04, 0.05, 0.06, 0.82)
	stylebox.border_color = Color(0.98, 0.82, 0.24, 0.95)
	stylebox.set_border_width_all(3)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.45)
	stylebox.shadow_size = 8
	return stylebox


func _create_stamina_bar_background_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.02, 0.02, 0.02, 0.94)
	stylebox.border_color = Color(0.0, 0.0, 0.0, 0.75)
	stylebox.set_border_width_all(2)
	stylebox.set_corner_radius_all(5)
	return stylebox


func _create_stamina_bar_fill_stylebox(fill_color: Color) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = fill_color
	stylebox.set_corner_radius_all(4)
	return stylebox


func _create_white_sprite_text_row(text: String, target_height: float, letter_spacing: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(letter_spacing))
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

		var glyph_width := target_height
		if glyph_texture.get_height() > 0:
			glyph_width = float(glyph_texture.get_width()) * target_height / float(glyph_texture.get_height())

		var glyph_rect := TextureRect.new()
		glyph_rect.custom_minimum_size = Vector2(glyph_width, target_height)
		glyph_rect.size = glyph_rect.custom_minimum_size
		glyph_rect.texture = glyph_texture
		glyph_rect.material = _get_white_sprite_text_material()
		glyph_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(glyph_rect)

	return row


func _get_white_sprite_text_material() -> ShaderMaterial:
	if white_sprite_text_material != null:
		return white_sprite_text_material

	var shader := Shader.new()
	shader.code = (
		"shader_type canvas_item;\n"
		+ "uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);\n"
		+ "void fragment() {\n"
		+ "	vec4 tex = texture(TEXTURE, UV);\n"
		+ "	COLOR = vec4(text_color.rgb, tex.a * text_color.a);\n"
		+ "}\n"
	)
	white_sprite_text_material = ShaderMaterial.new()
	white_sprite_text_material.shader = shader
	white_sprite_text_material.set_shader_parameter("text_color", Color.WHITE)
	return white_sprite_text_material


func _create_count_digits_root(root_name: String, label: Label) -> Node2D:
	if not is_instance_valid(label):
		return null

	label.hide()
	var digits_root := Node2D.new()
	digits_root.name = root_name
	digits_root.position = Vector2(label.offset_left, label.offset_top + 10.0)
	digits_root.visible = false
	canvas_layer.add_child(digits_root)
	return digits_root


func _create_sprite_word_root(text: String, target_height: float, spacing: float) -> Node2D:
	var word_root := Node2D.new()
	var x_offset := 0.0
	var normalized_text := text.to_upper()

	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		var letter_texture := SpriteFont.get_glyph_texture(character)
		if letter_texture == null:
			continue

		var letter_sprite := Sprite2D.new()
		letter_sprite.texture = letter_texture
		letter_sprite.centered = false
		var letter_scale := target_height / float(letter_texture.get_height())
		letter_sprite.scale = Vector2.ONE * letter_scale
		letter_sprite.position = Vector2(x_offset, 0.0)
		word_root.add_child(letter_sprite)
		x_offset += (letter_texture.get_width() * letter_scale) + spacing

	return word_root


func _render_number_as_sprites(cache_key: String, digits_root: Node2D, value: int, target_height: float, spacing: float, prefix_texture: Texture2D = null, prefix_spacing: float = 0.0) -> void:
	if not is_instance_valid(digits_root):
		return

	var safe_value := maxi(value, 0)
	if displayed_number_cache.get(cache_key, -1) == safe_value:
		return

	displayed_number_cache[cache_key] = safe_value
	for child in digits_root.get_children():
		child.queue_free()

	var x_offset := 0.0
	if prefix_texture != null:
		var prefix_sprite := Sprite2D.new()
		prefix_sprite.texture = prefix_texture
		prefix_sprite.centered = false
		var prefix_scale := target_height / float(prefix_texture.get_height())
		prefix_sprite.scale = Vector2.ONE * prefix_scale
		prefix_sprite.position = Vector2.ZERO
		digits_root.add_child(prefix_sprite)
		x_offset += (prefix_texture.get_width() * prefix_scale) + prefix_spacing

	for digit_char in str(safe_value):
		var digit_texture: Texture2D = SpriteFont.DIGIT_TEXTURES.get(str(digit_char))
		if digit_texture == null:
			continue

		var digit_sprite := Sprite2D.new()
		digit_sprite.texture = digit_texture
		digit_sprite.centered = false
		var digit_scale := target_height / float(digit_texture.get_height())
		digit_sprite.scale = Vector2.ONE * digit_scale
		digit_sprite.position = Vector2(x_offset, 0.0)
		digits_root.add_child(digit_sprite)
		x_offset += (digit_texture.get_width() * digit_scale) + spacing

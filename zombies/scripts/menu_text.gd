class_name MenuText
extends RefCounted

## Bitmap sprite-text builders for the menu UI: turns a string into a row of
## glyph TextureRects (with accent marks and digit spacing), and helpers that
## swap a Button/Label/TextureRect's content for sprite text. Stateless static
## helpers shared by every menu screen; glyph lookup goes through SpriteFont.

const SPRITE_TEXT_LETTER_SPACING := -26
const SPRITE_TEXT_DIGIT_HEIGHT_MULTIPLIER := 0.6
const SPRITE_TEXT_DIGIT_MIN_GAP := 3.0
const SPRITE_TEXT_DIGIT_WORD_GAP := 34.0
const SPRITE_TEXT_WORD_SPACING_MULTIPLIER := 0.78


static func set_button_sprite_text(
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
	center.add_child(create_sprite_text(text, target_height, letter_spacing))
	button.add_child(center)


static func replace_label_with_sprite_text(label: Label, text: String, target_height: float, centered: bool) -> void:
	if label == null:
		return

	var parent := label.get_parent()
	if parent == null:
		return

	var sprite_text := create_sprite_text(text, target_height)
	sprite_text.name = "%sSpriteText" % label.name
	sprite_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_text.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
	sprite_text.custom_minimum_size = Vector2(0, maxf(label.custom_minimum_size.y, target_height + 6.0))
	parent.add_child(sprite_text)
	parent.move_child(sprite_text, label.get_index())
	label.hide()


static func replace_texture_with_sprite_text(texture_rect: TextureRect, text: String, target_height: float, centered: bool) -> void:
	if texture_rect == null:
		return

	var parent := texture_rect.get_parent()
	if parent == null:
		return

	var sprite_text := create_sprite_text(text, target_height)
	sprite_text.name = "%sSpriteText" % texture_rect.name
	sprite_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite_text.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
	sprite_text.custom_minimum_size = Vector2(0, maxf(texture_rect.custom_minimum_size.y, target_height + 6.0))
	parent.add_child(sprite_text)
	parent.move_child(sprite_text, texture_rect.get_index())
	texture_rect.hide()


static func set_label_sprite_text(label: Label, text: String, target_height: float) -> void:
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
	center.add_child(create_sprite_text(text, target_height))
	label.add_child(center)


static func create_sprite_text(
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

		var glyph_texture := SpriteFont.get_glyph_texture(character)
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


static func create_sprite_text_block(
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

	for line in SpriteFont.wrap_lines(text, max_line_characters):
		var row := create_sprite_text(line, target_height, letter_spacing)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		block.add_child(row)

	return block


static func _has_sprite_font_accent(character: String) -> bool:
	return character in ["Á", "É", "Í", "Ó", "Ú"]


static func _get_sprite_font_accent_height(target_height: float) -> float:
	return target_height * 0.22


static func _create_sprite_font_accent(glyph_width: float, target_height: float) -> Control:
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

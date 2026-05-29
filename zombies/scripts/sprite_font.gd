class_name SpriteFont
extends RefCounted

## Shared bitmap-font primitives used by both the in-game HUD (main.gd) and the
## menus (menu.gd). Owns the glyph atlas, accented-character normalization, text
## sanitization and line wrapping.
##
## The higher-level row/block builders stay in their own scripts because they
## genuinely differ: menu.gd draws accent marks and per-digit gaps, while main.gd
## recolours glyphs with a shader and renders the HUD with Sprite2D nodes. Those
## builders all funnel their glyph lookups through get_glyph_texture() here.

const LETTER_FONT_TEXTURE := preload("res://assets/Texto/Fuente de letras.png")
const LETTER_FONT_COLUMNS := 13
const LETTER_FONT_ROWS := 2
const LETTER_FONT_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
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

const _PUNCTUATION_REPLACEMENTS := {
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


## Returns the texture for a single character (digit sprite or letter atlas
## region), or null when the character has no glyph.
static func get_glyph_texture(character: String) -> Texture2D:
	if DIGIT_TEXTURES.has(character):
		return DIGIT_TEXTURES[character] as Texture2D

	var normalized_character := normalize_character(character)
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


## Maps accented (and common mojibake) characters to their base letter.
static func normalize_character(character: String) -> String:
	match character:
		"Á", "À", "Ä", "Â", "Ã", "Ã€", "Ã„", "Ã‚":
			return "A"
		"É", "È", "Ë", "Ê", "Ã‰", "Ãˆ", "Ã‹", "ÃŠ":
			return "E"
		"Í", "Ì", "Ï", "Î", "Ã", "ÃŒ", "Ã", "ÃŽ":
			return "I"
		"Ó", "Ò", "Ö", "Ô", "Ã“", "Ã’", "Ã–", "Ã”":
			return "O"
		"Ú", "Ù", "Ü", "Û", "Ãš", "Ã™", "Ãœ", "Ã›":
			return "U"
		"Ñ", "Ã‘":
			return "N"
		_:
			return character


## Upper-cases the text and strips punctuation down to spaces.
static func sanitize_text(text: String) -> String:
	var sanitized := text.to_upper()
	for character in _PUNCTUATION_REPLACEMENTS:
		sanitized = sanitized.replace(character, String(_PUNCTUATION_REPLACEMENTS[character]))
	return sanitized.strip_edges()


## Word-wraps sanitized text into lines no longer than max_line_characters.
## Always returns at least one (possibly empty) line.
static func wrap_lines(text: String, max_line_characters: int) -> Array[String]:
	var lines: Array[String] = []
	var words := sanitize_text(text).split(" ", false)
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

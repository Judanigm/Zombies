class_name BaseZoneController
extends Node

## The home-base "explanada": scene construction (floor, walls, fences, campfire,
## boxes, buildable base + preview), the build UI/picker, and the stored-loot
## display. Extracted from main.gd.
##
## main.gd creates this as a child, sets `main`, and calls setup() after the
## CanvasLayer exists. main keeps the cross-system base navigation (go_to_base /
## return_from_base, which move the player/camera, pause zombies and switch
## music) and calls show_zone()/hide_zone()/update_travel_ui()/update_loot_display()
## /cancel_build_preview() here. Visual nodes are parented under main / main's
## CanvasLayer / base_zone_root exactly as before. Build cost goes through the
## LootEconomy autoload. Reads main.is_in_base_zone / main.player_dead.

const BASE_ZONE_TEXTURE := preload("res://assets/Texto/Explanada de base.png")
const BASE_HORIZONTAL_FENCE_TEXTURE := preload("res://assets/Objetos de la base/Valla de madera.png")
const BASE_VERTICAL_FENCE_TEXTURE := preload("res://assets/Objetos de la base/Valla vertical.png")
const BASE_CAMPFIRE_TEXTURE := preload("res://assets/Objetos de la base/Fogata.png")
const BASE_SMOKE_TEXTURE := preload("res://assets/Objetos de la base/Particula de humo.png")
const BASE_BOX_TEXTURE := preload("res://assets/Objetos de la base/Caja.png")
const BASE_BUILDING_TEXTURE := preload("res://assets/Objetos de la base/Base.png")
const BASE_BUILD_BUTTON_TEXTURE := preload("res://assets/Texto/Botón construir.png")
const BASE_ZONE_ORIGIN := Vector2(5200, 0)
const BASE_ZONE_SIZE := Vector2(3500, 2625)
const BASE_ZONE_WALL_THICKNESS := 72.0
const BASE_ZONE_PLAYER_SPAWN_OFFSET := Vector2(0, 260)
const BASE_FENCE_TARGET_MAX_SIZE := 126.0
const BASE_BOTTOM_GATE_WIDTH_RATIO := 1.15
const BASE_BOX_TARGET_MAX_SIZE := 170.0
const BASE_BOX_FENCE_PADDING := Vector2(155.0, 145.0)
const BASE_BUILDING_TARGET_MAX_SIZE := 1700.0
const BASE_BUILT_BOX_TARGET_MAX_SIZE := 150.0
const BASE_BUILT_BOX_PADDING := 110.0
const BASE_BUILD_BUTTON_SIZE := Vector2(280.0, 104.0)
const BASE_BUILD_PICKER_SIZE := Vector2(560.0, 178.0)
const BASE_BUILD_OPTION_SIZE := Vector2(210.0, 142.0)

var main: Node = null

var base_zone_root: Node2D = null
var base_default_content_root: Node2D = null
var base_building_body: StaticBody2D = null
var base_building_sprite: Sprite2D = null
var base_building_collision: CollisionShape2D = null
var base_building_click_area: Area2D = null
var base_zone_label: Label = null
var base_build_button: Button = null
var base_build_picker_panel: PanelContainer = null
var base_build_option_button: Button = null
var base_loot_display_root: Control = null
var base_build_picker_open: bool = false
var base_build_preview_active: bool = false
var base_building_placed: bool = false


func setup() -> void:
	_setup_base_zone()
	_setup_base_travel_ui()
	_setup_base_build_ui()


func show_zone() -> void:
	if is_instance_valid(base_zone_root):
		base_zone_root.show()


func hide_zone() -> void:
	if is_instance_valid(base_zone_root):
		base_zone_root.hide()


func _setup_base_zone() -> void:
	if base_zone_root != null:
		return

	base_zone_root = Node2D.new()
	base_zone_root.name = "ExplanadaBase"
	base_zone_root.position = BASE_ZONE_ORIGIN
	base_zone_root.z_index = 20
	base_zone_root.visible = false
	main.add_child(base_zone_root)

	base_default_content_root = Node2D.new()
	base_default_content_root.name = "BaseDefaultContent"
	base_zone_root.add_child(base_default_content_root)
	_setup_base_loot_display()

	var half_size := BASE_ZONE_SIZE * 0.5
	var base_floor := Sprite2D.new()
	base_floor.name = "BaseFloor"
	base_floor.texture = BASE_ZONE_TEXTURE
	base_floor.centered = true
	base_floor.z_index = -20
	if BASE_ZONE_TEXTURE != null and BASE_ZONE_TEXTURE.get_width() > 0 and BASE_ZONE_TEXTURE.get_height() > 0:
		base_floor.scale = Vector2(
			BASE_ZONE_SIZE.x / float(BASE_ZONE_TEXTURE.get_width()),
			BASE_ZONE_SIZE.y / float(BASE_ZONE_TEXTURE.get_height())
		)
	base_zone_root.add_child(base_floor)

	_add_base_wall(
		"BaseTopWall",
		Vector2(0, -half_size.y - BASE_ZONE_WALL_THICKNESS * 0.5),
		Vector2(BASE_ZONE_SIZE.x + BASE_ZONE_WALL_THICKNESS * 2.0, BASE_ZONE_WALL_THICKNESS)
	)
	_add_base_wall(
		"BaseBottomWall",
		Vector2(0, half_size.y + BASE_ZONE_WALL_THICKNESS * 0.5),
		Vector2(BASE_ZONE_SIZE.x + BASE_ZONE_WALL_THICKNESS * 2.0, BASE_ZONE_WALL_THICKNESS)
	)
	_add_base_wall(
		"BaseLeftWall",
		Vector2(-half_size.x - BASE_ZONE_WALL_THICKNESS * 0.5, 0),
		Vector2(BASE_ZONE_WALL_THICKNESS, BASE_ZONE_SIZE.y)
	)
	_add_base_wall(
		"BaseRightWall",
		Vector2(half_size.x + BASE_ZONE_WALL_THICKNESS * 0.5, 0),
		Vector2(BASE_ZONE_WALL_THICKNESS, BASE_ZONE_SIZE.y)
	)
	_setup_base_fences()
	_setup_base_campfire()
	_setup_base_corner_boxes()
	_setup_base_building_preview()


func _setup_base_travel_ui() -> void:
	var canvas_layer := main.get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	base_zone_label = Label.new()
	base_zone_label.name = "BaseZoneLabel"
	base_zone_label.text = "EXPLANADA BASE"
	base_zone_label.visible = false
	base_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base_zone_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	base_zone_label.offset_left = -260.0
	base_zone_label.offset_top = 24.0
	base_zone_label.offset_right = 260.0
	base_zone_label.offset_bottom = 80.0
	base_zone_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 1.0))
	base_zone_label.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.04, 0.95))
	base_zone_label.add_theme_constant_override("outline_size", 5)
	base_zone_label.add_theme_font_size_override("font_size", 36)
	canvas_layer.add_child(base_zone_label)

	update_travel_ui()


func _setup_base_loot_display() -> void:
	if base_loot_display_root != null:
		return

	var canvas_layer := main.get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	var display_panel := PanelContainer.new()
	base_loot_display_root = display_panel
	base_loot_display_root.name = "BaseLootDisplay"
	base_loot_display_root.visible = false
	base_loot_display_root.custom_minimum_size = Vector2(300.0, 250.0)
	base_loot_display_root.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	base_loot_display_root.offset_left = -BASE_BUILD_BUTTON_SIZE.x - 24.0
	base_loot_display_root.offset_top = 24.0 + BASE_BUILD_BUTTON_SIZE.y + 14.0
	base_loot_display_root.offset_right = -24.0
	base_loot_display_root.offset_bottom = base_loot_display_root.offset_top + 250.0
	display_panel.add_theme_stylebox_override("panel", _create_base_build_panel_stylebox())
	canvas_layer.add_child(base_loot_display_root)
	update_loot_display()


func update_loot_display() -> void:
	if not is_instance_valid(base_loot_display_root):
		return

	for child in base_loot_display_root.get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	base_loot_display_root.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Loot guardado"
	title.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.03, 1.0))
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_font_size_override("font_size", 26)
	content.add_child(title)

	var build_cost_label := Label.new()
	build_cost_label.text = "Base: madera %d, hierro %d" % [LootEconomy.BASE_BUILD_WOOD_COST, LootEconomy.BASE_BUILD_IRON_COST]
	build_cost_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68, 1.0))
	build_cost_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
	build_cost_label.add_theme_constant_override("outline_size", 2)
	build_cost_label.add_theme_font_size_override("font_size", 18)
	content.add_child(build_cost_label)

	var has_any_loot := false
	for loot_id_variant in LootEconomy.LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		var amount := LootEconomy.get_base_loot_count(loot_id)
		if amount <= 0:
			continue

		has_any_loot = true
		var texture: Texture2D = LootEconomy.LOOT_TEXTURES.get(loot_id, null) as Texture2D
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0.0, 42.0)
		row.add_theme_constant_override("separation", 10)
		content.add_child(row)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(38.0, 38.0)
		icon.texture = texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)

		var label := Label.new()
		label.text = "%s x%d" % [String(LootEconomy.LOOT_DISPLAY_NAMES.get(loot_id, "Loot")), amount]
		label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.9, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_font_size_override("font_size", 23)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)

	if has_any_loot:
		return

	var empty_label := Label.new()
	empty_label.text = "Sin loot guardado"
	empty_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.84, 1.0))
	empty_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
	empty_label.add_theme_constant_override("outline_size", 3)
	empty_label.add_theme_font_size_override("font_size", 23)
	content.add_child(empty_label)


func _setup_base_build_ui() -> void:
	var canvas_layer := main.get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	base_build_button = Button.new()
	base_build_button.name = "BaseBuildButton"
	base_build_button.visible = false
	base_build_button.flat = true
	base_build_button.focus_mode = Control.FOCUS_ALL
	base_build_button.custom_minimum_size = BASE_BUILD_BUTTON_SIZE
	base_build_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	base_build_button.offset_left = -BASE_BUILD_BUTTON_SIZE.x - 24.0
	base_build_button.offset_top = 24.0
	base_build_button.offset_right = -24.0
	base_build_button.offset_bottom = 24.0 + BASE_BUILD_BUTTON_SIZE.y
	base_build_button.pressed.connect(_on_base_build_button_pressed)
	base_build_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	canvas_layer.add_child(base_build_button)

	var build_button_graphic := TextureRect.new()
	build_button_graphic.name = "Graphic"
	build_button_graphic.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_button_graphic.texture = BASE_BUILD_BUTTON_TEXTURE
	build_button_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	build_button_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	build_button_graphic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_build_button.add_child(build_button_graphic)

	base_build_picker_panel = PanelContainer.new()
	base_build_picker_panel.name = "BaseBuildPicker"
	base_build_picker_panel.visible = false
	base_build_picker_panel.custom_minimum_size = BASE_BUILD_PICKER_SIZE
	base_build_picker_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	base_build_picker_panel.offset_left = -BASE_BUILD_PICKER_SIZE.x * 0.5
	base_build_picker_panel.offset_top = -BASE_BUILD_PICKER_SIZE.y - 22.0
	base_build_picker_panel.offset_right = BASE_BUILD_PICKER_SIZE.x * 0.5
	base_build_picker_panel.offset_bottom = -22.0
	base_build_picker_panel.add_theme_stylebox_override("panel", _create_base_build_panel_stylebox())
	canvas_layer.add_child(base_build_picker_panel)

	var picker_margin := MarginContainer.new()
	picker_margin.add_theme_constant_override("margin_left", 18)
	picker_margin.add_theme_constant_override("margin_top", 16)
	picker_margin.add_theme_constant_override("margin_right", 18)
	picker_margin.add_theme_constant_override("margin_bottom", 16)
	base_build_picker_panel.add_child(picker_margin)

	var picker_row := HBoxContainer.new()
	picker_row.alignment = BoxContainer.ALIGNMENT_CENTER
	picker_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picker_margin.add_child(picker_row)

	base_build_option_button = Button.new()
	base_build_option_button.name = "BaseBuildOptionButton"
	base_build_option_button.custom_minimum_size = BASE_BUILD_OPTION_SIZE
	base_build_option_button.flat = true
	base_build_option_button.focus_mode = Control.FOCUS_ALL
	base_build_option_button.pressed.connect(_on_base_build_option_pressed)
	base_build_option_button.add_theme_stylebox_override("normal", _create_base_build_option_stylebox(false))
	base_build_option_button.add_theme_stylebox_override("pressed", _create_base_build_option_stylebox(true))
	base_build_option_button.add_theme_stylebox_override("hover", _create_base_build_option_stylebox(true))
	base_build_option_button.add_theme_stylebox_override("focus", _create_base_build_option_stylebox(true))
	picker_row.add_child(base_build_option_button)

	var option_graphic := TextureRect.new()
	option_graphic.name = "Graphic"
	option_graphic.set_anchors_preset(Control.PRESET_FULL_RECT)
	option_graphic.texture = BASE_BUILDING_TEXTURE
	option_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	option_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	option_graphic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_build_option_button.add_child(option_graphic)

	update_travel_ui()


func _setup_base_building_preview() -> void:
	if base_zone_root == null or BASE_BUILDING_TEXTURE == null:
		return

	var used_rect := _get_texture_used_rect(BASE_BUILDING_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var building_scale := BASE_BUILDING_TARGET_MAX_SIZE / largest_side
	base_building_body = StaticBody2D.new()
	base_building_body.name = "BuiltBaseBody"
	base_building_body.visible = false
	base_building_body.z_index = 18
	base_zone_root.add_child(base_building_body)

	base_building_sprite = Sprite2D.new()
	base_building_sprite.name = "BuiltBase"
	base_building_sprite.texture = BASE_BUILDING_TEXTURE
	base_building_sprite.centered = true
	base_building_sprite.scale = Vector2.ONE * building_scale
	base_building_body.add_child(base_building_sprite)

	base_building_collision = CollisionShape2D.new()
	base_building_collision.name = "CollisionShape2D"
	base_building_collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var body_shape := RectangleShape2D.new()
	body_shape.size = used_rect.size * building_scale
	base_building_collision.shape = body_shape
	base_building_collision.disabled = true
	base_building_body.add_child(base_building_collision)

	_setup_built_base_boxes(used_rect, building_scale)

	base_building_click_area = Area2D.new()
	base_building_click_area.name = "BuiltBaseClickArea"
	base_building_click_area.input_pickable = false
	base_building_click_area.monitoring = false
	base_building_click_area.z_index = 19
	base_building_click_area.input_event.connect(_on_base_building_preview_input_event)
	base_zone_root.add_child(base_building_click_area)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * building_scale
	collision.shape = shape
	base_building_click_area.add_child(collision)


func _get_base_default_content_parent() -> Node:
	if is_instance_valid(base_default_content_root):
		return base_default_content_root
	return base_zone_root


func _setup_built_base_boxes(building_used_rect: Rect2, building_scale: float) -> void:
	if not is_instance_valid(base_building_body) or BASE_BOX_TEXTURE == null:
		return

	var building_center := (
		building_used_rect.position
		+ building_used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var building_half_size := building_used_rect.size * building_scale * 0.5
	var top_y := building_center.y - building_half_size.y - BASE_BUILT_BOX_PADDING
	var bottom_y := building_center.y + building_half_size.y + BASE_BUILT_BOX_PADDING
	var left_x := building_center.x - building_half_size.x - BASE_BUILT_BOX_PADDING
	var right_x := building_center.x + building_half_size.x + BASE_BUILT_BOX_PADDING
	var horizontal_positions := [-0.36, -0.12, 0.12, 0.36]
	var side_positions := [-0.32, -0.12, 0.12, 0.32]

	var box_index := 1
	for x_ratio in horizontal_positions:
		var x := building_center.x + building_half_size.x * float(x_ratio)
		_add_built_base_box("BuiltBaseTopBox%d" % box_index, Vector2(x, top_y))
		box_index += 1
		_add_built_base_box("BuiltBaseBottomBox%d" % box_index, Vector2(x, bottom_y))
		box_index += 1

	for y_ratio in side_positions:
		var y := building_center.y + building_half_size.y * float(y_ratio)
		_add_built_base_box("BuiltBaseLeftBox%d" % box_index, Vector2(left_x, y))
		box_index += 1
		_add_built_base_box("BuiltBaseRightBox%d" % box_index, Vector2(right_x, y))
		box_index += 1


func _add_built_base_box(box_name: String, box_position: Vector2) -> void:
	if not is_instance_valid(base_building_body) or BASE_BOX_TEXTURE == null:
		return

	var used_rect := _get_texture_used_rect(BASE_BOX_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var box_scale := BASE_BUILT_BOX_TARGET_MAX_SIZE / largest_side
	var body := StaticBody2D.new()
	body.name = box_name
	body.position = box_position
	body.z_index = 24
	base_building_body.add_child(body)

	var box := Sprite2D.new()
	box.name = "Visual"
	box.texture = BASE_BOX_TEXTURE
	box.centered = true
	box.scale = Vector2.ONE * box_scale
	body.add_child(box)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BOX_TEXTURE.get_size() * 0.5
	) * box_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * box_scale
	collision.shape = shape
	collision.disabled = true
	body.add_child(collision)


func _create_base_build_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.06, 0.07, 0.06, 0.9)
	stylebox.border_color = Color(0.87, 0.72, 0.38, 0.95)
	stylebox.set_border_width_all(4)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.35)
	stylebox.shadow_size = 8
	return stylebox


func _create_base_build_option_stylebox(active: bool) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	var background_alpha := 0.82 if active else 0.62
	var border_alpha := 0.98 if active else 0.65
	stylebox.bg_color = Color(0.18, 0.16, 0.11, background_alpha)
	stylebox.border_color = Color(0.95, 0.84, 0.46, border_alpha)
	stylebox.set_border_width_all(3)
	stylebox.set_corner_radius_all(6)
	return stylebox


func _add_base_wall(wall_name: String, wall_position: Vector2, wall_size: Vector2) -> void:
	_add_base_static_rect(
		wall_name,
		wall_position,
		wall_size,
		Color(0, 0, 0, 0)
	)


func _add_base_static_rect(
	body_name: String,
	body_position: Vector2,
	body_size: Vector2,
	_visual_color: Color
) -> void:
	if base_zone_root == null:
		return

	var body := StaticBody2D.new()
	body.name = body_name
	body.position = body_position
	_get_base_default_content_parent().add_child(body)

	var shape := RectangleShape2D.new()
	shape.size = body_size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)


func _setup_base_fences() -> void:
	if base_zone_root == null:
		return

	var horizontal_used_rect := _get_texture_used_rect(BASE_HORIZONTAL_FENCE_TEXTURE)
	var vertical_used_rect := _get_texture_used_rect(BASE_VERTICAL_FENCE_TEXTURE)
	var horizontal_largest_side := maxf(horizontal_used_rect.size.x, horizontal_used_rect.size.y)
	var vertical_largest_side := maxf(vertical_used_rect.size.x, vertical_used_rect.size.y)
	if horizontal_largest_side <= 0.0 or vertical_largest_side <= 0.0:
		return

	var horizontal_scale := BASE_FENCE_TARGET_MAX_SIZE / horizontal_largest_side
	var vertical_scale := BASE_FENCE_TARGET_MAX_SIZE / vertical_largest_side
	var horizontal_step := horizontal_used_rect.size.x * horizontal_scale
	var horizontal_height := horizontal_used_rect.size.y * horizontal_scale
	var vertical_step := vertical_used_rect.size.y * vertical_scale
	var vertical_width := vertical_used_rect.size.x * vertical_scale
	var top_row_width := horizontal_step * 8.0
	var vertical_row_height := vertical_step * 5.0
	var bottom_gate_width := horizontal_step * BASE_BOTTOM_GATE_WIDTH_RATIO
	var bottom_row_width := top_row_width + bottom_gate_width
	var top_y := -vertical_row_height * 0.5 - horizontal_height * 0.5
	var bottom_y := vertical_row_height * 0.5 + horizontal_height * 0.5
	var left_x := -bottom_row_width * 0.5 - vertical_width * 0.5
	var right_x := bottom_row_width * 0.5 + vertical_width * 0.5

	for index in range(8):
		var top_x := -top_row_width * 0.5 + horizontal_step * (float(index) + 0.5)
		_add_base_fence_sprite(
			"TopFence%d" % (index + 1),
			BASE_HORIZONTAL_FENCE_TEXTURE,
			Vector2(top_x, top_y),
			horizontal_scale,
			4
		)

	for index in range(8):
		var group_index := index % 4
		var side := -1.0 if index < 4 else 1.0
		var bottom_x := side * (bottom_gate_width * 0.5 + horizontal_step * (float(group_index) + 0.5))
		_add_base_fence_sprite(
			"BottomFence%d" % (index + 1),
			BASE_HORIZONTAL_FENCE_TEXTURE,
			Vector2(bottom_x, bottom_y),
			horizontal_scale,
			4
		)

	for index in range(5):
		var vertical_y := -vertical_row_height * 0.5 + vertical_step * (float(index) + 0.5)
		_add_base_fence_sprite(
			"LeftFence%d" % (index + 1),
			BASE_VERTICAL_FENCE_TEXTURE,
			Vector2(left_x, vertical_y),
			vertical_scale,
			4
		)
		_add_base_fence_sprite(
			"RightFence%d" % (index + 1),
			BASE_VERTICAL_FENCE_TEXTURE,
			Vector2(right_x, vertical_y),
			vertical_scale,
			4
		)


func _add_base_fence_sprite(
	fence_name: String,
	texture: Texture2D,
	fence_position: Vector2,
	fence_scale: float,
	fence_z_index: int
) -> void:
	if base_zone_root == null or texture == null:
		return

	var fence_body := StaticBody2D.new()
	fence_body.name = fence_name
	fence_body.position = fence_position
	fence_body.z_index = fence_z_index
	_get_base_default_content_parent().add_child(fence_body)

	var fence := Sprite2D.new()
	fence.name = "Visual"
	fence.texture = texture
	fence.centered = true
	fence.scale = Vector2.ONE * fence_scale
	fence_body.add_child(fence)

	var used_rect := _get_texture_used_rect(texture)
	var texture_size := texture.get_size()
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- texture_size * 0.5
	) * fence_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * fence_scale
	collision.shape = shape
	fence_body.add_child(collision)


func _get_texture_used_rect(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2.ONE)

	var image := texture.get_image()
	if image == null:
		return Rect2(Vector2.ZERO, texture.get_size())

	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Rect2(Vector2.ZERO, texture.get_size())

	return Rect2(
		Vector2(used_rect.position.x, used_rect.position.y),
		Vector2(used_rect.size.x, used_rect.size.y)
	)


func _setup_base_campfire() -> void:
	if base_zone_root == null:
		return

	var campfire_scale := 0.62
	var campfire_body := StaticBody2D.new()
	campfire_body.name = "Campfire"
	campfire_body.position = Vector2.ZERO
	campfire_body.z_index = 22
	_get_base_default_content_parent().add_child(campfire_body)

	var campfire := Sprite2D.new()
	campfire.name = "Visual"
	campfire.texture = BASE_CAMPFIRE_TEXTURE
	campfire.scale = Vector2.ONE * campfire_scale
	campfire_body.add_child(campfire)

	var used_rect := _get_texture_used_rect(BASE_CAMPFIRE_TEXTURE)
	var texture_size := BASE_CAMPFIRE_TEXTURE.get_size()
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- texture_size * 0.5
	) * campfire_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * campfire_scale
	collision.shape = shape
	campfire_body.add_child(collision)

	var smoke := GPUParticles2D.new()
	smoke.name = "CampfireSmoke"
	smoke.texture = BASE_SMOKE_TEXTURE
	smoke.amount = 18
	smoke.lifetime = 3.2
	smoke.preprocess = 1.4
	smoke.local_coords = false
	smoke.position = Vector2(0, -170)
	smoke.z_index = 24
	smoke.process_material = _create_base_smoke_material()
	_get_base_default_content_parent().add_child(smoke)
	smoke.emitting = true


func _setup_base_corner_boxes() -> void:
	if base_zone_root == null or BASE_BOX_TEXTURE == null:
		return

	var horizontal_used_rect := _get_texture_used_rect(BASE_HORIZONTAL_FENCE_TEXTURE)
	var vertical_used_rect := _get_texture_used_rect(BASE_VERTICAL_FENCE_TEXTURE)
	var horizontal_largest_side := maxf(horizontal_used_rect.size.x, horizontal_used_rect.size.y)
	var vertical_largest_side := maxf(vertical_used_rect.size.x, vertical_used_rect.size.y)
	if horizontal_largest_side <= 0.0 or vertical_largest_side <= 0.0:
		return

	var horizontal_scale := BASE_FENCE_TARGET_MAX_SIZE / horizontal_largest_side
	var vertical_scale := BASE_FENCE_TARGET_MAX_SIZE / vertical_largest_side
	var horizontal_step := horizontal_used_rect.size.x * horizontal_scale
	var horizontal_height := horizontal_used_rect.size.y * horizontal_scale
	var vertical_step := vertical_used_rect.size.y * vertical_scale
	var vertical_width := vertical_used_rect.size.x * vertical_scale
	var top_row_width := horizontal_step * 8.0
	var vertical_row_height := vertical_step * 5.0
	var bottom_gate_width := horizontal_step * BASE_BOTTOM_GATE_WIDTH_RATIO
	var bottom_row_width := top_row_width + bottom_gate_width
	var top_y := -vertical_row_height * 0.5 - horizontal_height * 0.5
	var bottom_y := vertical_row_height * 0.5 + horizontal_height * 0.5
	var left_x := -bottom_row_width * 0.5 - vertical_width * 0.5
	var right_x := bottom_row_width * 0.5 + vertical_width * 0.5
	var box_positions := [
		Vector2(left_x + BASE_BOX_FENCE_PADDING.x, top_y + BASE_BOX_FENCE_PADDING.y),
		Vector2(right_x - BASE_BOX_FENCE_PADDING.x, top_y + BASE_BOX_FENCE_PADDING.y),
		Vector2(left_x + BASE_BOX_FENCE_PADDING.x, bottom_y - BASE_BOX_FENCE_PADDING.y),
		Vector2(right_x - BASE_BOX_FENCE_PADDING.x, bottom_y - BASE_BOX_FENCE_PADDING.y),
	]

	for index in range(box_positions.size()):
		_add_base_corner_box("CornerBox%d" % (index + 1), box_positions[index])


func _add_base_corner_box(box_name: String, box_position: Vector2) -> void:
	if base_zone_root == null or BASE_BOX_TEXTURE == null:
		return

	var body := StaticBody2D.new()
	body.name = box_name
	body.position = box_position
	body.z_index = 12
	_get_base_default_content_parent().add_child(body)

	var used_rect := _get_texture_used_rect(BASE_BOX_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var box_scale := BASE_BOX_TARGET_MAX_SIZE / largest_side
	var box := Sprite2D.new()
	box.name = "Visual"
	box.texture = BASE_BOX_TEXTURE
	box.centered = true
	box.scale = Vector2.ONE * box_scale
	body.add_child(box)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BOX_TEXTURE.get_size() * 0.5
	) * box_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * box_scale
	collision.shape = shape
	body.add_child(collision)


func _create_base_smoke_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 26.0
	material.direction = Vector3(0, -1, 0)
	material.spread = 24.0
	material.initial_velocity_min = 18.0
	material.initial_velocity_max = 42.0
	material.gravity = Vector3(0, -8, 0)
	material.scale_min = 0.08
	material.scale_max = 0.18
	material.color = Color(0.85, 0.85, 0.85, 0.42)
	material.hue_variation_min = -0.05
	material.hue_variation_max = 0.05
	return material


func update_travel_ui() -> void:
	var show_base_ui: bool = main.is_in_base_zone and not main.player_dead and not main._is_menu_visible()
	if is_instance_valid(base_zone_label):
		base_zone_label.visible = show_base_ui
	if is_instance_valid(base_build_button):
		base_build_button.visible = show_base_ui
	if is_instance_valid(base_build_picker_panel):
		base_build_picker_panel.visible = show_base_ui and base_build_picker_open
	if is_instance_valid(base_loot_display_root):
		base_loot_display_root.visible = show_base_ui


func _on_base_build_button_pressed() -> void:
	if not main.is_in_base_zone or main.player_dead:
		return

	base_build_picker_open = not base_build_picker_open
	update_travel_ui()


func _on_base_build_option_pressed() -> void:
	if base_building_placed:
		base_build_picker_open = false
		update_travel_ui()
		return

	if not _has_base_building_cost():
		return

	if base_build_preview_active:
		_confirm_base_building()
	else:
		_show_base_build_preview()


func _on_base_building_preview_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not base_build_preview_active:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not mouse_event.is_echo():
			_confirm_base_building()
			main.get_viewport().set_input_as_handled()


func _show_base_build_preview() -> void:
	if not main.is_in_base_zone or base_building_placed or not is_instance_valid(base_building_sprite):
		return
	if not _has_base_building_cost():
		return

	base_build_preview_active = true
	if is_instance_valid(base_building_body):
		base_building_body.visible = true
	base_building_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45)
	if is_instance_valid(base_building_body):
		_set_collision_shapes_disabled(base_building_body, true)
	if is_instance_valid(base_building_click_area):
		base_building_click_area.monitoring = true
		base_building_click_area.input_pickable = true


func _confirm_base_building() -> void:
	if base_building_placed or not is_instance_valid(base_building_sprite):
		return
	if not _spend_base_building_cost():
		return

	base_build_preview_active = false
	base_building_placed = true
	base_build_picker_open = false
	if is_instance_valid(base_building_body):
		base_building_body.visible = true
	base_building_sprite.modulate = Color.WHITE
	if is_instance_valid(base_default_content_root):
		base_default_content_root.hide()
		_set_collision_shapes_disabled(base_default_content_root, true)
	if is_instance_valid(base_building_body):
		_set_collision_shapes_disabled(base_building_body, false)
	if is_instance_valid(base_building_click_area):
		base_building_click_area.monitoring = false
		base_building_click_area.input_pickable = false
	update_travel_ui()


func _has_base_building_cost() -> bool:
	return LootEconomy.has_building_cost()


func _spend_base_building_cost() -> bool:
	if not LootEconomy.spend_building_cost():
		return false

	update_loot_display()
	return true


func cancel_build_preview() -> void:
	base_build_picker_open = false
	base_build_preview_active = false
	if is_instance_valid(base_building_body) and not base_building_placed:
		base_building_body.hide()
	if is_instance_valid(base_building_body) and not base_building_placed:
		_set_collision_shapes_disabled(base_building_body, true)
	if is_instance_valid(base_building_click_area) and not base_building_placed:
		base_building_click_area.monitoring = false
		base_building_click_area.input_pickable = false


func _set_collision_shapes_disabled(root: Node, disabled: bool) -> void:
	if root == null:
		return

	for child in root.get_children():
		var collision_shape := child as CollisionShape2D
		if collision_shape != null:
			collision_shape.disabled = disabled
		_set_collision_shapes_disabled(child, disabled)

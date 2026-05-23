extends StaticBody2D

const MINECART_TEXTURE := preload("res://assets/Objetos de la base/Minecart.png")

const MINECART_TARGET_MAX_SIZE := 240.0
const MOVE_SPEED := 95.0
const BOTTOM_DESPAWN_Y := 1120.0


func _ready() -> void:
	add_to_group("time_freezable_objects")
	collision_layer = 1
	collision_mask = 0
	z_index = 16
	_setup_visual()
	_setup_collision()


func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN * MOVE_SPEED * delta
	if global_position.y >= BOTTOM_DESPAWN_Y:
		queue_free()


func take_damage(_amount: int = 1) -> void:
	return


func _setup_visual() -> void:
	var visual := Sprite2D.new()
	visual.name = "Visual"
	visual.texture = MINECART_TEXTURE
	visual.centered = true
	visual.scale = Vector2.ONE * _get_texture_scale(MINECART_TEXTURE, MINECART_TARGET_MAX_SIZE)
	add_child(visual)


func _setup_collision() -> void:
	var used_rect := _get_texture_used_rect(MINECART_TEXTURE)
	var texture_size := MINECART_TEXTURE.get_size()
	var minecart_scale := _get_texture_scale(MINECART_TEXTURE, MINECART_TARGET_MAX_SIZE)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- texture_size * 0.5
	) * minecart_scale

	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * minecart_scale
	collision.shape = shape
	add_child(collision)


func _get_texture_scale(texture: Texture2D, target_max_size: float) -> float:
	if texture == null:
		return 1.0

	var used_rect := _get_texture_used_rect(texture)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return 1.0

	return target_max_size / largest_side


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

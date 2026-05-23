extends Area2D

@export var arming_time: float = 6.0
@export var blast_radius: float = 84.0
@export var damage_amount: int = 999

const INACTIVE_ANIMATION := &"inactive"
const ACTIVE_ANIMATION := &"active"
const INACTIVE_TEXTURE := preload("res://assets/Power ups/Mina/Colocada desactivada.png")
const ACTIVE_TEXTURE := preload("res://assets/Power ups/Mina/Colocada activada.png")
const MINE_EXPLOSION_SCENE := preload("res://scenes/power_ups/mine_explosion.tscn")
const INACTIVE_FRAME_SIZE := Vector2(760, 643)
const ACTIVE_FRAME_SIZE := Vector2(760, 643)
const ACTIVE_FRAME_COUNT := 2

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var arming_timer: float = 0.0
var is_armed: bool = false
var has_detonated: bool = false


func _ready() -> void:
	add_to_group("placed_mines")
	add_to_group("time_freezable_objects")
	body_entered.connect(_on_body_entered)
	arming_timer = arming_time
	animated_sprite.sprite_frames = _build_sprite_frames()
	animated_sprite.play(INACTIVE_ANIMATION)
	monitoring = true


func _process(delta: float) -> void:
	if has_detonated or is_armed:
		return

	arming_timer = maxf(arming_timer - delta, 0.0)
	if arming_timer == 0.0:
		_arm()


func _arm() -> void:
	is_armed = true
	animated_sprite.play(ACTIVE_ANIMATION)
	_check_active_mine_achievement()

	for body in get_overlapping_bodies():
		if body.is_in_group("zombies"):
			_detonate(body)
			return


func _on_body_entered(body: Node) -> void:
	if not is_armed or has_detonated:
		return
	if not body.is_in_group("zombies"):
		return

	_detonate(body)


func _detonate(trigger_body: Node = null) -> void:
	if has_detonated:
		return

	has_detonated = true
	monitoring = false
	collision_shape.disabled = true
	_kill_zombies_in_blast(trigger_body)

	var explosion := MINE_EXPLOSION_SCENE.instantiate()
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	scene_root.add_child(explosion)
	explosion.global_position = global_position
	queue_free()


func _kill_zombies_in_blast(trigger_body: Node = null) -> void:
	var affected_zombies: Array[Node] = []

	if trigger_body != null and trigger_body.is_in_group("zombies"):
		affected_zombies.append(trigger_body)

	for body in get_overlapping_bodies():
		if body == null or not body.is_in_group("zombies") or affected_zombies.has(body):
			continue
		affected_zombies.append(body)

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie == null or not (zombie is Node2D) or affected_zombies.has(zombie):
			continue
		if (zombie as Node2D).global_position.distance_to(global_position) <= blast_radius:
			affected_zombies.append(zombie)

	for zombie in affected_zombies:
		var applied_damage := damage_amount
		if zombie.has_method("get_explosion_damage_amount"):
			applied_damage = zombie.get_explosion_damage_amount(damage_amount)

		if zombie.has_method("take_damage"):
			zombie.take_damage(applied_damage)
		elif zombie.has_method("die"):
			zombie.die()


func is_active_for_achievement() -> bool:
	return is_armed and not has_detonated


func _check_active_mine_achievement() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	if scene_root != null and scene_root.has_method("check_active_mine_achievement"):
		scene_root.check_active_mine_achievement()


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()

	frames.add_animation(INACTIVE_ANIMATION)
	frames.set_animation_loop(INACTIVE_ANIMATION, true)
	frames.set_animation_speed(INACTIVE_ANIMATION, 1.0)
	frames.add_frame(
		INACTIVE_ANIMATION,
		_make_atlas_texture(INACTIVE_TEXTURE, Rect2(Vector2.ZERO, INACTIVE_FRAME_SIZE))
	)

	frames.add_animation(ACTIVE_ANIMATION)
	frames.set_animation_loop(ACTIVE_ANIMATION, true)
	frames.set_animation_speed(ACTIVE_ANIMATION, 5.0)

	for frame_index in range(ACTIVE_FRAME_COUNT):
		var frame_region := Rect2(
			frame_index * ACTIVE_FRAME_SIZE.x,
			0,
			ACTIVE_FRAME_SIZE.x,
			ACTIVE_FRAME_SIZE.y
		)
		frames.add_frame(ACTIVE_ANIMATION, _make_atlas_texture(ACTIVE_TEXTURE, frame_region))

	return frames


func _make_atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = region
	return atlas_texture

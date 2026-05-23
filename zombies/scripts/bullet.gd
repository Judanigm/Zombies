extends Area2D

@export var speed: float = 520.0
@export var homing_detection_radius: float = 340.0
@export_range(0.0, 20.0, 0.1) var homing_turn_speed: float = 8.0

const NORMAL_BULLET_TEXTURE := preload("res://assets/Bala/bala_clean.png")
const HOMING_BULLET_TEXTURE := preload("res://assets/Power ups/Balas teledirigidas/Bala.png")
const NORMAL_BULLET_SCALE := Vector2(0.7, 0.7)
const HOMING_BULLET_SCALE := Vector2(0.03, 0.03)
const NORMAL_BULLET_RADIUS := 4.0
const HOMING_BULLET_RADIUS := 0.2
const DOUBLE_KILL_ACHIEVEMENT_ID := &"two_zombies_one_bullet"
const DOUBLE_KILL_LOOKAHEAD_DISTANCE := 220.0
const DOUBLE_KILL_PATH_WIDTH := 56.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Visual

var direction: Vector2 = Vector2.RIGHT
var owner_node: Node = null
var homing_enabled: bool = false
var achievement_tracking_enabled: bool = false
var achievement_kill_count: int = 0
var hit_targets: Dictionary = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if homing_enabled:
		_update_homing_direction(delta)

	position += direction * speed * delta


func setup(
	start_position: Vector2,
	start_direction: Vector2,
	shooter: Node,
	enable_homing: bool = false,
	enable_achievement_tracking: bool = false
) -> void:
	global_position = start_position
	direction = start_direction.normalized()
	rotation = direction.angle()
	owner_node = shooter
	homing_enabled = enable_homing
	achievement_tracking_enabled = enable_achievement_tracking
	achievement_kill_count = 0
	hit_targets.clear()
	_apply_bullet_style()


func _on_body_entered(body: Node) -> void:
	if body == owner_node:
		return

	if not _process_hit_target(body):
		queue_free()


func _update_homing_direction(delta: float) -> void:
	var target := _get_nearest_zombie()
	if target == null:
		return

	var desired_direction := global_position.direction_to(target.global_position)
	if desired_direction == Vector2.ZERO:
		return

	direction = direction.lerp(desired_direction, minf(homing_turn_speed * delta, 1.0)).normalized()
	rotation = direction.angle()


func _get_nearest_zombie() -> Node2D:
	var nearest_zombie: Node2D = null
	var nearest_distance := homing_detection_radius

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not (zombie is Node2D):
			continue

		var zombie_node := zombie as Node2D
		var distance := global_position.distance_to(zombie_node.global_position)
		if distance > homing_detection_radius or distance >= nearest_distance:
			continue

		nearest_distance = distance
		nearest_zombie = zombie_node

	return nearest_zombie


func _apply_bullet_style() -> void:
	if is_instance_valid(visual):
		visual.texture = HOMING_BULLET_TEXTURE if homing_enabled else NORMAL_BULLET_TEXTURE
		visual.scale = HOMING_BULLET_SCALE if homing_enabled else NORMAL_BULLET_SCALE

	if is_instance_valid(collision_shape) and collision_shape.shape is CircleShape2D:
		var bullet_shape := collision_shape.shape as CircleShape2D
		bullet_shape.radius = HOMING_BULLET_RADIUS if homing_enabled else NORMAL_BULLET_RADIUS


func _on_area_entered(area: Area2D) -> void:
	if area == owner_node:
		return

	var target: Node = area
	if not area.has_method("take_damage") and not area.has_method("die"):
		var parent := area.get_parent()
		if parent != null:
			target = parent

	if target == owner_node:
		return

	if not _process_hit_target(target):
		queue_free()


func _process_hit_target(target: Node) -> bool:
	if target == null:
		return false

	var target_id := target.get_instance_id()
	if hit_targets.has(target_id):
		return true
	hit_targets[target_id] = true

	var can_take_damage := target.has_method("take_damage") or target.has_method("die")
	if not can_take_damage:
		return false

	var target_was_zombie := target.is_in_group("zombies")
	if target.has_method("take_damage"):
		target.take_damage(1)
	else:
		target.die()

	var target_killed := target_was_zombie and not target.is_in_group("zombies")
	if not target_killed:
		return false

	if achievement_tracking_enabled:
		achievement_kill_count += 1
		if achievement_kill_count >= 2:
			_unlock_double_kill_achievement()

	if _should_pierce_after_kill(target):
		global_position += direction * 8.0
		return true

	return false


func _should_pierce_after_kill(current_target: Node) -> bool:
	if not achievement_tracking_enabled:
		return false

	for zombie in get_tree().get_nodes_in_group("zombies"):
		if (
			not is_instance_valid(zombie)
			or zombie == current_target
			or not (zombie is Node2D)
		):
			continue

		var zombie_node := zombie as Node2D
		var offset := zombie_node.global_position - global_position
		var forward_distance := offset.dot(direction)
		if forward_distance <= 0.0 or forward_distance > DOUBLE_KILL_LOOKAHEAD_DISTANCE:
			continue

		var perpendicular_distance := absf(offset.cross(direction))
		if perpendicular_distance <= DOUBLE_KILL_PATH_WIDTH:
			return true

	return false


func _unlock_double_kill_achievement() -> void:
	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("unlock_achievement"):
		scene_root.unlock_achievement(DOUBLE_KILL_ACHIEVEMENT_ID)

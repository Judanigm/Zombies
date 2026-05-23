extends Area2D

@export var speed: float = 430.0
@export var visual_scale: float = 0.28
@export var collision_radius: float = 16.0
@export var puddle_lifetime: float = 20.0

const ACID_SPIT_TEXTURE := preload("res://assets/Zombies/Atómico/Escupitajo de ácido.png")
const ACID_PUDDLE_SCRIPT := preload("res://scripts/atomic_acid_puddle.gd")

var direction: Vector2 = Vector2.RIGHT
var target_position: Vector2 = Vector2.ZERO
var has_splashed: bool = false


func _ready() -> void:
	add_to_group("time_freezable_objects")
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)

	var visual := Sprite2D.new()
	visual.texture = ACID_SPIT_TEXTURE
	visual.scale = Vector2.ONE * visual_scale
	add_child(visual)

	var shape := CircleShape2D.new()
	shape.radius = collision_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func setup(start_position: Vector2, end_position: Vector2) -> void:
	global_position = start_position
	target_position = end_position
	direction = start_position.direction_to(end_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	if has_splashed:
		return

	var distance_to_target := global_position.distance_to(target_position)
	var travel_distance := speed * delta
	if travel_distance >= distance_to_target:
		global_position = target_position
		_splash()
		return

	global_position += direction * travel_distance


func _on_body_entered(body: Node) -> void:
	if has_splashed:
		return
	if body != null and body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)
	_splash()


func _splash() -> void:
	has_splashed = true
	var puddle := ACID_PUDDLE_SCRIPT.new()
	puddle.lifetime = puddle_lifetime

	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	scene_root.add_child(puddle)
	puddle.global_position = global_position
	queue_free()

extends Node2D

@export var throw_speed: float = 700.0
@export var arc_height: float = 68.0
@export var spin_speed: float = 10.0

const GRENADE_EXPLOSION_SCENE := preload("res://scenes/power_ups/grenade_explosion.tscn")

@onready var visual_root: Node2D = $VisualRoot
@onready var shadow: Polygon2D = $Shadow

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var travel_time: float = 0.0
var travel_progress: float = 0.0


func _ready() -> void:
	add_to_group("time_freezable_objects")


func setup(origin: Vector2, target: Vector2) -> void:
	start_position = origin
	target_position = target
	global_position = origin
	travel_time = maxf(origin.distance_to(target) / throw_speed, 0.08)
	travel_progress = 0.0


func _process(delta: float) -> void:
	if travel_time <= 0.0:
		_explode()
		return

	travel_progress = minf(travel_progress + delta / travel_time, 1.0)
	global_position = start_position.lerp(target_position, travel_progress)

	var arc_offset := sin(travel_progress * PI) * arc_height
	visual_root.position = Vector2(0.0, -arc_offset)
	visual_root.rotation += delta * spin_speed

	var shadow_scale := 0.86 + (1.0 - travel_progress) * 0.14
	shadow.scale = Vector2(shadow_scale, shadow_scale)

	if travel_progress >= 1.0:
		_explode()


func _explode() -> void:
	var explosion := GRENADE_EXPLOSION_SCENE.instantiate()
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	scene_root.add_child(explosion)
	explosion.global_position = target_position
	queue_free()

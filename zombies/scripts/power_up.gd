extends Area2D
class_name PowerUp

signal picked_up(power_up_id: StringName, collector: Node)

@export var power_up_id: StringName = &"power_up"
@export var display_name: String = "Power Up"
@export var bob_height: float = 8.0
@export var bob_speed: float = 2.4
@export var tilt_degrees: float = 5.0
@export var pickup_sound_volume_db: float = 14.0

const PICKUP_SOUND := preload("res://assets/Sonido/Efectos/Agarrar objeto.wav")

@onready var visual_root: Node2D = $VisualRoot
@onready var shadow: Polygon2D = $Shadow

var base_visual_position: Vector2 = Vector2.ZERO
var hover_phase: float = 0.0


func _ready() -> void:
	add_to_group("power_ups")
	add_to_group("time_freezable_objects")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	base_visual_position = visual_root.position
	hover_phase = randf() * TAU


func _process(delta: float) -> void:
	hover_phase += delta * bob_speed

	var bob_offset := sin(hover_phase) * bob_height
	visual_root.position = base_visual_position + Vector2(0.0, bob_offset)
	visual_root.rotation = deg_to_rad(sin(hover_phase * 0.5) * tilt_degrees)

	var normalized_height := absf(bob_offset) / maxf(bob_height, 1.0)
	var shadow_scale := 1.0 - normalized_height * 0.16
	shadow.scale = Vector2(shadow_scale, shadow_scale)
	var shadow_color := shadow.color
	shadow_color.a = lerpf(0.12, 0.22, 1.0 - normalized_height)
	shadow.color = shadow_color


func _on_body_entered(body: Node) -> void:
	_try_collect(body)


func _on_area_entered(area: Area2D) -> void:
	if area == null:
		return

	if area.is_in_group("player"):
		_try_collect(area)
		return

	var parent := area.get_parent()
	if parent != null:
		_try_collect(parent)


func _try_collect(collector: Node) -> void:
	if collector == null or not collector.is_in_group("player"):
		return

	_finish_pickup(collector)


func _finish_pickup(collector: Node) -> void:
	_play_pickup_sound()
	emit_signal("picked_up", power_up_id, collector)
	queue_free()


func _play_pickup_sound() -> void:
	if PICKUP_SOUND == null:
		return

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	var sound_player := AudioStreamPlayer2D.new()
	sound_player.stream = PICKUP_SOUND
	sound_player.volume_db = pickup_sound_volume_db
	sound_player.global_position = global_position
	root.add_child(sound_player)
	sound_player.finished.connect(sound_player.queue_free)
	sound_player.play()

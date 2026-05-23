extends Area2D

@export var lifetime: float = 20.0
@export var visual_scale: float = 0.45
@export var collision_radius: float = 44.0
@export var damage_interval: float = 1.1

const ACID_PUDDLE_TEXTURE := preload("res://assets/Zombies/Atómico/Ácido en el suelo.png")

var damage_timers: Dictionary = {}


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)

	var visual := Sprite2D.new()
	visual.texture = ACID_PUDDLE_TEXTURE
	visual.scale = Vector2.ONE * visual_scale
	add_child(visual)

	var shape := CircleShape2D.new()
	shape.radius = collision_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	call_deferred("_damage_overlapping_players")


func _physics_process(delta: float) -> void:
	lifetime = maxf(lifetime - delta, 0.0)
	if lifetime == 0.0:
		queue_free()
		return

	for body_id in damage_timers.keys():
		damage_timers[body_id] = maxf(float(damage_timers[body_id]) - delta, 0.0)

	_damage_overlapping_players()


func _on_body_entered(body: Node) -> void:
	_damage_player(body)


func _damage_overlapping_players() -> void:
	for body in get_overlapping_bodies():
		_damage_player(body)


func _damage_player(body: Node) -> void:
	if body == null or not body.is_in_group("player") or not body.has_method("take_damage"):
		return

	var body_id := body.get_instance_id()
	if float(damage_timers.get(body_id, 0.0)) > 0.0:
		return

	body.take_damage(1)
	damage_timers[body_id] = damage_interval

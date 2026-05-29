extends Zombie

## Fast zombie: high speed, weaves toward the player in a zigzag, dies in one hit.

@export_range(0.0, 2.0, 0.01) var zigzag_strength: float = 0.75
@export var zigzag_frequency: float = 7.0

const DEAD_FRAME_SIZE := Vector2(303, 407)
const WALK_FRAME_SIZE := Vector2(447, 608)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const DEAD_TEXTURE := preload("res://assets/Zombies/Fast/Dead.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Fast/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Fast/Andar arriba.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Fast/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Fast/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Fast/Spawn.png")

@onready var electric_particles: GPUParticles2D = $ElectricParticles

var zigzag_time: float = 0.0
var zigzag_phase: float = 0.0


func _init() -> void:
	move_speed = 200.0
	corpse_duration = 0.75
	spawn_duration = 1.25
	spawn_shake_distance = 16.0
	spawn_shake_speed = 42.0


func get_zombie_type() -> StringName:
	return TYPE_FAST


func _on_ready() -> void:
	zigzag_phase = randf() * TAU
	electric_particles.emitting = true


func _on_death() -> void:
	electric_particles.emitting = false


func _process_active(delta: float) -> void:
	zigzag_time += delta
	var direction := _get_zigzag_direction_to_player()
	velocity = direction * move_speed
	move_and_slide()
	_update_visuals()
	_update_animation()


func _get_zigzag_direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO

	var to_player := player.global_position - global_position
	if to_player == Vector2.ZERO:
		return Vector2.ZERO

	var forward := to_player.normalized()
	var sideways := Vector2(-forward.y, forward.x)
	var zigzag_amount := sin(zigzag_time * zigzag_frequency + zigzag_phase) * zigzag_strength
	return (forward + sideways * zigzag_amount).normalized()


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 13.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 13.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 13.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 13.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 13.0)
	return frames

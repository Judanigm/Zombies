extends Zombie

## Strong zombie: slow, larger, takes two hits to kill.

const DEAD_FRAME_SIZE := Vector2(394, 536)
const WALK_FRAME_SIZE := Vector2(447, 708)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const DEAD_TEXTURE := preload("res://assets/Zombies/Fuerte/Dead.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar alante.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Fuerte/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Fuerte/Spawn.png")


func _init() -> void:
	move_speed = 72.0
	sprite_scale = 0.36
	spawn_sprite_scale = 0.26
	sprite_offset = Vector2(0, 18)
	dead_sprite_scale = 0.46
	dead_sprite_offset = Vector2(0, 18)
	corpse_duration = 1.1
	spawn_shake_distance = 10.0
	spawn_shake_speed = 28.0
	max_health = 2


func get_zombie_type() -> StringName:
	return TYPE_STRONG


func is_strong_zombie() -> bool:
	return true


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 6.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 6.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 6.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 6.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	return frames

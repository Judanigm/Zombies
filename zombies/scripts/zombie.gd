extends Zombie

## Standard zombie: chases the player in a straight line, dies in one hit.

const DEAD_FRAME_SIZE := Vector2(685, 501)
const WALK_FRAME_SIZE := Vector2(447, 608)
const WALK_FRAME_COUNT := 4
const SPAWN_FRAME_SIZE := Vector2(1054, 728)
const DEAD_TEXTURE := preload("res://assets/Zombies/Normal/dead.png")
const WALK_DOWN_TEXTURE := preload("res://assets/Zombies/Normal/Andar abajo.png")
const WALK_UP_TEXTURE := preload("res://assets/Zombies/Normal/Andar arriba.png")
const WALK_LEFT_TEXTURE := preload("res://assets/Zombies/Normal/Andar izquierda.png")
const WALK_RIGHT_TEXTURE := preload("res://assets/Zombies/Normal/Andar derecha.png")
const SPAWN_TEXTURE := preload("res://assets/Zombies/Normal/Spawn.png")


func get_zombie_type() -> StringName:
	return TYPE_NORMAL


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_single_frame_animation(frames, DEAD_ANIMATION, DEAD_TEXTURE, DEAD_FRAME_SIZE, 1.0)
	_add_strip_animation(frames, WALK_DOWN_ANIMATION, WALK_DOWN_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_UP_ANIMATION, WALK_UP_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_RIGHT_ANIMATION, WALK_RIGHT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_strip_animation(frames, WALK_LEFT_ANIMATION, WALK_LEFT_TEXTURE, WALK_FRAME_SIZE, WALK_FRAME_COUNT, 7.0)
	_add_single_frame_animation(frames, SPAWN_ANIMATION, SPAWN_TEXTURE, SPAWN_FRAME_SIZE, 6.0)
	return frames

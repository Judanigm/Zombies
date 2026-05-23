extends Node2D

@export var sprite_scale: float = 0.18
@export var frame_count: int = 3
@export var animation_speed: float = 10.0
@export var explosion_sound_volume_db: float = 2.0

const EXPLOSION_TEXTURE := preload("res://assets/Power ups/Mina/Explosión.png")
const EXPLOSION_SOUND := preload("res://assets/Sonido/Efectos/efecto de sonido de explosión.mp3")
const EXPLOSION_ANIMATION := &"explode"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite.sprite_frames = _build_sprite_frames()
	animated_sprite.scale = Vector2.ONE * sprite_scale
	animated_sprite.animation_finished.connect(_on_animation_finished)
	_play_explosion_sound()
	animated_sprite.play(EXPLOSION_ANIMATION)


func _on_animation_finished() -> void:
	queue_free()


func _play_explosion_sound() -> void:
	if EXPLOSION_SOUND == null:
		return

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	var explosion_sound_player := AudioStreamPlayer2D.new()
	explosion_sound_player.stream = EXPLOSION_SOUND
	explosion_sound_player.volume_db = explosion_sound_volume_db
	explosion_sound_player.global_position = global_position
	root.add_child(explosion_sound_player)
	explosion_sound_player.finished.connect(explosion_sound_player.queue_free)
	explosion_sound_player.play()


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(EXPLOSION_ANIMATION)
	frames.set_animation_loop(EXPLOSION_ANIMATION, false)
	frames.set_animation_speed(EXPLOSION_ANIMATION, animation_speed)

	var texture_size := EXPLOSION_TEXTURE.get_size()
	var frame_width := int(texture_size.x / frame_count)
	var frame_height := int(texture_size.y)

	for frame_index in range(frame_count):
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = EXPLOSION_TEXTURE
		atlas_texture.region = Rect2(
			frame_index * frame_width,
			0,
			frame_width,
			frame_height
		)
		frames.add_frame(EXPLOSION_ANIMATION, atlas_texture)

	return frames

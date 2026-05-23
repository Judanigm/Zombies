extends Node2D

const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const ATOMIC_ZOMBIE_SCENE := preload("res://scenes/atomic_zombie.tscn")
const FAST_ZOMBIE_SCENE := preload("res://scenes/fast_zombie.tscn")
const STRONG_ZOMBIE_SCENE := preload("res://scenes/strong_zombie.tscn")
const MINER_ZOMBIE_SCENE := preload("res://scenes/miner_zombie.tscn")
const MICHAEL_JACKSON_ZOMBIE_SCENE := preload("res://scenes/zombie_michael_jackson.tscn")
const GRENADE_POWER_UP_SCENE := preload("res://scenes/power_ups/grenade_power_up.tscn")
const HOMING_BULLETS_POWER_UP_SCENE := preload("res://scenes/power_ups/homing_bullets_power_up.tscn")
const MEDKIT_POWER_UP_SCENE := preload("res://scenes/power_ups/medkit_power_up.tscn")
const MINE_POWER_UP_SCENE := preload("res://scenes/power_ups/mine_power_up.tscn")
const TELEPORT_ORB_POWER_UP_SCENE := preload("res://scenes/power_ups/teleport_orb_power_up.tscn")
const ANTI_COOLDOWN_POWER_UP_SCENE := preload("res://scenes/power_ups/anti_cooldown_power_up.tscn")
const TRIPLE_BULLET_POWER_UP_SCENE := preload("res://scenes/power_ups/triple_bullet_power_up.tscn")
const TIME_FREEZE_POWER_UP_SCENE := preload("res://scenes/power_ups/time_freeze_power_up.tscn")
const LOOT_CONTAINER_SCRIPT := preload("res://scripts/loot_container.gd")
const LOOT_MINECART_SCRIPT := preload("res://scripts/loot_minecart.gd")
const LOOT_TEXTURES := {
	&"oil": preload("res://assets/Objetos de la base/Loot/Bote de petróleo.png"),
	&"wood": preload("res://assets/Objetos de la base/Loot/Cacho de madera.png"),
	&"iron": preload("res://assets/Objetos de la base/Loot/Lingote de hierro.png"),
	&"copper": preload("res://assets/Objetos de la base/Loot/Lámina de cobre.png"),
}
const LOOT_DISPLAY_NAMES := {
	&"oil": "Petroleo",
	&"wood": "Madera",
	&"iron": "Hierro",
	&"copper": "Cobre",
}
const LOOT_DISPLAY_ORDER := [&"wood", &"iron", &"copper", &"oil"]
const BASE_BUILD_WOOD_COST := 35
const BASE_BUILD_IRON_COST := 10
const WAVE_TITLE_TEXT := "WAVE"
const LETTER_FONT_TEXTURE := preload("res://assets/Texto/Fuente de letras.png")
const LETTER_FONT_COLUMNS := 13
const LETTER_FONT_ROWS := 2
const LETTER_FONT_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const WAVE_TITLE_TEXT_HEIGHT := 66.0
const WAVE_TITLE_LETTER_SPACING := -17.0
const COUNT_MULTIPLIER_TEXTURE := preload("res://assets/Texto/x.png")
const FOG_TEXTURE := preload("res://assets/Texto/Particulas de niebla.png")
const HARD_FOG_TEXTURE := preload("res://assets/Texto/Particulas de niebla duras.png")
const BASE_ZONE_TEXTURE := preload("res://assets/Texto/Explanada de base.png")
const BASE_HORIZONTAL_FENCE_TEXTURE := preload("res://assets/Objetos de la base/Valla de madera.png")
const BASE_VERTICAL_FENCE_TEXTURE := preload("res://assets/Objetos de la base/Valla vertical.png")
const BASE_CAMPFIRE_TEXTURE := preload("res://assets/Objetos de la base/Fogata.png")
const BASE_SMOKE_TEXTURE := preload("res://assets/Objetos de la base/Particula de humo.png")
const BASE_BOX_TEXTURE := preload("res://assets/Objetos de la base/Caja.png")
const BASE_BUILDING_TEXTURE := preload("res://assets/Objetos de la base/Base.png")
const BASE_BUILD_BUTTON_TEXTURE := preload("res://assets/Texto/Botón construir.png")
const FOG_MUSIC_STREAM := preload("res://assets/Sonido/Música/Niebla.mp3")
const BASE_MUSIC_STREAM := preload("res://assets/Sonido/Música/Musica de la expalnada de la base.mp3")
const ACHIEVEMENT_NOTIFICATION_SOUND := preload("res://assets/Sonido/Efectos/Xbox sonido logro inusual [VFQ27MdSyFU].mp3")
const ACHIEVEMENT_NOTIFICATION_TARGET_HEIGHT := 400.0
const ACHIEVEMENT_NOTIFICATION_MARGIN := 20.0
const ACHIEVEMENT_NOTIFICATION_HIDDEN_OFFSET := 24.0
const ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION := 0.34
const ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION := 0.28
const ACHIEVEMENT_NOTIFICATION_VISIBLE_TIME := 9.0
const ACHIEVEMENT_NOTIFICATION_FALLBACK_WIDTH := 420.0
const ACHIEVEMENT_SAVE_PATH := "user://achievements.cfg"
const BASE_LOOT_SAVE_PATH := "user://base_loot.cfg"
const ACHIEVEMENT_TWO_ZOMBIES_ONE_BULLET := &"two_zombies_one_bullet"
const ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE := &"three_strong_zombies_one_grenade"
const ACHIEVEMENT_TEN_GRENADES := &"ten_grenades"
const ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON := &"defeat_michael_jackson"
const ACHIEVEMENT_DISCOVER_ALL_ZOMBIES := &"discover_all_zombies"
const ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES := &"kill_100_normal_zombies"
const ACHIEVEMENT_KILL_100_FAST_ZOMBIES := &"kill_100_fast_zombies"
const ACHIEVEMENT_KILL_100_STRONG_ZOMBIES := &"kill_100_strong_zombies"
const ACHIEVEMENT_TEN_ACTIVE_MINES := &"ten_active_mines"
const ACHIEVEMENT_CLOSE_ZOMBIE_KILL := &"close_zombie_kill"
const ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE := Vector2(140, 112)
const ACHIEVEMENT_NOTIFICATION_HEADING_HEIGHT := 30.0
const ACHIEVEMENT_NOTIFICATION_TITLE_HEIGHT := 38.0
const ACHIEVEMENT_NOTIFICATION_TITLE_MAX_CHARS := 15
const ACHIEVEMENT_NOTIFICATION_DESCRIPTION_MAX_CHARS := 24
const ACHIEVEMENT_NOTIFICATION_LETTER_SPACING := -18.0
const ACHIEVEMENT_IMAGE_TEXTURES := {
	&"two_zombies_one_bullet": preload("res://assets/Texto/Logros/Double shoot 2.png"),
	&"three_strong_zombies_one_grenade": preload("res://assets/Texto/Logros/Bomba 2.png"),
	&"ten_grenades": preload("res://assets/Texto/Logros/Ahorros explosivos 2.png"),
	&"defeat_michael_jackson": preload("res://assets/Texto/Logros/Aguafiestas 2.png"),
	&"discover_all_zombies": preload("res://assets/Texto/Logros/Zombi\u00f3logo 2.png"),
	&"kill_100_normal_zombies": preload("res://assets/Texto/Logros/Verde asesino 2.png"),
	&"kill_100_fast_zombies": preload("res://assets/Texto/Logros/R\u00e1pido asesino 2.png"),
	&"kill_100_strong_zombies": preload("res://assets/Texto/Logros/Asesino por fuerza bruta 2.png"),
	&"ten_active_mines": preload("res://assets/Texto/Logros/Mala suerte 2.png"),
	&"close_zombie_kill": preload("res://assets/Texto/Logros/Sigilo 101 2.png"),
}
const ZOMBIE_TYPE_NORMAL := &"normal"
const ZOMBIE_TYPE_ATOMIC := &"atomic"
const ZOMBIE_TYPE_FAST := &"fast"
const ZOMBIE_TYPE_STRONG := &"strong"
const ZOMBIE_TYPE_MINER := &"miner"
const ZOMBIE_TYPE_MICHAEL_JACKSON := &"michael_jackson"
const ACTIVE_MINES_ACHIEVEMENT_TARGET := 10
const CLOSE_ZOMBIE_KILL_DISTANCE := 96.0
const FOG_START_WAVE := 15
const FOG_WAVE_PERIOD := 20
const FOG_WAVE_DURATION := 10
const FOG_BRIGHTNESS := Color(0.72, 0.72, 0.72, 1.0)
const MICHAEL_JACKSON_BRIGHTNESS := Color(0.72, 0.72, 0.72, 1.0)
const HARD_MODE_STRONG_ZOMBIE_START_WAVE := 1
const HARD_MODE_FAST_ZOMBIE_START_WAVE := 3
const HARD_MODE_FAST_ZOMBIES_ADDED_PER_WAVE := 2
const HARD_MODE_MINER_ZOMBIE_START_WAVE := 7
const HARD_MODE_FOG_START_WAVE := 10
const HARD_MODE_ZOMBIE_SPEED_MULTIPLIER := 1.12
const HARD_MODE_POWER_UP_DROP_MULTIPLIER := 0.55
const HARD_FOG_MIN_COUNT := 5
const HARD_FOG_MAX_COUNT := 6
const HARD_FOG_EXTRA_PER_PERIOD := 1
const HARD_FOG_MAX_TOTAL_COUNT := 14
const HARD_FOG_ALPHA := 0.58
const HARD_FOG_DRIFT_DISTANCE := 34.0
const HARD_FOG_MIN_DRIFT_SPEED := 0.18
const SELECTED_POWER_UP_ICON_SCALE := 1.14
const POWER_UP_MEDKIT := &"medkit"
const POWER_UP_TELEPORT_ORB := &"teleport_orb"
const POWER_UP_GRENADE := &"grenade"
const POWER_UP_MINE := &"mine"
const HARD_FOG_MAX_DRIFT_SPEED := 0.34
const BASE_ZONE_ORIGIN := Vector2(5200, 0)
const BASE_ZONE_SIZE := Vector2(3500, 2625)
const BASE_ZONE_WALL_THICKNESS := 72.0
const BASE_ZONE_PLAYER_SPAWN_OFFSET := Vector2(0, 260)
const BASE_FENCE_TARGET_MAX_SIZE := 126.0
const BASE_BOTTOM_GATE_WIDTH_RATIO := 1.15
const BASE_BOX_TARGET_MAX_SIZE := 170.0
const BASE_BOX_FENCE_PADDING := Vector2(155.0, 145.0)
const BASE_BUILDING_TARGET_MAX_SIZE := 1700.0
const BASE_BUILT_BOX_TARGET_MAX_SIZE := 150.0
const BASE_BUILT_BOX_PADDING := 110.0
const BASE_BUILD_BUTTON_SIZE := Vector2(280.0, 104.0)
const BASE_BUILD_PICKER_SIZE := Vector2(560.0, 178.0)
const BASE_BUILD_OPTION_SIZE := Vector2(210.0, 142.0)
const BATTLE_LOOT_CONTAINER_POSITION := Vector2(950, -840)
const BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE := Vector2(1120, 1120)
const BATTLE_LOOT_MINECART_POSITION := Vector2(0, -1120)
const BATTLE_LOOT_MINECART_MIN_SPAWN_TIME := 18.0
const BATTLE_LOOT_MINECART_MAX_SPAWN_TIME := 36.0
const EXTRACTION_WAVE_ZOMBIE_MULTIPLIER := 1.65
const EXTRACTION_WAVE_MIN_EXTRA_ZOMBIES := 5
const EXTRACTION_WAVE_FAST_BONUS := 2
const EXTRACTION_WAVE_STRONG_BONUS := 1
const LATE_WAVE_SOFTEN_START := 13
const LATE_WAVE_ZOMBIE_REDUCTION_STEP := 2
const LATE_WAVE_ZOMBIES_REMOVED_ON_START := 1
const LATE_WAVE_EXTRA_SPAWN_INTERVAL := 0.15
const LATE_WAVE_EXTRA_SPAWN_INTERVAL_PER_WAVE := 0.02
const LATE_WAVE_MAX_EXTRA_SPAWN_INTERVAL := 0.35
const LATE_WAVE_FAST_RATIO_CAP := 0.40
const LATE_WAVE_STRONG_RATIO_CAP := 0.22
const LATE_WAVE_MINER_RATIO_CAP := 0.12
const MICHAEL_JACKSON_HEALTH_ADDED_PER_RETURN := 3
const ZOMBIE_TYPES_FOR_ZOMBIOLOGO := [
	ZOMBIE_TYPE_NORMAL,
	ZOMBIE_TYPE_ATOMIC,
	ZOMBIE_TYPE_FAST,
	ZOMBIE_TYPE_STRONG,
	ZOMBIE_TYPE_MINER,
	ZOMBIE_TYPE_MICHAEL_JACKSON,
]
const ZOMBIE_KILL_MILESTONE := 100
const ACHIEVEMENT_DEFINITIONS := [
	{
		"id": ACHIEVEMENT_TWO_ZOMBIES_ONE_BULLET,
		"title": "Double Kill",
		"description": "Kill 2 zombies with the same bullet without using power-ups.",
	},
	{
		"id": ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE,
		"title": "Boom!!!",
		"description": "Kill three strong zombies with one grenade.",
	},
	{
		"id": ACHIEVEMENT_TEN_GRENADES,
		"title": "Explosive Savings",
		"description": "Stockpile 10 grenades.",
	},
	{
		"id": ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON,
		"title": "Party Pooper",
		"description": "Defeat the Michael Jackson zombie.",
	},
	{
		"id": ACHIEVEMENT_DISCOVER_ALL_ZOMBIES,
		"title": "Zombiologist",
		"description": "Discover every zombie type.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES,
		"title": "Green Slayer",
		"description": "Kill 100 or more normal zombies.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_FAST_ZOMBIES,
		"title": "Speed Slayer",
		"description": "Kill 100 or more fast zombies.",
	},
	{
		"id": ACHIEVEMENT_KILL_100_STRONG_ZOMBIES,
		"title": "Brute Force Slayer",
		"description": "Kill 100 or more strong zombies.",
	},
	{
		"id": ACHIEVEMENT_TEN_ACTIVE_MINES,
		"title": "Very Bad Luck",
		"description": "Have 10 armed mines on the ground at the same time.",
	},
	{
		"id": ACHIEVEMENT_CLOSE_ZOMBIE_KILL,
		"title": "Stealth 101",
		"description": "Kill a zombie that is very close to you.",
	},
]
const DIGIT_TEXTURES := {
	"0": preload("res://assets/Texto/0.png"),
	"1": preload("res://assets/Texto/1.png"),
	"2": preload("res://assets/Texto/2.png"),
	"3": preload("res://assets/Texto/3.png"),
	"4": preload("res://assets/Texto/4.png"),
	"5": preload("res://assets/Texto/5.png"),
	"6": preload("res://assets/Texto/6.png"),
	"7": preload("res://assets/Texto/7.png"),
	"8": preload("res://assets/Texto/8.png"),
	"9": preload("res://assets/Texto/9.png"),
}
const WAVE_SETTING_ORDER := [
	"first_wave_delay",
	"time_between_waves",
	"base_zombies_per_wave",
	"zombies_added_per_wave",
	"base_spawn_interval",
	"min_spawn_interval",
	"spawn_interval_reduction_per_wave",
	"fast_zombie_start_wave",
	"max_fast_zombies_on_start_wave",
	"fast_zombies_added_per_wave",
	"strong_zombie_start_wave",
	"max_strong_zombies_on_start_wave",
	"strong_zombies_added_per_wave",
	"atomic_zombie_start_wave",
	"max_atomic_zombies_on_start_wave",
	"atomic_zombies_added_per_wave",
	"miner_zombie_start_wave",
	"max_miner_zombies_on_start_wave",
	"miner_zombies_added_per_wave",
	"michael_jackson_start_wave",
	"michael_jackson_wave_interval",
	"minimum_normal_zombies_after_wave_ten",
	"michael_jackson_initial_zombie_delay",
	"michael_jackson_spawn_interval_bonus",
	"medkit_drop_start_wave",
	"medkit_drop_chance",
	"grenade_drop_start_wave",
	"grenade_drop_chance",
	"homing_bullets_drop_start_wave",
	"homing_bullets_drop_chance",
	"mine_drop_start_wave",
	"mine_drop_chance",
	"teleport_orb_drop_start_wave",
	"teleport_orb_drop_chance",
	"anti_cooldown_drop_start_wave",
	"anti_cooldown_drop_chance",
	"triple_bullet_drop_start_wave",
	"triple_bullet_drop_chance",
	"time_freeze_drop_start_wave",
	"time_freeze_drop_chance",
]
const WAVE_SETTING_TYPES := {
	"first_wave_delay": TYPE_FLOAT,
	"time_between_waves": TYPE_FLOAT,
	"base_zombies_per_wave": TYPE_INT,
	"zombies_added_per_wave": TYPE_INT,
	"base_spawn_interval": TYPE_FLOAT,
	"min_spawn_interval": TYPE_FLOAT,
	"spawn_interval_reduction_per_wave": TYPE_FLOAT,
	"fast_zombie_start_wave": TYPE_INT,
	"max_fast_zombies_on_start_wave": TYPE_INT,
	"fast_zombies_added_per_wave": TYPE_INT,
	"strong_zombie_start_wave": TYPE_INT,
	"max_strong_zombies_on_start_wave": TYPE_INT,
	"strong_zombies_added_per_wave": TYPE_INT,
	"atomic_zombie_start_wave": TYPE_INT,
	"max_atomic_zombies_on_start_wave": TYPE_INT,
	"atomic_zombies_added_per_wave": TYPE_INT,
	"miner_zombie_start_wave": TYPE_INT,
	"max_miner_zombies_on_start_wave": TYPE_INT,
	"miner_zombies_added_per_wave": TYPE_INT,
	"michael_jackson_start_wave": TYPE_INT,
	"michael_jackson_wave_interval": TYPE_INT,
	"minimum_normal_zombies_after_wave_ten": TYPE_INT,
	"michael_jackson_initial_zombie_delay": TYPE_FLOAT,
	"michael_jackson_spawn_interval_bonus": TYPE_FLOAT,
	"medkit_drop_start_wave": TYPE_INT,
	"medkit_drop_chance": TYPE_FLOAT,
	"grenade_drop_start_wave": TYPE_INT,
	"grenade_drop_chance": TYPE_FLOAT,
	"homing_bullets_drop_start_wave": TYPE_INT,
	"homing_bullets_drop_chance": TYPE_FLOAT,
	"mine_drop_start_wave": TYPE_INT,
	"mine_drop_chance": TYPE_FLOAT,
	"teleport_orb_drop_start_wave": TYPE_INT,
	"teleport_orb_drop_chance": TYPE_FLOAT,
	"anti_cooldown_drop_start_wave": TYPE_INT,
	"anti_cooldown_drop_chance": TYPE_FLOAT,
	"triple_bullet_drop_start_wave": TYPE_INT,
	"triple_bullet_drop_chance": TYPE_FLOAT,
	"time_freeze_drop_start_wave": TYPE_INT,
	"time_freeze_drop_chance": TYPE_FLOAT,
}

@export var first_wave_delay: float = 1.0
@export var time_between_waves: float = 2.5
@export var base_zombies_per_wave: int = 3
@export var zombies_added_per_wave: int = 1
@export var base_spawn_interval: float = 1.2
@export var min_spawn_interval: float = 0.35
@export var spawn_interval_reduction_per_wave: float = 0.08
@export var spawn_area: Rect2 = Rect2(-1320, -980, 2640, 1960)
@export var edge_margin: float = 72.0
@export var min_spawn_distance_from_player: float = 420.0
@export var fast_zombie_start_wave: int = 5
@export var max_fast_zombies_on_start_wave: int = 2
@export var fast_zombies_added_per_wave: int = 1
@export var strong_zombie_start_wave: int = 7
@export var max_strong_zombies_on_start_wave: int = 1
@export var strong_zombies_added_per_wave: int = 1
@export var atomic_zombie_start_wave: int = 8
@export var max_atomic_zombies_on_start_wave: int = 1
@export var atomic_zombies_added_per_wave: int = 1
@export var miner_zombie_start_wave: int = 12
@export var max_miner_zombies_on_start_wave: int = 1
@export var miner_zombies_added_per_wave: int = 1
@export var michael_jackson_start_wave: int = 10
@export var michael_jackson_wave_interval: int = 10
@export var minimum_normal_zombies_after_wave_ten: int = 5
@export var michael_jackson_initial_zombie_delay: float = 4.5
@export var michael_jackson_spawn_interval_bonus: float = 1.1
@export var medkit_drop_start_wave: int = 4
@export_range(0.0, 1.0, 0.01) var medkit_drop_chance: float = 0.05
@export var grenade_drop_start_wave: int = 3
@export_range(0.0, 1.0, 0.01) var grenade_drop_chance: float = 0.08
@export var homing_bullets_drop_start_wave: int = 6
@export_range(0.0, 1.0, 0.01) var homing_bullets_drop_chance: float = 0.04
@export var mine_drop_start_wave: int = 3
@export_range(0.0, 1.0, 0.01) var mine_drop_chance: float = 0.05
@export var teleport_orb_drop_start_wave: int = 5
@export_range(0.0, 1.0, 0.01) var teleport_orb_drop_chance: float = 0.04
@export var anti_cooldown_drop_start_wave: int = 5
@export_range(0.0, 1.0, 0.01) var anti_cooldown_drop_chance: float = 0.035
@export var triple_bullet_drop_start_wave: int = 4
@export_range(0.0, 1.0, 0.01) var triple_bullet_drop_chance: float = 0.045
@export var time_freeze_drop_start_wave: int = 6
@export_range(0.0, 1.0, 0.01) var time_freeze_drop_chance: float = 0.035
@export var teleport_minimum_distance_from_zombies: float = 320.0
@export var teleport_minimum_travel_distance: float = 220.0
@export var teleport_search_attempts: int = 30
@export var teleport_wall_padding: float = 96.0

@onready var player: Node2D = $Player
@onready var wave_label: Label = $CanvasLayer/WaveLabel
@onready var grenade_icon: TextureRect = $CanvasLayer/GrenadeIcon
@onready var grenade_count_label: Label = $CanvasLayer/GrenadeCountLabel
@onready var medkit_icon: TextureRect = $CanvasLayer/MedkitIcon
@onready var medkit_count_label: Label = $CanvasLayer/MedkitCountLabel
@onready var mine_icon: TextureRect = $CanvasLayer/MineIcon
@onready var mine_count_label: Label = $CanvasLayer/MineCountLabel
@onready var teleport_orb_icon: TextureRect = $CanvasLayer/TeleportOrbIcon
@onready var teleport_orb_count_label: Label = $CanvasLayer/TeleportOrbCountLabel
@onready var menu: CanvasLayer = $Menu
@onready var player_camera: Camera2D = $Player/Camera2D

var wave_display_root: Node2D
var wave_number_root: Node2D
var grenade_count_digits_root: Node2D
var medkit_count_digits_root: Node2D
var mine_count_digits_root: Node2D
var teleport_orb_count_digits_root: Node2D
var stamina_bar_panel: PanelContainer = null
var stamina_bar: ProgressBar = null
var base_zone_root: Node2D = null
var base_default_content_root: Node2D = null
var base_building_body: StaticBody2D = null
var base_building_sprite: Sprite2D = null
var base_building_collision: CollisionShape2D = null
var base_building_click_area: Area2D = null
var base_zone_label: Label = null
var base_build_button: Button = null
var base_build_picker_panel: PanelContainer = null
var base_build_option_button: Button = null
var base_loot_display_root: Control = null
var fog_overlay: Sprite2D = null
var fog_brightness_modulate: CanvasModulate = null
var fog_music: AudioStreamPlayer = null
var base_music: AudioStreamPlayer = null
var hard_fog_particles: Array[Dictionary] = []
var hard_fog_time: float = 0.0
var hard_fog_period_start: int = -1
var displayed_number_cache: Dictionary = {}
var unlocked_achievements: Dictionary = {}
var zombie_kill_counts: Dictionary = {}
var discovered_zombie_types: Dictionary = {}
var wave_record: int = 0
var achievement_feedback_enabled: bool = false
var achievement_notification_queue: Array[StringName] = []
var achievement_notification_active: bool = false
var achievement_notification_logo: Control = null
var achievement_notification_sound_player: AudioStreamPlayer = null
var achievement_notification_tween: Tween = null
var white_sprite_text_material: ShaderMaterial = null
var selected_power_up_id: StringName = &""
var power_up_icon_base_scales: Dictionary = {}

var current_wave: int = 0
var zombies_left_to_spawn: int = 0
var normal_zombies_left_to_spawn: int = 0
var atomic_zombies_left_to_spawn: int = 0
var fast_zombies_left_to_spawn: int = 0
var strong_zombies_left_to_spawn: int = 0
var miner_zombies_left_to_spawn: int = 0
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var wave_active: bool = false
var player_dead: bool = false
var hard_mode_enabled: bool = false
var is_in_base_zone: bool = false
var base_build_picker_open: bool = false
var base_build_preview_active: bool = false
var base_building_placed: bool = false
var return_from_base_position: Vector2 = Vector2.ZERO
var battle_camera_limit_left: int = 0
var battle_camera_limit_top: int = 0
var battle_camera_limit_right: int = 0
var battle_camera_limit_bottom: int = 0
var loot_minecart_spawn_timer: float = 0.0
var expedition_loot_counts: Dictionary = {}
var stored_base_loot_counts: Dictionary = {}
var extraction_requested: bool = false
var extraction_wave_active: bool = false
var time_freeze_timer: float = 0.0
var time_frozen_zombie_states: Dictionary = {}
var time_frozen_object_states: Dictionary = {}
var time_frozen_music_states: Array[Dictionary] = []


func _ready() -> void:
	randomize()
	_reset_loot_minecart_spawn_timer()
	_load_achievements()
	_load_base_loot()
	_cache_battle_camera_limits()
	_setup_base_zone()
	_setup_battle_loot_container()
	_setup_fog_effect()
	_setup_number_displays()
	_setup_stamina_bar()
	_setup_base_travel_ui()
	_setup_base_build_ui()
	_setup_expedition_ui()
	_setup_achievement_feedback()
	_setup_power_up_selection_ui()
	if player.has_signal("died"):
		player.died.connect(_on_player_died)
	if player.has_signal("selected_power_up_changed"):
		player.selected_power_up_changed.connect(_on_player_selected_power_up_changed)
	if player.has_signal("stamina_changed"):
		player.stamina_changed.connect(_on_player_stamina_changed)
	if player.has_signal("medkit_count_changed"):
		player.medkit_count_changed.connect(_on_player_medkit_count_changed)
	if player.has_signal("grenade_count_changed"):
		player.grenade_count_changed.connect(_on_player_grenade_count_changed)
	if player.has_signal("mine_count_changed"):
		player.mine_count_changed.connect(_on_player_mine_count_changed)
	if player.has_signal("teleport_orb_count_changed"):
		player.teleport_orb_count_changed.connect(_on_player_teleport_orb_count_changed)
	if player.has_method("get_medkit_count"):
		_update_medkit_icon(player.get_medkit_count())
	if player.has_method("get_grenade_count"):
		_update_grenade_icon(player.get_grenade_count())
	if player.has_method("get_mine_count"):
		_update_mine_icon(player.get_mine_count())
	if player.has_method("get_teleport_orb_count"):
		_update_teleport_orb_icon(player.get_teleport_orb_count())
	if player.has_method("get_stamina") and player.has_method("get_max_stamina"):
		_update_stamina_bar(float(player.call("get_stamina")), float(player.call("get_max_stamina")))
	_update_selected_power_up_ui()
	wave_timer = first_wave_delay
	_update_wave_label()
	_update_fog_effect_for_wave()
	_update_base_travel_ui()
	achievement_feedback_enabled = true


func set_hard_mode_enabled(enabled: bool) -> void:
	hard_mode_enabled = enabled
	_update_fog_effect_for_wave()


func is_hard_mode_enabled() -> bool:
	return hard_mode_enabled


func unlock_achievement(achievement_id: StringName) -> bool:
	if not _has_achievement_definition(achievement_id):
		return false
	if bool(unlocked_achievements.get(achievement_id, false)):
		return false

	unlocked_achievements[achievement_id] = true
	_save_achievements()
	_queue_achievement_feedback(achievement_id)
	return true


func get_achievements_text() -> String:
	var lines: Array[String] = []

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var unlocked := bool(unlocked_achievements.get(achievement_id, false))
		var status := "UNLOCKED" if unlocked else "LOCKED"
		lines.append("[%s] %s" % [status, String(achievement["title"])])
		lines.append(String(achievement["description"]))
		lines.append("")

	return "\n".join(lines).strip_edges()


func get_achievements_data() -> Array[Dictionary]:
	var achievements: Array[Dictionary] = []

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var achievement_data: Dictionary = achievement.duplicate()
		achievement_data["unlocked"] = bool(unlocked_achievements.get(achievement_id, false))
		achievements.append(achievement_data)

	return achievements


func get_wave_record() -> int:
	return wave_record


func skip_to_wave(target_wave: int) -> void:
	if player_dead:
		return

	target_wave = maxi(target_wave, 1)
	_clear_current_wave_for_skip()
	current_wave = target_wave - 1
	wave_timer = 0.0
	_start_next_wave()


func go_to_base() -> void:
	if player_dead or is_in_base_zone or not is_instance_valid(player):
		return

	return_from_base_position = player.global_position
	is_in_base_zone = true
	_set_zombies_paused_for_base(true)
	_move_player_to(BASE_ZONE_ORIGIN + BASE_ZONE_PLAYER_SPAWN_OFFSET)
	_set_camera_limits_to_rect(Rect2(BASE_ZONE_ORIGIN - BASE_ZONE_SIZE * 0.5, BASE_ZONE_SIZE))
	if is_instance_valid(base_zone_root):
		base_zone_root.show()
	if is_instance_valid(wave_display_root):
		wave_display_root.hide()
	if is_instance_valid(fog_overlay):
		fog_overlay.hide()
	if is_instance_valid(fog_brightness_modulate):
		fog_brightness_modulate.color = Color.WHITE
	_set_hard_fog_particles_visible(false)
	_update_fog_music_for_state(false)
	_update_base_loot_display()
	_update_base_travel_ui()
	_update_expedition_ui()


func return_from_base() -> void:
	if player_dead or not is_in_base_zone or not is_instance_valid(player):
		return

	_cancel_base_build_preview()
	is_in_base_zone = false
	_move_player_to(return_from_base_position)
	_restore_battle_camera_limits()
	_set_zombies_paused_for_base(false)
	if is_instance_valid(base_zone_root):
		base_zone_root.hide()
	_update_wave_label()
	_update_fog_effect_for_wave()
	_update_base_travel_ui()
	_update_expedition_ui()


func return_from_base_to_menu() -> void:
	if player_dead:
		return

	if is_in_base_zone:
		return_from_base()

	if is_instance_valid(menu) and menu.has_method("show_main_menu"):
		menu.call("show_main_menu")


func toggle_base_zone() -> void:
	if is_in_base_zone:
		return_from_base_to_menu()
	else:
		go_to_base()


func is_player_in_base_zone() -> bool:
	return is_in_base_zone


func register_grenade_stock(grenade_count: int) -> void:
	if grenade_count >= 10:
		unlock_achievement(ACHIEVEMENT_TEN_GRENADES)


func register_grenade_strong_zombie_kills(kill_count: int) -> void:
	if kill_count >= 3:
		unlock_achievement(ACHIEVEMENT_THREE_STRONG_ZOMBIES_ONE_GRENADE)


func check_active_mine_achievement() -> void:
	if bool(unlocked_achievements.get(ACHIEVEMENT_TEN_ACTIVE_MINES, false)):
		return
	if _get_active_placed_mine_count() >= ACTIVE_MINES_ACHIEVEMENT_TARGET:
		unlock_achievement(ACHIEVEMENT_TEN_ACTIVE_MINES)


func clear_achievements() -> void:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		unlocked_achievements[achievement_id] = false

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		zombie_kill_counts[zombie_type] = 0
		discovered_zombie_types[zombie_type] = false

	_save_achievements()


func _load_achievements() -> void:
	unlocked_achievements.clear()
	zombie_kill_counts.clear()
	discovered_zombie_types.clear()
	var config := ConfigFile.new()
	var load_result := config.load(ACHIEVEMENT_SAVE_PATH)
	wave_record = 0
	if load_result == OK:
		wave_record = maxi(int(config.get_value("stats", "wave_record", 0)), 0)

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		var unlocked := false
		if load_result == OK:
			unlocked = bool(config.get_value("achievements", String(achievement_id), false))
		unlocked_achievements[achievement_id] = unlocked

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		var kill_count := 0
		var discovered := false
		if load_result == OK:
			kill_count = int(config.get_value("zombie_kills", String(zombie_type), 0))
			discovered = bool(config.get_value("discovered_zombies", String(zombie_type), kill_count > 0))
		zombie_kill_counts[zombie_type] = kill_count
		discovered_zombie_types[zombie_type] = discovered

	_sync_achievement_progress()


func _save_achievements() -> void:
	var config := ConfigFile.new()

	for achievement in ACHIEVEMENT_DEFINITIONS:
		var achievement_id: StringName = achievement["id"]
		config.set_value(
			"achievements",
			String(achievement_id),
			bool(unlocked_achievements.get(achievement_id, false))
		)

	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		config.set_value(
			"zombie_kills",
			String(zombie_type),
			int(zombie_kill_counts.get(zombie_type, 0))
		)
		config.set_value(
			"discovered_zombies",
			String(zombie_type),
			bool(discovered_zombie_types.get(zombie_type, false))
		)

	config.set_value("stats", "wave_record", wave_record)

	config.save(ACHIEVEMENT_SAVE_PATH)


func _load_base_loot() -> void:
	stored_base_loot_counts.clear()
	var config := ConfigFile.new()
	var load_result := config.load(BASE_LOOT_SAVE_PATH)

	for loot_id_variant in LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		var amount := 0
		if load_result == OK:
			amount = maxi(int(config.get_value("loot", String(loot_id), 0)), 0)
		stored_base_loot_counts[loot_id] = amount


func save_base_loot() -> void:
	var config := ConfigFile.new()
	for loot_id_variant in LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		config.set_value("loot", String(loot_id), int(stored_base_loot_counts.get(loot_id, 0)))

	config.save(BASE_LOOT_SAVE_PATH)


func _has_achievement_definition(achievement_id: StringName) -> bool:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		if achievement["id"] == achievement_id:
			return true
	return false


func _process(delta: float) -> void:
	_update_hard_fog_particles(delta)
	_update_base_travel_ui()
	_update_expedition_ui()
	_update_time_freeze(delta)

	if _is_time_freeze_active():
		return

	if player_dead:
		return

	if is_in_base_zone:
		return

	if not _is_menu_visible():
		_update_loot_minecart_spawn(delta)

	if not wave_active:
		if _get_alive_zombie_count() > 0:
			return
		if extraction_requested:
			_start_extraction_wave()
			return

		wave_timer = maxf(wave_timer - delta, 0.0)
		_update_wave_label()
		if wave_timer == 0.0:
			_start_next_wave()
		return

	spawn_timer = maxf(spawn_timer - delta, 0.0)
	if zombies_left_to_spawn > 0 and spawn_timer == 0.0:
		_spawn_next_zombie()
		spawn_timer = _get_spawn_interval_for_wave()

	if zombies_left_to_spawn == 0 and _get_alive_zombie_count() == 0:
		if extraction_wave_active:
			_complete_expedition_to_base()
			return
		if extraction_requested:
			_start_extraction_wave()
			return

		wave_active = false
		wave_timer = time_between_waves
		_update_wave_label()


func _start_next_wave() -> void:
	current_wave += 1
	wave_active = true
	_register_wave_record(current_wave)
	var base_zombies_for_wave := _get_total_zombies_for_wave(current_wave)
	zombies_left_to_spawn = base_zombies_for_wave
	strong_zombies_left_to_spawn = _get_strong_zombies_for_wave(current_wave, zombies_left_to_spawn)
	strong_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		strong_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_STRONG_RATIO_CAP
	)
	var zombies_remaining_after_strong := zombies_left_to_spawn - strong_zombies_left_to_spawn
	fast_zombies_left_to_spawn = _get_fast_zombies_for_wave(current_wave, zombies_remaining_after_strong)
	fast_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		fast_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_FAST_RATIO_CAP
	)
	normal_zombies_left_to_spawn = base_zombies_for_wave - fast_zombies_left_to_spawn - strong_zombies_left_to_spawn
	miner_zombies_left_to_spawn = _get_miner_zombies_for_wave(current_wave)
	miner_zombies_left_to_spawn = _apply_late_wave_special_cap(
		current_wave,
		miner_zombies_left_to_spawn,
		base_zombies_for_wave,
		LATE_WAVE_MINER_RATIO_CAP
	)
	zombies_left_to_spawn += miner_zombies_left_to_spawn
	_ensure_minimum_normal_zombies()
	atomic_zombies_left_to_spawn = _get_atomic_zombies_for_wave(current_wave, normal_zombies_left_to_spawn)
	spawn_timer = 0.0
	if _should_spawn_michael_jackson(current_wave):
		_spawn_michael_jackson_zombie()
		spawn_timer = michael_jackson_initial_zombie_delay
	_update_wave_label()
	_update_fog_effect_for_wave()


func _register_wave_record(wave: int) -> void:
	if wave <= wave_record:
		return

	wave_record = wave
	_save_achievements()


func _clear_current_wave_for_skip() -> void:
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	spawn_timer = 0.0

	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(zombie_node):
			zombie_node.queue_free()


func _cache_battle_camera_limits() -> void:
	if not is_instance_valid(player_camera):
		return

	battle_camera_limit_left = player_camera.limit_left
	battle_camera_limit_top = player_camera.limit_top
	battle_camera_limit_right = player_camera.limit_right
	battle_camera_limit_bottom = player_camera.limit_bottom


func _setup_base_zone() -> void:
	if base_zone_root != null:
		return

	base_zone_root = Node2D.new()
	base_zone_root.name = "ExplanadaBase"
	base_zone_root.position = BASE_ZONE_ORIGIN
	base_zone_root.z_index = 20
	base_zone_root.visible = false
	add_child(base_zone_root)

	base_default_content_root = Node2D.new()
	base_default_content_root.name = "BaseDefaultContent"
	base_zone_root.add_child(base_default_content_root)
	_setup_base_loot_display()

	var half_size := BASE_ZONE_SIZE * 0.5
	var base_floor := Sprite2D.new()
	base_floor.name = "BaseFloor"
	base_floor.texture = BASE_ZONE_TEXTURE
	base_floor.centered = true
	base_floor.z_index = -20
	if BASE_ZONE_TEXTURE != null and BASE_ZONE_TEXTURE.get_width() > 0 and BASE_ZONE_TEXTURE.get_height() > 0:
		base_floor.scale = Vector2(
			BASE_ZONE_SIZE.x / float(BASE_ZONE_TEXTURE.get_width()),
			BASE_ZONE_SIZE.y / float(BASE_ZONE_TEXTURE.get_height())
		)
	base_zone_root.add_child(base_floor)

	_add_base_wall(
		"BaseTopWall",
		Vector2(0, -half_size.y - BASE_ZONE_WALL_THICKNESS * 0.5),
		Vector2(BASE_ZONE_SIZE.x + BASE_ZONE_WALL_THICKNESS * 2.0, BASE_ZONE_WALL_THICKNESS)
	)
	_add_base_wall(
		"BaseBottomWall",
		Vector2(0, half_size.y + BASE_ZONE_WALL_THICKNESS * 0.5),
		Vector2(BASE_ZONE_SIZE.x + BASE_ZONE_WALL_THICKNESS * 2.0, BASE_ZONE_WALL_THICKNESS)
	)
	_add_base_wall(
		"BaseLeftWall",
		Vector2(-half_size.x - BASE_ZONE_WALL_THICKNESS * 0.5, 0),
		Vector2(BASE_ZONE_WALL_THICKNESS, BASE_ZONE_SIZE.y)
	)
	_add_base_wall(
		"BaseRightWall",
		Vector2(half_size.x + BASE_ZONE_WALL_THICKNESS * 0.5, 0),
		Vector2(BASE_ZONE_WALL_THICKNESS, BASE_ZONE_SIZE.y)
	)
	_setup_base_fences()
	_setup_base_campfire()
	_setup_base_corner_boxes()
	_setup_base_building_preview()


func _setup_base_travel_ui() -> void:
	var canvas_layer := get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	base_zone_label = Label.new()
	base_zone_label.name = "BaseZoneLabel"
	base_zone_label.text = "EXPLANADA BASE"
	base_zone_label.visible = false
	base_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base_zone_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	base_zone_label.offset_left = -260.0
	base_zone_label.offset_top = 24.0
	base_zone_label.offset_right = 260.0
	base_zone_label.offset_bottom = 80.0
	base_zone_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 1.0))
	base_zone_label.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.04, 0.95))
	base_zone_label.add_theme_constant_override("outline_size", 5)
	base_zone_label.add_theme_font_size_override("font_size", 36)
	canvas_layer.add_child(base_zone_label)

	_update_base_travel_ui()


func _setup_battle_loot_container() -> void:
	if get_node_or_null("BattleLootContainer") != null:
		return

	var container := StaticBody2D.new()
	container.name = "BattleLootContainer"
	container.set_script(LOOT_CONTAINER_SCRIPT)
	container.global_position = BATTLE_LOOT_CONTAINER_POSITION
	add_child(container)


func _setup_expedition_ui() -> void:
	_update_expedition_ui()


func _update_loot_minecart_spawn(delta: float) -> void:
	if get_node_or_null("BattleLootMinecart") != null:
		return

	loot_minecart_spawn_timer = maxf(loot_minecart_spawn_timer - delta, 0.0)
	if loot_minecart_spawn_timer > 0.0:
		return

	_spawn_loot_minecart()


func _spawn_loot_minecart() -> void:
	if get_node_or_null("BattleLootMinecart") != null:
		return

	var minecart := StaticBody2D.new()
	minecart.name = "BattleLootMinecart"
	minecart.set_script(LOOT_MINECART_SCRIPT)
	minecart.global_position = BATTLE_LOOT_MINECART_POSITION
	minecart.tree_exited.connect(_reset_loot_minecart_spawn_timer)
	add_child(minecart)


func _reset_loot_minecart_spawn_timer() -> void:
	loot_minecart_spawn_timer = randf_range(
		BATTLE_LOOT_MINECART_MIN_SPAWN_TIME,
		BATTLE_LOOT_MINECART_MAX_SPAWN_TIME
	)


func _start_extraction_wave() -> void:
	if player_dead or is_in_base_zone or extraction_wave_active:
		return

	extraction_requested = false
	extraction_wave_active = true
	wave_active = true
	current_wave += 1
	_register_wave_record(current_wave)

	var base_zombies_for_wave := _get_total_zombies_for_wave(current_wave)
	var extraction_total := maxi(
		int(ceil(float(base_zombies_for_wave) * EXTRACTION_WAVE_ZOMBIE_MULTIPLIER)),
		base_zombies_for_wave + EXTRACTION_WAVE_MIN_EXTRA_ZOMBIES
	)
	strong_zombies_left_to_spawn = mini(
		_get_strong_zombies_for_wave(current_wave, extraction_total) + EXTRACTION_WAVE_STRONG_BONUS,
		extraction_total
	)
	var remaining_after_strong := maxi(extraction_total - strong_zombies_left_to_spawn, 0)
	fast_zombies_left_to_spawn = mini(
		_get_fast_zombies_for_wave(current_wave, remaining_after_strong) + EXTRACTION_WAVE_FAST_BONUS,
		remaining_after_strong
	)
	miner_zombies_left_to_spawn = mini(
		_get_miner_zombies_for_wave(current_wave),
		maxi(extraction_total - strong_zombies_left_to_spawn - fast_zombies_left_to_spawn, 0)
	)
	normal_zombies_left_to_spawn = maxi(
		extraction_total - strong_zombies_left_to_spawn - fast_zombies_left_to_spawn - miner_zombies_left_to_spawn,
		0
	)
	atomic_zombies_left_to_spawn = _get_atomic_zombies_for_wave(current_wave, normal_zombies_left_to_spawn)
	zombies_left_to_spawn = extraction_total
	spawn_timer = 0.0
	_update_wave_label()
	_update_fog_effect_for_wave()
	_update_expedition_ui()


func _complete_expedition_to_base() -> void:
	extraction_wave_active = false
	extraction_requested = false
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	_commit_expedition_loot_to_base()
	_clear_collectible_loot_nodes()
	_update_expedition_ui()
	go_to_base()


func register_collected_loot(loot_id: StringName) -> void:
	if player_dead or is_in_base_zone or not LOOT_TEXTURES.has(loot_id):
		return

	expedition_loot_counts[loot_id] = int(expedition_loot_counts.get(loot_id, 0)) + 1


func _commit_expedition_loot_to_base() -> void:
	for loot_id_variant in expedition_loot_counts.keys():
		var loot_id: StringName = StringName(loot_id_variant)
		var amount := int(expedition_loot_counts.get(loot_id, 0))
		if amount <= 0:
			continue

		stored_base_loot_counts[loot_id] = int(stored_base_loot_counts.get(loot_id, 0)) + amount

	expedition_loot_counts.clear()
	save_base_loot()
	_update_base_loot_display()


func _clear_expedition_loot() -> void:
	expedition_loot_counts.clear()
	extraction_requested = false
	extraction_wave_active = false
	_clear_collectible_loot_nodes()
	_update_expedition_ui()


func _clear_collectible_loot_nodes() -> void:
	for loot_node in get_tree().get_nodes_in_group("collectible_loot"):
		if is_instance_valid(loot_node):
			loot_node.queue_free()


func _update_expedition_ui() -> void:
	pass


func _setup_base_loot_display() -> void:
	if base_loot_display_root != null:
		return

	var canvas_layer := get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	var display_panel := PanelContainer.new()
	base_loot_display_root = display_panel
	base_loot_display_root.name = "BaseLootDisplay"
	base_loot_display_root.visible = false
	base_loot_display_root.custom_minimum_size = Vector2(300.0, 250.0)
	base_loot_display_root.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	base_loot_display_root.offset_left = -BASE_BUILD_BUTTON_SIZE.x - 24.0
	base_loot_display_root.offset_top = 24.0 + BASE_BUILD_BUTTON_SIZE.y + 14.0
	base_loot_display_root.offset_right = -24.0
	base_loot_display_root.offset_bottom = base_loot_display_root.offset_top + 250.0
	display_panel.add_theme_stylebox_override("panel", _create_base_build_panel_stylebox())
	canvas_layer.add_child(base_loot_display_root)
	_update_base_loot_display()


func _update_base_loot_display() -> void:
	if not is_instance_valid(base_loot_display_root):
		return

	for child in base_loot_display_root.get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	base_loot_display_root.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Loot guardado"
	title.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.03, 1.0))
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_font_size_override("font_size", 26)
	content.add_child(title)

	var build_cost_label := Label.new()
	build_cost_label.text = "Base: madera %d, hierro %d" % [BASE_BUILD_WOOD_COST, BASE_BUILD_IRON_COST]
	build_cost_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.68, 1.0))
	build_cost_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
	build_cost_label.add_theme_constant_override("outline_size", 2)
	build_cost_label.add_theme_font_size_override("font_size", 18)
	content.add_child(build_cost_label)

	var has_any_loot := false
	for loot_id_variant in LOOT_DISPLAY_ORDER:
		var loot_id: StringName = loot_id_variant as StringName
		var amount := int(stored_base_loot_counts.get(loot_id, 0))
		if amount <= 0:
			continue

		has_any_loot = true
		var texture: Texture2D = LOOT_TEXTURES.get(loot_id, null) as Texture2D
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0.0, 42.0)
		row.add_theme_constant_override("separation", 10)
		content.add_child(row)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(38.0, 38.0)
		icon.texture = texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)

		var label := Label.new()
		label.text = "%s x%d" % [String(LOOT_DISPLAY_NAMES.get(loot_id, "Loot")), amount]
		label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.9, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_font_size_override("font_size", 23)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)

	if has_any_loot:
		return

	var empty_label := Label.new()
	empty_label.text = "Sin loot guardado"
	empty_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.84, 1.0))
	empty_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 1.0))
	empty_label.add_theme_constant_override("outline_size", 3)
	empty_label.add_theme_font_size_override("font_size", 23)
	content.add_child(empty_label)


func _setup_base_build_ui() -> void:
	var canvas_layer := get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	base_build_button = Button.new()
	base_build_button.name = "BaseBuildButton"
	base_build_button.visible = false
	base_build_button.flat = true
	base_build_button.focus_mode = Control.FOCUS_ALL
	base_build_button.custom_minimum_size = BASE_BUILD_BUTTON_SIZE
	base_build_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	base_build_button.offset_left = -BASE_BUILD_BUTTON_SIZE.x - 24.0
	base_build_button.offset_top = 24.0
	base_build_button.offset_right = -24.0
	base_build_button.offset_bottom = 24.0 + BASE_BUILD_BUTTON_SIZE.y
	base_build_button.pressed.connect(_on_base_build_button_pressed)
	base_build_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	base_build_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	canvas_layer.add_child(base_build_button)

	var build_button_graphic := TextureRect.new()
	build_button_graphic.name = "Graphic"
	build_button_graphic.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_button_graphic.texture = BASE_BUILD_BUTTON_TEXTURE
	build_button_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	build_button_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	build_button_graphic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_build_button.add_child(build_button_graphic)

	base_build_picker_panel = PanelContainer.new()
	base_build_picker_panel.name = "BaseBuildPicker"
	base_build_picker_panel.visible = false
	base_build_picker_panel.custom_minimum_size = BASE_BUILD_PICKER_SIZE
	base_build_picker_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	base_build_picker_panel.offset_left = -BASE_BUILD_PICKER_SIZE.x * 0.5
	base_build_picker_panel.offset_top = -BASE_BUILD_PICKER_SIZE.y - 22.0
	base_build_picker_panel.offset_right = BASE_BUILD_PICKER_SIZE.x * 0.5
	base_build_picker_panel.offset_bottom = -22.0
	base_build_picker_panel.add_theme_stylebox_override("panel", _create_base_build_panel_stylebox())
	canvas_layer.add_child(base_build_picker_panel)

	var picker_margin := MarginContainer.new()
	picker_margin.add_theme_constant_override("margin_left", 18)
	picker_margin.add_theme_constant_override("margin_top", 16)
	picker_margin.add_theme_constant_override("margin_right", 18)
	picker_margin.add_theme_constant_override("margin_bottom", 16)
	base_build_picker_panel.add_child(picker_margin)

	var picker_row := HBoxContainer.new()
	picker_row.alignment = BoxContainer.ALIGNMENT_CENTER
	picker_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picker_margin.add_child(picker_row)

	base_build_option_button = Button.new()
	base_build_option_button.name = "BaseBuildOptionButton"
	base_build_option_button.custom_minimum_size = BASE_BUILD_OPTION_SIZE
	base_build_option_button.flat = true
	base_build_option_button.focus_mode = Control.FOCUS_ALL
	base_build_option_button.pressed.connect(_on_base_build_option_pressed)
	base_build_option_button.add_theme_stylebox_override("normal", _create_base_build_option_stylebox(false))
	base_build_option_button.add_theme_stylebox_override("pressed", _create_base_build_option_stylebox(true))
	base_build_option_button.add_theme_stylebox_override("hover", _create_base_build_option_stylebox(true))
	base_build_option_button.add_theme_stylebox_override("focus", _create_base_build_option_stylebox(true))
	picker_row.add_child(base_build_option_button)

	var option_graphic := TextureRect.new()
	option_graphic.name = "Graphic"
	option_graphic.set_anchors_preset(Control.PRESET_FULL_RECT)
	option_graphic.texture = BASE_BUILDING_TEXTURE
	option_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	option_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	option_graphic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_build_option_button.add_child(option_graphic)

	_update_base_travel_ui()


func _setup_base_building_preview() -> void:
	if base_zone_root == null or BASE_BUILDING_TEXTURE == null:
		return

	var used_rect := _get_texture_used_rect(BASE_BUILDING_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var building_scale := BASE_BUILDING_TARGET_MAX_SIZE / largest_side
	base_building_body = StaticBody2D.new()
	base_building_body.name = "BuiltBaseBody"
	base_building_body.visible = false
	base_building_body.z_index = 18
	base_zone_root.add_child(base_building_body)

	base_building_sprite = Sprite2D.new()
	base_building_sprite.name = "BuiltBase"
	base_building_sprite.texture = BASE_BUILDING_TEXTURE
	base_building_sprite.centered = true
	base_building_sprite.scale = Vector2.ONE * building_scale
	base_building_body.add_child(base_building_sprite)

	base_building_collision = CollisionShape2D.new()
	base_building_collision.name = "CollisionShape2D"
	base_building_collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var body_shape := RectangleShape2D.new()
	body_shape.size = used_rect.size * building_scale
	base_building_collision.shape = body_shape
	base_building_collision.disabled = true
	base_building_body.add_child(base_building_collision)

	_setup_built_base_boxes(used_rect, building_scale)

	base_building_click_area = Area2D.new()
	base_building_click_area.name = "BuiltBaseClickArea"
	base_building_click_area.input_pickable = false
	base_building_click_area.monitoring = false
	base_building_click_area.z_index = 19
	base_building_click_area.input_event.connect(_on_base_building_preview_input_event)
	base_zone_root.add_child(base_building_click_area)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * building_scale
	collision.shape = shape
	base_building_click_area.add_child(collision)


func _get_base_default_content_parent() -> Node:
	if is_instance_valid(base_default_content_root):
		return base_default_content_root
	return base_zone_root


func _setup_built_base_boxes(building_used_rect: Rect2, building_scale: float) -> void:
	if not is_instance_valid(base_building_body) or BASE_BOX_TEXTURE == null:
		return

	var building_center := (
		building_used_rect.position
		+ building_used_rect.size * 0.5
		- BASE_BUILDING_TEXTURE.get_size() * 0.5
	) * building_scale
	var building_half_size := building_used_rect.size * building_scale * 0.5
	var top_y := building_center.y - building_half_size.y - BASE_BUILT_BOX_PADDING
	var bottom_y := building_center.y + building_half_size.y + BASE_BUILT_BOX_PADDING
	var left_x := building_center.x - building_half_size.x - BASE_BUILT_BOX_PADDING
	var right_x := building_center.x + building_half_size.x + BASE_BUILT_BOX_PADDING
	var horizontal_positions := [-0.36, -0.12, 0.12, 0.36]
	var side_positions := [-0.32, -0.12, 0.12, 0.32]

	var box_index := 1
	for x_ratio in horizontal_positions:
		var x := building_center.x + building_half_size.x * float(x_ratio)
		_add_built_base_box("BuiltBaseTopBox%d" % box_index, Vector2(x, top_y))
		box_index += 1
		_add_built_base_box("BuiltBaseBottomBox%d" % box_index, Vector2(x, bottom_y))
		box_index += 1

	for y_ratio in side_positions:
		var y := building_center.y + building_half_size.y * float(y_ratio)
		_add_built_base_box("BuiltBaseLeftBox%d" % box_index, Vector2(left_x, y))
		box_index += 1
		_add_built_base_box("BuiltBaseRightBox%d" % box_index, Vector2(right_x, y))
		box_index += 1


func _add_built_base_box(box_name: String, box_position: Vector2) -> void:
	if not is_instance_valid(base_building_body) or BASE_BOX_TEXTURE == null:
		return

	var used_rect := _get_texture_used_rect(BASE_BOX_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var box_scale := BASE_BUILT_BOX_TARGET_MAX_SIZE / largest_side
	var body := StaticBody2D.new()
	body.name = box_name
	body.position = box_position
	body.z_index = 24
	base_building_body.add_child(body)

	var box := Sprite2D.new()
	box.name = "Visual"
	box.texture = BASE_BOX_TEXTURE
	box.centered = true
	box.scale = Vector2.ONE * box_scale
	body.add_child(box)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BOX_TEXTURE.get_size() * 0.5
	) * box_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * box_scale
	collision.shape = shape
	collision.disabled = true
	body.add_child(collision)


func _create_base_build_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.06, 0.07, 0.06, 0.9)
	stylebox.border_color = Color(0.87, 0.72, 0.38, 0.95)
	stylebox.set_border_width_all(4)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.35)
	stylebox.shadow_size = 8
	return stylebox


func _create_base_build_option_stylebox(active: bool) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	var background_alpha := 0.82 if active else 0.62
	var border_alpha := 0.98 if active else 0.65
	stylebox.bg_color = Color(0.18, 0.16, 0.11, background_alpha)
	stylebox.border_color = Color(0.95, 0.84, 0.46, border_alpha)
	stylebox.set_border_width_all(3)
	stylebox.set_corner_radius_all(6)
	return stylebox


func _add_base_wall(wall_name: String, wall_position: Vector2, wall_size: Vector2) -> void:
	_add_base_static_rect(
		wall_name,
		wall_position,
		wall_size,
		Color(0, 0, 0, 0)
	)


func _add_base_static_rect(
	body_name: String,
	body_position: Vector2,
	body_size: Vector2,
	_visual_color: Color
) -> void:
	if base_zone_root == null:
		return

	var body := StaticBody2D.new()
	body.name = body_name
	body.position = body_position
	_get_base_default_content_parent().add_child(body)

	var shape := RectangleShape2D.new()
	shape.size = body_size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)


func _setup_base_fences() -> void:
	if base_zone_root == null:
		return

	var horizontal_used_rect := _get_texture_used_rect(BASE_HORIZONTAL_FENCE_TEXTURE)
	var vertical_used_rect := _get_texture_used_rect(BASE_VERTICAL_FENCE_TEXTURE)
	var horizontal_largest_side := maxf(horizontal_used_rect.size.x, horizontal_used_rect.size.y)
	var vertical_largest_side := maxf(vertical_used_rect.size.x, vertical_used_rect.size.y)
	if horizontal_largest_side <= 0.0 or vertical_largest_side <= 0.0:
		return

	var horizontal_scale := BASE_FENCE_TARGET_MAX_SIZE / horizontal_largest_side
	var vertical_scale := BASE_FENCE_TARGET_MAX_SIZE / vertical_largest_side
	var horizontal_step := horizontal_used_rect.size.x * horizontal_scale
	var horizontal_height := horizontal_used_rect.size.y * horizontal_scale
	var vertical_step := vertical_used_rect.size.y * vertical_scale
	var vertical_width := vertical_used_rect.size.x * vertical_scale
	var top_row_width := horizontal_step * 8.0
	var vertical_row_height := vertical_step * 5.0
	var bottom_gate_width := horizontal_step * BASE_BOTTOM_GATE_WIDTH_RATIO
	var bottom_row_width := top_row_width + bottom_gate_width
	var top_y := -vertical_row_height * 0.5 - horizontal_height * 0.5
	var bottom_y := vertical_row_height * 0.5 + horizontal_height * 0.5
	var left_x := -bottom_row_width * 0.5 - vertical_width * 0.5
	var right_x := bottom_row_width * 0.5 + vertical_width * 0.5

	for index in range(8):
		var top_x := -top_row_width * 0.5 + horizontal_step * (float(index) + 0.5)
		_add_base_fence_sprite(
			"TopFence%d" % (index + 1),
			BASE_HORIZONTAL_FENCE_TEXTURE,
			Vector2(top_x, top_y),
			horizontal_scale,
			4
		)

	for index in range(8):
		var group_index := index % 4
		var side := -1.0 if index < 4 else 1.0
		var bottom_x := side * (bottom_gate_width * 0.5 + horizontal_step * (float(group_index) + 0.5))
		_add_base_fence_sprite(
			"BottomFence%d" % (index + 1),
			BASE_HORIZONTAL_FENCE_TEXTURE,
			Vector2(bottom_x, bottom_y),
			horizontal_scale,
			4
		)

	for index in range(5):
		var vertical_y := -vertical_row_height * 0.5 + vertical_step * (float(index) + 0.5)
		_add_base_fence_sprite(
			"LeftFence%d" % (index + 1),
			BASE_VERTICAL_FENCE_TEXTURE,
			Vector2(left_x, vertical_y),
			vertical_scale,
			4
		)
		_add_base_fence_sprite(
			"RightFence%d" % (index + 1),
			BASE_VERTICAL_FENCE_TEXTURE,
			Vector2(right_x, vertical_y),
			vertical_scale,
			4
		)


func _add_base_fence_sprite(
	fence_name: String,
	texture: Texture2D,
	fence_position: Vector2,
	fence_scale: float,
	fence_z_index: int
) -> void:
	if base_zone_root == null or texture == null:
		return

	var fence_body := StaticBody2D.new()
	fence_body.name = fence_name
	fence_body.position = fence_position
	fence_body.z_index = fence_z_index
	_get_base_default_content_parent().add_child(fence_body)

	var fence := Sprite2D.new()
	fence.name = "Visual"
	fence.texture = texture
	fence.centered = true
	fence.scale = Vector2.ONE * fence_scale
	fence_body.add_child(fence)

	var used_rect := _get_texture_used_rect(texture)
	var texture_size := texture.get_size()
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- texture_size * 0.5
	) * fence_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * fence_scale
	collision.shape = shape
	fence_body.add_child(collision)


func _get_texture_used_rect(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2.ONE)

	var image := texture.get_image()
	if image == null:
		return Rect2(Vector2.ZERO, texture.get_size())

	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Rect2(Vector2.ZERO, texture.get_size())

	return Rect2(
		Vector2(used_rect.position.x, used_rect.position.y),
		Vector2(used_rect.size.x, used_rect.size.y)
	)


func _setup_base_campfire() -> void:
	if base_zone_root == null:
		return

	var campfire_scale := 0.62
	var campfire_body := StaticBody2D.new()
	campfire_body.name = "Campfire"
	campfire_body.position = Vector2.ZERO
	campfire_body.z_index = 22
	_get_base_default_content_parent().add_child(campfire_body)

	var campfire := Sprite2D.new()
	campfire.name = "Visual"
	campfire.texture = BASE_CAMPFIRE_TEXTURE
	campfire.scale = Vector2.ONE * campfire_scale
	campfire_body.add_child(campfire)

	var used_rect := _get_texture_used_rect(BASE_CAMPFIRE_TEXTURE)
	var texture_size := BASE_CAMPFIRE_TEXTURE.get_size()
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- texture_size * 0.5
	) * campfire_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * campfire_scale
	collision.shape = shape
	campfire_body.add_child(collision)

	var smoke := GPUParticles2D.new()
	smoke.name = "CampfireSmoke"
	smoke.texture = BASE_SMOKE_TEXTURE
	smoke.amount = 18
	smoke.lifetime = 3.2
	smoke.preprocess = 1.4
	smoke.local_coords = false
	smoke.position = Vector2(0, -170)
	smoke.z_index = 24
	smoke.process_material = _create_base_smoke_material()
	_get_base_default_content_parent().add_child(smoke)
	smoke.emitting = true


func _setup_base_corner_boxes() -> void:
	if base_zone_root == null or BASE_BOX_TEXTURE == null:
		return

	var horizontal_used_rect := _get_texture_used_rect(BASE_HORIZONTAL_FENCE_TEXTURE)
	var vertical_used_rect := _get_texture_used_rect(BASE_VERTICAL_FENCE_TEXTURE)
	var horizontal_largest_side := maxf(horizontal_used_rect.size.x, horizontal_used_rect.size.y)
	var vertical_largest_side := maxf(vertical_used_rect.size.x, vertical_used_rect.size.y)
	if horizontal_largest_side <= 0.0 or vertical_largest_side <= 0.0:
		return

	var horizontal_scale := BASE_FENCE_TARGET_MAX_SIZE / horizontal_largest_side
	var vertical_scale := BASE_FENCE_TARGET_MAX_SIZE / vertical_largest_side
	var horizontal_step := horizontal_used_rect.size.x * horizontal_scale
	var horizontal_height := horizontal_used_rect.size.y * horizontal_scale
	var vertical_step := vertical_used_rect.size.y * vertical_scale
	var vertical_width := vertical_used_rect.size.x * vertical_scale
	var top_row_width := horizontal_step * 8.0
	var vertical_row_height := vertical_step * 5.0
	var bottom_gate_width := horizontal_step * BASE_BOTTOM_GATE_WIDTH_RATIO
	var bottom_row_width := top_row_width + bottom_gate_width
	var top_y := -vertical_row_height * 0.5 - horizontal_height * 0.5
	var bottom_y := vertical_row_height * 0.5 + horizontal_height * 0.5
	var left_x := -bottom_row_width * 0.5 - vertical_width * 0.5
	var right_x := bottom_row_width * 0.5 + vertical_width * 0.5
	var box_positions := [
		Vector2(left_x + BASE_BOX_FENCE_PADDING.x, top_y + BASE_BOX_FENCE_PADDING.y),
		Vector2(right_x - BASE_BOX_FENCE_PADDING.x, top_y + BASE_BOX_FENCE_PADDING.y),
		Vector2(left_x + BASE_BOX_FENCE_PADDING.x, bottom_y - BASE_BOX_FENCE_PADDING.y),
		Vector2(right_x - BASE_BOX_FENCE_PADDING.x, bottom_y - BASE_BOX_FENCE_PADDING.y),
	]

	for index in range(box_positions.size()):
		_add_base_corner_box("CornerBox%d" % (index + 1), box_positions[index])


func _add_base_corner_box(box_name: String, box_position: Vector2) -> void:
	if base_zone_root == null or BASE_BOX_TEXTURE == null:
		return

	var body := StaticBody2D.new()
	body.name = box_name
	body.position = box_position
	body.z_index = 12
	_get_base_default_content_parent().add_child(body)

	var used_rect := _get_texture_used_rect(BASE_BOX_TEXTURE)
	var largest_side := maxf(used_rect.size.x, used_rect.size.y)
	if largest_side <= 0.0:
		return

	var box_scale := BASE_BOX_TARGET_MAX_SIZE / largest_side
	var box := Sprite2D.new()
	box.name = "Visual"
	box.texture = BASE_BOX_TEXTURE
	box.centered = true
	box.scale = Vector2.ONE * box_scale
	body.add_child(box)

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.position = (
		used_rect.position
		+ used_rect.size * 0.5
		- BASE_BOX_TEXTURE.get_size() * 0.5
	) * box_scale
	var shape := RectangleShape2D.new()
	shape.size = used_rect.size * box_scale
	collision.shape = shape
	body.add_child(collision)


func _create_base_smoke_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 26.0
	material.direction = Vector3(0, -1, 0)
	material.spread = 24.0
	material.initial_velocity_min = 18.0
	material.initial_velocity_max = 42.0
	material.gravity = Vector3(0, -8, 0)
	material.scale_min = 0.08
	material.scale_max = 0.18
	material.color = Color(0.85, 0.85, 0.85, 0.42)
	material.hue_variation_min = -0.05
	material.hue_variation_max = 0.05
	return material


func _update_base_travel_ui() -> void:
	var show_base_ui := is_in_base_zone and not player_dead and not _is_menu_visible()
	if is_instance_valid(base_zone_label):
		base_zone_label.visible = show_base_ui
	if is_instance_valid(base_build_button):
		base_build_button.visible = show_base_ui
	if is_instance_valid(base_build_picker_panel):
		base_build_picker_panel.visible = show_base_ui and base_build_picker_open
	if is_instance_valid(base_loot_display_root):
		base_loot_display_root.visible = show_base_ui


func _on_base_build_button_pressed() -> void:
	if not is_in_base_zone or player_dead:
		return

	base_build_picker_open = not base_build_picker_open
	_update_base_travel_ui()


func _on_base_build_option_pressed() -> void:
	if base_building_placed:
		base_build_picker_open = false
		_update_base_travel_ui()
		return

	if not _has_base_building_cost():
		return

	if base_build_preview_active:
		_confirm_base_building()
	else:
		_show_base_build_preview()


func _on_base_building_preview_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not base_build_preview_active:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not mouse_event.is_echo():
			_confirm_base_building()
			get_viewport().set_input_as_handled()


func _show_base_build_preview() -> void:
	if not is_in_base_zone or base_building_placed or not is_instance_valid(base_building_sprite):
		return
	if not _has_base_building_cost():
		return

	base_build_preview_active = true
	if is_instance_valid(base_building_body):
		base_building_body.visible = true
	base_building_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45)
	if is_instance_valid(base_building_body):
		_set_collision_shapes_disabled(base_building_body, true)
	if is_instance_valid(base_building_click_area):
		base_building_click_area.monitoring = true
		base_building_click_area.input_pickable = true


func _confirm_base_building() -> void:
	if base_building_placed or not is_instance_valid(base_building_sprite):
		return
	if not _spend_base_building_cost():
		return

	base_build_preview_active = false
	base_building_placed = true
	base_build_picker_open = false
	if is_instance_valid(base_building_body):
		base_building_body.visible = true
	base_building_sprite.modulate = Color.WHITE
	if is_instance_valid(base_default_content_root):
		base_default_content_root.hide()
		_set_collision_shapes_disabled(base_default_content_root, true)
	if is_instance_valid(base_building_body):
		_set_collision_shapes_disabled(base_building_body, false)
	if is_instance_valid(base_building_click_area):
		base_building_click_area.monitoring = false
		base_building_click_area.input_pickable = false
	_update_base_travel_ui()


func _has_base_building_cost() -> bool:
	return (
		int(stored_base_loot_counts.get(&"wood", 0)) >= BASE_BUILD_WOOD_COST
		and int(stored_base_loot_counts.get(&"iron", 0)) >= BASE_BUILD_IRON_COST
	)


func _spend_base_building_cost() -> bool:
	if not _has_base_building_cost():
		return false

	stored_base_loot_counts[&"wood"] = int(stored_base_loot_counts.get(&"wood", 0)) - BASE_BUILD_WOOD_COST
	stored_base_loot_counts[&"iron"] = int(stored_base_loot_counts.get(&"iron", 0)) - BASE_BUILD_IRON_COST
	save_base_loot()
	_update_base_loot_display()
	return true


func _cancel_base_build_preview() -> void:
	base_build_picker_open = false
	base_build_preview_active = false
	if is_instance_valid(base_building_body) and not base_building_placed:
		base_building_body.hide()
	if is_instance_valid(base_building_body) and not base_building_placed:
		_set_collision_shapes_disabled(base_building_body, true)
	if is_instance_valid(base_building_click_area) and not base_building_placed:
		base_building_click_area.monitoring = false
		base_building_click_area.input_pickable = false


func _set_collision_shapes_disabled(root: Node, disabled: bool) -> void:
	if root == null:
		return

	for child in root.get_children():
		var collision_shape := child as CollisionShape2D
		if collision_shape != null:
			collision_shape.disabled = disabled
		_set_collision_shapes_disabled(child, disabled)


func _move_player_to(target_position: Vector2) -> void:
	player.global_position = target_position
	var player_body := player as CharacterBody2D
	if player_body != null:
		player_body.velocity = Vector2.ZERO


func _set_camera_limits_to_rect(rect: Rect2) -> void:
	if not is_instance_valid(player_camera):
		return

	player_camera.limit_left = floori(rect.position.x)
	player_camera.limit_top = floori(rect.position.y)
	player_camera.limit_right = ceili(rect.end.x)
	player_camera.limit_bottom = ceili(rect.end.y)
	player_camera.reset_smoothing()


func _restore_battle_camera_limits() -> void:
	if not is_instance_valid(player_camera):
		return

	player_camera.limit_left = battle_camera_limit_left
	player_camera.limit_top = battle_camera_limit_top
	player_camera.limit_right = battle_camera_limit_right
	player_camera.limit_bottom = battle_camera_limit_bottom
	player_camera.reset_smoothing()


func _set_zombies_paused_for_base(paused: bool) -> void:
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie_node):
			continue

		zombie_node.set_process(not paused and not _is_time_freeze_active())
		zombie_node.set_physics_process(not paused and not _is_time_freeze_active())


func activate_time_freeze(duration: float = 10.0) -> void:
	if player_dead or is_in_base_zone or duration <= 0.0:
		return

	time_freeze_timer = maxf(time_freeze_timer, duration)
	_pause_time_freeze_music()
	_freeze_current_zombies()
	_freeze_current_time_freezable_objects()


func _update_time_freeze(delta: float) -> void:
	if not _is_time_freeze_active():
		return

	if player_dead or is_in_base_zone:
		_end_time_freeze()
		return

	_freeze_current_time_freezable_objects()
	time_freeze_timer = maxf(time_freeze_timer - delta, 0.0)
	if time_freeze_timer == 0.0:
		_end_time_freeze()


func _is_time_freeze_active() -> bool:
	return time_freeze_timer > 0.0


func _freeze_current_zombies() -> void:
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie_node):
			continue

		var zombie_id := zombie_node.get_instance_id()
		if not time_frozen_zombie_states.has(zombie_id):
			time_frozen_zombie_states[zombie_id] = _capture_time_freeze_state(zombie_node)

		zombie_node.set_process(false)
		zombie_node.set_physics_process(false)
		_pause_time_freeze_visuals(zombie_node)


func _freeze_current_time_freezable_objects() -> void:
	for object_node in get_tree().get_nodes_in_group("time_freezable_objects"):
		if not is_instance_valid(object_node) or object_node.is_in_group("player"):
			continue

		var object_id := object_node.get_instance_id()
		if not time_frozen_object_states.has(object_id):
			time_frozen_object_states[object_id] = _capture_time_freeze_state(object_node)

		object_node.set_process(false)
		object_node.set_physics_process(false)
		_pause_time_freeze_visuals(object_node)


func _capture_time_freeze_state(zombie_node: Node) -> Dictionary:
	var animated_sprites: Array[Dictionary] = []
	for child in zombie_node.find_children("*", "AnimatedSprite2D", true, false):
		var animated_sprite := child as AnimatedSprite2D
		if animated_sprite == null:
			continue

		animated_sprites.append({
			"node": animated_sprite,
			"was_playing": animated_sprite.is_playing(),
		})

	var particles: Array[Dictionary] = []
	for child in zombie_node.find_children("*", "GPUParticles2D", true, false):
		var particle_node := child as GPUParticles2D
		if particle_node == null:
			continue

		particles.append({
			"node": particle_node,
			"was_emitting": particle_node.emitting,
		})

	var audio_players: Array[Dictionary] = []
	for audio_2d_child in zombie_node.find_children("*", "AudioStreamPlayer2D", true, false):
		var audio_player_2d := audio_2d_child as AudioStreamPlayer2D
		if audio_player_2d == null:
			continue

		audio_players.append({
			"node": audio_player_2d,
			"was_playing": audio_player_2d.playing,
		})

	for audio_child in zombie_node.find_children("*", "AudioStreamPlayer", true, false):
		var audio_player := audio_child as AudioStreamPlayer
		if audio_player == null:
			continue

		audio_players.append({
			"node": audio_player,
			"was_playing": audio_player.playing,
		})

	return {
		"node": zombie_node,
		"was_processing": zombie_node.is_processing(),
		"was_physics_processing": zombie_node.is_physics_processing(),
		"animated_sprites": animated_sprites,
		"particles": particles,
		"audio_players": audio_players,
	}


func _pause_time_freeze_visuals(zombie_node: Node) -> void:
	for child in zombie_node.find_children("*", "AnimatedSprite2D", true, false):
		var animated_sprite := child as AnimatedSprite2D
		if animated_sprite != null:
			animated_sprite.stop()

	for child in zombie_node.find_children("*", "GPUParticles2D", true, false):
		var particle_node := child as GPUParticles2D
		if particle_node != null:
			particle_node.emitting = false

	for audio_2d_child in zombie_node.find_children("*", "AudioStreamPlayer2D", true, false):
		var audio_player_2d := audio_2d_child as AudioStreamPlayer2D
		if audio_player_2d != null and audio_player_2d.playing:
			audio_player_2d.stream_paused = true

	for audio_child in zombie_node.find_children("*", "AudioStreamPlayer", true, false):
		var audio_player := audio_child as AudioStreamPlayer
		if audio_player != null and audio_player.playing:
			audio_player.stream_paused = true


func _end_time_freeze() -> void:
	time_freeze_timer = 0.0
	_resume_time_frozen_zombies()
	_resume_time_freeze_music()


func _resume_time_frozen_zombies() -> void:
	for state_variant in time_frozen_zombie_states.values():
		var state := state_variant as Dictionary
		var zombie_node_variant = state.get("node", null)
		if not is_instance_valid(zombie_node_variant):
			continue
		var zombie_node := zombie_node_variant as Node

		if not is_in_base_zone:
			zombie_node.set_process(true)
			zombie_node.set_physics_process(true)

		if zombie_node.is_in_group("zombies"):
			for sprite_state_variant in state.get("animated_sprites", []):
				var sprite_state := sprite_state_variant as Dictionary
				var animated_sprite_variant = sprite_state.get("node", null)
				if not is_instance_valid(animated_sprite_variant):
					continue
				var animated_sprite := animated_sprite_variant as AnimatedSprite2D
				if animated_sprite != null and bool(sprite_state.get("was_playing", false)):
					animated_sprite.play()

			for particle_state_variant in state.get("particles", []):
				var particle_state := particle_state_variant as Dictionary
				var particle_node_variant = particle_state.get("node", null)
				if not is_instance_valid(particle_node_variant):
					continue
				var particle_node := particle_node_variant as GPUParticles2D
				if particle_node != null:
					particle_node.emitting = bool(particle_state.get("was_emitting", false))

			for audio_state_variant in state.get("audio_players", []):
				var audio_state := audio_state_variant as Dictionary
				var audio_player_variant = audio_state.get("node", null)
				if not is_instance_valid(audio_player_variant):
					continue
				var audio_player := audio_player_variant as Node
				if audio_player != null and bool(audio_state.get("was_playing", false)):
					audio_player.set("stream_paused", false)

	time_frozen_zombie_states.clear()
	_resume_time_frozen_objects()


func _resume_time_frozen_objects() -> void:
	for state_variant in time_frozen_object_states.values():
		var state := state_variant as Dictionary
		var object_node_variant = state.get("node", null)
		if not is_instance_valid(object_node_variant):
			continue
		var object_node := object_node_variant as Node

		object_node.set_process(bool(state.get("was_processing", true)))
		object_node.set_physics_process(bool(state.get("was_physics_processing", true)))

		for sprite_state_variant in state.get("animated_sprites", []):
			var sprite_state := sprite_state_variant as Dictionary
			var animated_sprite_variant = sprite_state.get("node", null)
			if not is_instance_valid(animated_sprite_variant):
				continue
			var animated_sprite := animated_sprite_variant as AnimatedSprite2D
			if animated_sprite != null and bool(sprite_state.get("was_playing", false)):
				animated_sprite.play()

		for particle_state_variant in state.get("particles", []):
			var particle_state := particle_state_variant as Dictionary
			var particle_node_variant = particle_state.get("node", null)
			if not is_instance_valid(particle_node_variant):
				continue
			var particle_node := particle_node_variant as GPUParticles2D
			if particle_node != null:
				particle_node.emitting = bool(particle_state.get("was_emitting", false))

		for audio_state_variant in state.get("audio_players", []):
			var audio_state := audio_state_variant as Dictionary
			var audio_player_variant = audio_state.get("node", null)
			if not is_instance_valid(audio_player_variant):
				continue
			var audio_player := audio_player_variant as Node
			if audio_player != null and bool(audio_state.get("was_playing", false)):
				audio_player.set("stream_paused", false)

	time_frozen_object_states.clear()


func _pause_time_freeze_music() -> void:
	for music_player in _get_time_freeze_music_players():
		if not is_instance_valid(music_player) or not music_player.playing:
			continue

		var already_tracked := false
		for state in time_frozen_music_states:
			var tracked_player = state.get("node", null)
			if is_instance_valid(tracked_player) and tracked_player == music_player:
				already_tracked = true
				break

		if not already_tracked:
			time_frozen_music_states.append({
				"node": music_player,
				"was_playing": true,
			})

		music_player.stream_paused = true


func _resume_time_freeze_music() -> void:
	for state in time_frozen_music_states:
		var music_player_variant = state.get("node", null)
		if not is_instance_valid(music_player_variant):
			continue

		var music_player := music_player_variant as AudioStreamPlayer
		if music_player != null and bool(state.get("was_playing", false)):
			music_player.stream_paused = false

	time_frozen_music_states.clear()
	restore_music_after_priority_audio()


func _get_time_freeze_music_players() -> Array[AudioStreamPlayer]:
	var music_players: Array[AudioStreamPlayer] = []
	for node_name in [&"GameMusic", &"MenuMusic"]:
		var player_node := get_node_or_null(NodePath(node_name)) as AudioStreamPlayer
		if player_node != null:
			music_players.append(player_node)

	if is_instance_valid(fog_music):
		music_players.append(fog_music)
	if is_instance_valid(base_music):
		music_players.append(base_music)

	return music_players


func _spawn_next_zombie() -> void:
	var zombie_scene := _get_next_zombie_scene()
	if zombie_scene == null:
		return

	var zombie := zombie_scene.instantiate()
	zombie.global_position = _get_spawn_position_for_scene(zombie_scene)
	_apply_hard_mode_to_zombie(zombie)
	_register_zombie(zombie)
	add_child(zombie)
	zombies_left_to_spawn -= 1


func _get_next_zombie_scene() -> PackedScene:
	if (
		fast_zombies_left_to_spawn <= 0
		and strong_zombies_left_to_spawn <= 0
		and miner_zombies_left_to_spawn <= 0
		and normal_zombies_left_to_spawn <= 0
	):
		return null

	if strong_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		return _get_next_normal_zombie_scene()

	if strong_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0 and normal_zombies_left_to_spawn <= 0:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0 and fast_zombies_left_to_spawn <= 0:
		if strong_zombies_left_to_spawn > 0 and randf() < float(strong_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		if fast_zombies_left_to_spawn > 0 and randf() < float(fast_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			fast_zombies_left_to_spawn -= 1
			return FAST_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		if normal_zombies_left_to_spawn > 0 and randf() < float(normal_zombies_left_to_spawn) / float(zombies_left_to_spawn):
			return _get_next_normal_zombie_scene()
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if normal_zombies_left_to_spawn <= 0:
		var strong_or_miner_total := strong_zombies_left_to_spawn + miner_zombies_left_to_spawn
		if strong_or_miner_total > 0 and randf() < float(strong_zombies_left_to_spawn) / float(strong_or_miner_total):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		if miner_zombies_left_to_spawn > 0:
			miner_zombies_left_to_spawn -= 1
			return MINER_ZOMBIE_SCENE
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0 and strong_zombies_left_to_spawn <= 0:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if fast_zombies_left_to_spawn <= 0:
		var strong_or_miner_total := strong_zombies_left_to_spawn + miner_zombies_left_to_spawn
		if strong_or_miner_total > 0 and randf() < float(strong_zombies_left_to_spawn) / float(strong_or_miner_total):
			strong_zombies_left_to_spawn -= 1
			return STRONG_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0 and miner_zombies_left_to_spawn <= 0:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if strong_zombies_left_to_spawn <= 0:
		if randf() < float(fast_zombies_left_to_spawn) / float(fast_zombies_left_to_spawn + miner_zombies_left_to_spawn):
			fast_zombies_left_to_spawn -= 1
			return FAST_ZOMBIE_SCENE
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	var random_pick := randf()
	var strong_ratio := float(strong_zombies_left_to_spawn) / float(zombies_left_to_spawn)
	var fast_ratio := float(fast_zombies_left_to_spawn) / float(zombies_left_to_spawn)
	var miner_ratio := float(miner_zombies_left_to_spawn) / float(zombies_left_to_spawn)

	if random_pick < strong_ratio:
		strong_zombies_left_to_spawn -= 1
		return STRONG_ZOMBIE_SCENE

	if random_pick < strong_ratio + fast_ratio:
		fast_zombies_left_to_spawn -= 1
		return FAST_ZOMBIE_SCENE

	if random_pick < strong_ratio + fast_ratio + miner_ratio:
		miner_zombies_left_to_spawn -= 1
		return MINER_ZOMBIE_SCENE

	return _get_next_normal_zombie_scene()


func _get_next_normal_zombie_scene() -> PackedScene:
	var normal_like_zombies_left := normal_zombies_left_to_spawn
	normal_zombies_left_to_spawn -= 1
	if (
		normal_like_zombies_left > 0
		and atomic_zombies_left_to_spawn > 0
		and randf() < float(atomic_zombies_left_to_spawn) / float(normal_like_zombies_left)
	):
		atomic_zombies_left_to_spawn -= 1
		return ATOMIC_ZOMBIE_SCENE
	return ZOMBIE_SCENE


func _get_fast_zombies_for_wave(wave: int, total_zombies: int) -> int:
	var start_wave := HARD_MODE_FAST_ZOMBIE_START_WAVE if hard_mode_enabled else fast_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_fast_intro := wave - start_wave
	var added_per_wave := HARD_MODE_FAST_ZOMBIES_ADDED_PER_WAVE if hard_mode_enabled else fast_zombies_added_per_wave
	var fast_zombie_count := max_fast_zombies_on_start_wave + (waves_since_fast_intro * added_per_wave)
	var max_fast_by_total := maxi(total_zombies if hard_mode_enabled else total_zombies - 1, 0)
	return mini(fast_zombie_count, max_fast_by_total)


func _get_strong_zombies_for_wave(wave: int, total_zombies: int) -> int:
	var start_wave := HARD_MODE_STRONG_ZOMBIE_START_WAVE if hard_mode_enabled else strong_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_strong_intro := wave - start_wave
	var strong_zombie_count := max_strong_zombies_on_start_wave + (waves_since_strong_intro * strong_zombies_added_per_wave)
	var max_strong_by_total := maxi(total_zombies - 2, 0)
	return mini(strong_zombie_count, max_strong_by_total)


func _get_atomic_zombies_for_wave(wave: int, normal_like_zombies: int) -> int:
	if wave < atomic_zombie_start_wave:
		return 0

	var waves_since_atomic_intro := wave - atomic_zombie_start_wave
	var atomic_zombie_count := max_atomic_zombies_on_start_wave + (waves_since_atomic_intro * atomic_zombies_added_per_wave)
	return mini(atomic_zombie_count, normal_like_zombies)


func _get_miner_zombies_for_wave(wave: int) -> int:
	var start_wave := HARD_MODE_MINER_ZOMBIE_START_WAVE if hard_mode_enabled else miner_zombie_start_wave
	if wave < start_wave:
		return 0

	var waves_since_miner_intro := wave - start_wave
	return max_miner_zombies_on_start_wave + (waves_since_miner_intro * miner_zombies_added_per_wave)


func _get_total_zombies_for_wave(wave: int) -> int:
	var total_zombies := base_zombies_per_wave + (wave - 1) * zombies_added_per_wave
	if not _is_late_wave_softened(wave):
		return total_zombies

	var softened_total := total_zombies - _get_late_wave_zombie_reduction(wave)
	return maxi(softened_total, minimum_normal_zombies_after_wave_ten + 2)


func _get_spawn_interval_for_wave() -> float:
	var spawn_interval := maxf(
		base_spawn_interval - (current_wave - 1) * spawn_interval_reduction_per_wave,
		min_spawn_interval
	)
	if _is_late_wave_softened(current_wave):
		spawn_interval += _get_late_wave_spawn_interval_bonus(current_wave)
	if _should_spawn_michael_jackson(current_wave):
		spawn_interval += michael_jackson_spawn_interval_bonus
	return spawn_interval


func _get_spawn_position_for_scene(zombie_scene: PackedScene) -> Vector2:
	if zombie_scene == FAST_ZOMBIE_SCENE:
		return _get_random_spawn_position_inside_area()
	return _get_edge_spawn_position()


func _should_spawn_michael_jackson(wave: int) -> bool:
	if wave < michael_jackson_start_wave:
		return false
	if michael_jackson_wave_interval <= 0:
		return false
	return wave % michael_jackson_wave_interval == 0


func _spawn_michael_jackson_zombie() -> void:
	var zombie := MICHAEL_JACKSON_ZOMBIE_SCENE.instantiate()
	var base_health := int(zombie.get("max_health"))
	zombie.set("max_health", _get_michael_jackson_health_for_wave(current_wave, base_health))
	zombie.global_position = _get_spawn_position_for_scene(MICHAEL_JACKSON_ZOMBIE_SCENE)
	_apply_hard_mode_to_zombie(zombie)
	_register_zombie(zombie)
	if zombie.has_signal("died"):
		zombie.died.connect(_on_michael_jackson_died)
	add_child(zombie)


func _apply_hard_mode_to_zombie(zombie: Node) -> void:
	if not hard_mode_enabled or zombie == null:
		return
	if not _node_has_property(zombie, "move_speed"):
		return

	var base_speed := float(zombie.get("move_speed"))
	zombie.set("move_speed", base_speed * HARD_MODE_ZOMBIE_SPEED_MULTIPLIER)


func _node_has_property(node: Object, property_name: String) -> bool:
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _get_michael_jackson_health_for_wave(wave: int, base_health: int) -> int:
	if michael_jackson_wave_interval <= 0 or wave <= michael_jackson_start_wave:
		return base_health

	var previous_appearances := int((wave - michael_jackson_start_wave) / michael_jackson_wave_interval)
	return base_health + previous_appearances * MICHAEL_JACKSON_HEALTH_ADDED_PER_RETURN


func _register_zombie(zombie: Node) -> void:
	if zombie == null or not zombie.has_signal("died"):
		return

	zombie.died.connect(_on_spawned_zombie_died.bind(zombie))
	_register_zombie_discovery(zombie)


func _on_spawned_zombie_died(zombie: Node) -> void:
	if (
		player_dead
		or not is_instance_valid(zombie)
		or not (zombie is Node2D)
	):
		return

	var drop_position := (zombie as Node2D).global_position
	_register_zombie_kill(zombie)

	_spawn_single_power_up_drop(drop_position)


func _spawn_single_power_up_drop(drop_position: Vector2) -> void:
	var drop_options: Array[Dictionary] = []
	_append_drop_option(drop_options, MEDKIT_POWER_UP_SCENE, medkit_drop_start_wave, medkit_drop_chance)
	_append_drop_option(drop_options, GRENADE_POWER_UP_SCENE, grenade_drop_start_wave, grenade_drop_chance)
	_append_drop_option(drop_options, HOMING_BULLETS_POWER_UP_SCENE, homing_bullets_drop_start_wave, homing_bullets_drop_chance)
	_append_drop_option(drop_options, MINE_POWER_UP_SCENE, mine_drop_start_wave, mine_drop_chance)
	_append_drop_option(drop_options, TELEPORT_ORB_POWER_UP_SCENE, teleport_orb_drop_start_wave, teleport_orb_drop_chance)
	_append_drop_option(drop_options, ANTI_COOLDOWN_POWER_UP_SCENE, anti_cooldown_drop_start_wave, anti_cooldown_drop_chance)
	_append_drop_option(drop_options, TRIPLE_BULLET_POWER_UP_SCENE, triple_bullet_drop_start_wave, triple_bullet_drop_chance)
	_append_drop_option(drop_options, TIME_FREEZE_POWER_UP_SCENE, time_freeze_drop_start_wave, time_freeze_drop_chance)

	if drop_options.is_empty():
		return

	var total_weight := 0.0
	for option in drop_options:
		total_weight += float(option.get("weight", 0.0))

	if total_weight <= 0.0 or randf() >= minf(total_weight, 1.0):
		return

	var roll := randf() * total_weight
	for option in drop_options:
		roll -= float(option.get("weight", 0.0))
		if roll > 0.0:
			continue

		var power_up_scene := option.get("scene", null) as PackedScene
		if power_up_scene != null:
			var power_up := power_up_scene.instantiate()
			power_up.global_position = drop_position
			add_child(power_up)
		return


func _append_drop_option(drop_options: Array[Dictionary], scene: PackedScene, start_wave: int, chance: float) -> void:
	var effective_chance := chance * _get_power_up_drop_chance_multiplier()
	if scene == null or current_wave < start_wave or effective_chance <= 0.0:
		return

	drop_options.append({
		"scene": scene,
		"weight": effective_chance,
	})


func _get_power_up_drop_chance_multiplier() -> float:
	return HARD_MODE_POWER_UP_DROP_MULTIPLIER if hard_mode_enabled else 1.0


func _ensure_minimum_normal_zombies() -> void:
	if current_wave <= 10:
		return
	if normal_zombies_left_to_spawn >= minimum_normal_zombies_after_wave_ten:
		return

	var missing_normals := minimum_normal_zombies_after_wave_ten - normal_zombies_left_to_spawn
	normal_zombies_left_to_spawn += missing_normals
	zombies_left_to_spawn += missing_normals


func _register_zombie_kill(zombie: Node) -> void:
	var zombie_type := _get_zombie_type(zombie)
	if zombie_type == &"":
		return

	zombie_kill_counts[zombie_type] = int(zombie_kill_counts.get(zombie_type, 0)) + 1
	_register_zombie_type_as_discovered(zombie_type)
	_register_close_zombie_kill(zombie)

	_sync_achievement_progress()
	_save_achievements()


func _register_zombie_discovery(zombie: Node) -> void:
	var zombie_type := _get_zombie_type(zombie)
	if zombie_type != &"":
		_register_zombie_type_as_discovered(zombie_type)


func _register_zombie_type_as_discovered(zombie_type: StringName) -> void:
	if bool(discovered_zombie_types.get(zombie_type, false)):
		return

	discovered_zombie_types[zombie_type] = true
	if _has_discovered_all_zombie_types():
		unlock_achievement(ACHIEVEMENT_DISCOVER_ALL_ZOMBIES)
	_save_achievements()


func _sync_achievement_progress() -> void:
	if int(zombie_kill_counts.get(ZOMBIE_TYPE_NORMAL, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock_achievement(ACHIEVEMENT_KILL_100_NORMAL_ZOMBIES)
	if int(zombie_kill_counts.get(ZOMBIE_TYPE_FAST, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock_achievement(ACHIEVEMENT_KILL_100_FAST_ZOMBIES)
	if int(zombie_kill_counts.get(ZOMBIE_TYPE_STRONG, 0)) >= ZOMBIE_KILL_MILESTONE:
		unlock_achievement(ACHIEVEMENT_KILL_100_STRONG_ZOMBIES)
	if _has_discovered_all_zombie_types():
		unlock_achievement(ACHIEVEMENT_DISCOVER_ALL_ZOMBIES)


func _get_zombie_type(zombie: Node) -> StringName:
	if zombie == null:
		return &""
	if zombie.has_method("get_zombie_type"):
		return StringName(zombie.call("get_zombie_type"))
	if zombie.has_method("is_strong_zombie") and bool(zombie.call("is_strong_zombie")):
		return ZOMBIE_TYPE_STRONG
	return &""


func _register_close_zombie_kill(zombie: Node) -> void:
	if bool(unlocked_achievements.get(ACHIEVEMENT_CLOSE_ZOMBIE_KILL, false)):
		return
	if not is_instance_valid(player) or not (zombie is Node2D):
		return

	var zombie_position := (zombie as Node2D).global_position
	if player.global_position.distance_to(zombie_position) <= CLOSE_ZOMBIE_KILL_DISTANCE:
		unlock_achievement(ACHIEVEMENT_CLOSE_ZOMBIE_KILL)


func _get_active_placed_mine_count() -> int:
	var active_mines := 0
	for mine in get_tree().get_nodes_in_group("placed_mines"):
		if not is_instance_valid(mine):
			continue
		if mine.has_method("is_active_for_achievement"):
			if bool(mine.call("is_active_for_achievement")):
				active_mines += 1
			continue
		if bool(mine.get("is_armed")) and not bool(mine.get("has_detonated")):
			active_mines += 1

	return active_mines


func _has_discovered_all_zombie_types() -> bool:
	for zombie_type in ZOMBIE_TYPES_FOR_ZOMBIOLOGO:
		if not bool(discovered_zombie_types.get(zombie_type, false)):
			return false
	return true


func _is_late_wave_softened(wave: int) -> bool:
	return wave >= LATE_WAVE_SOFTEN_START


func _get_late_wave_zombie_reduction(wave: int) -> int:
	if not _is_late_wave_softened(wave):
		return 0

	var waves_since_softening := wave - LATE_WAVE_SOFTEN_START
	return LATE_WAVE_ZOMBIES_REMOVED_ON_START + int(
		floor(float(waves_since_softening) / float(LATE_WAVE_ZOMBIE_REDUCTION_STEP))
	)


func _get_late_wave_spawn_interval_bonus(wave: int) -> float:
	if not _is_late_wave_softened(wave):
		return 0.0

	var waves_since_softening := wave - LATE_WAVE_SOFTEN_START
	return minf(
		LATE_WAVE_EXTRA_SPAWN_INTERVAL + (float(waves_since_softening) * LATE_WAVE_EXTRA_SPAWN_INTERVAL_PER_WAVE),
		LATE_WAVE_MAX_EXTRA_SPAWN_INTERVAL
	)


func _apply_late_wave_special_cap(wave: int, count: int, total_zombies: int, ratio_cap: float) -> int:
	if not _is_late_wave_softened(wave):
		return count

	var capped_count := int(floor(float(total_zombies) * ratio_cap))
	return mini(count, maxi(capped_count, 0))


func _get_edge_spawn_position() -> Vector2:
	var player_position := player.global_position if is_instance_valid(player) else Vector2.ZERO

	for _attempt in range(32):
		var candidate := _get_random_edge_position()
		if _is_valid_zombie_spawn_position(candidate, player_position):
			return candidate

	for _attempt in range(32):
		var candidate := _get_random_edge_position()
		if not _is_near_battle_loot_container(candidate):
			return candidate

	return _get_fallback_spawn_position_away_from_container()


func _get_random_spawn_position_inside_area() -> Vector2:
	var player_position := player.global_position if is_instance_valid(player) else Vector2.ZERO
	var left := spawn_area.position.x + edge_margin
	var right := spawn_area.end.x - edge_margin
	var top := spawn_area.position.y + edge_margin
	var bottom := spawn_area.end.y - edge_margin

	for _attempt in range(32):
		var candidate := Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		if _is_valid_zombie_spawn_position(candidate, player_position):
			return candidate

	for _attempt in range(32):
		var candidate := Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		if not _is_near_battle_loot_container(candidate):
			return candidate

	return _get_fallback_spawn_position_away_from_container()


func _is_valid_zombie_spawn_position(candidate: Vector2, player_position: Vector2) -> bool:
	return (
		candidate.distance_to(player_position) >= min_spawn_distance_from_player
		and not _is_near_battle_loot_container(candidate)
	)


func _is_near_battle_loot_container(candidate: Vector2) -> bool:
	var exclusion_rect := Rect2(
		BATTLE_LOOT_CONTAINER_POSITION - BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE * 0.5,
		BATTLE_LOOT_CONTAINER_SPAWN_EXCLUSION_SIZE
	)
	return exclusion_rect.has_point(candidate)


func _get_fallback_spawn_position_away_from_container() -> Vector2:
	return spawn_area.position + Vector2.ONE * edge_margin


func _get_random_edge_position() -> Vector2:
	var left := spawn_area.position.x + edge_margin
	var right := spawn_area.end.x - edge_margin
	var top := spawn_area.position.y + edge_margin
	var bottom := spawn_area.end.y - edge_margin
	var edge := randi_range(0, 3)

	match edge:
		0:
			return Vector2(randf_range(left, right), top)
		1:
			return Vector2(randf_range(left, right), bottom)
		2:
			return Vector2(left, randf_range(top, bottom))
		_:
			return Vector2(right, randf_range(top, bottom))


func get_safe_teleport_position(from_position: Vector2) -> Vector2:
	if is_in_base_zone:
		return _get_safe_base_teleport_position(from_position)

	var zombie_positions := _get_alive_zombie_positions()
	var candidate_positions := _get_teleport_candidate_positions(from_position, zombie_positions)
	var best_position := from_position
	var best_score := -INF

	for candidate in candidate_positions:
		if not _is_valid_teleport_position(candidate):
			continue

		var nearest_zombie_distance := _get_nearest_zombie_distance(candidate, zombie_positions)
		var travel_distance := candidate.distance_to(from_position)
		if travel_distance < teleport_minimum_travel_distance:
			nearest_zombie_distance -= (teleport_minimum_travel_distance - travel_distance) * 0.6

		var candidate_score := nearest_zombie_distance + travel_distance * 0.35
		if nearest_zombie_distance >= teleport_minimum_distance_from_zombies:
			candidate_score += 1000.0

		if candidate_score > best_score:
			best_score = candidate_score
			best_position = candidate

	return best_position


func _get_safe_base_teleport_position(from_position: Vector2) -> Vector2:
	var base_rect := Rect2(
		BASE_ZONE_ORIGIN - BASE_ZONE_SIZE * 0.5 + Vector2.ONE * BASE_ZONE_WALL_THICKNESS,
		BASE_ZONE_SIZE - Vector2.ONE * BASE_ZONE_WALL_THICKNESS * 2.0
	)
	var best_position := from_position
	var best_distance := 0.0

	for _attempt in range(teleport_search_attempts):
		var candidate := _get_random_point_in_rect(base_rect)
		if not _is_valid_teleport_position(candidate):
			continue

		var travel_distance := candidate.distance_to(from_position)
		if travel_distance > best_distance:
			best_distance = travel_distance
			best_position = candidate

	return best_position


func _get_alive_zombie_positions() -> Array[Vector2]:
	var zombie_positions: Array[Vector2] = []
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if zombie_node is Node2D:
			zombie_positions.append((zombie_node as Node2D).global_position)
	return zombie_positions


func _get_teleport_candidate_positions(
	from_position: Vector2,
	zombie_positions: Array[Vector2]
) -> Array[Vector2]:
	var teleport_rect := _get_teleport_rect()
	var candidate_positions: Array[Vector2] = []
	var rect_center := teleport_rect.get_center()
	var nearest_zombie_position := _get_nearest_zombie_position(from_position, zombie_positions)

	candidate_positions.append(rect_center)
	candidate_positions.append(Vector2(teleport_rect.position.x, teleport_rect.position.y))
	candidate_positions.append(Vector2(teleport_rect.end.x, teleport_rect.position.y))
	candidate_positions.append(Vector2(teleport_rect.position.x, teleport_rect.end.y))
	candidate_positions.append(Vector2(teleport_rect.end.x, teleport_rect.end.y))

	if nearest_zombie_position != Vector2.INF:
		var away_direction := nearest_zombie_position.direction_to(from_position)
		if away_direction == Vector2.ZERO:
			away_direction = Vector2.RIGHT.rotated(randf() * TAU)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction * teleport_minimum_travel_distance,
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction * (teleport_minimum_travel_distance * 1.8),
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction.rotated(0.7) * (teleport_minimum_travel_distance * 1.4),
				teleport_rect
			)
		)
		candidate_positions.append(
			_clamp_to_teleport_rect(
				from_position + away_direction.rotated(-0.7) * (teleport_minimum_travel_distance * 1.4),
				teleport_rect
			)
		)

	for _attempt in range(teleport_search_attempts):
		candidate_positions.append(_get_random_point_in_rect(teleport_rect))

	return candidate_positions


func _get_nearest_zombie_position(from_position: Vector2, zombie_positions: Array[Vector2]) -> Vector2:
	var nearest_position := Vector2.INF
	var nearest_distance := INF

	for zombie_position in zombie_positions:
		var distance := from_position.distance_to(zombie_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_position = zombie_position

	return nearest_position


func _get_nearest_zombie_distance(from_position: Vector2, zombie_positions: Array[Vector2]) -> float:
	if zombie_positions.is_empty():
		return teleport_minimum_distance_from_zombies + from_position.distance_to(player.global_position)

	var nearest_distance := INF
	for zombie_position in zombie_positions:
		nearest_distance = minf(nearest_distance, from_position.distance_to(zombie_position))
	return nearest_distance


func _get_teleport_rect() -> Rect2:
	var rect_position := spawn_area.position + Vector2.ONE * teleport_wall_padding
	var rect_size := spawn_area.size - Vector2.ONE * teleport_wall_padding * 2.0
	return Rect2(rect_position, rect_size)


func _get_random_point_in_rect(rect: Rect2) -> Vector2:
	return Vector2(
		randf_range(rect.position.x, rect.end.x),
		randf_range(rect.position.y, rect.end.y)
	)


func _clamp_to_teleport_rect(point: Vector2, rect: Rect2) -> Vector2:
	return Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)


func _is_valid_teleport_position(position: Vector2) -> bool:
	if not is_instance_valid(player):
		return true

	var player_body := player as PhysicsBody2D
	if player_body == null:
		return true

	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return true

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(0.0, position + collision_shape.position)
	query.collision_mask = player_body.collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [player_body.get_rid()]

	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _get_alive_zombie_count() -> int:
	return get_tree().get_nodes_in_group("zombies").size()


func _update_wave_label() -> void:
	if not is_instance_valid(wave_display_root):
		return

	wave_display_root.show()
	var wave_number := current_wave if wave_active else current_wave + 1
	_render_number_as_sprites("wave", wave_number_root, wave_number, 44.0, 5.0)


func _on_player_died() -> void:
	player_dead = true
	_clear_expedition_loot()
	_cancel_base_build_preview()
	is_in_base_zone = false
	_restore_battle_camera_limits()
	_set_zombies_paused_for_base(false)
	if is_instance_valid(base_zone_root):
		base_zone_root.hide()
	wave_active = false
	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	_update_base_travel_ui()
	if is_instance_valid(wave_label):
		wave_label.hide()
	if is_instance_valid(wave_display_root):
		wave_display_root.hide()
	if is_instance_valid(stamina_bar_panel):
		stamina_bar_panel.hide()
	if is_instance_valid(menu) and menu.has_method("show_game_over"):
		menu.show_game_over()


func _on_player_grenade_count_changed(grenade_count: int) -> void:
	_update_grenade_icon(grenade_count)


func _on_player_medkit_count_changed(medkit_count: int) -> void:
	_update_medkit_icon(medkit_count)


func _on_player_mine_count_changed(mine_count: int) -> void:
	_update_mine_icon(mine_count)


func _on_player_teleport_orb_count_changed(teleport_orb_count: int) -> void:
	_update_teleport_orb_icon(teleport_orb_count)


func _on_player_stamina_changed(stamina: float, max_stamina: float) -> void:
	_update_stamina_bar(stamina, max_stamina)


func _on_player_selected_power_up_changed(power_up_id: StringName) -> void:
	selected_power_up_id = power_up_id
	_update_selected_power_up_ui()


func _setup_power_up_selection_ui() -> void:
	var icon_by_power_up := _get_power_up_icons()
	for power_up_id in icon_by_power_up:
		var icon := icon_by_power_up[power_up_id] as TextureRect
		if not is_instance_valid(icon):
			continue
		power_up_icon_base_scales[power_up_id] = icon.scale
		icon.pivot_offset = icon.size * 0.5


func _update_selected_power_up_ui() -> void:
	var icon_by_power_up := _get_power_up_icons()
	for power_up_id in icon_by_power_up:
		var icon := icon_by_power_up[power_up_id] as TextureRect
		if not is_instance_valid(icon):
			continue
		if icon.pivot_offset == Vector2.ZERO:
			icon.pivot_offset = icon.size * 0.5
		var base_scale: Vector2 = power_up_icon_base_scales.get(power_up_id, Vector2.ONE)
		icon.scale = base_scale * (SELECTED_POWER_UP_ICON_SCALE if power_up_id == selected_power_up_id and icon.visible else 1.0)


func _get_power_up_icons() -> Dictionary:
	return {
		POWER_UP_GRENADE: grenade_icon,
		POWER_UP_MEDKIT: medkit_icon,
		POWER_UP_TELEPORT_ORB: teleport_orb_icon,
		POWER_UP_MINE: mine_icon,
	}


func _update_grenade_icon(grenade_count: int) -> void:
	if not is_instance_valid(grenade_icon) or not is_instance_valid(grenade_count_label):
		return

	var has_grenades := grenade_count > 0
	grenade_icon.visible = has_grenades
	_update_selected_power_up_ui()
	grenade_count_label.hide()
	if is_instance_valid(grenade_count_digits_root):
		grenade_count_digits_root.visible = has_grenades
		_render_number_as_sprites("grenades", grenade_count_digits_root, grenade_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func _update_medkit_icon(medkit_count: int) -> void:
	if not is_instance_valid(medkit_icon) or not is_instance_valid(medkit_count_label):
		return

	var has_medkits := medkit_count > 0
	medkit_icon.visible = has_medkits
	_update_selected_power_up_ui()
	medkit_count_label.hide()
	if is_instance_valid(medkit_count_digits_root):
		medkit_count_digits_root.hide()


func _update_mine_icon(mine_count: int) -> void:
	if not is_instance_valid(mine_icon) or not is_instance_valid(mine_count_label):
		return

	var has_mines := mine_count > 0
	mine_icon.visible = has_mines
	_update_selected_power_up_ui()
	mine_count_label.hide()
	if is_instance_valid(mine_count_digits_root):
		mine_count_digits_root.visible = has_mines
		_render_number_as_sprites("mines", mine_count_digits_root, mine_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func _update_teleport_orb_icon(teleport_orb_count: int) -> void:
	if not is_instance_valid(teleport_orb_icon) or not is_instance_valid(teleport_orb_count_label):
		return

	var has_teleport_orbs := teleport_orb_count > 0
	teleport_orb_icon.visible = has_teleport_orbs
	_update_selected_power_up_ui()
	teleport_orb_count_label.hide()
	if is_instance_valid(teleport_orb_count_digits_root):
		teleport_orb_count_digits_root.visible = has_teleport_orbs
		_render_number_as_sprites("teleport_orbs", teleport_orb_count_digits_root, teleport_orb_count, 44.0, 4.0, COUNT_MULTIPLIER_TEXTURE, 6.0)


func _on_michael_jackson_died() -> void:
	unlock_achievement(ACHIEVEMENT_DEFEAT_MICHAEL_JACKSON)
	_update_fog_effect_for_wave()

	if not wave_active:
		return

	zombies_left_to_spawn = 0
	normal_zombies_left_to_spawn = 0
	atomic_zombies_left_to_spawn = 0
	fast_zombies_left_to_spawn = 0
	strong_zombies_left_to_spawn = 0
	miner_zombies_left_to_spawn = 0
	spawn_timer = 0.0

	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if zombie_node.has_method("die"):
			zombie_node.die()


func _setup_fog_effect() -> void:
	fog_overlay = Sprite2D.new()
	fog_overlay.name = "WaveFogOverlay"
	fog_overlay.texture = FOG_TEXTURE
	fog_overlay.centered = true
	fog_overlay.z_index = 900
	fog_overlay.visible = false
	fog_overlay.modulate = Color(1.0, 1.0, 1.0, 0.48)
	var fog_area := spawn_area.grow(160.0)
	fog_overlay.position = fog_area.get_center()
	if FOG_TEXTURE != null and FOG_TEXTURE.get_width() > 0 and FOG_TEXTURE.get_height() > 0:
		var fog_scale := maxf(
			fog_area.size.x / float(FOG_TEXTURE.get_width()),
			fog_area.size.y / float(FOG_TEXTURE.get_height())
		)
		fog_overlay.scale = Vector2.ONE * fog_scale * 1.08
	add_child(fog_overlay)

	fog_brightness_modulate = CanvasModulate.new()
	fog_brightness_modulate.name = "WaveFogBrightness"
	fog_brightness_modulate.color = Color.WHITE
	add_child(fog_brightness_modulate)

	fog_music = AudioStreamPlayer.new()
	fog_music.name = "FogMusic"
	fog_music.process_mode = Node.PROCESS_MODE_ALWAYS
	fog_music.bus = &"Master"
	fog_music.stream = FOG_MUSIC_STREAM
	fog_music.volume_db = -8.0
	if fog_music.stream is AudioStreamMP3:
		fog_music.stream.loop = true
	elif fog_music.stream is AudioStreamWAV:
		fog_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	add_child(fog_music)

	base_music = AudioStreamPlayer.new()
	base_music.name = "BaseMusic"
	base_music.process_mode = Node.PROCESS_MODE_ALWAYS
	base_music.bus = &"Master"
	base_music.stream = BASE_MUSIC_STREAM
	base_music.volume_db = -8.0
	if base_music.stream is AudioStreamMP3:
		base_music.stream.loop = true
	elif base_music.stream is AudioStreamWAV:
		base_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	add_child(base_music)


func _update_fog_effect_for_wave() -> void:
	if is_in_base_zone:
		if is_instance_valid(fog_overlay):
			fog_overlay.hide()
		if is_instance_valid(fog_brightness_modulate):
			fog_brightness_modulate.color = Color.WHITE
		_set_hard_fog_particles_visible(false)
		_update_fog_music_for_state(false)
		return

	var fog_active := _should_show_fog_for_wave(current_wave)
	if is_instance_valid(fog_overlay):
		fog_overlay.visible = fog_active
	_update_environment_brightness(fog_active)
	_update_fog_music_for_state(fog_active)
	if fog_active:
		var period_start := _get_fog_period_start_wave(current_wave)
		if hard_fog_period_start != period_start or hard_fog_particles.is_empty():
			_spawn_hard_fog_particles(period_start)
		else:
			_set_hard_fog_particles_visible(true)
	else:
		_clear_hard_fog_particles()
		hard_fog_period_start = -1


func apply_michael_jackson_brightness_override() -> void:
	_update_fog_effect_for_wave()


func restore_michael_jackson_brightness_override() -> void:
	_update_fog_effect_for_wave()


func _update_environment_brightness(fog_active: bool) -> void:
	if not is_instance_valid(fog_brightness_modulate):
		return

	if _has_active_michael_jackson():
		fog_brightness_modulate.color = MICHAEL_JACKSON_BRIGHTNESS
		return

	fog_brightness_modulate.color = FOG_BRIGHTNESS if fog_active else Color.WHITE


func _should_show_fog_for_wave(wave: int) -> bool:
	if hard_mode_enabled:
		return wave >= HARD_MODE_FOG_START_WAVE

	if wave < FOG_START_WAVE or FOG_WAVE_PERIOD <= 0:
		return false

	var waves_since_start := wave - FOG_START_WAVE
	return waves_since_start % FOG_WAVE_PERIOD < FOG_WAVE_DURATION


func restore_music_after_priority_audio() -> void:
	_update_fog_music_for_state(false if is_in_base_zone else _should_show_fog_for_wave(current_wave))


func _update_fog_music_for_state(fog_active: bool) -> void:
	var game_music := get_node_or_null("GameMusic") as AudioStreamPlayer

	if _is_time_freeze_active():
		_pause_time_freeze_music()
		return

	if _is_menu_visible() or player_dead:
		_stop_audio_player(fog_music)
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		return
	if _has_active_michael_jackson():
		_stop_audio_player(fog_music)
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		return

	if is_in_base_zone:
		_stop_audio_player(fog_music)
		_stop_audio_player(game_music)
		_play_audio_player(base_music)
		return

	if fog_active:
		_stop_audio_player(base_music)
		_stop_audio_player(game_music)
		_play_audio_player(fog_music)
		return

	_stop_audio_player(fog_music)
	_stop_audio_player(base_music)
	_play_audio_player(game_music)


func _has_active_michael_jackson() -> bool:
	for zombie_node in get_tree().get_nodes_in_group("zombies"):
		if zombie_node == null:
			continue
		if zombie_node.has_method("get_zombie_type") and StringName(zombie_node.call("get_zombie_type")) == ZOMBIE_TYPE_MICHAEL_JACKSON:
			return true
	return false


func _is_menu_visible() -> bool:
	return is_instance_valid(menu) and menu.visible


func _play_audio_player(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	if not player.playing:
		player.play()


func _stop_audio_player(player: AudioStreamPlayer) -> void:
	if player != null and player.playing:
		player.stop()


func _get_fog_period_start_wave(wave: int) -> int:
	if not _should_show_fog_for_wave(wave):
		return -1

	var completed_periods := int((wave - FOG_START_WAVE) / FOG_WAVE_PERIOD)
	return FOG_START_WAVE + completed_periods * FOG_WAVE_PERIOD


func _spawn_hard_fog_particles(period_start: int) -> void:
	_clear_hard_fog_particles()
	hard_fog_period_start = period_start
	hard_fog_time = 0.0

	var particle_count := _get_hard_fog_particle_count(period_start)
	var fog_area := spawn_area.grow(160.0)
	var hard_fog_target_size := fog_area.size / 3.0
	var hard_fog_center_area := Rect2(
		fog_area.position + hard_fog_target_size * 0.5,
		fog_area.size - hard_fog_target_size
	)
	for index in range(particle_count):
		var particle := Sprite2D.new()
		particle.name = "HardFogParticle%d" % (index + 1)
		particle.texture = HARD_FOG_TEXTURE
		particle.centered = true
		particle.z_index = 920
		particle.modulate = Color(1.0, 1.0, 1.0, HARD_FOG_ALPHA)
		particle.position = _get_random_point_in_rect(hard_fog_center_area)
		particle.rotation = randf_range(-0.18, 0.18)
		if HARD_FOG_TEXTURE != null and HARD_FOG_TEXTURE.get_width() > 0 and HARD_FOG_TEXTURE.get_height() > 0:
			var particle_scale := maxf(
				hard_fog_target_size.x / float(HARD_FOG_TEXTURE.get_width()),
				hard_fog_target_size.y / float(HARD_FOG_TEXTURE.get_height())
			)
			particle.scale = Vector2.ONE * particle_scale

		add_child(particle)
		hard_fog_particles.append({
			"sprite": particle,
			"base_position": particle.position,
			"phase": randf() * TAU,
			"speed": randf_range(HARD_FOG_MIN_DRIFT_SPEED, HARD_FOG_MAX_DRIFT_SPEED),
			"drift": randf_range(HARD_FOG_DRIFT_DISTANCE * 0.65, HARD_FOG_DRIFT_DISTANCE),
		})


func _get_hard_fog_particle_count(period_start: int) -> int:
	var completed_periods := maxi(int((period_start - FOG_START_WAVE) / FOG_WAVE_PERIOD), 0)
	var extra_particles := completed_periods * HARD_FOG_EXTRA_PER_PERIOD
	var min_count := mini(HARD_FOG_MIN_COUNT + extra_particles, HARD_FOG_MAX_TOTAL_COUNT)
	var max_count := mini(HARD_FOG_MAX_COUNT + extra_particles, HARD_FOG_MAX_TOTAL_COUNT)
	return randi_range(min_count, max_count)


func _set_hard_fog_particles_visible(visible: bool) -> void:
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if is_instance_valid(sprite):
			sprite.visible = visible


func _clear_hard_fog_particles() -> void:
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if is_instance_valid(sprite):
			sprite.queue_free()
	hard_fog_particles.clear()


func _update_hard_fog_particles(delta: float) -> void:
	if hard_fog_particles.is_empty():
		return

	hard_fog_time += delta
	for particle_data in hard_fog_particles:
		var sprite := particle_data.get("sprite", null) as Sprite2D
		if not is_instance_valid(sprite) or not sprite.visible:
			continue

		var base_position: Vector2 = particle_data.get("base_position", Vector2.ZERO)
		var phase := float(particle_data.get("phase", 0.0))
		var speed := float(particle_data.get("speed", 0.0))
		var drift := float(particle_data.get("drift", HARD_FOG_DRIFT_DISTANCE))
		var movement_time := hard_fog_time * speed
		sprite.position = base_position + Vector2(
			cos(movement_time + phase),
			sin(movement_time * 0.8 + phase)
		) * drift


func get_wave_settings_text() -> String:
	var lines: Array[String] = []
	lines.append("# Edit these values and press Apply")
	lines.append("# Format: key=value")
	for key_variant in WAVE_SETTING_ORDER:
		var key := String(key_variant)
		lines.append("%s=%s" % [key, str(get(key))])
	return "\n".join(lines)


func apply_wave_settings_text(settings_text: String) -> Dictionary:
	var parsed_values := {}
	var line_number := 0

	for raw_line in settings_text.split("\n"):
		line_number += 1
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var separator_index := line.find("=")
		if separator_index == -1:
			return {"ok": false, "error": "Invalid line %d" % line_number}

		var key := line.substr(0, separator_index).strip_edges()
		var value_text := line.substr(separator_index + 1).strip_edges()
		if not WAVE_SETTING_TYPES.has(key):
			return {"ok": false, "error": "Unknown key: %s" % key}
		if value_text.is_empty():
			return {"ok": false, "error": "Empty value for %s" % key}

		var value_type: int = WAVE_SETTING_TYPES[key]
		if value_type == TYPE_INT:
			if not value_text.is_valid_int() and not value_text.is_valid_float():
				return {"ok": false, "error": "Invalid value for %s" % key}
			parsed_values[key] = maxi(int(round(value_text.to_float())), 0)
		elif value_type == TYPE_FLOAT:
			if not value_text.is_valid_float() and not value_text.is_valid_int():
				return {"ok": false, "error": "Invalid value for %s" % key}
			parsed_values[key] = maxf(value_text.to_float(), 0.0)

	for key_variant in WAVE_SETTING_ORDER:
		var key := String(key_variant)
		if parsed_values.has(key):
			set(key, parsed_values[key])

	if not wave_active:
		if current_wave == 0:
			wave_timer = first_wave_delay
		else:
			wave_timer = minf(wave_timer, time_between_waves)
		_update_wave_label()

	return {"ok": true}


func _setup_number_displays() -> void:
	if not is_instance_valid(wave_label):
		return

	wave_label.hide()
	wave_display_root = Node2D.new()
	wave_display_root.name = "WaveDisplayRoot"
	wave_display_root.position = Vector2(wave_label.offset_left, wave_label.offset_top)
	$CanvasLayer.add_child(wave_display_root)

	var wave_title_root := _create_sprite_word_root(
		WAVE_TITLE_TEXT,
		WAVE_TITLE_TEXT_HEIGHT,
		WAVE_TITLE_LETTER_SPACING
	)
	wave_title_root.name = "WaveTitleRoot"
	wave_display_root.add_child(wave_title_root)

	wave_number_root = Node2D.new()
	wave_number_root.name = "WaveNumberRoot"
	wave_number_root.position = Vector2(226.0, 8.0)
	wave_display_root.add_child(wave_number_root)

	grenade_count_digits_root = _create_count_digits_root("GrenadeCountDigits", grenade_count_label)
	medkit_count_digits_root = _create_count_digits_root("MedkitCountDigits", medkit_count_label)
	mine_count_digits_root = _create_count_digits_root("MineCountDigits", mine_count_label)
	teleport_orb_count_digits_root = _create_count_digits_root("TeleportOrbCountDigits", teleport_orb_count_label)


func _setup_stamina_bar() -> void:
	var canvas_layer := get_node_or_null("CanvasLayer") as CanvasLayer
	if canvas_layer == null:
		return

	stamina_bar_panel = PanelContainer.new()
	stamina_bar_panel.name = "StaminaBarPanel"
	stamina_bar_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	stamina_bar_panel.offset_left = -620.0
	stamina_bar_panel.offset_top = -74.0
	stamina_bar_panel.offset_right = -80.0
	stamina_bar_panel.offset_bottom = -24.0
	stamina_bar_panel.add_theme_stylebox_override("panel", _create_stamina_panel_stylebox())
	canvas_layer.add_child(stamina_bar_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	stamina_bar_panel.add_child(margin)

	var content := HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)

	var label := _create_white_sprite_text_row("STAMINA", 40.0, -18.0)
	label.custom_minimum_size = Vector2(190, 46)
	label.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(label)

	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(340, 28)
	stamina_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamina_bar.min_value = 0.0
	stamina_bar.max_value = 100.0
	stamina_bar.value = 100.0
	stamina_bar.show_percentage = false
	stamina_bar.add_theme_stylebox_override("background", _create_stamina_bar_background_stylebox())
	stamina_bar.add_theme_stylebox_override("fill", _create_stamina_bar_fill_stylebox(Color(0.22, 0.92, 0.38, 1.0)))
	content.add_child(stamina_bar)


func _update_stamina_bar(stamina: float, max_stamina: float) -> void:
	if not is_instance_valid(stamina_bar):
		return

	var safe_max_stamina := maxf(max_stamina, 1.0)
	var stamina_ratio := clampf(stamina / safe_max_stamina, 0.0, 1.0)
	stamina_bar.max_value = safe_max_stamina
	stamina_bar.value = clampf(stamina, 0.0, safe_max_stamina)

	var fill_color := Color(0.22, 0.92, 0.38, 1.0)
	if stamina_ratio <= 0.25:
		fill_color = Color(0.95, 0.12, 0.08, 1.0)
	elif stamina_ratio <= 0.55:
		fill_color = Color(1.0, 0.78, 0.16, 1.0)
	stamina_bar.add_theme_stylebox_override("fill", _create_stamina_bar_fill_stylebox(fill_color))


func _create_stamina_panel_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.04, 0.05, 0.06, 0.82)
	stylebox.border_color = Color(0.98, 0.82, 0.24, 0.95)
	stylebox.set_border_width_all(3)
	stylebox.set_corner_radius_all(8)
	stylebox.shadow_color = Color(0, 0, 0, 0.45)
	stylebox.shadow_size = 8
	return stylebox


func _create_stamina_bar_background_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.02, 0.02, 0.02, 0.94)
	stylebox.border_color = Color(0.0, 0.0, 0.0, 0.75)
	stylebox.set_border_width_all(2)
	stylebox.set_corner_radius_all(5)
	return stylebox


func _create_stamina_bar_fill_stylebox(fill_color: Color) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = fill_color
	stylebox.set_corner_radius_all(4)
	return stylebox


func _create_white_sprite_text_row(text: String, target_height: float, letter_spacing: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(letter_spacing))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var normalized_text := _sanitize_achievement_sprite_text(text)
	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		if character == " ":
			var space := Control.new()
			space.custom_minimum_size = Vector2(target_height * 0.5, target_height)
			space.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(space)
			continue

		var glyph_texture := _get_sprite_letter_texture(character)
		if glyph_texture == null:
			continue

		var glyph_width := target_height
		if glyph_texture.get_height() > 0:
			glyph_width = float(glyph_texture.get_width()) * target_height / float(glyph_texture.get_height())

		var glyph_rect := TextureRect.new()
		glyph_rect.custom_minimum_size = Vector2(glyph_width, target_height)
		glyph_rect.size = glyph_rect.custom_minimum_size
		glyph_rect.texture = glyph_texture
		glyph_rect.material = _get_white_sprite_text_material()
		glyph_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(glyph_rect)

	return row


func _get_white_sprite_text_material() -> ShaderMaterial:
	if white_sprite_text_material != null:
		return white_sprite_text_material

	var shader := Shader.new()
	shader.code = (
		"shader_type canvas_item;\n"
		+ "uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);\n"
		+ "void fragment() {\n"
		+ "	vec4 tex = texture(TEXTURE, UV);\n"
		+ "	COLOR = vec4(text_color.rgb, tex.a * text_color.a);\n"
		+ "}\n"
	)
	white_sprite_text_material = ShaderMaterial.new()
	white_sprite_text_material.shader = shader
	white_sprite_text_material.set_shader_parameter("text_color", Color.WHITE)
	return white_sprite_text_material


func _setup_achievement_feedback() -> void:
	achievement_notification_sound_player = AudioStreamPlayer.new()
	achievement_notification_sound_player.name = "AchievementNotificationSound"
	achievement_notification_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	achievement_notification_sound_player.stream = ACHIEVEMENT_NOTIFICATION_SOUND
	add_child(achievement_notification_sound_player)

	var notification := PanelContainer.new()
	notification.name = "AchievementNotification"
	notification.process_mode = Node.PROCESS_MODE_ALWAYS
	notification.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notification.z_index = 100
	notification.visible = false
	notification.modulate = Color(1.0, 1.0, 1.0, 0.0)
	notification.size = _get_achievement_notification_size()
	notification.add_theme_stylebox_override("panel", _create_notification_stylebox())

	var margin := MarginContainer.new()
	margin.name = "NotificationMargin"
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notification.add_child(margin)

	var content := HBoxContainer.new()
	content.name = "Content"
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(content)

	var image := TextureRect.new()
	image.name = "Image"
	image.custom_minimum_size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	image.size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(image)

	var text_content := VBoxContainer.new()
	text_content.name = "TextContent"
	text_content.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_content.add_theme_constant_override("separation", 4)
	content.add_child(text_content)

	var heading := VBoxContainer.new()
	heading.name = "Heading"
	heading.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.add_child(heading)

	var title := VBoxContainer.new()
	title.name = "Title"
	title.alignment = BoxContainer.ALIGNMENT_CENTER
	text_content.add_child(title)

	achievement_notification_logo = notification
	achievement_notification_logo.position = _get_achievement_notification_hidden_position(achievement_notification_logo.size)
	$CanvasLayer.add_child(achievement_notification_logo)


func _queue_achievement_feedback(achievement_id: StringName) -> void:
	if not achievement_feedback_enabled:
		return

	achievement_notification_queue.append(achievement_id)
	if achievement_notification_active:
		return

	_show_next_achievement_notification()


func _create_notification_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.86, 0.72, 0.42, 0.96)
	stylebox.border_color = Color(0.20, 0.09, 0.04, 0.95)
	stylebox.set_border_width_all(5)
	stylebox.set_corner_radius_all(10)
	stylebox.shadow_color = Color(0, 0, 0, 0.35)
	stylebox.shadow_size = 8
	return stylebox


func _show_next_achievement_notification() -> void:
	if achievement_notification_queue.is_empty() or not is_instance_valid(achievement_notification_logo):
		return

	var achievement_id: StringName = StringName(achievement_notification_queue.pop_front())
	var achievement_data := _get_achievement_definition(achievement_id)
	achievement_notification_active = true
	_populate_achievement_notification(achievement_data)
	achievement_notification_logo.size = _get_achievement_notification_size()
	var hidden_position := _get_achievement_notification_hidden_position(achievement_notification_logo.size)
	var visible_position := _get_achievement_notification_visible_position(achievement_notification_logo.size)
	achievement_notification_logo.position = hidden_position
	achievement_notification_logo.modulate = Color(1.0, 1.0, 1.0, 0.0)
	achievement_notification_logo.visible = true
	_play_achievement_notification_sound()

	if achievement_notification_tween != null:
		achievement_notification_tween.kill()

	achievement_notification_tween = achievement_notification_logo.create_tween()
	achievement_notification_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"position",
		visible_position,
		ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION
	)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"modulate:a",
		1.0,
		ACHIEVEMENT_NOTIFICATION_SLIDE_IN_DURATION
	)
	achievement_notification_tween.tween_interval(_get_achievement_notification_visible_time())
	achievement_notification_tween.tween_callback(_start_achievement_notification_exit.bind(hidden_position))


func _start_achievement_notification_exit(hidden_position: Vector2) -> void:
	if not is_instance_valid(achievement_notification_logo):
		_on_achievement_notification_finished()
		return

	if achievement_notification_tween != null:
		achievement_notification_tween.kill()

	achievement_notification_tween = achievement_notification_logo.create_tween()
	achievement_notification_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"position",
		hidden_position,
		ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION
	)
	achievement_notification_tween.parallel().tween_property(
		achievement_notification_logo,
		"modulate:a",
		0.0,
		ACHIEVEMENT_NOTIFICATION_SLIDE_OUT_DURATION
	)
	achievement_notification_tween.finished.connect(_on_achievement_notification_finished)


func _on_achievement_notification_finished() -> void:
	achievement_notification_active = false
	achievement_notification_tween = null
	if is_instance_valid(achievement_notification_logo):
		achievement_notification_logo.visible = false

	if not achievement_notification_queue.is_empty():
		_show_next_achievement_notification()


func _play_achievement_notification_sound() -> void:
	if achievement_notification_sound_player == null or achievement_notification_sound_player.stream == null:
		return

	if achievement_notification_sound_player.playing:
		achievement_notification_sound_player.stop()
	achievement_notification_sound_player.play()


func _get_achievement_notification_visible_time() -> float:
	return ACHIEVEMENT_NOTIFICATION_VISIBLE_TIME


func _get_achievement_definition(achievement_id: StringName) -> Dictionary:
	for achievement in ACHIEVEMENT_DEFINITIONS:
		if achievement.get("id", &"") == achievement_id:
			return achievement

	return {}


func _populate_achievement_notification(achievement_data: Dictionary) -> void:
	if not is_instance_valid(achievement_notification_logo):
		return

	var image := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/Image") as TextureRect
	var heading := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/TextContent/Heading") as VBoxContainer
	var title := achievement_notification_logo.get_node_or_null("NotificationMargin/Content/TextContent/Title") as VBoxContainer
	var achievement_id: StringName = StringName(achievement_data.get("id", &""))
	if image != null:
		image.texture = ACHIEVEMENT_IMAGE_TEXTURES.get(achievement_id) as Texture2D
		image.visible = image.texture != null
		image.custom_minimum_size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
		image.size = ACHIEVEMENT_NOTIFICATION_IMAGE_SIZE
	if heading != null:
		_set_achievement_sprite_text_block(
			heading,
			"ACHIEVEMENT UNLOCKED",
			ACHIEVEMENT_NOTIFICATION_HEADING_HEIGHT,
			ACHIEVEMENT_NOTIFICATION_DESCRIPTION_MAX_CHARS,
			ACHIEVEMENT_NOTIFICATION_LETTER_SPACING
		)
	if title != null:
		_set_achievement_sprite_text_block(
			title,
			String(achievement_data.get("title", "Achievement")),
			ACHIEVEMENT_NOTIFICATION_TITLE_HEIGHT,
			ACHIEVEMENT_NOTIFICATION_TITLE_MAX_CHARS,
			ACHIEVEMENT_NOTIFICATION_LETTER_SPACING
		)

func _get_achievement_notification_size(_texture: Texture2D = null) -> Vector2:
	return Vector2(780.0, 190.0)


func _get_achievement_notification_visible_position(notification_size: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		ACHIEVEMENT_NOTIFICATION_MARGIN,
		maxf(viewport_size.y - notification_size.y - ACHIEVEMENT_NOTIFICATION_MARGIN, ACHIEVEMENT_NOTIFICATION_MARGIN)
	)


func _get_achievement_notification_hidden_position(notification_size: Vector2) -> Vector2:
	var visible_position := _get_achievement_notification_visible_position(notification_size)
	return Vector2(-notification_size.x - ACHIEVEMENT_NOTIFICATION_HIDDEN_OFFSET, visible_position.y)


func _set_achievement_sprite_text_block(
	container: VBoxContainer,
	text: String,
	target_height: float,
	max_line_characters: int,
	letter_spacing: float
) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for line in _wrap_achievement_sprite_text_lines(text, max_line_characters):
		var row := _create_achievement_sprite_text_row(line, target_height, letter_spacing)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(row)


func _create_achievement_sprite_text_row(text: String, target_height: float, letter_spacing: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", int(letter_spacing))
	row.custom_minimum_size = Vector2(0.0, target_height + 4.0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var normalized_text := _sanitize_achievement_sprite_text(text)
	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		if character == " ":
			var space := Control.new()
			space.custom_minimum_size = Vector2(target_height * 0.5, target_height)
			space.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(space)
			continue

		var glyph_texture := _get_sprite_letter_texture(character)
		if glyph_texture == null:
			continue

		var glyph_height := target_height * 0.7 if character.is_valid_int() else target_height
		var glyph_width := glyph_height
		if glyph_texture.get_height() > 0:
			glyph_width = float(glyph_texture.get_width()) * glyph_height / float(glyph_texture.get_height())

		var glyph_rect := TextureRect.new()
		glyph_rect.custom_minimum_size = Vector2(glyph_width, target_height)
		glyph_rect.size = glyph_rect.custom_minimum_size
		glyph_rect.texture = glyph_texture
		glyph_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(glyph_rect)

	return row


func _wrap_achievement_sprite_text_lines(text: String, max_line_characters: int) -> Array[String]:
	var lines: Array[String] = []
	var words := _sanitize_achievement_sprite_text(text).split(" ", false)
	var current_line := ""

	for word in words:
		if current_line.is_empty():
			current_line = word
			continue

		var candidate := "%s %s" % [current_line, word]
		if candidate.length() > max_line_characters:
			lines.append(current_line)
			current_line = word
		else:
			current_line = candidate

	if not current_line.is_empty():
		lines.append(current_line)
	if lines.is_empty():
		lines.append("")

	return lines


func _sanitize_achievement_sprite_text(text: String) -> String:
	var sanitized := text.to_upper()
	var replacements := {
		".": " ",
		",": " ",
		":": " ",
		";": " ",
		"!": " ",
		"?": " ",
		"-": " ",
		"'": "",
		"\"": "",
		"/": " ",
		"(": " ",
		")": " ",
	}

	for character in replacements:
		sanitized = sanitized.replace(character, String(replacements[character]))

	return sanitized.strip_edges()


func _create_count_digits_root(root_name: String, label: Label) -> Node2D:
	if not is_instance_valid(label):
		return null

	label.hide()
	var digits_root := Node2D.new()
	digits_root.name = root_name
	digits_root.position = Vector2(label.offset_left, label.offset_top + 10.0)
	digits_root.visible = false
	$CanvasLayer.add_child(digits_root)
	return digits_root


func _create_sprite_word_root(text: String, target_height: float, spacing: float) -> Node2D:
	var word_root := Node2D.new()
	var x_offset := 0.0
	var normalized_text := text.to_upper()

	for index in range(normalized_text.length()):
		var character := normalized_text.substr(index, 1)
		var letter_texture := _get_sprite_letter_texture(character)
		if letter_texture == null:
			continue

		var letter_sprite := Sprite2D.new()
		letter_sprite.texture = letter_texture
		letter_sprite.centered = false
		var letter_scale := target_height / float(letter_texture.get_height())
		letter_sprite.scale = Vector2.ONE * letter_scale
		letter_sprite.position = Vector2(x_offset, 0.0)
		word_root.add_child(letter_sprite)
		x_offset += (letter_texture.get_width() * letter_scale) + spacing

	return word_root


func _get_sprite_letter_texture(character: String) -> Texture2D:
	if DIGIT_TEXTURES.has(character):
		return DIGIT_TEXTURES[character] as Texture2D

	character = _normalize_sprite_letter_character(character)
	var character_index := LETTER_FONT_CHARS.find(character)
	if character_index < 0:
		return null

	var texture_size := LETTER_FONT_TEXTURE.get_size()
	var cell_width := texture_size.x / float(LETTER_FONT_COLUMNS)
	var cell_height := texture_size.y / float(LETTER_FONT_ROWS)
	var column := character_index % LETTER_FONT_COLUMNS
	var row := int(character_index / LETTER_FONT_COLUMNS)
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = LETTER_FONT_TEXTURE
	atlas_texture.region = Rect2(
		column * cell_width,
		row * cell_height,
		cell_width,
		cell_height
	)
	return atlas_texture


func _normalize_sprite_letter_character(character: String) -> String:
	match character:
		"Á", "À", "Ä", "Â", "Ã", "Ã€", "Ã„", "Ã‚":
			return "A"
		"É", "È", "Ë", "Ê", "Ã‰", "Ãˆ", "Ã‹", "ÃŠ":
			return "E"
		"Í", "Ì", "Ï", "Î", "Ã", "ÃŒ", "Ã", "ÃŽ":
			return "I"
		"Ó", "Ò", "Ö", "Ô", "Ã“", "Ã’", "Ã–", "Ã”":
			return "O"
		"Ú", "Ù", "Ü", "Û", "Ãš", "Ã™", "Ãœ", "Ã›":
			return "U"
		"Ñ", "Ã‘":
			return "N"
		_:
			return character


func _render_number_as_sprites(cache_key: String, digits_root: Node2D, value: int, target_height: float, spacing: float, prefix_texture: Texture2D = null, prefix_spacing: float = 0.0) -> void:
	if not is_instance_valid(digits_root):
		return

	var safe_value := maxi(value, 0)
	if displayed_number_cache.get(cache_key, -1) == safe_value:
		return

	displayed_number_cache[cache_key] = safe_value
	for child in digits_root.get_children():
		child.queue_free()

	var x_offset := 0.0
	if prefix_texture != null:
		var prefix_sprite := Sprite2D.new()
		prefix_sprite.texture = prefix_texture
		prefix_sprite.centered = false
		var prefix_scale := target_height / float(prefix_texture.get_height())
		prefix_sprite.scale = Vector2.ONE * prefix_scale
		prefix_sprite.position = Vector2.ZERO
		digits_root.add_child(prefix_sprite)
		x_offset += (prefix_texture.get_width() * prefix_scale) + prefix_spacing

	for digit_char in str(safe_value):
		var digit_texture: Texture2D = DIGIT_TEXTURES.get(str(digit_char))
		if digit_texture == null:
			continue

		var digit_sprite := Sprite2D.new()
		digit_sprite.texture = digit_texture
		digit_sprite.centered = false
		var digit_scale := target_height / float(digit_texture.get_height())
		digit_sprite.scale = Vector2.ONE * digit_scale
		digit_sprite.position = Vector2(x_offset, 0.0)
		digits_root.add_child(digit_sprite)
		x_offset += (digit_texture.get_width() * digit_scale) + spacing

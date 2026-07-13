extends Node2D

const WORLD_LEFT := -80
const WORLD_RIGHT := 1200
const FALL_LIMIT := 360.0

const SKY := Color("#a9b9a6")
const FAR_HILL := Color("#829b78")
const MID_HILL := Color("#6f8a65")
const NEAR_HILL := Color("#5e7657")
const CLOUD := Color("#d4d8c6")
const CLOUD_SHADOW := Color("#b9c1ae")
const TREE_TRUNK := Color("#5c594a")
const TREE_LEAF := Color("#667f5b")
const FLAG := Color("#d8dcc6")
const FLAG_POLE := Color("#4f5749")
const SHEEP_COUNT := 7
const SHEEP_MAX_PER_PLATFORM := 3
const SHEEP_MIN_SEPARATION := 42.0
const CAMERA_FOLLOW_OFFSET := Vector2(58, -24)
const INTRO_START_HOLD := 0.45
const INTRO_PAN_SECONDS := 3.0
const INTRO_END_HOLD := 0.55
const INTRO_RETURN_SECONDS := 2.2
const LEVEL_CLEAR_DELAY_SECONDS := 1.0
const LEVEL_COUNT := 4
const LEVEL_NAMES := ["春天", "夏天", "秋天", "冬天"]
const START_POSITION := Vector2(36, 222)

const LEVEL_SPRING := 0
const LEVEL_SUMMER := 1
const LEVEL_AUTUMN := 2
const LEVEL_WINTER := 3
const TITLE_COVER_TEXTURE: Texture2D = preload("res://素材/游戏封面.png")
const TITLE_COVER_REGION := Rect2(0, 521, 2385, 1343)
const TITLE_START_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/title_start_button.png")
const TITLE_TUTORIAL_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/title_tutorial_button.png")
const TITLE_QUIT_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/title_quit_button.png")
const RESULT_HOME_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/result_home_button.png")
const RESULT_NEXT_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/result_next_button.png")
const RESULT_RESTART_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/result_restart_button.png")
const HUD_CONTINUE_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/hud_continue_button.png")
const HUD_PAUSE_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/hud_pause_button.png")
const HUD_MUSIC_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/hud_music_button.png")
const HUD_MUTE_BUTTON_TEXTURE: Texture2D = preload("res://素材/processed/hud_mute_button.png")
const PAUSE_SCREEN_TEXTURE: Texture2D = preload("res://素材/角色/游戏暂停.png")
const PAUSE_SCREEN_REGION := Rect2(0, 390, 2385, 1995)
const PAUSE_CONTINUE_BUTTON_TEXTURE: Texture2D = preload("res://素材/按钮/暂停时继续游戏.png")
const PAUSE_RESTART_BUTTON_TEXTURE: Texture2D = preload("res://素材/按钮/暂停时重新开始.png")
const PAUSE_HOME_BUTTON_TEXTURE: Texture2D = preload("res://素材/按钮/暂停时返回主页.png")
const PAUSE_TUTORIAL_BUTTON_TEXTURE: Texture2D = preload("res://素材/按钮/游戏说明.png")
const PAUSE_CONTINUE_BUTTON_REGION := Rect2(52, 174, 2269, 613)
const PAUSE_RESTART_BUTTON_REGION := Rect2(62, 710, 2283, 607)
const PAUSE_HOME_BUTTON_REGION := Rect2(56, 1158, 2321, 617)
const PAUSE_TUTORIAL_BUTTON_REGION := Rect2(58, 1576, 2287, 615)
const LEVEL_FAIL_TEXTURE: Texture2D = preload("res://素材/角色/失败卡.png")
const LEVEL_CLEAR_TEXTURE: Texture2D = preload("res://素材/角色/通关卡.png")
const BACKGROUND_MUSIC: AudioStream = preload("res://素材/音乐/背景音效.MP3")
const SHEEP_COLLECT_SOUND: AudioStream = preload("res://素材/音乐/小羊叫.MP3")
const BUTTON_SOUND: AudioStream = preload("res://素材/音乐/按钮声.MP3")
const LEVEL_CLEAR_SOUND: AudioStream = preload("res://素材/音乐/通关音效.mp3")
const LEVEL_FAIL_SOUND: AudioStream = preload("res://素材/音乐/失败音效.mp3")
const UI_FONT: FontFile = preload("res://fonts/NotoSansSC-VF.ttf")
const BACKGROUND_MUSIC_VOLUME_DB := -12.0
const SHEEP_COLLECT_SOUND_VOLUME_DB := -6.0
const BUTTON_SOUND_VOLUME_DB := -8.0
const LEVEL_CLEAR_SOUND_VOLUME_DB := -6.0
const LEVEL_FAIL_SOUND_VOLUME_DB := -6.0
const TITLE_BUTTON_PRESS_SCALE := 0.92
const TITLE_BUTTON_POP_SCALE := 1.08
const RESULT_CLEAR_LEFT_BUTTON_POSITION := Vector2(147, 218)
const RESULT_CLEAR_RIGHT_BUTTON_POSITION := Vector2(249, 218)
const RESULT_FAIL_LEFT_BUTTON_POSITION := Vector2(147, 227)
const RESULT_FAIL_RIGHT_BUTTON_POSITION := Vector2(249, 227)
const RESULT_BUTTON_SIZE := Vector2(84, 30)
const HUD_STATE_BUTTON_SIZE := Vector2(28, 28)
const HUD_MUSIC_BUTTON_POSITION := Vector2(410, 8)
const HUD_PAUSE_BUTTON_POSITION := Vector2(444, 8)
const GAME_VIEWPORT_SIZE := Vector2(480, 270)
const PAUSE_SCREEN_DISPLAY_POSITION := Vector2(115, 35)
const PAUSE_SCREEN_DISPLAY_SIZE := Vector2(232, 194)
const PAUSE_MENU_BUTTON_SIZE := Vector2(82, 22)
const PAUSE_MENU_CONTINUE_POSITION := Vector2(216, 89)
const PAUSE_MENU_RESTART_POSITION := Vector2(216, 115)
const PAUSE_MENU_HOME_POSITION := Vector2(216, 141)
const PAUSE_MENU_TUTORIAL_POSITION := Vector2(216, 167)

var _player: ShepherdPlayer
var _camera: Camera2D
var _hud_layer: CanvasLayer
var _counter_label: Label
var _status_label: Label
var _music_button: TextureButton
var _pause_button: TextureButton
var _background_music_player: AudioStreamPlayer
var _sheep_collect_sound_player: AudioStreamPlayer
var _button_sound_player: AudioStreamPlayer
var _level_clear_sound_player: AudioStreamPlayer
var _level_fail_sound_player: AudioStreamPlayer
var _collected := 0
var _total_sheep := 0
var _won := false
var _last_checkpoint := START_POSITION
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _intro_active := false
var _intro_tween: Tween
var _level_clear_tween: Tween
var _level_index := LEVEL_SPRING
var _game_started := false
var _music_muted := false
var _game_paused := false
var _title_layer: CanvasLayer
var _result_layer: CanvasLayer
var _pause_layer: CanvasLayer
var _mushroom_platform_index: int = -1

var _platforms: Array[Rect2] = []

func _style_label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)

func _style_button(button: Button, font_size: int = 12) -> void:
	button.add_theme_font_override("font", UI_FONT)
	button.add_theme_font_size_override("font_size", font_size)

func _ready() -> void:
	_rng.randomize()
	_ensure_input_map()
	_create_world()
	_create_player()
	_create_camera()
	_create_audio_players()
	_create_hud()
	_reset_level(false)
	_set_world_visible(false)
	_create_cover_title_screen()

func _process(_delta: float) -> void:
	if not _game_started:
		if Input.is_action_just_pressed("jump"):
			_start_game()
		return
	if _result_layer:
		return

	if _player.global_position.y > FALL_LIMIT:
		_cancel_level_clear_delay()
		_show_level_result(false)
		return

	if _player.is_on_floor() and _player.global_position.x > _last_checkpoint.x + 38.0:
		_last_checkpoint = _player.global_position

	if Input.is_action_just_pressed("restart"):
		_reset_level()

	if not _won and _collected == _total_sheep and _is_player_on_summit_platform():
		_complete_level()
		return

	if not _intro_active:
		_update_camera_follow()

func _draw() -> void:
	if not _game_started:
		return

	var colors := _season_colors()
	var sky: Color = colors["sky"]
	var far_hill: Color = colors["far_hill"]
	var mid_hill: Color = colors["mid_hill"]
	var near_hill: Color = colors["near_hill"]
	var cloud: Color = colors["cloud"]
	var cloud_shadow: Color = colors["cloud_shadow"]
	var tree_trunk: Color = colors["tree_trunk"]
	var tree_leaf: Color = colors["tree_leaf"]
	var snow: Color = colors["snow"]

	draw_rect(Rect2(Vector2(WORLD_LEFT - 160, -190), Vector2(WORLD_RIGHT + 320, 560)), sky)
	_draw_cloud(Vector2(42, 36), cloud, cloud_shadow)
	_draw_cloud(Vector2(314, 18), cloud, cloud_shadow)
	_draw_cloud(Vector2(742, -8), cloud, cloud_shadow)
	_draw_snowflakes(snow)

	draw_polygon(
		PackedVector2Array([Vector2(-120, 238), Vector2(210, 96), Vector2(530, 238)]),
		PackedColorArray([far_hill, far_hill, far_hill])
	)
	draw_polygon(
		PackedVector2Array([Vector2(150, 238), Vector2(610, 40), Vector2(1060, 238)]),
		PackedColorArray([mid_hill, mid_hill, mid_hill])
	)
	draw_polygon(
		PackedVector2Array([Vector2(500, 238), Vector2(980, 22), Vector2(1240, 238)]),
		PackedColorArray([near_hill, near_hill, near_hill])
	)

	for x in range(-40, 1080, 96):
		_draw_tree(
			Vector2(x, 220 + int(sin(float(x) * 0.05) * 10.0)),
			tree_trunk,
			tree_leaf,
			bool(colors["tree_snow"])
		)

	_draw_ground_details(colors)
	_draw_summit_flag(_summit_flag_position(), sky)

func _create_world() -> void:
	_rebuild_platforms()

func _rebuild_platforms() -> void:
	for platform in get_tree().get_nodes_in_group("season_platforms"):
		platform.free()
	_platforms = _platform_layout_for_level(_level_index)
	for rect in _platforms:
		var platform := HillPlatform.new()
		add_child(platform)
		platform.add_to_group("season_platforms")
		platform.setup(rect)
		platform.set_season(_level_index)

func _reset_level(start_preview: bool = true) -> void:
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
	_cancel_level_clear_delay()

	_rebuild_platforms()
	_collected = 0
	_total_sheep = 0
	_won = false
	_last_checkpoint = START_POSITION
	_clear_sheep()
	_clear_mushrooms()
	_mushroom_platform_index = _mushroom_platform_index_for_level()
	_spawn_random_sheep()
	_spawn_mushroom_bad()

	if _player:
		_player.pocket_count = 0
		_player.pocket_capacity = _total_sheep
		_player.respawn(_last_checkpoint)
		_player.controls_enabled = start_preview
		_player.queue_redraw()

	_update_hud()
	queue_redraw()
	if start_preview:
		_start_route_preview()
	elif _status_label:
		_intro_active = false
		_status_label.visible = false

func _clear_sheep() -> void:
	for sheep in get_tree().get_nodes_in_group("sheep"):
		sheep.free()

func _clear_mushrooms() -> void:
	for mushroom in get_tree().get_nodes_in_group("mushrooms"):
		mushroom.free()
	for projectile in get_tree().get_nodes_in_group("mushroom_projectiles"):
		projectile.free()

func _spawn_random_sheep() -> void:
	var slots: Array[Dictionary] = _make_sheep_spawn_slots(SHEEP_COUNT)

	for i in range(SHEEP_COUNT):
		var slot: Dictionary = slots[i]
		var platform_index: int = int(slot["platform"])
		var rect: Rect2 = _platforms[platform_index]
		var x: float = float(slot["x"])
		var variant: int = _random_allowed_sheep_variant(i)
		var behavior: int = _sheep_behavior_for_variant(variant)
		var walk_left: float = float(slot.get("walk_left", x))
		var walk_right: float = float(slot.get("walk_right", x))
		if behavior == PocketSheep.MODE_WALK or behavior == PocketSheep.MODE_RUN:
			walk_left = _sheep_min_x(rect, platform_index) - 2.0
			walk_right = _sheep_max_x(rect) + 2.0

		var sheep := PocketSheep.new()
		add_child(sheep)
		sheep.add_to_group("sheep")
		sheep.global_position = Vector2(x, rect.position.y - 1.0)
		sheep.setup(
			_rng.randf_range(0.0, TAU),
			behavior,
			walk_left,
			walk_right,
			1 if _rng.randf() > 0.5 else -1,
			_sheep_speed_for_behavior(behavior),
			int(_rng.randi()),
			variant
		)
		sheep.pocketed.connect(_on_sheep_pocketed)

	_total_sheep = SHEEP_COUNT

func _spawn_mushroom_bad() -> void:
	var platform_index: int = _mushroom_platform_index
	if platform_index < 0 or platform_index >= _platforms.size():
		return
	var rect: Rect2 = _platforms[platform_index]
	var mushroom: MushroomBad = MushroomBad.new()
	add_child(mushroom)
	mushroom.add_to_group("mushrooms")
	mushroom.global_position = Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - 1.0)
	var direction: int = 1 if _level_index % 2 == 0 else -1
	var mode: int = _mushroom_mode_for_level()
	var speed: float = 0.0
	if mode == MushroomBad.MODE_WALK:
		speed = 8.0 + float(_level_index) * 2.0
	mushroom.setup(
		rect.position.x + 18.0,
		rect.end.x - 18.0,
		direction,
		speed,
		mode
	)
	mushroom.player_touched.connect(_on_mushroom_touched)

func _mushroom_platform_index_for_level() -> int:
	match _level_index:
		LEVEL_SUMMER:
			return 4
		LEVEL_AUTUMN:
			return 5
		LEVEL_WINTER:
			return 5
		_:
			return -1

func _mushroom_mode_for_level() -> int:
	match _level_index:
		LEVEL_SUMMER:
			return MushroomBad.MODE_STAND
		LEVEL_WINTER:
			return MushroomBad.MODE_ATTACK
		_:
			return MushroomBad.MODE_WALK

func _on_mushroom_touched() -> void:
	if _result_layer:
		return
	_show_level_result(false)

func _make_sheep_spawn_slots(total: int) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	var capacities: Array[int] = []
	var platform_counts: Array[int] = []
	var total_capacity: int = 0

	for platform_index in range(_platforms.size()):
		var rect: Rect2 = _platforms[platform_index]
		var min_x: float = _sheep_min_x(rect, platform_index)
		var max_x: float = _sheep_max_x(rect)
		var capacity: int = min(SHEEP_MAX_PER_PLATFORM, _sheep_platform_capacity(min_x, max_x))
		if (_level_index == LEVEL_SUMMER or _level_index == LEVEL_WINTER) and platform_index == _mushroom_platform_index:
			capacity = 0
		capacities.append(capacity)
		platform_counts.append(0)
		total_capacity += capacity

	var target_total: int = min(total, total_capacity)
	while _count_platform_sheep(platform_counts) < target_total:
		var available_platforms: Array[int] = []
		for platform_index in range(capacities.size()):
			if platform_counts[platform_index] < capacities[platform_index]:
				available_platforms.append(platform_index)
		if available_platforms.is_empty():
			break

		var pick_index: int = _rng.randi_range(0, available_platforms.size() - 1)
		var picked_platform: int = available_platforms[pick_index]
		platform_counts[picked_platform] += 1

	for platform_index in range(_platforms.size()):
		if platform_counts[platform_index] <= 0:
			continue

		var rect: Rect2 = _platforms[platform_index]
		var min_x: float = _sheep_min_x(rect, platform_index)
		var max_x: float = _sheep_max_x(rect)
		var positions: Array[float] = _make_platform_sheep_positions(min_x, max_x, platform_counts[platform_index])
		for x in positions:
			slots.append({
				"platform": platform_index,
				"x": x,
			})

	_shuffle_sheep_slots(slots)
	_assign_sheep_patrol_bounds(slots)
	return slots

func _count_platform_sheep(platform_counts: Array[int]) -> int:
	var total: int = 0
	for count in platform_counts:
		total += count
	return total

func _sheep_platform_capacity(min_x: float, max_x: float) -> int:
	if max_x < min_x:
		return 0
	return int(floor((max_x - min_x) / SHEEP_MIN_SEPARATION)) + 1

func _make_platform_sheep_positions(min_x: float, max_x: float, count: int) -> Array[float]:
	var positions: Array[float] = []
	if count <= 0:
		return positions
	if count == 1:
		positions.append(_rng.randf_range(min_x, max_x))
		return positions

	var group_width: float = SHEEP_MIN_SEPARATION * float(count - 1)
	var start_min: float = min_x
	var start_max: float = max_x - group_width
	var start: float = min_x
	if start_min <= start_max:
		start = _rng.randf_range(start_min, start_max)

	for member in range(count):
		positions.append(start + SHEEP_MIN_SEPARATION * float(member))
	return positions

func _shuffle_sheep_slots(slots: Array[Dictionary]) -> void:
	if slots.size() <= 1:
		return
	for i in range(slots.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var temp: Dictionary = slots[i]
		slots[i] = slots[j]
		slots[j] = temp

func _assign_sheep_patrol_bounds(slots: Array[Dictionary]) -> void:
	for platform_index in range(_platforms.size()):
		var platform_slots: Array[Dictionary] = []
		for slot in slots:
			if int(slot["platform"]) == platform_index:
				platform_slots.append(slot)
		if platform_slots.is_empty():
			continue

		platform_slots.sort_custom(_sort_sheep_slots_by_x)
		var rect: Rect2 = _platforms[platform_index]
		var platform_min_x: float = _sheep_min_x(rect, platform_index)
		var platform_max_x: float = _sheep_max_x(rect)

		for index in range(platform_slots.size()):
			var slot: Dictionary = platform_slots[index]
			var x: float = float(slot["x"])
			var walk_left: float = platform_min_x
			var walk_right: float = platform_max_x

			if index > 0:
				var previous_x: float = float(platform_slots[index - 1]["x"])
				walk_left = max(walk_left, (previous_x + x + SHEEP_MIN_SEPARATION) * 0.5)
			if index < platform_slots.size() - 1:
				var next_x: float = float(platform_slots[index + 1]["x"])
				walk_right = min(walk_right, (x + next_x - SHEEP_MIN_SEPARATION) * 0.5)

			if walk_left > walk_right:
				walk_left = x
				walk_right = x

			slot["walk_left"] = clamp(walk_left, platform_min_x, platform_max_x)
			slot["walk_right"] = clamp(walk_right, platform_min_x, platform_max_x)

func _sort_sheep_slots_by_x(a: Dictionary, b: Dictionary) -> bool:
	return float(a["x"]) < float(b["x"])

func _random_allowed_sheep_variant(index: int) -> int:
	var guaranteed: Array[int] = []
	if _level_index == LEVEL_AUTUMN or _level_index == LEVEL_WINTER:
		guaranteed = [
			PocketSheep.VARIANT_SLEEP,
			PocketSheep.VARIANT_WALK,
			PocketSheep.VARIANT_RUN,
			PocketSheep.VARIANT_WALK,
		]
	else:
		guaranteed = [
			PocketSheep.VARIANT_SLEEP,
			PocketSheep.VARIANT_GRAZE,
			PocketSheep.VARIANT_WALK,
			PocketSheep.VARIANT_RUN,
		]
	if index < guaranteed.size():
		return guaranteed[index]

	var roll: float = _rng.randf()
	if _level_index == LEVEL_AUTUMN or _level_index == LEVEL_WINTER:
		if roll < 0.34:
			return PocketSheep.VARIANT_SLEEP
		if roll < 0.72:
			return PocketSheep.VARIANT_WALK
		return PocketSheep.VARIANT_RUN

	if roll < 0.25:
		return PocketSheep.VARIANT_SLEEP
	if roll < 0.5:
		return PocketSheep.VARIANT_GRAZE
	if roll < 0.78:
		return PocketSheep.VARIANT_WALK
	return PocketSheep.VARIANT_RUN

func _sheep_behavior_for_variant(variant: int) -> int:
	match variant:
		PocketSheep.VARIANT_SLEEP:
			return PocketSheep.MODE_SLEEP
		PocketSheep.VARIANT_GRAZE:
			return PocketSheep.MODE_GRAZE
		PocketSheep.VARIANT_RUN:
			return PocketSheep.MODE_RUN
		_:
			return PocketSheep.MODE_WALK

func _sheep_speed_for_behavior(behavior: int) -> float:
	if behavior == PocketSheep.MODE_RUN:
		return _rng.randf_range(34.0, 46.0)
	if behavior == PocketSheep.MODE_WALK:
		return _rng.randf_range(7.0, 13.0)
	return 0.0

func _sheep_min_x(rect: Rect2, platform_index: int) -> float:
	var min_x: float = rect.position.x + 18.0
	if platform_index == 0:
		min_x = max(min_x, _last_checkpoint.x + 96.0)
	return min_x

func _sheep_max_x(rect: Rect2) -> float:
	return rect.position.x + rect.size.x - 18.0

func _create_player() -> void:
	_player = ShepherdPlayer.new()
	add_child(_player)
	_player.add_to_group("player")
	_player.global_position = _last_checkpoint
	_player.spawn_point = _last_checkpoint
	_player.pocket_capacity = _total_sheep

func _create_camera() -> void:
	_camera = Camera2D.new()
	_camera.limit_left = WORLD_LEFT
	_camera.limit_right = WORLD_RIGHT
	_camera.limit_top = -140
	_camera.limit_bottom = 278
	_camera.offset = Vector2.ZERO
	_camera.global_position = _camera_follow_target()
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 6.0
	add_child(_camera)
	_camera.make_current()

func _create_audio_players() -> void:
	_background_music_player = AudioStreamPlayer.new()
	_background_music_player.name = "BackgroundMusic"
	_background_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_background_music_player.stream = BACKGROUND_MUSIC
	if _background_music_player.stream is AudioStreamMP3:
		var music_stream := _background_music_player.stream as AudioStreamMP3
		music_stream.loop = true
	_background_music_player.volume_db = BACKGROUND_MUSIC_VOLUME_DB
	_background_music_player.autoplay = true
	add_child(_background_music_player)
	_background_music_player.play()

	_sheep_collect_sound_player = AudioStreamPlayer.new()
	_sheep_collect_sound_player.name = "SheepCollectSound"
	_sheep_collect_sound_player.stream = SHEEP_COLLECT_SOUND
	_sheep_collect_sound_player.volume_db = SHEEP_COLLECT_SOUND_VOLUME_DB
	add_child(_sheep_collect_sound_player)

	_button_sound_player = AudioStreamPlayer.new()
	_button_sound_player.name = "ButtonSound"
	_button_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_button_sound_player.stream = BUTTON_SOUND
	_button_sound_player.volume_db = BUTTON_SOUND_VOLUME_DB
	add_child(_button_sound_player)

	_level_clear_sound_player = AudioStreamPlayer.new()
	_level_clear_sound_player.name = "LevelClearSound"
	_level_clear_sound_player.stream = LEVEL_CLEAR_SOUND
	_level_clear_sound_player.volume_db = LEVEL_CLEAR_SOUND_VOLUME_DB
	add_child(_level_clear_sound_player)

	_level_fail_sound_player = AudioStreamPlayer.new()
	_level_fail_sound_player.name = "LevelFailSound"
	_level_fail_sound_player.stream = LEVEL_FAIL_SOUND
	_level_fail_sound_player.volume_db = LEVEL_FAIL_SOUND_VOLUME_DB
	add_child(_level_fail_sound_player)

func _camera_follow_target() -> Vector2:
	return _player.global_position + CAMERA_FOLLOW_OFFSET

func _camera_preview_target() -> Vector2:
	if _platforms.is_empty():
		return Vector2(1036, 28)
	var summit: Rect2 = _platforms[_platforms.size() - 1]
	return Vector2(summit.position.x + summit.size.x * 0.5, summit.position.y - 14.0)

func _update_camera_follow() -> void:
	_camera.global_position = _camera_follow_target()

func _start_route_preview() -> void:
	_intro_active = true
	_player.controls_enabled = false
	_status_label.text = "%s路线预览" % _current_level_name()
	_status_label.visible = true
	_camera.position_smoothing_enabled = false
	_camera.global_position = _camera_follow_target()

	_intro_tween = create_tween()
	_intro_tween.tween_interval(INTRO_START_HOLD)
	_intro_tween.tween_property(_camera, "global_position", _camera_preview_target(), INTRO_PAN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_intro_tween.tween_interval(INTRO_END_HOLD)
	_intro_tween.tween_property(_camera, "global_position", _camera_follow_target(), INTRO_RETURN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_intro_tween.tween_callback(_finish_route_preview)

func _finish_route_preview() -> void:
	_intro_active = false
	_player.controls_enabled = true
	_camera.position_smoothing_enabled = true
	_update_camera_follow()
	if _collected == _total_sheep:
		_status_label.text = "山顶见"
		_status_label.visible = true
	else:
		_status_label.visible = false

func _create_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_hud_layer)

	var panel := ColorRect.new()
	panel.color = Color(0.19, 0.25, 0.18, 0.72)
	panel.position = Vector2(8, 8)
	panel.size = Vector2(168, 22)
	_hud_layer.add_child(panel)

	_counter_label = Label.new()
	_counter_label.position = Vector2(14, 9)
	_style_label(_counter_label, 11, Color("#eef0da"))
	_hud_layer.add_child(_counter_label)

	_status_label = Label.new()
	_status_label.position = Vector2(190, 10)
	_style_label(_status_label, 14, Color("#eef0da"))
	_status_label.visible = false
	_hud_layer.add_child(_status_label)

	_music_button = _create_hud_state_button(HUD_MUSIC_BUTTON_TEXTURE, HUD_MUSIC_BUTTON_POSITION, Callable(self, "_toggle_music_mute"))
	_pause_button = _create_hud_state_button(HUD_CONTINUE_BUTTON_TEXTURE, HUD_PAUSE_BUTTON_POSITION, Callable(self, "_toggle_game_pause"))

func _create_hud_state_button(texture: Texture2D, position: Vector2, callback: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.position = position
	button.size = HUD_STATE_BUTTON_SIZE
	button.pivot_offset = HUD_STATE_BUTTON_SIZE * 0.5
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_set_button_texture(button, texture)
	button.pressed.connect(callback)
	_hud_layer.add_child(button)
	return button

func _set_button_texture(button: TextureButton, texture: Texture2D) -> void:
	if not button:
		return
	button.texture_normal = texture
	button.texture_hover = texture
	button.texture_pressed = texture

func _set_world_visible(visible: bool) -> void:
	if _player:
		_player.visible = visible
	for sheep in get_tree().get_nodes_in_group("sheep"):
		sheep.visible = visible
	for mushroom in get_tree().get_nodes_in_group("mushrooms"):
		mushroom.visible = visible
	for projectile in get_tree().get_nodes_in_group("mushroom_projectiles"):
		projectile.visible = visible
	if _counter_label:
		_counter_label.get_parent().visible = visible

func _create_cover_title_screen() -> void:
	_title_layer = CanvasLayer.new()
	_title_layer.layer = 20
	add_child(_title_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_layer.add_child(root)

	var cover := TextureRect.new()
	cover.texture = _atlas_texture(TITLE_COVER_TEXTURE, TITLE_COVER_REGION)
	cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root.add_child(cover)

	_create_hover_title_button(root, TITLE_START_BUTTON_TEXTURE, Vector2(200, 77), Vector2(81, 29), Callable(self, "_start_game"))
	_create_hover_title_button(root, TITLE_TUTORIAL_BUTTON_TEXTURE, Vector2(200, 109), Vector2(81, 29), Callable(self, "_show_cover_tutorial"))
	_create_hover_title_button(root, TITLE_QUIT_BUTTON_TEXTURE, Vector2(200, 142), Vector2(81, 29), Callable(self, "_quit_game"))

func _atlas_texture(source: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas

func _create_hover_title_button(parent: Control, texture: Texture2D, position: Vector2, size: Vector2, callback: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.position = position
	button.size = size
	button.pivot_offset = size * 0.5
	button.texture_hover = texture
	button.texture_pressed = texture
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(Callable(self, "_press_title_button").bind(button, callback))
	parent.add_child(button)
	return button

func _press_title_button(button: TextureButton, callback: Callable) -> void:
	_play_button_sound()
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(TITLE_BUTTON_PRESS_SCALE, TITLE_BUTTON_PRESS_SCALE), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(TITLE_BUTTON_POP_SCALE, TITLE_BUTTON_POP_SCALE), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(callback)
	tween.tween_callback(func() -> void:
		if is_instance_valid(button):
			button.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func _play_button_sound() -> void:
	if not _button_sound_player:
		return
	_button_sound_player.stop()
	_button_sound_player.play()

func _toggle_music_mute() -> void:
	_play_button_sound()
	_music_muted = not _music_muted
	_set_button_texture(_music_button, HUD_MUTE_BUTTON_TEXTURE if _music_muted else HUD_MUSIC_BUTTON_TEXTURE)
	if not _background_music_player:
		return
	if _music_muted:
		_background_music_player.stream_paused = true
	else:
		_background_music_player.stream_paused = false
		if _game_started and not _result_layer:
			_play_background_music()

func _toggle_game_pause() -> void:
	if not _game_started or _result_layer:
		return
	_play_button_sound()
	_set_game_paused(not _game_paused)

func _set_game_paused(paused: bool) -> void:
	_game_paused = paused
	get_tree().paused = paused
	_set_button_texture(_pause_button, HUD_PAUSE_BUTTON_TEXTURE if paused else HUD_CONTINUE_BUTTON_TEXTURE)
	if paused:
		_show_pause_screen()
	else:
		_clear_pause_screen()

func _show_pause_screen() -> void:
	if _pause_layer:
		return

	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 25
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_layer)

	var root := Control.new()
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_layer.add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.02, 0.58)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)

	var screen_rect := _pause_screen_display_rect()
	var card_scale := Vector2(
		screen_rect.size.x / PAUSE_SCREEN_REGION.size.x,
		screen_rect.size.y / PAUSE_SCREEN_REGION.size.y
	)
	_create_pause_card_shadow(root, screen_rect.position, card_scale)

	var card := Sprite2D.new()
	card.texture = _atlas_texture(PAUSE_SCREEN_TEXTURE, PAUSE_SCREEN_REGION)
	card.centered = false
	card.position = screen_rect.position
	card.scale = card_scale
	card.z_index = 10
	root.add_child(card)

	_create_pause_menu_button(root, PAUSE_MENU_CONTINUE_POSITION, PAUSE_MENU_BUTTON_SIZE, PAUSE_CONTINUE_BUTTON_TEXTURE, PAUSE_CONTINUE_BUTTON_REGION, Callable(self, "_resume_game"))
	_create_pause_menu_button(root, PAUSE_MENU_RESTART_POSITION, PAUSE_MENU_BUTTON_SIZE, PAUSE_RESTART_BUTTON_TEXTURE, PAUSE_RESTART_BUTTON_REGION, Callable(self, "_restart_from_pause"))
	_create_pause_menu_button(root, PAUSE_MENU_HOME_POSITION, PAUSE_MENU_BUTTON_SIZE, PAUSE_HOME_BUTTON_TEXTURE, PAUSE_HOME_BUTTON_REGION, Callable(self, "_return_to_title_from_pause"))
	_create_pause_menu_button(root, PAUSE_MENU_TUTORIAL_POSITION, PAUSE_MENU_BUTTON_SIZE, PAUSE_TUTORIAL_BUTTON_TEXTURE, PAUSE_TUTORIAL_BUTTON_REGION, Callable(self, "_show_pause_tutorial"))

func _create_pause_card_shadow(parent: Node, position: Vector2, scale: Vector2) -> void:
	var shadow_offsets := [
		Vector2(0, 1),
		Vector2(1, 2),
		Vector2(-1, 2),
		Vector2(0, 3),
	]
	var shadow_alphas := [0.10, 0.08, 0.06, 0.04]
	for index in range(shadow_offsets.size()):
		var shadow := Sprite2D.new()
		shadow.texture = _atlas_texture(PAUSE_SCREEN_TEXTURE, PAUSE_SCREEN_REGION)
		shadow.centered = false
		shadow.position = position + shadow_offsets[index]
		shadow.scale = scale
		shadow.modulate = Color(0.0, 0.0, 0.0, float(shadow_alphas[index]))
		shadow.z_index = 9
		parent.add_child(shadow)

func _pause_screen_display_rect() -> Rect2:
	var viewport_size: Vector2 = GAME_VIEWPORT_SIZE
	var size: Vector2 = PAUSE_SCREEN_DISPLAY_SIZE
	var max_size: Vector2 = viewport_size * 0.92
	if size.x > max_size.x or size.y > max_size.y:
		var scale: float = min(max_size.x / size.x, max_size.y / size.y)
		size *= scale
	var position: Vector2 = PAUSE_SCREEN_DISPLAY_POSITION
	return Rect2(position, size)

func _clear_pause_screen() -> void:
	if not _pause_layer:
		return
	_pause_layer.queue_free()
	_pause_layer = null

func _create_pause_menu_button(parent: Control, position: Vector2, size: Vector2, texture: Texture2D, region: Rect2, callback: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.position = position
	button.size = size
	button.pivot_offset = size * 0.5
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.texture_hover = _atlas_texture(texture, region)
	button.texture_pressed = _atlas_texture(texture, region)
	button.focus_mode = Control.FOCUS_NONE
	button.z_index = 20
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(Callable(self, "_press_pause_menu_button").bind(callback))
	parent.add_child(button)
	return button

func _press_pause_menu_button(callback: Callable) -> void:
	_play_button_sound()
	callback.call()

func _resume_game() -> void:
	_set_game_paused(false)

func _restart_from_pause() -> void:
	_set_game_paused(false)
	_reset_level()

func _return_to_title_from_pause() -> void:
	_set_game_paused(false)
	_return_to_title()

func _show_pause_tutorial() -> void:
	if not _pause_layer:
		return
	var existing := _pause_layer.get_node_or_null("TutorialPopup")
	if existing:
		existing.queue_free()
		return

	var popup := Control.new()
	popup.name = "TutorialPopup"
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.z_index = 100
	popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_layer.add_child(popup)

	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.07, 0.05, 0.62)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.z_index = 100
	popup.add_child(shade)

	var panel := ColorRect.new()
	panel.color = Color(0.78, 0.68, 0.50, 0.97)
	panel.position = Vector2(86, 28)
	panel.size = Vector2(308, 218)
	panel.z_index = 101
	popup.add_child(panel)

	var title := Label.new()
	title.text = "游戏说明"
	title.position = Vector2(170, 38)
	title.size = Vector2(140, 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_label(title, 18, Color("#3d2c1c"))
	title.z_index = 102
	popup.add_child(title)

	var text := Label.new()
	text.text = "A/D 或方向键移动\nSpace/W/上方向键跳跃\n起跳后快速再按一次可跳得更高\n收集每关 7 只小羊后到山顶旗子通关\n碰到红蘑菇或小红球会失败\nR 重新开始当前关"
	text.position = Vector2(152, 92)
	text.size = Vector2(176, 92)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(text, 9, Color("#3d2c1c"))
	text.z_index = 102
	popup.add_child(text)

	var close := Button.new()
	close.process_mode = Node.PROCESS_MODE_ALWAYS
	close.text = "返回"
	close.position = Vector2(194, 210)
	close.size = Vector2(92, 28)
	_style_button(close, 12)
	close.z_index = 102
	close.pressed.connect(Callable(popup, "queue_free"))
	popup.add_child(close)

func _play_level_result_sound(passed: bool) -> void:
	_stop_background_music()
	var player: AudioStreamPlayer = _level_clear_sound_player if passed else _level_fail_sound_player
	if not player:
		return
	player.stop()
	player.play()

func _stop_background_music() -> void:
	if _background_music_player and _background_music_player.playing:
		_background_music_player.stop()

func _play_background_music() -> void:
	if _music_muted:
		return
	if _background_music_player and not _background_music_player.playing:
		_background_music_player.stream_paused = false
		_background_music_player.play()

func _cancel_level_clear_delay() -> void:
	if _level_clear_tween and _level_clear_tween.is_valid():
		_level_clear_tween.kill()
	_level_clear_tween = null

func _show_cover_tutorial() -> void:
	if not _title_layer:
		return
	var existing := _title_layer.get_node_or_null("TutorialPopup")
	if existing:
		existing.queue_free()
		return

	var popup := Control.new()
	popup.name = "TutorialPopup"
	popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_layer.add_child(popup)

	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.07, 0.05, 0.62)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup.add_child(shade)

	var panel := ColorRect.new()
	panel.color = Color(0.78, 0.68, 0.50, 0.97)
	panel.position = Vector2(86, 28)
	panel.size = Vector2(308, 218)
	popup.add_child(panel)

	var text := Label.new()
	text.text = "游戏说明\n\nA/D 或方向键移动\nSpace/W/上方向键跳跃\n起跳后快速再按一次可跳得更高\n收集每关 7 只小羊后到山顶旗子通关\n碰到红蘑菇或小红球会失败\nR 重新开始当前关"
	text.position = Vector2(104, 42)
	text.size = Vector2(272, 140)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(text, 9, Color("#3d2c1c"))
	popup.add_child(text)

	var close := Button.new()
	close.text = "返回"
	close.position = Vector2(194, 210)
	close.size = Vector2(92, 28)
	_style_button(close, 12)
	close.pressed.connect(Callable(popup, "queue_free"))
	popup.add_child(close)

func _create_title_screen() -> void:
	_title_layer = CanvasLayer.new()
	_title_layer.layer = 20
	add_child(_title_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_layer.add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.14, 0.19, 0.14, 0.88)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)

	var title := Label.new()
	title.text = "牧羊人四季口袋"
	title.position = Vector2(40, 24)
	title.size = Vector2(400, 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title, 27, Color("#f3f0dc"))
	root.add_child(title)

	var tutorial_title := Label.new()
	tutorial_title.text = "游戏教程"
	tutorial_title.position = Vector2(46, 72)
	tutorial_title.size = Vector2(388, 22)
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(tutorial_title, 15, Color("#f3f0dc"))
	root.add_child(tutorial_title)

	var tutorial := Label.new()
	tutorial.text = "A/D 或方向键移动\nSpace/W/上方向键跳跃\n起跳后快速再按一次可跳得更高\n收集 7 只小羊后到山顶旗子通关\n碰到红蘑菇或小红球会失败\nR 重开当前关"
	tutorial.position = Vector2(80, 99)
	tutorial.size = Vector2(320, 96)
	tutorial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(tutorial, 11, Color("#e6ead4"))
	root.add_child(tutorial)

	var start_button := Button.new()
	start_button.text = "开始游戏"
	start_button.position = Vector2(170, 190)
	start_button.size = Vector2(140, 28)
	_style_button(start_button, 12)
	start_button.pressed.connect(_start_game)
	root.add_child(start_button)

	var quit_button := Button.new()
	quit_button.text = "退出游戏"
	quit_button.position = Vector2(170, 224)
	quit_button.size = Vector2(140, 28)
	_style_button(quit_button, 12)
	quit_button.pressed.connect(_quit_game)
	root.add_child(quit_button)

	start_button.grab_focus()

func _start_game() -> void:
	if _game_started:
		return
	_set_game_paused(false)
	_game_started = true
	if _title_layer:
		_title_layer.visible = false
	_level_index = LEVEL_SPRING
	_reset_level()
	_set_world_visible(true)

func _quit_game() -> void:
	get_tree().quit()

func _complete_level() -> void:
	_won = true
	if _status_label:
		_status_label.text = "太棒了"
		_status_label.visible = true
	_cancel_level_clear_delay()
	_level_clear_tween = create_tween()
	_level_clear_tween.tween_interval(LEVEL_CLEAR_DELAY_SECONDS)
	_level_clear_tween.tween_callback(func() -> void:
		if _won and not _result_layer:
			_show_level_result(true)
	)

func _show_level_result(passed: bool) -> void:
	if _result_layer:
		return
	_set_game_paused(false)
	_cancel_level_clear_delay()
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
	_intro_active = false
	_won = passed
	_player.controls_enabled = false
	if _status_label:
		_status_label.visible = false
	_play_level_result_sound(passed)

	_result_layer = CanvasLayer.new()
	_result_layer.layer = 30
	add_child(_result_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_layer.add_child(root)

	var card := TextureRect.new()
	card.texture = LEVEL_CLEAR_TEXTURE if passed else LEVEL_FAIL_TEXTURE
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root.add_child(card)

	if passed:
		_create_result_button(root, RESULT_NEXT_BUTTON_TEXTURE, RESULT_CLEAR_LEFT_BUTTON_POSITION, RESULT_BUTTON_SIZE, Callable(self, "_advance_level_or_home"))
		_create_result_button(root, RESULT_HOME_BUTTON_TEXTURE, RESULT_CLEAR_RIGHT_BUTTON_POSITION, RESULT_BUTTON_SIZE, Callable(self, "_return_to_title"))
	else:
		_create_result_button(root, RESULT_RESTART_BUTTON_TEXTURE, RESULT_FAIL_LEFT_BUTTON_POSITION, RESULT_BUTTON_SIZE, Callable(self, "_restart_current_level"))
		_create_result_button(root, RESULT_HOME_BUTTON_TEXTURE, RESULT_FAIL_RIGHT_BUTTON_POSITION, RESULT_BUTTON_SIZE, Callable(self, "_return_to_title"))

func _create_result_button(parent: Control, texture: Texture2D, position: Vector2, size: Vector2, callback: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.position = position
	button.size = size
	button.pivot_offset = size * 0.5
	button.texture_hover = texture
	button.texture_pressed = texture
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(Callable(self, "_press_result_button").bind(button, callback))
	parent.add_child(button)
	return button

func _press_result_button(button: TextureButton, callback: Callable) -> void:
	_play_button_sound()
	if is_instance_valid(button):
		button.disabled = true
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(TITLE_BUTTON_PRESS_SCALE, TITLE_BUTTON_PRESS_SCALE), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(TITLE_BUTTON_POP_SCALE, TITLE_BUTTON_POP_SCALE), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(callback)
	tween.tween_callback(func() -> void:
		if is_instance_valid(button):
			button.disabled = false
	)

func _clear_result_screen() -> void:
	if not _result_layer:
		return
	_result_layer.queue_free()
	_result_layer = null
	_play_background_music()

func _restart_current_level() -> void:
	_clear_result_screen()
	_reset_level()

func _advance_level_or_home() -> void:
	_clear_result_screen()
	if _level_index >= LEVEL_COUNT - 1:
		_return_to_title()
		return
	_advance_level()

func _return_to_title() -> void:
	_set_game_paused(false)
	_clear_result_screen()
	_game_started = false
	_level_index = LEVEL_SPRING
	_reset_level(false)
	_set_world_visible(false)
	if _title_layer:
		_title_layer.visible = true

func _advance_level() -> void:
	_level_index = min(_level_index + 1, LEVEL_COUNT - 1)
	_reset_level()

func _is_player_on_summit_platform() -> bool:
	if not _player or not _player.is_on_floor():
		return false
	var summit: Rect2 = _platforms[_platforms.size() - 1]
	var player_position: Vector2 = _player.global_position
	return (
		player_position.x >= summit.position.x - 8.0
		and player_position.x <= summit.end.x + 8.0
		and player_position.y <= summit.position.y + 14.0
	)

func _summit_flag_position() -> Vector2:
	if _platforms.is_empty():
		return Vector2(1062, 18)
	var summit: Rect2 = _platforms[_platforms.size() - 1]
	return Vector2(summit.end.x - 52.0, summit.position.y - 24.0)

func _on_sheep_pocketed(_sheep: Node) -> void:
	_collected += 1
	_play_sheep_collect_sound()
	_player.pocket_count = _collected
	_player.queue_redraw()
	_update_hud()
	if _collected == _total_sheep:
		_status_label.text = "山顶见"
		_status_label.visible = true

func _play_sheep_collect_sound() -> void:
	if not _sheep_collect_sound_player:
		return
	_sheep_collect_sound_player.stop()
	_sheep_collect_sound_player.play()

func _update_hud() -> void:
	if _counter_label:
		_counter_label.text = "%d/4 %s  口袋 %d/%d" % [_level_index + 1, _current_level_name(), _collected, _total_sheep]

func _current_level_name() -> String:
	return str(LEVEL_NAMES[_level_index])

func _platform_layout_for_level(level: int) -> Array[Rect2]:
	match level:
		LEVEL_SUMMER:
			return [
				Rect2(Vector2(-60, 230), Vector2(220, 24)),
				Rect2(Vector2(198, 202), Vector2(86, 18)),
				Rect2(Vector2(318, 174), Vector2(118, 18)),
				Rect2(Vector2(470, 190), Vector2(82, 18)),
				Rect2(Vector2(586, 158), Vector2(96, 18)),
				Rect2(Vector2(716, 126), Vector2(126, 18)),
				Rect2(Vector2(874, 144), Vector2(78, 18)),
				Rect2(Vector2(982, 102), Vector2(82, 18)),
				Rect2(Vector2(1090, 62), Vector2(72, 20)),
			]
		LEVEL_AUTUMN:
			return [
				Rect2(Vector2(-60, 230), Vector2(250, 24)),
				Rect2(Vector2(220, 206), Vector2(78, 18)),
				Rect2(Vector2(330, 182), Vector2(96, 18)),
				Rect2(Vector2(458, 206), Vector2(118, 18)),
				Rect2(Vector2(608, 170), Vector2(74, 18)),
				Rect2(Vector2(714, 136), Vector2(122, 18)),
				Rect2(Vector2(868, 154), Vector2(76, 18)),
				Rect2(Vector2(976, 112), Vector2(82, 18)),
				Rect2(Vector2(1088, 66), Vector2(76, 20)),
			]
		LEVEL_WINTER:
			return [
				Rect2(Vector2(-60, 230), Vector2(205, 24)),
				Rect2(Vector2(176, 198), Vector2(64, 18)),
				Rect2(Vector2(274, 220), Vector2(104, 18)),
				Rect2(Vector2(410, 186), Vector2(70, 18)),
				Rect2(Vector2(512, 150), Vector2(100, 18)),
				Rect2(Vector2(644, 166), Vector2(78, 18)),
				Rect2(Vector2(754, 128), Vector2(92, 18)),
				Rect2(Vector2(878, 88), Vector2(78, 18)),
				Rect2(Vector2(988, 48), Vector2(118, 20)),
			]
		_:
			return [
				Rect2(Vector2(-60, 230), Vector2(235, 24)),
				Rect2(Vector2(205, 205), Vector2(86, 18)),
				Rect2(Vector2(325, 218), Vector2(118, 18)),
				Rect2(Vector2(478, 186), Vector2(82, 18)),
				Rect2(Vector2(594, 158), Vector2(126, 18)),
				Rect2(Vector2(752, 176), Vector2(78, 18)),
				Rect2(Vector2(862, 134), Vector2(82, 18)),
				Rect2(Vector2(974, 94), Vector2(72, 18)),
				Rect2(Vector2(1076, 56), Vector2(72, 20)),
			]

func _update_platform_seasons() -> void:
	for platform in get_tree().get_nodes_in_group("season_platforms"):
		if platform is HillPlatform:
			(platform as HillPlatform).set_season(_level_index)

func _season_colors() -> Dictionary:
	match _level_index:
		LEVEL_SPRING:
			return {
				"sky": Color("#aebda9"),
				"far_hill": Color("#879d79"),
				"mid_hill": Color("#748d68"),
				"near_hill": Color("#617a59"),
				"cloud": Color("#d7dbc9"),
				"cloud_shadow": Color("#bdc5b2"),
				"tree_trunk": Color("#5c594a"),
				"tree_leaf": Color("#6e875f"),
				"tree_snow": false,
				"flower_a": Color("#cba7a0"),
				"flower_b": Color("#d8d4bf"),
				"flower_c": Color("#a98d6a"),
				"snow": Color(1, 1, 1, 0),
			}
		LEVEL_AUTUMN:
			return {
				"sky": Color("#b7b8a5"),
				"far_hill": Color("#918a68"),
				"mid_hill": Color("#827a57"),
				"near_hill": Color("#6c6548"),
				"cloud": Color("#d9d7c6"),
				"cloud_shadow": Color("#c0bba9"),
				"tree_trunk": Color("#5a5144"),
				"tree_leaf": Color("#8b7a4d"),
				"tree_snow": false,
				"flower_a": Color("#a88950"),
				"flower_b": Color("#b6a66c"),
				"flower_c": Color("#8f6945"),
				"snow": Color(1, 1, 1, 0),
			}
		LEVEL_WINTER:
			return {
				"sky": Color("#aab7ba"),
				"far_hill": Color("#89999b"),
				"mid_hill": Color("#6f8389"),
				"near_hill": Color("#5c7279"),
				"cloud": Color("#d6ddd8"),
				"cloud_shadow": Color("#b9c5c3"),
				"tree_trunk": Color("#575349"),
				"tree_leaf": Color("#c4cfce"),
				"tree_snow": true,
				"flower_a": Color("#d4dbd9"),
				"flower_b": Color("#c6d0cf"),
				"flower_c": Color("#b6c2c1"),
				"snow": Color("#e5ebe8"),
			}
		_:
			return {
				"sky": SKY,
				"far_hill": FAR_HILL,
				"mid_hill": MID_HILL,
				"near_hill": NEAR_HILL,
				"cloud": CLOUD,
				"cloud_shadow": CLOUD_SHADOW,
				"tree_trunk": TREE_TRUNK,
				"tree_leaf": TREE_LEAF,
				"tree_snow": false,
				"flower_a": Color(1, 1, 1, 0),
				"flower_b": Color(1, 1, 1, 0),
				"flower_c": Color(1, 1, 1, 0),
				"snow": Color(1, 1, 1, 0),
			}

func _ensure_input_map() -> void:
	_add_action_keys(&"move_left", [KEY_A, KEY_LEFT])
	_add_action_keys(&"move_right", [KEY_D, KEY_RIGHT])
	_add_action_keys(&"jump", [KEY_SPACE, KEY_W, KEY_UP])
	_add_action_keys(&"restart", [KEY_R])

func _add_action_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode in keys:
		if not _action_has_key(action, keycode):
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)

func _action_has_key(action: StringName, keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.physical_keycode == keycode:
				return true
	return false

func _draw_cloud(origin: Vector2, cloud_color: Color, shadow_color: Color) -> void:
	draw_rect(Rect2(origin + Vector2(0, 5), Vector2(46, 6)), shadow_color)
	draw_rect(Rect2(origin + Vector2(4, 0), Vector2(14, 8)), cloud_color)
	draw_rect(Rect2(origin + Vector2(16, -4), Vector2(16, 12)), cloud_color)
	draw_rect(Rect2(origin + Vector2(29, 1), Vector2(17, 9)), cloud_color)

func _draw_snowflakes(snow_color: Color) -> void:
	if _level_index != LEVEL_WINTER:
		return

	var flakes := [
		Vector2(-34, 44),
		Vector2(82, -54),
		Vector2(176, 82),
		Vector2(290, -26),
		Vector2(412, 51),
		Vector2(524, -47),
		Vector2(655, 76),
		Vector2(748, -18),
		Vector2(884, 43),
		Vector2(1024, -59),
		Vector2(1142, 70),
		Vector2(228, 132),
		Vector2(596, 146),
		Vector2(934, 132),
	]
	for index in range(flakes.size()):
		var flake: Vector2 = flakes[index]
		var size: Vector2 = Vector2(2, 2) if index % 3 != 0 else Vector2(3, 3)
		draw_rect(Rect2(flake, size), snow_color)

func _draw_tree(root: Vector2, trunk_color: Color, leaf_color: Color, snow_cap: bool) -> void:
	draw_rect(Rect2(root + Vector2(-2, -16), Vector2(4, 17)), trunk_color)
	draw_rect(Rect2(root + Vector2(-9, -25), Vector2(18, 11)), leaf_color)
	draw_rect(Rect2(root + Vector2(-6, -32), Vector2(13, 9)), leaf_color)
	if snow_cap:
		draw_rect(Rect2(root + Vector2(-8, -31), Vector2(16, 5)), Color("#f4f8f8"))
		draw_rect(Rect2(root + Vector2(-5, -36), Vector2(10, 5)), Color("#eef5f7"))

func _draw_ground_details(colors: Dictionary) -> void:
	if _level_index == LEVEL_SUMMER:
		return

	var detail_positions := [
		Vector2(6, 225),
		Vector2(52, 219),
		Vector2(107, 224),
		Vector2(165, 220),
		Vector2(232, 226),
		Vector2(314, 222),
		Vector2(392, 225),
		Vector2(486, 221),
		Vector2(548, 226),
		Vector2(632, 219),
		Vector2(706, 225),
		Vector2(788, 221),
		Vector2(858, 226),
		Vector2(934, 222),
		Vector2(1018, 225),
		Vector2(1096, 220),
	]
	for index in range(detail_positions.size()):
		var position: Vector2 = detail_positions[index]
		var color: Color = colors["flower_a"]
		if index % 3 == 1:
			color = colors["flower_b"]
		elif index % 3 == 2:
			color = colors["flower_c"]
		var size := Vector2(3, 3)
		if _level_index == LEVEL_AUTUMN:
			size = Vector2(4, 2)
		elif _level_index == LEVEL_WINTER:
			size = Vector2(4, 2)
		draw_rect(Rect2(position, size), color)

func _draw_summit_flag(root: Vector2, sky_color: Color = SKY) -> void:
	draw_rect(Rect2(root + Vector2(0, -18), Vector2(3, 22)), FLAG_POLE)
	draw_rect(Rect2(root + Vector2(3, -18), Vector2(16, 8)), FLAG)
	draw_rect(Rect2(root + Vector2(14, -13), Vector2(5, 3)), sky_color)

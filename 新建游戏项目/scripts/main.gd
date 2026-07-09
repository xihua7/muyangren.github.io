extends Node2D

const WORLD_LEFT := -80
const WORLD_RIGHT := 1120
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
const LEVEL_COUNT := 4
const LEVEL_NAMES := ["春天", "夏天", "秋天", "冬天"]
const START_POSITION := Vector2(36, 222)

const LEVEL_SPRING := 0
const LEVEL_SUMMER := 1
const LEVEL_AUTUMN := 2
const LEVEL_WINTER := 3

var _player: ShepherdPlayer
var _camera: Camera2D
var _counter_label: Label
var _status_label: Label
var _collected := 0
var _total_sheep := 0
var _won := false
var _last_checkpoint := START_POSITION
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _intro_active := false
var _intro_tween: Tween
var _level_index := LEVEL_SPRING

var _platforms := [
	Rect2(Vector2(-60, 230), Vector2(230, 24)),
	Rect2(Vector2(182, 204), Vector2(82, 18)),
	Rect2(Vector2(304, 176), Vector2(78, 18)),
	Rect2(Vector2(430, 148), Vector2(84, 18)),
	Rect2(Vector2(562, 121), Vector2(86, 18)),
	Rect2(Vector2(704, 94), Vector2(92, 18)),
	Rect2(Vector2(858, 67), Vector2(94, 18)),
	Rect2(Vector2(994, 42), Vector2(120, 20)),
]

func _ready() -> void:
	_rng.randomize()
	_ensure_input_map()
	_create_world()
	_create_player()
	_create_camera()
	_create_hud()
	_reset_level()

func _process(_delta: float) -> void:
	if _player.global_position.y > FALL_LIMIT:
		_player.respawn(_last_checkpoint)

	if _player.is_on_floor() and _player.global_position.x > _last_checkpoint.x + 38.0:
		_last_checkpoint = _player.global_position

	if Input.is_action_just_pressed("restart"):
		_reset_level()

	if not _won and _collected == _total_sheep and _player.global_position.x > 990.0:
		_complete_level()

	if not _intro_active:
		_update_camera_follow()

func _draw() -> void:
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
	_draw_summit_flag(Vector2(1062, 18), sky)

func _create_world() -> void:
	for rect in _platforms:
		var platform := HillPlatform.new()
		add_child(platform)
		platform.setup(rect)

func _reset_level() -> void:
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()

	_collected = 0
	_total_sheep = 0
	_won = false
	_last_checkpoint = START_POSITION
	_clear_sheep()
	_spawn_random_sheep()

	if _player:
		_player.pocket_count = 0
		_player.pocket_capacity = _total_sheep
		_player.respawn(_last_checkpoint)
		_player.controls_enabled = true
		_player.queue_redraw()

	_update_hud()
	queue_redraw()
	_start_route_preview()

func _clear_sheep() -> void:
	for sheep in get_tree().get_nodes_in_group("sheep"):
		sheep.free()

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
	var guaranteed: Array[int] = [
		PocketSheep.VARIANT_SLEEP,
		PocketSheep.VARIANT_GRAZE,
		PocketSheep.VARIANT_WALK,
		PocketSheep.VARIANT_RUN,
	]
	if index < guaranteed.size():
		return guaranteed[index]

	var roll: float = _rng.randf()
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
		return _rng.randf_range(18.0, 26.0)
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

func _camera_follow_target() -> Vector2:
	return _player.global_position + CAMERA_FOLLOW_OFFSET

func _camera_preview_target() -> Vector2:
	return Vector2(1036, 28)

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
	var layer := CanvasLayer.new()
	add_child(layer)

	var panel := ColorRect.new()
	panel.color = Color(0.19, 0.25, 0.18, 0.72)
	panel.position = Vector2(8, 8)
	panel.size = Vector2(168, 22)
	layer.add_child(panel)

	_counter_label = Label.new()
	_counter_label.position = Vector2(14, 9)
	_counter_label.add_theme_font_size_override("font_size", 11)
	_counter_label.add_theme_color_override("font_color", Color("#eef0da"))
	layer.add_child(_counter_label)

	_status_label = Label.new()
	_status_label.position = Vector2(190, 10)
	_status_label.add_theme_font_size_override("font_size", 14)
	_status_label.add_theme_color_override("font_color", Color("#eef0da"))
	_status_label.visible = false
	layer.add_child(_status_label)

func _complete_level() -> void:
	_won = true
	_player.controls_enabled = false
	if _level_index >= LEVEL_COUNT - 1:
		_status_label.text = "四季都走完了"
		_status_label.visible = true
		return

	_status_label.text = "进入%s" % LEVEL_NAMES[_level_index + 1]
	_status_label.visible = true

	var tween: Tween = create_tween()
	tween.tween_interval(0.9)
	tween.tween_callback(_advance_level)

func _advance_level() -> void:
	_level_index = min(_level_index + 1, LEVEL_COUNT - 1)
	_reset_level()

func _on_sheep_pocketed(_sheep: Node) -> void:
	_collected += 1
	_player.pocket_count = _collected
	_player.queue_redraw()
	_update_hud()
	if _collected == _total_sheep:
		_status_label.text = "山顶见"
		_status_label.visible = true

func _update_hud() -> void:
	if _counter_label:
		_counter_label.text = "%d/4 %s  口袋 %d/%d" % [_level_index + 1, _current_level_name(), _collected, _total_sheep]

func _current_level_name() -> String:
	return str(LEVEL_NAMES[_level_index])

func _season_colors() -> Dictionary:
	match _level_index:
		LEVEL_SPRING:
			return {
				"sky": Color("#c6d4bf"),
				"far_hill": Color("#93ad78"),
				"mid_hill": Color("#7f9c64"),
				"near_hill": Color("#5f8455"),
				"cloud": Color("#f2f4ea"),
				"cloud_shadow": Color("#d5dccb"),
				"tree_trunk": Color("#6a4730"),
				"tree_leaf": Color("#789756"),
				"tree_snow": false,
				"flower_a": Color("#f0a6aa"),
				"flower_b": Color("#f6ead6"),
				"flower_c": Color("#cf8b5d"),
				"snow": Color(1, 1, 1, 0),
			}
		LEVEL_AUTUMN:
			return {
				"sky": Color("#d9cfaa"),
				"far_hill": Color("#b99958"),
				"mid_hill": Color("#a87d32"),
				"near_hill": Color("#7e5f2a"),
				"cloud": Color("#f4f1e8"),
				"cloud_shadow": Color("#d5cfbd"),
				"tree_trunk": Color("#5f3b22"),
				"tree_leaf": Color("#d47a25"),
				"tree_snow": false,
				"flower_a": Color("#e39b27"),
				"flower_b": Color("#f1bf42"),
				"flower_c": Color("#bb5c1d"),
				"snow": Color(1, 1, 1, 0),
			}
		LEVEL_WINTER:
			return {
				"sky": Color("#c7d4dd"),
				"far_hill": Color("#aebfca"),
				"mid_hill": Color("#748b9f"),
				"near_hill": Color("#526f84"),
				"cloud": Color("#f6f8f7"),
				"cloud_shadow": Color("#d7e0e2"),
				"tree_trunk": Color("#5d472d"),
				"tree_leaf": Color("#dce8ec"),
				"tree_snow": true,
				"flower_a": Color("#eef5f7"),
				"flower_b": Color("#dbe7ec"),
				"flower_c": Color("#c7d6df"),
				"snow": Color("#f5f8f8"),
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
		var size := Vector2(2, 2) if index % 3 != 0 else Vector2(3, 3)
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

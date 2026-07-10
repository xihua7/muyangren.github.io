class_name PocketSheep
extends Area2D

signal pocketed(sheep)

const MODE_WALK := 0
const MODE_GRAZE := 1
const MODE_SLEEP := 2
const MODE_RUN := 3

const VARIANT_GRAZE := 0
const VARIANT_SLEEP := 1
const VARIANT_WALK := 2
const VARIANT_RUN := 3

const SHEEP_GRAZE: Texture2D = preload("res://素材/processed/sheep_graze_right.png")
const SHEEP_SLEEP_0: Texture2D = preload("res://素材/processed/sheep_sleep_0.png")
const SHEEP_SLEEP_1: Texture2D = preload("res://素材/processed/sheep_sleep_1.png")
const SHEEP_SLEEP_2: Texture2D = preload("res://素材/processed/sheep_sleep_2.png")
const SHEEP_WALK: Texture2D = preload("res://素材/processed/sheep_walk_right.png")
const SHEEP_RUN: Texture2D = preload("res://素材/processed/sheep_run_right.png")

const SHADOW := Color(0.17, 0.22, 0.16, 0.22)

var _behavior: int = MODE_WALK
var _variant: int = VARIANT_WALK
var _phase: float = 0.0
var _collected: bool = false
var _base_y: float = 0.0
var _walk_left: float = 0.0
var _walk_right: float = 0.0
var _speed: float = 9.0
var _direction: int = 1
var _pause_left: float = 0.0
var _grass_seed: int = 0

func _ready() -> void:
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(30, 28)

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -14)
	add_child(collision)

	body_entered.connect(_on_body_entered)
	z_index = 8

func setup(
	phase: float,
	behavior: int,
	walk_left: float,
	walk_right: float,
	direction: int,
	speed: float,
	grass_seed: int,
	variant: int
) -> void:
	_phase = phase
	_behavior = behavior
	_base_y = global_position.y
	_walk_left = walk_left
	_walk_right = walk_right
	_direction = 1 if direction >= 0 else -1
	_speed = speed
	_grass_seed = grass_seed
	_variant = clamp(variant, VARIANT_GRAZE, VARIANT_RUN)
	queue_redraw()

func _process(delta: float) -> void:
	if _collected:
		return

	var phase_speed: float = 3.0
	if _behavior == MODE_RUN:
		phase_speed = 5.2
	elif _behavior == MODE_GRAZE:
		phase_speed = 1.8
	elif _behavior == MODE_SLEEP:
		phase_speed = 1.2
	_phase += delta * phase_speed

	if _behavior == MODE_WALK or _behavior == MODE_RUN:
		_walk(delta)
	else:
		global_position.y = _base_y + sin(_phase) * 0.25

	queue_redraw()

func _walk(delta: float) -> void:
	global_position.y = _base_y + round(sin(_phase * 1.4) * 0.5)
	if _pause_left > 0.0:
		_pause_left = max(_pause_left - delta, 0.0)
		return

	global_position.x += float(_direction) * _speed * delta
	if global_position.x < _walk_left:
		global_position.x = _walk_left
		_turn_around()
	elif global_position.x > _walk_right:
		global_position.x = _walk_right
		_turn_around()

func _turn_around() -> void:
	_direction *= -1
	_pause_left = 0.12 + float(_grass_seed % 4) * 0.04

func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if body.is_in_group("player"):
		_collect_into(body)

func _collect_into(player: Node2D) -> void:
	_collected = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	pocketed.emit(self)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", player.global_position + Vector2(-5, -3), 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.08, 0.08), 0.26).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", -0.35, 0.26)
	tween.chain().tween_callback(queue_free)

func _draw() -> void:
	var texture: Texture2D = _current_texture()
	var size: Vector2 = texture.get_size()
	var squash: float = _squash_scale()
	var bottom_y: float = _bottom_offset()
	var flip: bool = _should_flip()

	draw_rect(Rect2(Vector2(-size.x * 0.36, -3), Vector2(size.x * 0.72, 4)), SHADOW)
	_draw_texture(texture, bottom_y, flip, squash)

func _current_texture() -> Texture2D:
	match _variant:
		VARIANT_GRAZE:
			return SHEEP_GRAZE
		VARIANT_SLEEP:
			return _sleep_texture()
		VARIANT_RUN:
			return SHEEP_RUN
		_:
			return SHEEP_WALK

func _sleep_texture() -> Texture2D:
	var frame_index: int = int(floor(_phase * 1.5)) % 3
	match frame_index:
		1:
			return SHEEP_SLEEP_1
		2:
			return SHEEP_SLEEP_2
		_:
			return SHEEP_SLEEP_0

func _bottom_offset() -> float:
	if _behavior == MODE_GRAZE:
		return 1.0 + sin(_phase * 1.6) * 0.35
	if _behavior == MODE_SLEEP:
		return 1.0
	if _behavior == MODE_RUN:
		return 1.0 + round(sin(_phase * 2.4))
	return 1.0 + round(sin(_phase * 2.0))

func _squash_scale() -> float:
	return 1.0

func _should_flip() -> bool:
	if _behavior == MODE_RUN:
		return _direction > 0
	return _direction < 0

func _draw_texture(texture: Texture2D, bottom_y: float, flip: bool, y_scale: float) -> void:
	var size: Vector2 = texture.get_size()
	var x_scale: float = -1.0 if flip else 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(x_scale, y_scale))
	draw_texture_rect(
		texture,
		Rect2(Vector2(-size.x * 0.5, (bottom_y - size.y) / y_scale), size),
		false
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

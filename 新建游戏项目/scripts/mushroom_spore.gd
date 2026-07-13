class_name MushroomSpore
extends Area2D

signal player_touched

const COLOR := Color("#e14b43")
const COLOR_DARK := Color("#9f2729")
const COLOR_EDGE := Color("#5a171b")
const HIGHLIGHT := Color("#ffd0b8")
const SHADOW := Color(0.18, 0.08, 0.06, 0.24)
const RADIUS := 3.0

var _direction: int = 1
var _speed: float = 46.0
var _range_left: float = 0.0
var _range_right: float = 0.0
var _phase: float = 0.0

func _ready() -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	body_entered.connect(_on_body_entered)
	z_index = 8

func setup(direction: int, range_left: float, range_right: float, speed: float = 46.0) -> void:
	_direction = 1 if direction >= 0 else -1
	_range_left = range_left
	_range_right = range_right
	_speed = speed
	queue_redraw()

func _process(delta: float) -> void:
	_phase += delta * 8.0
	global_position.x += float(_direction) * _speed * delta
	global_position.y += sin(_phase) * 0.05
	if global_position.x < _range_left or global_position.x > _range_right:
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2(-2, 3), Vector2(5, 1)), SHADOW)
	draw_rect(Rect2(Vector2(-2, -2), Vector2(5, 5)), COLOR_EDGE)
	draw_rect(Rect2(Vector2(-3, -1), Vector2(7, 3)), COLOR_EDGE)
	draw_rect(Rect2(Vector2(-2, -1), Vector2(5, 3)), COLOR)
	draw_rect(Rect2(Vector2(-1, -2), Vector2(3, 5)), COLOR)
	draw_rect(Rect2(Vector2(1, 0), Vector2(2, 2)), COLOR_DARK)
	draw_rect(Rect2(Vector2(-1, -2), Vector2(2, 1)), HIGHLIGHT)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_touched.emit()
		queue_free()

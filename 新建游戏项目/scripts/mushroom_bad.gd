class_name MushroomBad
extends Node2D

signal player_touched

const MODE_STAND := 0
const MODE_WALK := 1
const MODE_ATTACK := 2

const TEXTURE: Texture2D = preload("res://素材/processed/mushroom_bad.png")
const WALK_1: Texture2D = preload("res://素材/processed/mushroom_walk_1.png")
const WALK_2: Texture2D = preload("res://素材/processed/mushroom_walk_2.png")
const WALK_3: Texture2D = preload("res://素材/processed/mushroom_walk_3.png")
const SHADOW := Color(0.17, 0.18, 0.14, 0.26)
const DISPLAY_HEIGHT := 15.0
const HITBOX_SIZE := Vector2(13, 13)
const ATTACK_INTERVAL := 1.35

var _phase: float = 0.0
var _base_y: float = 0.0
var _walk_left: float = 0.0
var _walk_right: float = 0.0
var _speed: float = 10.0
var _direction: int = 1
var _mode: int = MODE_WALK
var _attack_left: float = 0.0
var _attack_right: float = 0.0
var _attack_left_time: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	z_index = 7
	_create_hitbox()

func setup(walk_left: float, walk_right: float, direction: int, speed: float, mode: int = MODE_WALK) -> void:
	_base_y = global_position.y
	_walk_left = walk_left
	_walk_right = walk_right
	_direction = 1 if direction >= 0 else -1
	_speed = speed
	_mode = mode
	_attack_left = walk_left
	_attack_right = walk_right
	_attack_left_time = ATTACK_INTERVAL * 0.65
	queue_redraw()

func _process(delta: float) -> void:
	_phase += delta * 2.0
	if _mode == MODE_WALK:
		global_position.x += float(_direction) * _speed * delta
	global_position.y = _base_y + round(sin(_phase) * 0.7)

	if _mode == MODE_WALK and global_position.x < _walk_left:
		global_position.x = _walk_left
		_direction = 1
	elif _mode == MODE_WALK and global_position.x > _walk_right:
		global_position.x = _walk_right
		_direction = -1
	elif _mode == MODE_ATTACK:
		_attack_left_time = max(_attack_left_time - delta, 0.0)
		if _attack_left_time <= 0.0:
			_shoot_spore()
			_attack_left_time = ATTACK_INTERVAL

	queue_redraw()

func _draw() -> void:
	var texture: Texture2D = _current_texture()
	var size: Vector2 = _display_size(texture)
	var bob: float = sin(_phase * 1.4) * 0.35
	draw_rect(Rect2(Vector2(-size.x * 0.34, -3), Vector2(size.x * 0.68, 4)), SHADOW)
	_draw_mushroom_texture(texture, size, bob)

func _current_texture() -> Texture2D:
	if _mode != MODE_WALK:
		return TEXTURE
	var frame: int = int(floor(_phase * 4.0)) % 4
	match frame:
		1:
			return WALK_2
		2:
			return WALK_3
		3:
			return WALK_2
		_:
			return WALK_1

func _display_size(texture: Texture2D) -> Vector2:
	var source_size: Vector2 = texture.get_size()
	return Vector2(source_size.x * DISPLAY_HEIGHT / source_size.y, DISPLAY_HEIGHT)

func _draw_mushroom_texture(texture: Texture2D, size: Vector2, bob: float) -> void:
	var flip: bool = _direction < 0
	var x_scale: float = -1.0 if flip else 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(x_scale, 1.0))
	var draw_x: float = -size.x * 0.5
	if flip:
		draw_x = -draw_x - size.x
	draw_texture_rect(texture, Rect2(Vector2(draw_x, -size.y + 1.0 + bob), size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _shoot_spore() -> void:
	var spore: MushroomSpore = MushroomSpore.new()
	get_parent().add_child(spore)
	spore.add_to_group("mushroom_projectiles")
	spore.global_position = global_position + Vector2(float(_direction) * 5.0, -8.0)
	spore.setup(_direction, _attack_left, _attack_right)
	spore.player_touched.connect(func() -> void:
		player_touched.emit()
	)

func _create_hitbox() -> void:
	var area: Area2D = Area2D.new()
	area.name = "DangerArea"
	add_child(area)

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = HITBOX_SIZE

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -HITBOX_SIZE.y * 0.5)
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_touched.emit()

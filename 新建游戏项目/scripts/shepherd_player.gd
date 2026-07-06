class_name ShepherdPlayer
extends CharacterBody2D

const SPEED := 126.0
const ACCELERATION := 880.0
const FRICTION := 1020.0
const JUMP_VELOCITY := -318.0
const GRAVITY := 880.0
const MAX_FALL_SPEED := 420.0
const COYOTE_TIME := 0.09
const JUMP_BUFFER_TIME := 0.11

const STATE_STAND := 0
const STATE_TRAVEL := 1
const STATE_REST := 2
const STATE_SLEEP := 3
const REST_AFTER_SECONDS := 12.0
const SLEEP_AFTER_SECONDS := 20.0

const SHEPHERD_STAND: Texture2D = preload("res://素材/processed/shepherd_stand.png")
const SHEPHERD_REST: Texture2D = preload("res://素材/processed/shepherd_rest.png")
const SHEPHERD_SLEEP: Texture2D = preload("res://素材/processed/shepherd_sleep.png")
const SHEPHERD_TRAVEL_WALK_0: Texture2D = preload("res://素材/processed/shepherd_travel_walk_0.png")
const SHEPHERD_TRAVEL_WALK_1: Texture2D = preload("res://素材/processed/shepherd_travel_walk_1.png")
const SHEPHERD_TRAVEL_WALK_2: Texture2D = preload("res://素材/processed/shepherd_travel_walk_2.png")
const SHEPHERD_TRAVEL_WALK_3: Texture2D = preload("res://素材/processed/shepherd_travel_walk_3.png")
const SHADOW := Color(0.18, 0.24, 0.17, 0.22)
const POCKET_WOOL := Color("#f5efd9")

var pocket_count := 0
var pocket_capacity := 0
var spawn_point := Vector2.ZERO
var controls_enabled := true

var _facing := 1
var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _walk_time := 0.0
var _pose_time := 0.0
var _was_on_floor := false
var _idle_time := 0.0

func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14, 24)

	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -3)
	add_child(collision)

	z_index = 10

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right") if controls_enabled else 0.0
	var input_direction := 0
	if direction > 0.0:
		input_direction = 1
	elif direction < 0.0:
		input_direction = -1

	var has_user_input := controls_enabled and (direction != 0.0 or Input.is_action_pressed("jump"))
	if has_user_input:
		_idle_time = 0.0
	elif not controls_enabled:
		_idle_time = 0.0
	else:
		_idle_time += delta

	_pose_time += delta

	if direction != 0.0:
		_facing = input_direction
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if is_on_floor():
		_coyote_left = COYOTE_TIME
	else:
		_coyote_left = max(_coyote_left - delta, 0.0)
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	if controls_enabled and Input.is_action_just_pressed("jump"):
		_jump_buffer_left = JUMP_BUFFER_TIME
	else:
		_jump_buffer_left = max(_jump_buffer_left - delta, 0.0)

	if _jump_buffer_left > 0.0 and _coyote_left > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_left = 0.0
		_coyote_left = 0.0

	if controls_enabled and Input.is_action_just_released("jump") and velocity.y < -80.0:
		velocity.y *= 0.45

	move_and_slide()

	if abs(velocity.x) > 2.0 and is_on_floor():
		_walk_time += delta * 10.0
	else:
		_walk_time = 0.0

	var state: int = _current_state()
	if _was_on_floor != is_on_floor() or abs(velocity.x) > 0.5 or state == STATE_STAND or state == STATE_REST or state == STATE_SLEEP:
		queue_redraw()
	_was_on_floor = is_on_floor()

func respawn(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	var state: int = _current_state()
	var texture: Texture2D = _texture_for_state(state)
	var texture_size: Vector2 = texture.get_size()
	var bob: float = _pose_bob(state)
	if is_on_floor():
		draw_rect(Rect2(Vector2(-8, 7), Vector2(16, 3)), SHADOW)
	_draw_shepherd_texture(texture, Vector2(-texture_size.x * 0.5, 9.0 - texture_size.y + bob), texture_size, _should_flip_texture())

	if pocket_capacity > 0 and pocket_count > 0:
		var pocket_limit: int = max(1, pocket_capacity)
		var wool_count: int = clamp(pocket_count, 0, pocket_limit)
		for i in range(min(wool_count, 5)):
			draw_rect(Rect2(Vector2(-9 + i * 3, -3 + bob), Vector2(2, 2)), POCKET_WOOL)

func _current_state() -> int:
	var can_idle_state: bool = is_on_floor() and abs(velocity.x) <= 2.0
	if can_idle_state and _idle_time >= SLEEP_AFTER_SECONDS:
		return STATE_SLEEP
	if can_idle_state and _idle_time >= REST_AFTER_SECONDS:
		return STATE_REST
	if abs(velocity.x) > 2.0:
		return STATE_TRAVEL
	return STATE_STAND

func _texture_for_state(state: int) -> Texture2D:
	match state:
		STATE_TRAVEL:
			return _travel_texture()
		STATE_REST:
			return SHEPHERD_REST
		STATE_SLEEP:
			return SHEPHERD_SLEEP
		_:
			return SHEPHERD_STAND

func _travel_texture() -> Texture2D:
	var frame_index: int = int(floor(_walk_time)) % 4
	match frame_index:
		1:
			return SHEPHERD_TRAVEL_WALK_1
		2:
			return SHEPHERD_TRAVEL_WALK_2
		3:
			return SHEPHERD_TRAVEL_WALK_3
		_:
			return SHEPHERD_TRAVEL_WALK_0

func _pose_bob(state: int) -> float:
	if not is_on_floor():
		return -1.0
	match state:
		STATE_TRAVEL:
			return round(sin(_walk_time) * 0.8)
		STATE_REST:
			return sin(_pose_time * 1.5) * 0.25
		STATE_SLEEP:
			return sin(_pose_time * 1.0) * 0.25
		_:
			return sin(_pose_time * 2.0) * 0.25

func _should_flip_texture() -> bool:
	var state := _current_state()
	if state == STATE_TRAVEL:
		return _facing > 0
	return false

func _draw_shepherd_texture(texture: Texture2D, position: Vector2, size: Vector2, flip: bool) -> void:
	var x_scale := -1.0 if flip else 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(x_scale, 1.0))
	var draw_x := -position.x - size.x if flip else position.x
	draw_texture_rect(texture, Rect2(Vector2(draw_x, position.y), size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

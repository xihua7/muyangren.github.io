class_name HillPlatform
extends StaticBody2D

const SEASON_SPRING := 0
const SEASON_SUMMER := 1
const SEASON_AUTUMN := 2
const SEASON_WINTER := 3

var size := Vector2(64, 16)
var season := SEASON_SPRING
var _collision: CollisionShape2D

func setup(rect: Rect2) -> void:
	position = rect.position + rect.size * 0.5
	size = rect.size

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	if not _collision:
		_collision = CollisionShape2D.new()
		add_child(_collision)
	_collision.shape = shape

	queue_redraw()

func set_season(value: int) -> void:
	season = value
	queue_redraw()

func _draw() -> void:
	var top_left := -size * 0.5
	var colors := _season_colors()

	draw_rect(Rect2(top_left, size), colors["dirt"])
	draw_rect(Rect2(top_left, Vector2(size.x, 5)), colors["grass"])
	draw_rect(Rect2(top_left + Vector2(0, 5), Vector2(size.x, 2)), colors["grass_dark"])
	draw_rect(Rect2(top_left + Vector2(0, size.y - 3), Vector2(size.x, 3)), colors["dirt_dark"])

	if season == SEASON_WINTER:
		draw_rect(Rect2(top_left + Vector2(0, -1), Vector2(size.x, 5)), colors["snow"])
		draw_rect(Rect2(top_left + Vector2(0, 4), Vector2(size.x, 2)), colors["snow_shadow"])

	var pebble_y := top_left.y + 9
	for x in range(6, int(size.x), 22):
		draw_rect(Rect2(top_left + Vector2(x, pebble_y), Vector2(4, 3)), colors["stone"])

	_draw_surface_details(top_left, colors)

func _season_colors() -> Dictionary:
	match season:
		SEASON_SUMMER:
			return {
				"grass": Color("#678a55"),
				"grass_dark": Color("#4d6a42"),
				"dirt": Color("#647059"),
				"dirt_dark": Color("#4a5647"),
				"stone": Color("#71806d"),
			}
		SEASON_AUTUMN:
			return {
				"grass": Color("#9a8a50"),
				"grass_dark": Color("#756b43"),
				"dirt": Color("#706949"),
				"dirt_dark": Color("#555139"),
				"stone": Color("#8b7f5a"),
				"leaf_a": Color("#b88b45"),
				"leaf_b": Color("#8f6840"),
				"leaf_c": Color("#c2a15d"),
			}
		SEASON_WINTER:
			return {
				"grass": Color("#7b8983"),
				"grass_dark": Color("#62736f"),
				"dirt": Color("#66706d"),
				"dirt_dark": Color("#4e5a57"),
				"stone": Color("#84908d"),
				"snow": Color("#eef3f0"),
				"snow_shadow": Color("#c8d5d4"),
			}
		_:
			return {
				"grass": Color("#7fab5f"),
				"grass_dark": Color("#5d854f"),
				"dirt": Color("#65745a"),
				"dirt_dark": Color("#4c5c48"),
				"stone": Color("#7d8a70"),
				"flower_a": Color("#d9aaa6"),
				"flower_b": Color("#f1e8c6"),
				"flower_c": Color("#c8b474"),
			}

func _draw_surface_details(top_left: Vector2, colors: Dictionary) -> void:
	match season:
		SEASON_AUTUMN:
			for x in range(10, int(size.x), 27):
				var color: Color = colors["leaf_a"]
				if x % 3 == 0:
					color = colors["leaf_b"]
				elif x % 5 == 0:
					color = colors["leaf_c"]
				draw_rect(Rect2(top_left + Vector2(x, -2), Vector2(4, 2)), color)
				draw_rect(Rect2(top_left + Vector2(x + 8, 1), Vector2(3, 2)), colors["leaf_b"])
		SEASON_WINTER:
			for x in range(12, int(size.x), 32):
				draw_rect(Rect2(top_left + Vector2(x, -3), Vector2(9, 2)), Color("#f7fbf9"))
		SEASON_SUMMER:
			for x in range(8, int(size.x), 18):
				draw_rect(Rect2(top_left + Vector2(x, -3), Vector2(2, 4)), Color("#6f9b56"))
				draw_rect(Rect2(top_left + Vector2(x + 3, -2), Vector2(2, 3)), Color("#5f864b"))
		_:
			for x in range(9, int(size.x), 24):
				draw_rect(Rect2(top_left + Vector2(x, -3), Vector2(2, 4)), Color("#74a957"))
				draw_rect(Rect2(top_left + Vector2(x + 4, -2), Vector2(2, 3)), Color("#63934e"))
				draw_rect(Rect2(top_left + Vector2(x + 9, -4), Vector2(2, 2)), colors["flower_a"])
				draw_rect(Rect2(top_left + Vector2(x + 11, -3), Vector2(2, 2)), colors["flower_b"])

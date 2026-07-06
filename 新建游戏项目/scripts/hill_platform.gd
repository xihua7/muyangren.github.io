class_name HillPlatform
extends StaticBody2D

const GRASS := Color("#6f8c61")
const GRASS_DARK := Color("#536d4c")
const DIRT := Color("#68705a")
const DIRT_DARK := Color("#4f5749")
const STONE := Color("#737a68")

var size := Vector2(64, 16)

func setup(rect: Rect2) -> void:
	position = rect.position + rect.size * 0.5
	size = rect.size

	var shape := RectangleShape2D.new()
	shape.size = size

	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	queue_redraw()

func _draw() -> void:
	var top_left := -size * 0.5

	draw_rect(Rect2(top_left, size), DIRT)
	draw_rect(Rect2(top_left, Vector2(size.x, 5)), GRASS)
	draw_rect(Rect2(top_left + Vector2(0, 5), Vector2(size.x, 2)), GRASS_DARK)
	draw_rect(Rect2(top_left + Vector2(0, size.y - 3), Vector2(size.x, 3)), DIRT_DARK)

	var pebble_y := top_left.y + 9
	for x in range(6, int(size.x), 22):
		draw_rect(Rect2(top_left + Vector2(x, pebble_y), Vector2(4, 3)), STONE)

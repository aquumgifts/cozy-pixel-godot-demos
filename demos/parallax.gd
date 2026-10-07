extends Node2D
const DIR := "res://cozy-space-backdrops/backgrounds/1x/"


func add_layer(file: String, tile: int, speed: float) -> void:
	var layer := Parallax2D.new()
	layer.repeat_size = Vector2(tile, tile)
	layer.autoscroll = Vector2(-speed, 0)
	var s := Sprite2D.new()
	s.texture = load(DIR + file)
	s.centered = false
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(0, 0, 640 + tile * 2, 360 + tile * 2)
	s.position = Vector2(-tile, -tile)
	layer.add_child(s)
	add_child(layer)


func _ready() -> void:
	add_layer("stars-far-tile.png", 128, 6)
	add_layer("stars-mid-tile.png", 128, 14)
	add_layer("stars-near-tile.png", 128, 30)

extends Node2D
const IN := "res://cozy-space-interiors/tiles/1x/"
const FU := "res://cozy-space-furniture/furniture/1x/"
const CREW := "res://cozy-space-tiny-crew/sheets/1x/"
const WALK: Array[int] = [0, 1, 2, 1]
var world := Node2D.new()
var crew := Sprite2D.new()
var row := 0
var t := 0.0


func _ready() -> void:
	scale = Vector2(2, 2)
	tile(IN + "floor-steel.png", Rect2(0, 32, 192, 112))
	tile(IN + "wall.png", Rect2(0, 0, 192, 32))
	world.y_sort_enabled = true
	add_child(world)
	prop("bed", Vector2(16, 80))
	prop("desk", Vector2(96, 64))
	prop("locker", Vector2(160, 64))
	prop("tallplant", Vector2(16, 144))
	prop("console", Vector2(128, 128))
	crew.texture = load(CREW + "tiny-engineer.png")
	crew.hframes = 3
	crew.vframes = 4
	crew.offset = Vector2(0, -8)
	crew.position = Vector2(96, 112)
	world.add_child(crew)


func tile(path: String, area: Rect2) -> void:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_repeat = TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, area.size)
	s.centered = false
	s.position = area.position
	add_child(s)


func prop(id: String, feet: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load(FU + "furniture-%s.png" % id)
	s.centered = false
	s.offset = Vector2(0, -s.texture.get_height())
	s.position = feet
	world.add_child(s)


func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right",
			"ui_up", "ui_down")
	crew.position += dir * 48.0 * delta
	var col := 1
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			row = 2 if dir.x > 0 else 1
		else:
			row = 0 if dir.y > 0 else 3
		t += delta * 8.0
		col = WALK[int(t) % 4]
	crew.frame = row * 3 + col

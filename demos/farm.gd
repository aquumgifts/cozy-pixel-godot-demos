extends Node2D
const DIR := "res://cozy-farm/"
const SPEED := 60.0
const SOIL := "tiles/1x/tile-soil-c.png"
const CARROT := "crops/1x/carrot-stages.png"
const WALK: Array[int] = [0, 1, 2, 1]
# sheet rows: 0 down, 1 left, 2 right, 3 up
const STEP := [Vector2(0, 12), Vector2(-12, 0),
		Vector2(12, 0), Vector2(0, -12)]
var farmer := Sprite2D.new()
var row := 0
var t := 0.0
var crops := {}
var harvested := 0


func tex(path: String) -> Texture2D:
	return load(DIR + path)


func _ready() -> void:
	var grass := Sprite2D.new()
	grass.texture = tex("tiles/1x/tile-grass-1.png")
	grass.texture_repeat = TEXTURE_REPEAT_ENABLED
	grass.region_enabled = true
	grass.region_rect = Rect2(0, 0, 640, 368)
	grass.centered = false
	add_child(grass)
	farmer.texture = tex("characters/1x/farmer.png")
	farmer.hframes = 3
	farmer.vframes = 4
	farmer.frame = 1
	farmer.position = Vector2(320, 180)
	farmer.z_index = 1
	add_child(farmer)


func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right",
			"ui_up", "ui_down")
	farmer.position += dir * SPEED * delta
	var col := 1
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			row = 2 if dir.x > 0 else 1
		else:
			row = 0 if dir.y > 0 else 3
		t += delta * 8.0
		col = WALK[int(t) % 4]
	farmer.frame = row * 3 + col
	for cell in crops:
		var c: Dictionary = crops[cell]
		c.age += delta
		c.crop.frame = mini(int(c.age / 3.0), 3)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept"):
		use()


func ahead() -> Vector2i:
	var p: Vector2 = farmer.position + STEP[row]
	return Vector2i((p / 16.0).floor())


func use() -> void:
	var cell := ahead()
	if not crops.has(cell):
		var soil := put(SOIL, cell)
		var crop := put(CARROT, cell)
		crop.hframes = 4
		crops[cell] = {"soil": soil, "crop": crop,
				"age": 0.0}
	elif crops[cell].crop.frame == 3:
		crops[cell].crop.queue_free()
		crops[cell].soil.queue_free()
		crops.erase(cell)
		harvested += 1
		print("Carrots harvested: ", harvested)


func put(path: String, cell: Vector2i) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex(path)
	s.centered = false
	s.position = Vector2(cell * 16)
	add_child(s)
	return s

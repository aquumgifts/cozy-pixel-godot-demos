extends Node2D
## Fishing minigame: walk to the end of the dock,
## cast, wait for the bite and press Space in time.

const FARM := "res://cozy-farm/"
const FISHING := "res://cozy-farm-fishing/"
const GRASS := FARM + "tiles/1x/tile-grass-1.png"
const FARMER := FARM + "characters/1x/farmer.png"
const WATER := FARM + "tiles/1x/tile-water-%s%s.png"
const FRAMES := ["", "-frame2", "-frame3"]
const PLANK := FISHING + "dock/1x/dock-%s-%s.png"
const FISH_PNG := FISHING + "fish/1x/%s.png"
const FISH := ["carp", "trout"]
const LILY := FISHING + "pond/1x/lily-pad.png"
const FLOWERS := FARM + "props/1x/flowers.png"
const DECOR := [
	[FARM + "trees/1x/pine.png", Vector2(6, 4)],
	[FARM + "trees/1x/oak.png", Vector2(262, 18)],
	[FARM + "props/1x/bush.png", Vector2(112, 50)],
	[FLOWERS, Vector2(52, 58)],
	[FLOWERS, Vector2(214, 30)],
	[LILY, Vector2(72, 112)],
	[LILY, Vector2(236, 138)],
]
const POND := Rect2i(2, 5, 16, 6)
const LAND := Rect2(8, 8, 304, 66)
const DOCK := Rect2(154, 60, 12, 73)
const SPEED := 50.0
const WALK: Array[int] = [0, 1, 2, 1]
enum { WALKING, WAITING, BITE, SHOWING }

var state := WALKING
var timer := 0.0
var clock := 0.0
var frame := 0
var row := 0
var step := 0.0
var caught := 0
var water: Array[Sprite2D] = []
var farmer := Sprite2D.new()
var line := Line2D.new()
var bobber := ColorRect.new()
var spot := Vector2.ZERO
var label := Label.new()


func _ready() -> void:
	scale = Vector2(2, 2)
	var grass := sprite(GRASS, Vector2.ZERO)
	grass.texture_repeat = TEXTURE_REPEAT_ENABLED
	grass.region_enabled = true
	grass.region_rect = Rect2(0, 0, 320, 192)
	for y in range(POND.position.y, POND.end.y):
		for x in range(POND.position.x, POND.end.x):
			var p := piece(x, y)
			var at := Vector2(x, y) * 16
			var w := sprite(WATER % [p, ""], at)
			w.set_meta("piece", p)
			water.append(w)
	for d in DECOR:
		sprite(d[0], d[1])
	for y in range(4, 9):
		var kind := "end" if y == 8 else "side"
		var w := Vector2(144, y * 16)
		var e := Vector2(160, y * 16)
		sprite(PLANK % [kind, "w"], w)
		sprite(PLANK % [kind, "e"], e)
	farmer.texture = load(FARMER)
	farmer.hframes = 3
	farmer.vframes = 4
	farmer.frame = 1
	farmer.position = Vector2(72, 40)
	add_child(farmer)
	line.width = 1.0
	line.default_color = Color("f4f1e8")
	bobber.size = Vector2(2, 2)
	bobber.color = Color("e4533d")
	add_child(line)
	add_child(bobber)
	line.hide()
	bobber.hide()
	var ui := CanvasLayer.new()
	add_child(ui)
	label.position = Vector2(16, 12)
	label.label_settings = LabelSettings.new()
	label.label_settings.shadow_color = Color.BLACK
	ui.add_child(label)


func sprite(path: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.centered = false
	s.position = pos
	add_child(s)
	return s


# Which of the 9 autotile pieces goes at (x, y):
# "nw", "n", "ne", "w", "c", "e", "sw", "s", "se".
func piece(x: int, y: int) -> String:
	var p := ""
	if y == POND.position.y:
		p = "n"
	elif y == POND.end.y - 1:
		p = "s"
	if x == POND.position.x:
		p += "w"
	elif x == POND.end.x - 1:
		p += "e"
	return p if p != "" else "c"


func _process(delta: float) -> void:
	animate_water(delta)
	timer -= delta
	match state:
		WALKING:
			walk(delta)
		WAITING:
			bob(sin(clock * 4.0))
			if timer <= 0.0:
				bite()
		BITE:
			if timer <= 0.0:
				reel(false)
		SHOWING:
			if timer <= 0.0:
				state = WALKING


func animate_water(delta: float) -> void:
	clock += delta
	var f := int(clock * 3.0) % 3
	if f == frame:
		return
	frame = f
	for w in water:
		var p: String = w.get_meta("piece")
		w.texture = load(WATER % [p, FRAMES[f]])


func walk(delta: float) -> void:
	var dir := Input.get_vector("ui_left",
			"ui_right", "ui_up", "ui_down")
	var p := farmer.position + dir * SPEED * delta
	if LAND.has_point(p) or DOCK.has_point(p):
		farmer.position = p
	var col := 1
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			row = 2 if dir.x > 0 else 1
		else:
			row = 0 if dir.y > 0 else 3
		step += delta * 8.0
		col = WALK[int(step) % 4]
	farmer.frame = row * 3 + col
	label.text = "Space: cast" if at_end() else ""


func at_end() -> bool:
	return farmer.position.y > 120


func _unhandled_input(e: InputEvent) -> void:
	if not e.is_action_pressed("ui_accept"):
		return
	if state == WALKING and at_end():
		cast()
	elif state == WAITING:
		reel(false)
	elif state == BITE:
		reel(true)


func cast() -> void:
	state = WAITING
	timer = randf_range(1.5, 4.0)
	row = 0
	farmer.frame = 1
	var hand := farmer.position + Vector2(5, 3)
	spot = farmer.position + Vector2(14, 26)
	line.points = PackedVector2Array([hand, spot])
	bob(0.0)
	line.show()
	bobber.show()
	label.text = "Wait for a bite..."


func bob(dy: float) -> void:
	bobber.position = spot + Vector2(0, roundf(dy))
	line.set_point_position(1, bobber.position)


func bite() -> void:
	state = BITE
	timer = 0.7
	bob(3.0)
	label.text = "Bite! Press Space!"


func reel(got_it: bool) -> void:
	state = SHOWING
	timer = 2.0
	line.hide()
	bobber.hide()
	if not got_it:
		label.text = "It got away..."
		return
	var fish: String = FISH.pick_random()
	caught += 1
	var msg := "You caught a %s! (%d)"
	label.text = msg % [fish, caught]
	var s := sprite(FISH_PNG % fish, spot)
	var top := farmer.position + Vector2(-8, -26)
	var tw := create_tween()
	tw.tween_property(s, "position", top, 0.35)
	tw.tween_interval(1.4)
	tw.tween_callback(s.queue_free)

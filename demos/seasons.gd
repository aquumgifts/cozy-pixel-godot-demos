extends Node2D
## Season swap: the same little farm in summer,
## autumn and winter. Space fades to the next one.

const FARM := "res://cozy-farm/"
const FALL := "res://cozy-farm-seasons/autumn/"
const SNOW := "res://cozy-farm-seasons/winter/"
const UI := "res://cozy-farm-ui/"
const ICON := UI + "icons/2x/season-%s.png"
const CROPS := FARM + "crops/1x/"
const NAMES := ["summer", "autumn", "winter"]
# Each kind of sprite: [summer, autumn, winter].
const ART := {
	"grass": [
		FARM + "tiles/1x/tile-grass-%d.png",
		FALL + "tiles/1x/autumn-grass-%d.png",
		SNOW + "tiles/1x/snow-%d.png",
	],
	"path": [
		FARM + "tiles/1x/tile-path-%s.png",
		FALL + "tiles/1x/path-%s.png",
		SNOW + "tiles/1x/path-%s.png",
	],
	"soil": [
		FARM + "tiles/1x/tile-soil-%s.png",
		FALL + "tiles/1x/soil-%s.png",
		SNOW + "tiles/1x/snowy-soil-%s.png",
	],
	"water": [
		FARM + "tiles/1x/tile-water-%s.png",
		FALL + "tiles/1x/water-%s.png",
		SNOW + "tiles/1x/ice-%s.png",
	],
	"crop": [
		CROPS + "cabbage/cabbage-4-ready.png",
		CROPS + "pumpkin/pumpkin-4-ready.png",
		"",
	],
	"house": [
		FARM + "buildings/1x/farmhouse.png",
		FARM + "buildings/1x/farmhouse.png",
		SNOW + "buildings/1x/snowy-farmhouse.png",
	],
	"tree": [
		FARM + "trees/1x/oak.png",
		FALL + "trees/1x/maple.png",
		SNOW + "trees/1x/bare-oak.png",
	],
	"pine": [
		FARM + "trees/1x/pine.png",
		FARM + "trees/1x/pine.png",
		SNOW + "trees/1x/snowy-pine.png",
	],
	"bush": [
		FARM + "props/1x/bush.png",
		FALL + "props/1x/autumn-bush.png",
		SNOW + "props/1x/snowy-bush.png",
	],
	"scarecrow": [
		FARM + "props/1x/scarecrow.png",
		FARM + "props/1x/scarecrow.png",
		SNOW + "props/1x/snowy-scarecrow.png",
	],
	"decor": [
		FARM + "props/1x/hay-bale.png",
		FALL + "props/1x/leaf-pile.png",
		SNOW + "props/1x/snowman.png",
	],
}
# Ground areas in tiles, as 9-piece autotiles.
const GROUND := [
	["soil", Rect2i(11, 1, 7, 5)],
	["path", Rect2i(-1, 7, 22, 2)],
	["water", Rect2i(1, 9, 6, 4)],
]
# Sprites on top, by top-left corner in pixels.
const THINGS := [
	["pine", Vector2(290, 0)],
	["house", Vector2(40, 64)],
	["tree", Vector2(108, 38)],
	["bush", Vector2(150, 92)],
	["scarecrow", Vector2(224, 34)],
	["tree", Vector2(280, 138)],
	["decor", Vector2(196, 148)],
]

var season := 0
var farm: CanvasGroup
var icon := TextureRect.new()
var label := Label.new()


func _ready() -> void:
	scale = Vector2(2, 2)
	farm = build()
	add_child(farm)
	var ui := CanvasLayer.new()
	add_child(ui)
	icon.position = Vector2(12, 12)
	ui.add_child(icon)
	label.position = Vector2(52, 18)
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 20
	label.label_settings.shadow_color = Color.BLACK
	ui.add_child(label)
	show_name()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_accept"):
		swap()


func swap() -> void:
	season = (season + 1) % NAMES.size()
	var next := build()
	next.modulate.a = 0.0
	add_child(next)
	var tw := create_tween()
	tw.tween_property(next, "modulate:a", 1.0, 1.5)
	tw.tween_callback(farm.queue_free)
	farm = next
	show_name()


func show_name() -> void:
	var n: String = NAMES[season]
	label.text = n.capitalize()
	icon.texture = load(ICON % n)


func art(kind: String) -> String:
	return ART[kind][season]


# One whole season of the farm in a CanvasGroup,
# so it can fade in as a single picture.
func build() -> CanvasGroup:
	var group := CanvasGroup.new()
	for c in cells(Rect2i(0, 0, 20, 12)):
		var n := hash(c) % 3 + 1
		var at := Vector2(c * 16)
		put(group, art("grass") % n, at)
	for g in GROUND:
		for c in cells(g[1]):
			var p := piece(g[1], c)
			var at := Vector2(c * 16)
			put(group, art(g[0]) % p, at)
	if art("crop") != "":
		var field: Rect2i = GROUND[0][1].grow(-1)
		for c in cells(field):
			put(group, art("crop"), Vector2(c * 16))
	for t in THINGS:
		put(group, art(t[0]), t[1])
	return group


func put(group: Node, path: String,
		pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.centered = false
	s.position = pos
	group.add_child(s)


# Every tile cell inside a rectangle.
func cells(r: Rect2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			out.append(Vector2i(x, y))
	return out


# Which of the 9 autotile pieces goes at cell c
# of the area r: "nw", "n", "ne", "w", "c", "e"...
func piece(r: Rect2i, c: Vector2i) -> String:
	var p := ""
	if c.y == r.position.y:
		p = "n"
	elif c.y == r.end.y - 1:
		p = "s"
	if c.x == r.position.x:
		p += "w"
	elif c.x == r.end.x - 1:
		p += "e"
	return p if p != "" else "c"

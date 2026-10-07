extends Node2D
## Village shop: walk to the general store, press
## Space to go in, buy things with your coins.

const VIL := "res://cozy-farm-village/"
const UI := "res://cozy-farm-ui/"
const FARM := "res://cozy-farm/"
const GRASS := FARM + "tiles/1x/tile-grass-1.png"
const FARMER := FARM + "characters/1x/farmer.png"
const ITEM := FARM + "items/2x/%s.png"
const COBBLE := VIL + "tiles/1x/cobble-%s.png"
const HOUSES := VIL + "buildings/1x/"
const PROPS := VIL + "props/1x/"
const VILLAGER := VIL + "characters/1x/florist.png"
const PANEL := UI + "panels/2x/panel-%s.png"
const BUTTON := UI + "buttons/2x/button-%s-%s.png"
const SLOT := UI + "slots/2x/slot-normal.png"
const COIN := UI + "icons/2x/coin.png"
const BROWN := Color("5b3a24")
const TOWN := [
	[HOUSES + "general-store.png", Vector2(24, 32)],
	[HOUSES + "bakery.png", Vector2(104, 32)],
	[HOUSES + "cottage-blue.png", Vector2(172, 48)],
	[HOUSES + "inn.png", Vector2(240, 16)],
	[PROPS + "lamppost.png", Vector2(90, 64)],
	[PROPS + "lamppost.png", Vector2(222, 64)],
	[PROPS + "flower-bed.png", Vector2(40, 140)],
	[PROPS + "bench.png", Vector2(140, 140)],
	[PROPS + "crate-apples.png", Vector2(236, 140)],
]
# [name, icon, price]. 50 coins buy at most 10 seed
# bags, so the 10 bag slots never run out.
const ITEMS := [
	["Seed bag", "seed-bag", 5],
	["Bread", "bread", 12],
	["Honey", "honey", 20],
	["Watering can", "watering-can", 30],
]
const DOOR := Vector2(56, 104)
const SPEED := 60.0
const WALK: Array[int] = [0, 1, 2, 1]

var coins := 50
var bought := 0
var row := 0
var step := 0.0
var farmer := Sprite2D.new()
var shade := ColorRect.new()
var bag := HBoxContainer.new()
var coin_label: Label
var tip: Label
var message: Label
var first_buy: Button


func _ready() -> void:
	scale = Vector2(2, 2)
	build_town()
	build_ui()


func build_town() -> void:
	strip(GRASS, 0, 192)
	strip(COBBLE % "n", 96, 16)
	strip(COBBLE % "s", 112, 16)
	for t in TOWN:
		sprite(t[0], t[1])
	var npc := sprite(VILLAGER, Vector2(196, 100))
	npc.hframes = 3
	npc.vframes = 4
	npc.frame = 1
	farmer.texture = load(FARMER)
	farmer.hframes = 3
	farmer.vframes = 4
	farmer.frame = 1
	farmer.position = Vector2(150, 110)
	add_child(farmer)


func build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	# The shop window, hidden until you go in.
	shade.color = Color(0, 0, 0, 0.4)
	shade.size = Vector2(640, 360)
	shade.hide()
	ui.add_child(shade)
	var shop := panel("parchment", Vector2(150, 16),
			Vector2(440, 250))
	shade.add_child(shop)
	var title := text("General Store", 20, BROWN)
	title.position = Vector2(28, 22)
	shop.add_child(title)
	var leave := button("Leave", "wood")
	leave.position = Vector2(316, 20)
	leave.pressed.connect(close_shop)
	shop.add_child(leave)
	var box := VBoxContainer.new()
	box.position = Vector2(28, 62)
	box.add_theme_constant_override("separation", 6)
	shop.add_child(box)
	for item in ITEMS:
		box.add_child(shop_row(item))
	message = text("", 16, BROWN)
	message.position = Vector2(28, 214)
	shop.add_child(message)
	# Coins, top left.
	var purse := panel("dark", Vector2(12, 12),
			Vector2(136, 64))
	ui.add_child(purse)
	var coin := TextureRect.new()
	coin.texture = load(COIN)
	coin.position = Vector2(18, 16)
	purse.add_child(coin)
	coin_label = text(str(coins), 20, Color.WHITE)
	coin_label.position = Vector2(58, 18)
	purse.add_child(coin_label)
	# The bag: 10 slots along the bottom.
	var bar := panel("dark", Vector2(99, 274),
			Vector2(442, 64))
	ui.add_child(bar)
	bag.position = Vector2(12, 12)
	bag.add_theme_constant_override("separation", 2)
	bar.add_child(bag)
	for i in 10:
		var slot := TextureRect.new()
		slot.texture = load(SLOT)
		bag.add_child(slot)
	tip = text("", 16, Color.WHITE)
	tip.position = Vector2(164, 30)
	tip.label_settings.shadow_color = Color.BLACK
	ui.add_child(tip)


func shop_row(item: Array) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 8)
	var icon := TextureRect.new()
	icon.texture = load(ITEM % item[1])
	r.add_child(icon)
	var what := text(item[0], 16, BROWN)
	what.custom_minimum_size.x = 130
	r.add_child(what)
	var coin := TextureRect.new()
	coin.texture = load(COIN)
	r.add_child(coin)
	var price := text(str(item[2]), 16, BROWN)
	price.custom_minimum_size.x = 36
	r.add_child(price)
	var buy := button("Buy", "green")
	buy.pressed.connect(purchase.bind(item))
	r.add_child(buy)
	if first_buy == null:
		first_buy = buy
	return r


func _process(delta: float) -> void:
	if shade.visible:
		return
	walk(delta)
	tip.text = ""
	if at_door():
		tip.text = "Space: enter the shop"


func walk(delta: float) -> void:
	var dir := Input.get_vector("ui_left",
			"ui_right", "ui_up", "ui_down")
	var p := farmer.position + dir * SPEED * delta
	farmer.position = p.clamp(Vector2(8, 102),
			Vector2(312, 122))
	var col := 1
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			row = 2 if dir.x > 0 else 1
		else:
			row = 0 if dir.y > 0 else 3
		step += delta * 8.0
		col = WALK[int(step) % 4]
	farmer.frame = row * 3 + col


func at_door() -> bool:
	return farmer.position.distance_to(DOOR) < 14


func _unhandled_input(e: InputEvent) -> void:
	if shade.visible or not at_door():
		return
	if e.is_action_pressed("ui_accept"):
		open_shop()


func open_shop() -> void:
	farmer.hide()
	tip.text = ""
	shade.show()
	first_buy.grab_focus()


func close_shop() -> void:
	shade.hide()
	message.text = ""
	farmer.show()
	farmer.frame = 1
	row = 0


func purchase(item: Array) -> void:
	var price: int = item[2]
	if coins < price:
		message.text = "Not enough coins!"
		coin_label.modulate = Color.RED
		create_tween().tween_property(coin_label,
				"modulate", Color.WHITE, 0.6)
		return
	coins -= price
	coin_label.text = str(coins)
	message.text = "%s added to your bag." % item[0]
	var icon := TextureRect.new()
	icon.texture = load(ITEM % item[1])
	icon.position = Vector2(4, 4)
	bag.get_child(bought).add_child(icon)
	bought += 1


func sprite(path: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.centered = false
	s.position = pos
	add_child(s)
	return s


# A texture repeated across the screen, h px tall.
func strip(path: String, y: int, h: int) -> void:
	var s := sprite(path, Vector2(0, y))
	s.texture_repeat = TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(0, 0, 320, h)


# A 9-slice panel: the 32 px corners never stretch.
func panel(kind: String, pos: Vector2,
		size: Vector2) -> NinePatchRect:
	var p := NinePatchRect.new()
	p.texture = load(PANEL % kind)
	p.patch_margin_left = 32
	p.patch_margin_top = 32
	p.patch_margin_right = 32
	p.patch_margin_bottom = 32
	p.position = pos
	p.size = size
	return p


func text(s: String, px: int, c: Color) -> Label:
	var l := Label.new()
	l.text = s
	l.label_settings = LabelSettings.new()
	l.label_settings.font_size = px
	l.label_settings.font_color = c
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


func button(s: String, color: String) -> Button:
	var b := Button.new()
	b.text = s
	b.custom_minimum_size = Vector2(96, 32)
	for state in ["normal", "hover", "pressed"]:
		var look := StyleBoxTexture.new()
		look.texture = load(BUTTON % [color, state])
		b.add_theme_stylebox_override(state, look)
	b.add_theme_stylebox_override("focus",
			b.get_theme_stylebox("hover"))
	return b

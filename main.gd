extends Node2D
## Menu: the parallax demo as the background, one button per demo,
## and links to the free packs the art comes from.

const COMPLETE := "https://aquumgifts.itch.io/cozy-space-complete"
const STORE := "https://aquumgifts.itch.io"
const UI := "res://cozy-space-icons-ui/ui/2x/"
const DEMOS := [
	["Parallax starfield", "parallax"],
	["Ship: fly, shoot, explode", "ship"],
	["Platformer astronaut", "astronaut"],
	["Tiny farming loop", "farm"],
	["Pixel HUD", "hud"],
	["Top-down room", "room"],
]


func _ready() -> void:
	var bg: Node2D = load("res://demos/parallax.tscn").instantiate()
	bg.get_node("Planet").position = Vector2(560, 70)
	add_child(bg)
	var ui := CanvasLayer.new()
	add_child(ui)

	var title := label("Cozy Pixel Demos", 32)
	title.position = Vector2(24, 18)
	ui.add_child(title)
	var sub := label("Six one-script Godot 4 demos · free pixel art by Bramble & Byte", 12)
	sub.position = Vector2(26, 60)
	sub.modulate = Color("c9b8ff")
	ui.add_child(sub)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(24, 96)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	ui.add_child(grid)
	for d in DEMOS:
		var b := button(d[0], Vector2(232, 40))
		b.pressed.connect(func(): get_tree().change_scene_to_file("res://demos/%s.tscn" % d[1]))
		grid.add_child(b)
	(grid.get_child(0) as Button).grab_focus()

	var note := label("Art: free packs by Bramble & Byte on itch.io (CC-BY 4.0 in this project)", 11)
	note.position = Vector2(26, 266)
	note.modulate = Color("c9b8ff")
	ui.add_child(note)

	var links := HBoxContainer.new()
	links.position = Vector2(24, 290)
	links.add_theme_constant_override("separation", 12)
	ui.add_child(links)
	var all := button("Every Cozy Space pack: Complete »", Vector2(300, 40), true)
	all.pressed.connect(OS.shell_open.bind(COMPLETE))
	links.add_child(all)
	var more := button("More free packs »", Vector2(164, 40))
	more.pressed.connect(OS.shell_open.bind(STORE))
	links.add_child(more)


func label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_shadow_color", Color("2a1f4a"))
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


func button(text: String, size: Vector2, gold := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = size
	b.add_theme_font_size_override("font_size", 13)
	for state in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxTexture.new()
		s.texture = load(UI + "panel-dark.png")
		s.set_texture_margin_all(8)
		if state != "normal":
			s.modulate_color = Color(1.35, 1.35, 1.6)
		b.add_theme_stylebox_override(state, s)
	b.add_theme_color_override("font_color", Color("ffd27a") if gold else Color("f2ecff"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_focus_color", Color("ffffff"))
	return b

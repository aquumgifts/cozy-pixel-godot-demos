extends CanvasLayer
## Autoload: shows the controls of the running demo and goes back
## to the menu on Esc. The demo scripts stay exactly as in the tutorials.

const MENU := "res://main.tscn"
const HINTS := {
	"parallax": "Three star layers scrolling at different speeds, and a turning planet",
	"ship": "Arrows: move · Space: fire · X: explosion",
	"astronaut": "Arrows: run · Space: jump",
	"farm": "Arrows: walk · Space: plant a carrot, then harvest it when it is ripe",
	"hud": "Oxygen drains on its own · click the button to refill it",
	"room": "Arrows: walk around the furniture (y-sorted)",
}

var hint := Label.new()


func _ready() -> void:
	layer = 100
	hint.position = Vector2(8, 340)
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint.add_theme_constant_override("shadow_offset_y", 1)
	add_child(hint)
	get_tree().scene_changed.connect(_update)
	_update.call_deferred()


func _update() -> void:
	var scene := get_tree().current_scene
	var demo := scene.scene_file_path.get_file().get_basename() if scene else ""
	hint.visible = HINTS.has(demo)
	if hint.visible:
		hint.text = "Esc: menu · " + HINTS[demo]


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel") and hint.visible:
		get_tree().change_scene_to_file(MENU)

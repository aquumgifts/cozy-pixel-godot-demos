extends CanvasLayer
const DIR := "res://cozy-space-icons-ui/"
const UI := DIR + "ui/2x/"
const ICONS := DIR + "icons/2x/"
var oxygen := TextureProgressBar.new()


func _ready() -> void:
	var panel := NinePatchRect.new()
	panel.texture = load(UI + "panel-dark.png")
	panel.patch_margin_left = 8
	panel.patch_margin_top = 8
	panel.patch_margin_right = 8
	panel.patch_margin_bottom = 8
	panel.position = Vector2(12, 12)
	panel.size = Vector2(160, 56)
	add_child(panel)
	var icon := TextureRect.new()
	icon.texture = load(ICONS + "icon-oxygen.png")
	icon.position = Vector2(12, 12)
	panel.add_child(icon)
	var bar := UI + "bar-"
	var frame: Texture2D = load(bar + "frame.png")
	var fill: Texture2D = load(bar + "fill-teal.png")
	oxygen.texture_under = frame
	oxygen.texture_progress = fill
	oxygen.texture_progress_offset = Vector2(2, 2)
	oxygen.max_value = 100
	oxygen.step = 0.0
	oxygen.value = 100
	oxygen.position = Vector2(52, 20)
	panel.add_child(oxygen)
	var button := TextureButton.new()
	var b := UI + "button-teal-"
	button.texture_normal = load(b + "normal.png")
	button.texture_hover = load(b + "hover.png")
	button.texture_pressed = load(b + "pressed.png")
	button.position = Vector2(12, 76)
	button.pressed.connect(refill)
	add_child(button)


func _process(delta: float) -> void:
	oxygen.value -= 6.0 * delta


func refill() -> void:
	oxygen.value = oxygen.max_value

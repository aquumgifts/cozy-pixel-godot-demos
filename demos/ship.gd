extends Node2D
const DIR := "res://cozy-space-ships/"
const SPEED := 120.0
const LO := Vector2(12, 16)
const HI := Vector2(628, 344)
const LASER := "projectiles/1x/laser-teal.png"
const BOOM := "explosions/1x/explosion-32-8f.png"
var ship := Sprite2D.new()
var lasers: Array[Sprite2D] = []
var t := 0.0
var cooldown := 0.0


func tex(path: String) -> Texture2D:
	return load(DIR + path)


func _ready() -> void:
	var f := "ships/1x/sparrow-cream-thrust-4f.png"
	ship.texture = tex(f)
	ship.hframes = 4
	ship.position = Vector2(320, 300)
	add_child(ship)


func _process(delta: float) -> void:
	t += delta * 12.0
	ship.frame = int(t) % 4
	var dir := Input.get_vector("ui_left", "ui_right",
			"ui_up", "ui_down")
	var p := ship.position + dir * SPEED * delta
	ship.position = p.clamp(LO, HI)
	cooldown -= delta
	var fire := Input.is_action_pressed("ui_accept")
	if fire and cooldown <= 0.0:
		cooldown = 0.18
		var shot := Sprite2D.new()
		shot.texture = tex(LASER)
		shot.position = ship.position - Vector2(0, 16)
		add_child(shot)
		lasers.append(shot)
	for shot in lasers.duplicate():
		shot.position.y -= 300.0 * delta
		if shot.position.y < -10:
			lasers.erase(shot)
			shot.queue_free()


func _unhandled_input(e) -> void:
	if e is InputEventKey and e.pressed:
		if e.keycode == KEY_X:
			explode(ship.position - Vector2(0, 60))


func explode(at: Vector2) -> void:
	var sheet := tex(BOOM)
	var frames := SpriteFrames.new()
	for i in 8:
		var a := AtlasTexture.new()
		a.atlas = sheet
		a.region = Rect2(i * 32, 0, 32, 32)
		frames.add_frame("default", a)
	frames.set_animation_speed("default", 14)
	frames.set_animation_loop("default", false)
	var boom := AnimatedSprite2D.new()
	boom.sprite_frames = frames
	boom.position = at
	boom.animation_finished.connect(boom.queue_free)
	add_child(boom)
	boom.play()

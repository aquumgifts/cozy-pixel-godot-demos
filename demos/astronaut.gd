extends Node2D
const DIR := "res://cozy-space-platformer/"
const SPEED := 90.0
const JUMP := -230.0
const GRAVITY := 600.0
const ACT := "ui_accept"
var player := CharacterBody2D.new()
var anim := AnimatedSprite2D.new()


func tex(path: String) -> Texture2D:
	return load(DIR + path)


func strip(frames: SpriteFrames, id: String,
		n: int, fps: float) -> void:
	frames.add_animation(id)
	frames.set_animation_speed(id, fps)
	var file := "astronaut-%s-%df.png" % [id, n]
	var sheet := tex("characters/1x/" + file)
	for i in n:
		var a := AtlasTexture.new()
		a.atlas = sheet
		a.region = Rect2(i * 16, 0, 16, 24)
		frames.add_frame(id, a)


func _ready() -> void:
	var frames := SpriteFrames.new()
	strip(frames, "idle", 4, 6)
	strip(frames, "run", 6, 10)
	strip(frames, "jump", 1, 1)
	strip(frames, "fall", 1, 1)
	anim.sprite_frames = frames
	player.add_child(anim)
	var box := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(10, 22)
	box.shape = r
	player.add_child(box)
	player.position = Vector2(80, 200)
	add_child(player)
	add_floor(Vector2(0, 300), 40)
	add_floor(Vector2(240, 240), 6)


func add_floor(at: Vector2, tiles: int) -> void:
	var body := StaticBody2D.new()
	body.position = at
	var s := Sprite2D.new()
	s.texture = tex("tiles/1x/hull-light-n.png")
	s.texture_repeat = TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(0, 0, tiles * 16, 16)
	s.centered = false
	body.add_child(s)
	var c := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(tiles * 16, 16)
	c.shape = r
	c.position = r.size / 2
	body.add_child(c)
	add_child(body)


func _physics_process(delta: float) -> void:
	var v := player.velocity
	v.y += GRAVITY * delta
	var dir := Input.get_axis("ui_left", "ui_right")
	v.x = dir * SPEED
	var jump := Input.is_action_just_pressed(ACT)
	if jump and player.is_on_floor():
		v.y = JUMP
	player.velocity = v
	player.move_and_slide()
	if dir != 0:
		anim.flip_h = dir < 0
	if not player.is_on_floor():
		var up := player.velocity.y < 0
		anim.play("jump" if up else "fall")
	elif dir != 0:
		anim.play("run")
	else:
		anim.play("idle")

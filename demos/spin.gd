extends Sprite2D
@export var fps := 10.0
var t := 0.0


func _ready() -> void:
	hframes = 24


func _process(delta: float) -> void:
	t += delta * fps
	frame = int(t) % hframes

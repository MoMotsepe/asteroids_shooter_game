extends TextureRect
var speed = 10
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta

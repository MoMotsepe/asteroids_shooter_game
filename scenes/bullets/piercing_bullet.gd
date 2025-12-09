#piercing asteroid
extends Area2D

#bullet properties
@export var speed: float = 800.0
@export var damage: int = 15 : set = set_damage, get = get_damage
var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	#handle movement
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	#remove when off screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()

#change damage
func set_damage(value: int):
	damage = 1 if value <= 0 else value

func get_damage() -> int:
	return damage

#ice bullet
extends Area2D

#bullet properties
@export var speed: float = 400.0
@export var damage: int = 3 : set = set_damage, get = get_damage
@export var slow_factor: float = 0.5
@export var freeze_area = preload("res://scenes/bullets/freeze_area.tscn")
var direction: Vector2 = Vector2.ZERO
var start_position: Vector2

func _ready() -> void:
	start_position = position

func _process(delta: float) -> void:
	#handle movement
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta
	
	#remove when off screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	#asteroid collision
	if (area.get_collision_layer_value(2)):
		spawn_area()

#change damage
func set_damage(value: int):
	damage = 1 if value <= 0 else value

func get_damage() -> int:
	return damage

func spawn_area():
	var new_area = freeze_area.instantiate()
	new_area.position = self.position
	new_area.setDamage(damage)
	new_area.setSpeedMultiplier(slow_factor)
	get_tree().current_scene.call_deferred("add_child", new_area)
	queue_free()

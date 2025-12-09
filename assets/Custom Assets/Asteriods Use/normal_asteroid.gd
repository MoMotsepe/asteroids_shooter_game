extends Node3D
# Filename: asteroid_rotator.gd
## The speed of rotation in radians per second for each axis (X, Y, Z).
## Adjust these values in the Inspector to change the asteroid's tumble.
@export var rotation_speed: Vector3 = Vector3(0.1, 0.2, 0.05)
@export var worth = 1

# _process is called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Apply rotation to each axis based on the rotation_speed and delta.
	# Multiplying by delta makes the rotation frame-rate independent, ensuring
	# the asteroid rotates at the same speed on all computers.
	rotate_x(rotation_speed.x * delta)
	rotate_y(rotation_speed.y * delta)
	rotate_z(rotation_speed.z * delta)

#to get the currency when astriod is destroyed
func get_worth() -> int:
	return worth

#healthbar
class_name Healthbar
extends TextureProgressBar

#signals
signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted

#health properties
@export var max_health: int = 3 : set = set_max_health, get = get_max_health
@onready var health: int = max_health : set = set_health, get = get_health

#change max health
func set_max_health(input_value: int):
	#invalid input value
	var clamped_value = 0 if input_value < 0 else input_value
	
	if clamped_value != max_health:
		var difference = clamped_value - max_health
		max_health = input_value
		max_health_changed.emit(difference)
		
		#health greater than max health
		if health > max_health:
			health = max_health
	
	#set health bar
	self.max_value = get_max_health()
	self.value = get_health()

func get_max_health():
	return max_health

#change health
func set_health(input_value: int):
	var clamped_value = clamp(input_value, 0, max_health)
	
	if clamped_value != health:
		var difference = clamped_value - health
		health = input_value
		health_changed.emit(difference)
		
		#health depleted
		if health <= 0:
			health_depleted.emit()
	
	self.value = get_health()

func get_health():
	return health

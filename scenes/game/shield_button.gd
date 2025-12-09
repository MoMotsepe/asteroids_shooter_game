extends TextureButton

@onready var shield_sound: AudioStreamPlayer2D = $"../ShieldSound"
var shield = preload("res://scenes/earth/shield.tscn")
signal ShieldFinished

func _on_pressed() -> void:
	self.disabled = true
	shield_sound.play()
	Currency.addCurrency(-25)
	
	var new_shield = shield.instantiate()
	new_shield.position = Vector2(961, 891)
	get_tree().current_scene.add_child(new_shield)
	new_shield.connect("tree_exited", Callable(self, "_on_shield_removed"))

func _on_shield_removed():
	ShieldFinished.emit()

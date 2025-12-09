extends TextureButton

@onready var black_hole_animation: AnimatedSprite2D = $"../BlackHoleAnimation"
@onready var black_hole_sound: AudioStreamPlayer2D = $"../BlackHoleSound"
signal BlackHoleFinished

func _on_pressed() -> void:
	self.disabled = true
	black_hole_animation.visible = true
	black_hole_animation.play()
	black_hole_sound.play()
	BlackHoleFinished.emit()
	Currency.addCurrency(-40)
	
	var asteroids = get_tree().get_nodes_in_group("Asteroids")
	for asteroid in asteroids:
		if not asteroid.is_in_group("Boss"):
			asteroid.queue_free()
		else:
			var damage = asteroid.healthbar.get_max_health() * 0.1
			var new_health = asteroid.healthbar.get_health() - int(damage)
			asteroid.healthbar.set_health(new_health)

func _on_black_hole_animation_animation_finished() -> void:
	black_hole_animation.stop()
	black_hole_animation.visible = false

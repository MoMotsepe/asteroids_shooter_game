extends TextureButton

@onready var shock_wave_sound: AudioStreamPlayer2D = $"../ShockWaveSound"
@onready var shock_wave_animation: AnimatedSprite2D = $"../ShockWaveAnimation"
@onready var speed_removal_zone: CollisionShape2D = $"../SpeedRemovalZone/CollisionShape2D"
@onready var stun_timer: Timer = $"../StunTimer"

var movement_speed: int = 200
var pushing_back: bool = false

signal ShockWaveFinished

func _on_pressed() -> void:
	self.disabled = true
	shock_wave_animation.visible = true
	shock_wave_animation.play()
	speed_removal_zone.disabled = false
	shock_wave_sound.play()
	pushing_back = true
	Currency.addCurrency(-20)

func _process(delta: float) -> void:
	if pushing_back:
		var asteroids = get_tree().get_nodes_in_group("Asteroids")
		var still_moving: bool = false
		
		for asteroid in asteroids:
			if asteroid.position.y > 400:
				asteroid.position.y -= movement_speed * delta
				still_moving = true
		
		if not still_moving:
			pushing_back = false
			stun_timer.start()

func _on_stun_timer_timeout() -> void:
	speed_removal_zone.disabled = true
	ShockWaveFinished.emit()

func _on_shock_wave_animation_animation_finished() -> void:
	shock_wave_animation.stop()
	shock_wave_animation.visible = false

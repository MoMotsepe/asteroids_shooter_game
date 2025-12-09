# pushback area
extends Area2D

@export var dps: int = 0
@export var slow_factor: float = 0.001

func getDamage() -> int:
	return dps

func getSpeedMultiplier() -> float:
	return slow_factor

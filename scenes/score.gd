#score
extends Node

var currentScore: int : set = setScore, get = getScore

func setScore(score: int):
	currentScore = score

func getScore() -> int:
	return currentScore

func addScore(score: int):
	currentScore += score

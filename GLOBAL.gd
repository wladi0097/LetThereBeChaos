extends Node

var cars = []
var player = null
var road = null
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func get_random_car() -> KinematicBody:
	return cars[rng.randi_range(0, cars.size() -1)]

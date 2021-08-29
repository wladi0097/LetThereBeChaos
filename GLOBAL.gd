extends Node

var cars = []
var towers = []
var player = null
var road = null
var currentMap = null
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func get_random_car() -> KinematicBody:
	return cars[rng.randi_range(0, cars.size() -1)]

func disable_tower_ui():
	for tower in towers:
		tower.get_node("Area").visible = false
		
func unpause_cars():
	for car in cars:
		car.paused = false
		
func unpause_towers():
	for tower in towers:
		tower.paused = false

func switch_to_race():
	disable_tower_ui()
	currentMap.transition_to_car_camera()

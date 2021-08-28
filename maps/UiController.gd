extends PanelContainer

onready var baseTower = preload("res://entities/basicTower.tscn")
onready var rayCast : RayCast = $placementRayCast
onready var camera : Camera = $Camera

var hasSelectedTowerPosition = false
var towerIdToBePlaced : int = Tower.INVALID

const Tower = {
	INVALID = -1,
	Base = 0,
	MultiShot = 1,
	Spike = 2
}

func getTower(var towerID : int) -> Spatial:
	return baseTower.instance()

func _on_placeTowerButton_pressed(towerID): 
	towerIdToBePlaced = towerID

func _input(event):
	if event is InputEventMouseButton && towerIdToBePlaced != Tower.INVALID:
		var ray_length = 100
		rayCast.transform.origin = camera.project_ray_origin(event.position)
		rayCast.cast_to = rayCast.transform.origin + camera.project_ray_normal(event.position) * ray_length
		hasSelectedTowerPosition = true

func _physics_process(delta):
	if hasSelectedTowerPosition && towerIdToBePlaced != Tower.INVALID && rayCast.is_colliding() :
		var tower = getTower(towerIdToBePlaced)
		tower.transform.origin = rayCast.get_collision_point()
		get_tree().get_root().add_child(tower)
		towerIdToBePlaced = Tower.INVALID
		hasSelectedTowerPosition = false

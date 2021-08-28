extends MarginContainer

onready var baseTower : PackedScene = preload("res://entities/basicTower.tscn")
onready var multiShotTower : PackedScene = preload("res://entities/multiShotTower.tscn")
onready var spikeTower : PackedScene = preload("res://entities/spikeTower.tscn")
onready var rayCast : RayCast = $placementRayCast
onready var camera : Camera = get_parent().get_node("TopDownCamera")
onready var messageLabel : Label = $CenterContainer/MessageLabel

var hasSelectedTowerPosition = false
var towerIdToBePlaced : int = Tower.INVALID

class TowerData:
	var Ressource : PackedScene
	var Label : Label
	var Count : int
	func _init(_towerRessource : PackedScene, _count : int, _towerLabel : Label):
		self.Ressource = _towerRessource
		self.Label = _towerLabel
		self.Count = _count
		self.Label.text = "Tower Left: %d" % self.Count

const Tower = {
	INVALID = -1,
	Base = 0,
	MultiShot = 1,
	Spike = 2
}

onready var TowerDict = {
	Tower.Base     : TowerData.new( baseTower     , 4, get_node("PanelContainer/VBoxContainer/BaseTowerLabel")  ),
	Tower.MultiShot: TowerData.new( multiShotTower, 3, get_node("PanelContainer/VBoxContainer/MultiTowerLabel") ),
	Tower.Spike    : TowerData.new( spikeTower    , 6, get_node("PanelContainer/VBoxContainer/SpikeTowerLabel") ),
}

func getTower(var towerID : int) -> TowerData:
	if towerID == Tower.INVALID:
		return TowerDict[Tower.Base]
	return TowerDict[towerID]

func placeTower(towerData: TowerData, location: Vector3):
	if towerData.Count <= 0:
		messageLabel.text = "No more towers!"
		towerIdToBePlaced = Tower.INVALID
		hasSelectedTowerPosition = false
		return
	
#	var spaceState : PhysicsDirectSpaceState = get_parent().get_world().direct_space_state
#	var collidingShapes = spaceState.collide_shape()
	
	var tower = towerData.Ressource.instance()
	tower.transform.origin = location
	get_tree().get_root().add_child(tower)

	towerIdToBePlaced = Tower.INVALID
	hasSelectedTowerPosition = false
	messageLabel.text = ""
	towerData.Count -= 1;
	towerData.Label.text = "Tower Left: %d" % towerData.Count
	

func _on_placeTowerButton_pressed(towerID):
	towerIdToBePlaced = towerID

func _input(event):
	if event is InputEventMouseButton && towerIdToBePlaced != Tower.INVALID:
		var ray_length = 1000
		rayCast.transform.origin = camera.project_ray_origin(event.position)
		rayCast.cast_to = rayCast.transform.origin + camera.project_ray_normal(event.position) * ray_length
		hasSelectedTowerPosition = true

func _physics_process(delta):
	if !hasSelectedTowerPosition || towerIdToBePlaced == Tower.INVALID:
		return
		
	if rayCast.is_colliding():
		print(rayCast.get_collider().name)

	if !rayCast.is_colliding() || "Area" in rayCast.get_collider().name:
		messageLabel.text = "Invalid location!"
		return

	placeTower(getTower(towerIdToBePlaced), rayCast.get_collision_point())

func isValidTowerPlacement(placementVec: Vector3) -> bool:
	return true

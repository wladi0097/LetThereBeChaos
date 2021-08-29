extends MarginContainer

onready var baseTower : PackedScene = preload("res://entities/basicTower.tscn")
onready var multiShotTower : PackedScene = preload("res://entities/multiShotTower.tscn")
onready var spikeTower : PackedScene = preload("res://entities/spikeTower.tscn")
onready var rayCast : RayCast = $placementRayCast
onready var camera : Camera = get_parent().get_node("TopDownCamera")
onready var messageLabel : Label = $CenterContainer/MessageLabel
onready var startButton : Button = $CenterContainer2/VBoxContainer/StartButton

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
		self.Label.text = "Left: %d" % self.Count

const Tower = {
	INVALID = -1,
	Base = 0,
	MultiShot = 1,
	Spike = 2
}

onready var TowerDict = {
	Tower.Base     : TowerData.new( baseTower     , 3, get_node("PanelContainer/VBoxContainer/BaseTowerLabel")  ),
	Tower.MultiShot: TowerData.new( multiShotTower, 3, get_node("PanelContainer/VBoxContainer/MultiTowerLabel") ),
	Tower.Spike    : TowerData.new( spikeTower    , 3, get_node("PanelContainer/VBoxContainer/SpikeTowerLabel") ),
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
	
	var tower = towerData.Ressource.instance()
	tower.transform.origin = location
	get_tree().get_root().add_child(tower)

	#towerIdToBePlaced = Tower.INVALID
	hasSelectedTowerPosition = false
	messageLabel.text = ""
	towerData.Count -= 1;
	towerData.Label.text = "Left: %d" % towerData.Count
	

func _on_placeTowerButton_pressed(towerID):
	towerIdToBePlaced = towerID
	
func prepareRayCast():
	var ray_length = 1000
	var position2D = get_global_mouse_position()
	rayCast.transform.origin = camera.project_ray_origin(position2D)
	rayCast.cast_to = camera.project_ray_normal(position2D) * ray_length

func haveAllTowersBeenPlaced() -> bool:
	for towerDictEntry in TowerDict:
		var towerData =  TowerDict[towerDictEntry]
		if towerData.Count > 0:
			return false
	return true

func _input(event):
	if event.is_action_pressed("left_click") && towerIdToBePlaced != Tower.INVALID:
		prepareRayCast()
		hasSelectedTowerPosition = true

func _physics_process(delta):
	if !hasSelectedTowerPosition || towerIdToBePlaced == Tower.INVALID:
		return

	if !rayCast.is_colliding() || "Area" in rayCast.get_collider().name:
		messageLabel.text = "Invalid location!"
		return

	if towerIdToBePlaced != Tower.Spike && rayCast.get_collider() == GLOBAL.road:
		messageLabel.text = "Invalid location!"
		return
	
	placeTower(getTower(towerIdToBePlaced), rayCast.get_collision_point())
	if haveAllTowersBeenPlaced():
		startButton.disabled = false

func _on_StartButton_button_down():
	GLOBAL.switch_to_race()

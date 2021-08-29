extends Spatial


onready var followCamera: Camera = $TopDown/TopDownCamera;
var playerCamera: Camera
var doTransition = false
var position_in_race := 1

func _ready():
	playerCamera = GLOBAL.player.camera
	GLOBAL.currentMap = self
	GLOBAL.road = get_node("World/road/StaticBody")
	
func _input(event):
	if event.is_action_pressed("debug1"):
		GLOBAL.unpause_cars()
	if event.is_action_pressed("debug3"):
		$TopDown/MarginContainer.visible = false
		doTransition = true
		
func transition_to_car_camera():
	doTransition = true

func _physics_process(delta):
	if doTransition:
		transition()
	pass

func transition():
	var length = playerCamera.global_transform.origin.distance_to(followCamera.global_transform.origin)
	var speed = 0.01
	
	if length < 10:
		speed = .5
		followCamera.rotation = lerp(followCamera.rotation, GLOBAL.player.rotation, 0.05)
	if length < 5:
		doTransition = false
		followCamera.current = false
		playerCamera.current = true
		GLOBAL.unpause_cars()
		GLOBAL.unpause_towers()
	
	if doTransition:
		followCamera.global_transform.origin = lerp(followCamera.global_transform.origin, playerCamera.global_transform.origin, 0.01)


func _on_FinishLine_body_entered(body):
	if "enemy" in body.name:
		position_in_race += 1
	if "Player" in body.name:
		$Finish/VBoxContainer/PositionInRace.text = "Position in race: " + String(position_in_race)
		$Finish.show()

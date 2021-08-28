extends Spatial


onready var followCamera: Camera = $TopDown/TopDownCamera;
var playerCamera: Camera
var doTransition = false

func _ready():
	playerCamera = GLOBAL.player.camera
	
func _input(event):
	if event.is_action_pressed("debug3"):
		$TopDown/MarginContainer.visible = false
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
	
	if doTransition:
		followCamera.global_transform.origin = lerp(followCamera.global_transform.origin, playerCamera.global_transform.origin, 0.01)

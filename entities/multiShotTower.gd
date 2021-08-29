extends Spatial

export var paused = true
export var shootLookDown = -0.5
onready var usedBullet: PackedScene = preload("res://entities/Bullet.tscn")
onready var shootPoint1 = $ShootPoint1
onready var shootPoint2 = $ShootPoint2
onready var shootPoint3 = $ShootPoint3
onready var shootPoint4 = $ShootPoint4

func _ready():
	GLOBAL.towers.append(self)

func _input(event):
	if event.is_action_pressed("debug2"):
		shoot()

func shoot():
	shootDirection(shootPoint1, Vector3(1, shootLookDown, 0))
	shootDirection(shootPoint2, Vector3(-1, shootLookDown, 0))
	shootDirection(shootPoint3, Vector3(0, shootLookDown, -1))
	shootDirection(shootPoint4, Vector3(0, shootLookDown, 1))
	
func shootDirection(shootPoint, direction):
	var bullet = usedBullet.instance().set_speed(5) \
		.set_bullet_direction(direction) \
		.set_start(shootPoint.global_transform.origin)
	get_tree().get_root().call_deferred("add_child", bullet)


func _on_Timer_timeout():
	if !paused:
		shoot()

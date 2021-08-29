extends Spatial

export var paused = true
onready var usedBullet: PackedScene = preload("res://entities/Bullet.tscn")
onready var shootPoint = $ShootPoint

func _ready():
	GLOBAL.towers.append(self)

func _input(event):
	if event.is_action_pressed("debug1"):
		shoot()

func shoot():
	var randomCarPosition = -GLOBAL.get_random_car().global_transform.origin.direction_to(shootPoint.global_transform.origin)
	var bullet = usedBullet.instance().set_speed(5) \
		.set_bullet_direction(randomCarPosition) \
		.set_start(shootPoint.global_transform.origin)
	get_tree().get_root().call_deferred("add_child", bullet)


func _on_Timer_timeout():
	if !paused:
		shoot()

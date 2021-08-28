extends Spatial

onready var usedBullet: PackedScene = preload("res://entities/Bullet.tscn")
onready var shootPoint = $Shootpoint

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_accept"):
		shoot()

func shoot():
	var bullet_instance = usedBullet.instance()
	bullet_instance.global_transform.origin = shootPoint.global_transform.origin
	bullet_instance.set_bullet_direction(Vector3(1, 0, 0))
	
	get_tree().get_root().call_deferred("add_child", bullet_instance)

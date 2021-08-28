extends RigidBody

var speed = 1000
var velocity = Vector3()
var direction = Vector3()
var aliveTime = 8

func _enter_tree():
	add_central_force(velocity)
	
	yield(get_tree().create_timer(aliveTime), "timeout")
	queue_free()
	
func set_speed(newSpeed: int):
	self.speed = newSpeed * 1000
	return self
	
func set_start(position: Vector3):
	self.global_transform.origin = position
	return self
	
func set_bullet_direction(newDirection: Vector3):
	direction = newDirection
	velocity = newDirection * speed
	return self

extends KinematicBody

var speed = 500
var velocity = Vector3()

func _enter_tree():
	yield(get_tree().create_timer(15), "timeout")
	queue_free()

func set_speed(newSpeed: int):
	self.speed = newSpeed
	return self
	
func set_start(position: Vector3):
	self.global_transform.origin = position
	return self
	
func set_bullet_direction(direction: Vector3):
	velocity = direction * speed
	return self

func _physics_process(delta):
	move_and_slide(velocity * delta, Vector3.UP, true, 4, PI/4, false)
	
	for i in get_slide_count():
		var collision: KinematicCollision = get_slide_collision(i)
		if "Car" in collision.collider.name:
			collision.collider.getHit(-collision.normal * speed / 100)

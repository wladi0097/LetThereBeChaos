extends KinematicBody
class_name Car

export var paused = true
export var use_camera_at_spawn = false
export var is_player = false
export var gravity = -20.0
export var wheel_base = 1.2
export var steering_limit = 10.0
export var engine_power = 12.0
export var braking = -9.0
export var friction = -2.0
export var drag = -2.0
export var max_speed_reverse = 3.0
export var slip_speed = 9.0
export var traction_slow = 0.75
export var traction_fast = 0.02

var drifting = false
var acceleration = Vector3.ZERO 
var velocity = Vector3.ZERO 
var steer_angle = 0.0
var ai_path = [Vector3()]
var current_speed = 0

onready var pivitFront = $pivit/FrontRay
onready var pivitRear = $pivit/RearRay
onready var camera = $Camera

func _ready():
	GLOBAL.cars.append(self)
	if is_player:
		GLOBAL.player = self
	if use_camera_at_spawn:
		camera.current = true

func _physics_process(delta):
	if is_on_floor():
		get_input()
		apply_friction(delta)
		
	calculate_steering(delta)
	apply_acceleration(delta)
	
	move_with_velocity()
	orient_car_to_floor()
	camera_fov()

func camera_fov():
	if is_player:
		camera.fov = lerp(camera.fov, 60 + current_speed * 2.5, .1) 

func orient_car_to_floor():
	if pivitFront.is_colliding() or pivitRear.is_colliding():
		var nf = pivitFront.get_collision_normal() if pivitFront.is_colliding() else Vector3.UP
		var nr = pivitRear.get_collision_normal() if pivitRear.is_colliding() else Vector3.UP
		var n = ((nr + nf) / 2.0).normalized()
		var xform = align_with_y(global_transform, n)
		global_transform = global_transform.interpolate_with(xform, 0.1)

func move_with_velocity():
	velocity = move_and_slide_with_snap(velocity, -transform.basis.y, Vector3.UP, true, 4,  0.785398, false)
	check_collision_with_cars()
	current_speed = Vector2(velocity.x, velocity.z).length()

func apply_acceleration(delta):
	acceleration.y = gravity
	velocity += acceleration * delta

func apply_friction(delta):
	if velocity.length() < 0.2 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	var rear_wheel = transform.origin + transform.basis.z * wheel_base / 2.0
	var front_wheel = transform.origin - transform.basis.z * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(transform.basis.y, steer_angle) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	if not drifting and velocity.length() > slip_speed:
		drifting = true
	if drifting and velocity.length() < slip_speed and steer_angle == 0:
		drifting = false
	var traction = traction_fast if drifting else traction_slow

	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	look_at(transform.origin + new_heading, transform.basis.y)
	
func get_input():
	if paused:
		return

	if is_player:
		get_player_input()
	else:
		get_api_input()

func get_api_input():
	var turn = 0
	
	# panik turn
	if $aiCheck/left.is_colliding() && !$aiCheck/right.is_colliding():
		turn = -1
	elif $aiCheck/right.is_colliding():
		turn = 1
	
	acceleration =  -transform.basis.z * engine_power
	steer_angle = turn * deg2rad(steering_limit)

func get_player_input():
	var turn = Input.get_action_strength("steer_left")
	turn -= Input.get_action_strength("steer_right")
	steer_angle = turn * deg2rad(steering_limit)
	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate"):
		acceleration = -transform.basis.z * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = -transform.basis.z * braking
		
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
	
func getHit(hitDirection):
	velocity = velocity + hitDirection
	
func check_collision_with_cars():
	for i in get_slide_count():
		var collision: KinematicCollision = get_slide_collision(i)
		if "Car" in collision.collider.name:
			collision.collider.getHit(-collision.normal * self.current_speed * 2)
		elif "Bullet" in collision.collider.name:
			pass

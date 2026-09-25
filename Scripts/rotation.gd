class_name Rotator

var vechicle:Vechicle
var rotation_speed :float = 0
var turning :bool = false
var cross_angle:= Vector3(0,1,0)

func _init(vech:Vechicle):
	vechicle = vech

func do_turning(input_dir,delta,on_ground):

	# Block for turning the vechicle
	var turn_rate :float = 0
	if on_ground:
		turn_rate = 2.5
	else:
		turn_rate = 1.5
		
	if input_dir.x:
		if input_dir.x > 0:
			rotation_speed = turn_accelerate_left(rotation_speed,turn_rate)
			turning = true
			vechicle.rotate_object_local(Vector3(0,1,0),rotation_speed*delta)
			vechicle.rotate_object_local(Vector3(1,0,0), -1*delta)

		if input_dir.x < 0:
			rotation_speed = turn_accelerate_right(rotation_speed,turn_rate)
			turning = true
			vechicle.rotate_object_local(Vector3(0,1,0),rotation_speed*delta)
			vechicle.rotate_object_local(Vector3(1,0,0), 1*delta)
	else:
		rotation_speed = turn_deccelerate(rotation_speed)
		vechicle.rotate_object_local(Vector3(0,1,0),rotation_speed*delta)

#Functions for accelerating and decelerating turning 
func turn_accelerate_left(rotation_sp : float ,max_rotation : float) -> float:
	if rotation_sp < 0:
		rotation_sp = 0
	rotation_sp += 0.1
	if rotation_sp > max_rotation:
		rotation_sp = max_rotation
	return rotation_sp

func turn_accelerate_right(rotation_sp : float ,max_rotation : float) -> float:
	if rotation_sp > 0:
		rotation_sp = 0
	rotation_sp -= 0.1
	if rotation_sp < -(max_rotation):
		rotation_sp = -(max_rotation)
	return rotation_sp

func turn_deccelerate(rotation_sp : float) -> float:
	if rotation_sp > 0:
		rotation_sp -= 0.2
		if rotation_sp < 0:
			rotation_sp = 0
	if rotation_sp < 0:
		rotation_sp += 0.2
		if rotation_sp > 0:
			rotation_sp = 0
	return rotation_sp

#This function makes a givent vector to rotate in a way that it would face the opposite direction of the given second vector
#The rotation can be also be given a weight to further controll the rotation

func rotate_to_vector(normal:Vector3, main_dir:Vector3,rotation_force:float) -> void:
	main_dir.normalized()
	normal.normalized()
	#Finds cross vector of the surface normal and ray direction normal
	main_dir.normalized()
	cross_angle = (normal.cross(main_dir)).normalized()
	#Finds angle between the surface and ray normals and rotates the vechicle around corss vector using the angle
	var angle = 1 + main_dir.dot(normal)
	vechicle.transform.basis = vechicle.transform.basis.rotated(cross_angle.normalized(), angle * rotation_force)

func orientation(on_ground,collision_normal,ray_dir):
	if on_ground:
		rotate_to_vector(collision_normal,ray_dir, 0.9)
	else: 
		rotate_to_vector(Vector3(0,1,0), ray_dir, 0.2)
	

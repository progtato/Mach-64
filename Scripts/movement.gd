class_name Movement

var engine_power:float = 0
var max_engine_power: float
var boost_power: float = 50
var current_boost_power: float = 0
var vechicle_mass: float
var strafe_acceleration: float
var max_acceleration: float
var displacement: float
var gravity :float
var bounce_velocity := Vector3(0,0,0)
var bounce_direction := Vector3(0,1,0)
var bounce_speed :float = 0
var force_of_ray :float = 0
var acceleration :float = 0
var vechicle :Vechicle
#var ray_wheel:Ray_Wheel

func _init(vech:Vechicle, mass:float, engine:float) -> void:
	vechicle = vech
	max_acceleration = (engine/mass)*100
	displacement = mass/max_acceleration
	max_engine_power = engine
	vechicle_mass = mass
	print ("max_accel",max_acceleration,"\n max_eng",max_engine_power*100)
	#print (acceleration)
	
	#Applies front facing acceleration if it's on the ground, otherwise it will glide down with lower deceleration.
func speed_check(input_dir,on_ground):
	if not on_ground:
		gravity = -9.8
		#force_of_ray = 0
	else:
		gravity = -0.5
		if input_dir.y > 0:
			engine_power = accelerate(engine_power, max_engine_power)
		else:
			engine_power = decelerate(engine_power)
		acceleration = calculate_acceleration(engine_power,displacement)
	#bounce_velocity *= 0.8


func accelerate(power:float, max_power:float) -> float:
	#speedforce = speedforce + acceleration
	#speedforce =  (acceleration/((vechicle.velocity).distance_to(Vector3(0,0,0))))
	power += 0.8
	#print (power)
	if power > max_power:
		power = max_power
	return power

func decelerate(power:float) -> float:
	power -= 3
	if power < 0:
		power = 0
	return power

func calculate_acceleration(power:float,curve_correction:float) -> float:
	var accel = (vechicle_mass/(-1*(power+curve_correction)))+max_acceleration
	#print (accel)
	return accel



func air_drag(coefficient:float ,speedforce:Vector3) -> Vector3:
	#print(speedforce)
	speedforce = speedforce - coefficient*((speedforce)/2)
	#print (speedforce)
	#if speedforce < 1:
	#	speedforce = 0
	return speedforce

func boost(energy) -> float:
	if Input.is_action_just_pressed("boost") and energy > 1 and current_boost_power == 0:
		current_boost_power += boost_power
		energy -= 10
		if energy < 1:
			energy = 1
	else:
		current_boost_power -= 1.2
		if current_boost_power < 0:
			current_boost_power = 0
	return energy

func update_velocity(vertical_force,on_ground) -> Vector3:
	vechicle.transform = vechicle.transform.orthonormalized()
	var velocity = vechicle.velocity
	velocity += (vechicle.transform.basis.y * vertical_force)
	velocity += (vechicle.transform.basis.x * acceleration) 
	velocity += (vechicle.transform.basis.x * current_boost_power)
	velocity += (vechicle.transform.basis.z * strafe_acceleration)
	velocity += bounce_velocity
	velocity.y += gravity

	if on_ground:
		velocity = air_drag(0.1,velocity)
	else:
		velocity = air_drag(0.05,velocity)
	bounce_velocity *= 0.9
	return velocity

	#Functions for strafing (drifting)
func strafe(input,delta):
	if input > 0:
		strafe_acceleration = 7
		vechicle.rotate_object_local(Vector3(1,0,0), 0.5*delta)
	elif input < 0:
		strafe_acceleration = -7
		vechicle.rotate_object_local(Vector3(1,0,0), -0.5*delta)
	else:
		strafe_acceleration = 0

func gravity_acceleration(grav : float ,grav_accel : float ,max_grav : float) -> float:
	grav -= grav_accel
	if grav < max_grav:
		grav = max_grav
	return grav

func evaluate_bounce(bounce_dir):
	bounce_dir.normalized()
	bounce_velocity += bounce_dir*acceleration*2
	vechicle.velocity *= 0.65
	vechicle.velocity = bounce_velocity
	engine_power -= 100
	if engine_power < 0:
		engine_power = 0
#	if acceleration < 0:
#	acceleration = 0

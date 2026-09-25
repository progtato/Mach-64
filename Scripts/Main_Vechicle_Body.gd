class_name Vechicle
extends CharacterBody3D

#Static function typing, the : after parameters says that this parameter needs to be that type of data.
#The -> says what type of data needs the return value to be. If it's void it means that the function shouldn't
#return anything. Overall it improves the code performance and catches invalid data entering the functions.
#Static data typing. The : tells what the data type the varibles is and it can't change to other data type
#Every new varinble needs to state to be either var or const, after that it can called by its own name.

#Vechicle centric
var vech_name:String
var mass:float
var energy:float
var max_energy:float
var engine_power:float = 1000
var cross_angle:= Vector3(0,1,0).normalized()
var collided_object = 0
var did_bounce:bool = false
var lap:int
var total_laps:int
var input:bool = false
var allowUserInput:bool = false
var allowBoost:bool = false
var move:Movement
var ui:UI
#Compoment objects
#Inheritance/ Composition
@onready var ray_cast = Ray.new($Ray)
@onready var rotator = Rotator.new(self)
#@onready var move = Movement.new(self,mass,engine_power)
#@onready var ui = UI.new($Energy,$StatBar/Speed,$StatBar/Lap,max_energy)

func load_preset(vname, vmass, power, venergy):
	vech_name = vname
	mass = vmass
	engine_power = power
	max_energy = venergy
	energy = venergy
	move = Movement.new(self,mass,engine_power)
	ui = UI.new($Energy,$StatBar/Speed,$StatBar/Lap,max_energy)
	$Controls/ControlAn.play("RESET")
	#$Label1.text = str("mass ",mass,"\nenginepower ",power,"\nenergy ",max_energy)
	
	

func _physics_process(delta:float) -> void:
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		#print(.distance_to(Vector3(0,0,0)))
		var vert_vel = velocity*transform.basis.y
		vert_vel =  (vert_vel.distance_to(Vector3(0,0,0)))
		ray_cast.check_ray(vert_vel)
		check_collided_object(ray_cast.ray_hit_dict["Object"])
	#Makes a 2D vector based on the input keys given
	#The x axis is "Turn right/left" and the y axis is "decelerate/accelerate"
		var input_dir:= Vector2(0,0)
		var sec_input_dir = 0

	
		if allowUserInput:
			input_dir = Input.get_vector("turn_right", "turn_left", "decelerate", "accelerate")
			sec_input_dir = Input.get_axis("left_strafe","right_strafe")
		
		if input_dir == Vector2(0,0) and sec_input_dir == 0:
			if input == false:
				$Controls/ControlAn.play("Appear")
				input = true
		else:
			if input == true:
				$Controls/ControlAn.play("Fade")
				input = false
		
		var on_ground = ray_cast.ray_hit_dict["on_ground"]
		var collision_normal = ray_cast.ray_hit_dict["Collision_normal"]
		var ray_dir = (transform.basis * Vector3(0,-10,0)).normalized()
		#print (energy)

		move.speed_check(input_dir, on_ground)
		if allowBoost:
			energy = move.boost(energy)
		move.strafe(sec_input_dir,delta)
		rotator.do_turning(input_dir,delta, on_ground)
		rotator.orientation(on_ground,collision_normal,ray_dir)

		#explicit_rotation(delta)

		#print (ray_cast.spring_force)
		velocity = move.update_velocity(ray_cast.spring_force,on_ground)
		var collision = move_and_collide(velocity * delta)
		if collision:
			if not did_bounce:
				collision_responce(collision, delta)
				did_bounce = true
		else:
			did_bounce = false
		#print(velocity)
		ui.update_ui(energy,transform.origin,lap,total_laps,delta)
	#print("Engine :",move.engine_power)
	#print("Accel :", move.acceleration)
	#'print("Vel :", velocity)
	#'print("Speed :",ui.speed_label.text)
		#$Label1.text = str("rotation_speed: ",rotator.rotation_speed)

func collision_responce(collide_info,delta) -> void:
	#var speed = move.acceleration_power
	var normal = collide_info.get_normal().normalized()
	var dir = velocity.normalized()
	var reflection = (-2*(dir.dot(normal))*normal) + dir
	move.evaluate_bounce(reflection)
	#var angle = 1 + dir.dot(reflection)
	#move.acceleration_power = ((speed*angle)-speed)
	energy -= 5
	move_and_collide(velocity * delta)


#This code checks if the ray detects any intersecting objects and returns their name
#Otherwise it states the name to be null
#This if statement prevents a error as the "collided_object.name" expects a string but NULL isn't a string

func check_collided_object(collision):
	if collision:
		collision = collision.name.left(9)
	else:
		collision = "Null"

	match collision:
		"Boost_Pad":
			regen_boost()

func regen_boost():
	energy += 2
	if energy > max_energy:
		energy = max_energy


func restart():
	move.engine_power = 0
	move.acceleration = 0
	velocity = Vector3(0,0,0)

func change_fov(fov):
	$Pivot/SpringArm3D/Camera3D.fov = fov


func assign_auth(id):
	$MultiplayerSynchronizer.set_multiplayer_authority(int(id))


func disable_UI():
	$StatBar.visible = false
	$Energy.visible = false
	$Controls.visible = false
	remove_child(get_node("Pivot"))

	#Prints vatiables onto the screen
#func print_info():
#	var text = str("Speed ",speed,"\n",velocity,bounce_speed, "\n Ground? ",on_ground,"\n zangle: ","\n rayDir ",ray_dir, "\n", 
#	"\n cross", cross_angle, "\n energy:",energy,"\n Surface:",collided_object,"\n",t)
#	$Label1.text = text
	
#Functions for rotating the vechicle in seperate axis
func explicit_rotation(delta):
	if Input.is_action_pressed("Rotate_z_up"):
		#rotate_object_local(Vector3(0,0,1), 5*delta)
		rotate_object_local(Vector3(0,0,1), 5 * delta)
	if Input.is_action_pressed("rotate_z_down"):
		rotate_object_local(Vector3(0,0,1),-5*delta)
		#rotate_object_local(Vector3(0,0,1), -5*delta)
	if Input.is_action_pressed("rotate_x_up"):
		rotate_object_local(Vector3(1,0,0), 5*delta)
	if Input.is_action_pressed("rotate_x_down"):
		rotate_object_local(Vector3(1,0,0), -5*delta)
		transform = transform.orthonormalized()

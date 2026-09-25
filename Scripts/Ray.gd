class_name Ray

var ray:RayCast3D
var ray_hit_dict:Dictionary
#Variables for suspension (spring)
const spring_strenght : float = 30
const rest_spring_distance : float = 8
const damping_strenght : float = 0.5
var offset :float = 0
var spring_force :float = 0

func _init(object):
	ray = object
		
func check_ray(_vert_vel):
	ray.force_raycast_update()
	if ray.is_colliding():
		ray_hit_dict =  collect_data()
		offset = get_offset()
		spring_force = suspension_force(offset)
	else:
		print("not detecting ground")
		ray_hit_dict = data_null()
		offset = get_offset()
		spring_force = suspension_force(offset)
	
func collect_data() -> Dictionary:
	#If the ray detects an object below it, collect all essential data about the collsion
	var object = ray.get_collider()
	var collision_point: Vector3 = ray.get_collision_point()
	var collision_normal: Vector3 = ray.get_collision_normal()
	var ray_origin: Vector3 = ray.global_position
	var distance: float = ray_origin.distance_to(collision_point)
	
	#All data is placed into a dictionary
	ray_hit_dict = {
	"Object": object,
	"Collision_point": collision_point,
	"ray_origin": ray_origin,
	"Collision_normal": collision_normal,
	"Distance": distance,
	"on_ground": true }
	#data send to the parent node
	#hit_ground.emit(ray_hit_dict)
	return ray_hit_dict
	
func data_null() -> Dictionary:
	ray_hit_dict  = {
	"Object": 0,
	"Collision_point": 0,
	"ray_origin": ray.global_position,
	"Collision_normal": Vector3(0,1,0),
	"Distance": 8,
	"on_ground": false }
	#hit_ground.emit(ray_hit_dict)
	return ray_hit_dict
	
func force_update():
	ray.force_raycast_update()
	collect_data()
	#print("refreshing")
	#print(ray_hit_dict["on_ground"])

func get_offset() -> float:
	var distance = ray_hit_dict["Distance"]
	var spring_offset =  rest_spring_distance - distance
	return spring_offset
	
func suspension_force (spring_offset :float) -> float:
	#print (rest_spring_distance) <-- THE PROBLEM
	var force = (spring_offset*spring_strenght)
	#force = force #- (force*damping_strenght)
	if force > 30:
		force = 30
	#print ("force",force)
	#print(force)
	return force

#This function uses the data given to the Ray_Wheel object to determine the upwards force
#needed to make the vechicle float, and returns that force value as a float

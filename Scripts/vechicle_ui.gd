class_name UI

var energy :ProgressBar
var speed_label :Label
var sb = StyleBoxFlat.new()
var location_1 := Vector3 (0,0,0)
var location_2 :Vector3
var max_energy :float
var lap_label :Label

func _init(progbar, speed, laps, vech_energy):
	energy = progbar
	speed_label = speed
	lap_label = laps
	max_energy = vech_energy
	energy.add_theme_stylebox_override("fill", sb)
	energy.max_value = max_energy

func update_ui(vech_energy, vech_location, lap,total_laps ,delta) -> void:
	var speed = calculate_speed(vech_location,delta)
	speed_label.text = str(speed," km/h")
	var g = calculate_energy(vech_energy)
	sb.bg_color = Color(0.522, g, 0)
	energy.value = vech_energy
	lap_label.text = str("Lap ",lap,"/",total_laps)
	
func calculate_speed(vech_location,delta) -> int:
	location_2 = vech_location
	var speed = location_1.distance_to(location_2)/delta
	location_1 = location_2
	return speed

func calculate_energy(vech_energy) -> float:
	var current_energy = vech_energy/max_energy
	return current_energy

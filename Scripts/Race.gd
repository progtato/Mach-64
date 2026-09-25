extends Node3D


var checkpoints: Array
var checkpoint_lists: Array
var checkpoint_lenght: int
var race_laps :int
var current_lap:int
var vech: Vechicle
var current_vech: Vechicle
var stats: Dictionary
var time: float = 0
var race_time: float
var lap_list: Array[float]
var timeLabel: Label
var countdown: Label
var playername: String
var trackname: String
var bound: Area3D
var level
var race_finish: bool = false
var online:bool = false

# Called when the node enters the scene tree for the first time.
#func _init(level) -> void:
	#print("hello")
	#add_child(level)

#func _init(track):
#	level = track

func _ready() -> void:
	timeLabel = $Time
	countdown = $Coutdown
	current_lap = 0
	checkpoints = $Checkpoints.get_children(false)
	bound = $OutOfBounds.get_children(false)[0]
	for i in checkpoints:
		checkpoint_lists.append(LinkedList.new(i))
	checkpoint_lenght = checkpoint_lists.size()

	await get_tree().create_timer(0.1).timeout
	var vech_list = checkpoint_lists[0].get_name().get_overlapping_bodies()
	var retry = get_node("GameOver/Retry")
	var exist = get_node("GameOver/End")
	retry.connect("pressed",_on_retry_pressed)
	exist.connect("pressed",_on_end_pressed)
	#connect("_on_retry_pressed",_on_retry_pressed)
	#retry.timeout.connect("Grl")

	for n in vech_list:
		checkpoint_lists[0].add(n)
	
	countDown()
	
	
func display_checkpoints():
	$Coutdown.text =""
	for check in checkpoint_lists:
		var data = check.get_all_data()
		$Coutdown.text = str(countdown.text,"Checkpoint ", check.get_name(),"\n")
		for packet in data:
			$Coutdown.text = str(countdown.text, packet,"\n")
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var index = 0
	check_health()
	#print (race_laps)
	if bound.get_overlapping_bodies():
		var bodies = bound.get_overlapping_bodies()
		for vechicle in bodies:
			for checkpoint in checkpoint_lists:
				if checkpoint.find(vechicle):
					print(checkpoint.get_name())
					vechicle.transform.origin =  checkpoint.get_name().transform.origin
					vechicle.transform.basis = checkpoint.get_name().transform.basis
					vechicle.restart()
		
	for checkpoint in checkpoint_lists:
		var check = str(checkpoint.name).left(6)
		#print(check)
		var vech_list :Array = checkpoint.get_name().get_overlapping_bodies()
		var sec_index = index
		#print(sec_index)
		for vechicle in vech_list:
			var check_pass = false
			if not checkpoint.find(vechicle):
				sec_index -= 1
				if sec_index < 0:
					sec_index = checkpoint_lenght-1
				#print ("looking at ",checkpoint_lists[sec_index].get_name())
				if checkpoint_lists[sec_index].find(vechicle):
					#print("added to",checkpoint.get_name())
					checkpoint.add(vechicle)
					#print(checkpoint_lists[sec_index].find(vechicle))
					checkpoint_lists[sec_index].remove(vechicle)
					#print(checkpoint_lists[sec_index].find(vechicle))
					check_pass = true


					
			if check_pass and check == "Finish":
				print ("lap done")
				if vechicle == vech:
					current_lap += 1
					vechicle.lap = current_lap
					add_lap_time()
				if current_lap == 1:
					activateBoost()
				if current_lap == race_laps - 1:
					lastLap()
				#vechicle.total_laps = 7
				if current_lap == race_laps:
					print("Game Finish")
					if not race_finish:
						#race_time = time
						#var laptime = sort_time_laps(lap_list)
						#get_node("/root/Menumanager").append_score(laptime,race_time)
						vech.allowUserInput = false
						race_time = time
						var laptime = sort_time_laps(lap_list)
						get_node("/root/Menumanager").append_score(laptime,race_time)
						if online:
							display_winner.rpc(playername)
							await get_tree().create_timer(5).timeout
							leave_online_race.rpc()
						else:
							showScore(laptime)
							await get_tree().create_timer(5).timeout
							get_node("/root/Menumanager").go_to_score(trackname,playername)
						race_finish = true
					await get_tree().create_timer(1).timeout
					print("hello")
					#get_node("/root/Menumanager/Menu").visible = true
					queue_free()
					
		index += 1
	time += _delta
	printTime()
	#display_checkpoints()
	
func create_vechicle(vech_stats,mainvech):
	#print(vech_stats)
	stats = vech_stats
	var vname = vech_stats["vechiclename"]
	var mass = vech_stats["vechiclemass"]
	var power = vech_stats["vechiclepower"]
	var energy = vech_stats["vechicleenergy"]
	current_vech = load("res://Scenes/Vechicle.tscn").instantiate()
	current_vech.load_preset(vname, mass, power, energy)
	current_vech.total_laps = race_laps
	#var location = get_node("Checkpoints/Finish").transform.origin
	current_vech.transform.origin =  get_node("Checkpoints/Finish").transform.origin
	current_vech.transform.basis = get_node("Checkpoints/Finish").transform.basis
	if mainvech:
		vech = current_vech
	else:
		current_vech.disable_UI()
	add_child(current_vech)
	#print (vech)

func assign_laps(laps,track):
	trackname = track
	race_laps = laps
	#vech.total_laps = race_laps
	#var location = get_node("Checkpoints/Finish").transform.origin
	#vech.transform.origin =  get_node("Checkpoints/Finish").transform.origin
	#vech.transform.basis = get_node("Checkpoints/Finish").transform.basis
	#add_child(vech)
	#print (vech)

func get_player_name(current_name):
	playername = current_name

func printTime():
	if lap_list:
		var text:String = str(time).left(4)
		text = str("Time: ",evaluate_time_format(time))
		var lap: int = 1
		for t in lap_list:
			var time_text =  evaluate_time_format(t)
			text  = str(text,"\nLap ",lap,": ",time_text)
			timeLabel.text = text
			lap += 1
	else:
		#var time_text = str(time).left(4)
		var time_text = evaluate_time_format(time)
		timeLabel.text = str("Time: ",time_text)
			

func add_lap_time():
	if lap_list:
		var total_time: float = 0
		for i in lap_list:
			total_time += i
		lap_list.append(time - (total_time))
	else:
		lap_list.append(time)

func evaluate_time_format(currenttime:float):
	currenttime = float(currenttime)
	var minutes = int(currenttime/60)
	var seconds = str(int(fmod(currenttime,60.0))).left(2)
	var miliseconds = str(int((currenttime-(int(currenttime)))*100)).left(2)
	var combinedtime: String = str(minutes,"'",seconds,"''",miliseconds)
	return (combinedtime)
	
func sort_time_laps(list):
	var lowesttime:float = 100
	for laptime in list:
		if laptime < lowesttime:
			lowesttime = laptime
	return lowesttime


func check_health():
	if vech.energy < 0:
		$Coutdown.text = "Game Over"
		$GameOver.visible = true
		vech.allowUserInput = false
	
func countDown():
	$Coutdown.text = "3"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = "2"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = "1"
	await get_tree().create_timer(1).timeout
	vech.allowUserInput = true
	$Coutdown.text = "GO!"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = ""
	time = 0
	

func activateBoost():
	vech.allowBoost = true
	$Coutdown.text = "Boost Ok!"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = ""

func lastLap():
	$Coutdown.text = "FINAL LAP!"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = ""

func showScore(lap):
	$Coutdown.text = "Congratualtions! You finished the race!"
	await get_tree().create_timer(1).timeout
	$Coutdown.text = str("Here is your score\nRace Time: ",evaluate_time_format(time),"\nBest Lap Time: ",evaluate_time_format(lap))
	await get_tree().create_timer(4).timeout

func _on_retry_pressed() -> void:
	for item in checkpoint_lists:
		if item.find(vech):
			item.remove(vech)
	remove_child(vech)
	create_vechicle(stats,true)
	assign_laps(race_laps,trackname)
	current_lap = 0
	lap_list.clear()
	checkpoint_lists[0].add(vech)
	$Coutdown.text = ""
	$GameOver.visible = false
	countDown()

func _on_end_pressed() -> void:
	get_node("/root/Menumanager/Menu").visible = true
	queue_free()


func assign_authority(id,main):
	if main:
		vech.assign_auth(id)
	else:
		current_vech.assign_auth(id)


@rpc("any_peer","call_local")
func display_winner(winner):
	$Coutdown.text = (winner+" wins!")
	await get_tree().create_timer(1).timeout
	$Coutdown.text = str("Here is your score\nRace Time: ",evaluate_time_format(time),"\nBest Lap Time: ",evaluate_time_format(sort_time_laps(lap_list)))
	await get_tree().create_timer(4).timeout

@rpc("any_peer","call_local")
func leave_online_race():
	multiplayer.set_multiplayer_peer(null)
	get_node("/root/Menumanager").go_to_score(trackname,playername)
	queue_free()

extends Control

var n = 0
var logged_in:bool = false
var racing: bool = false
var levels :Array
var vechicles :Array
var current_level :Node3D
var level_index :int = 0
var lap_index :int = 0
var current_vechicle:int
var current_track:String
var peer:ENetMultiplayerPeer
var online:bool = false
var connectAsPeer:bool = false
var players:Dictionary
var button_effect
var saves = save_manager.new()
var db = Database.new()
var test = load("res://Scenes/Testing grounds.tscn")

func _ready():
	apply_settings()
	check_if_logged()
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("Menu_popup")
	button_effect = preload("res:///Resourses/Button3.wav")
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.connect("pressed",button_sound)

func button_sound():
	$AudioStreamPlayer.stream = button_effect
	$AudioStreamPlayer.play()
	
func _process(_delta):
	if racing:
		check_if_esc()
	else:
		check_menu_esc()

func check_menu_esc():
	if Input.is_action_just_pressed("escape") and $Menu.visible == true:
		$AnimationPlayer.play_backwards("Menu_popup")
		await get_tree().create_timer(0.3).timeout
		get_tree().quit()
		
	if Input.is_action_just_pressed("escape") and $Menu.visible == false:
		$AnimationPlayer.play_backwards("Menu_popup")
		$Menu.visible = true
		$Log.visible = false
		$"Delete account".visible = false
		$Mutliplayer.visible = false
		$"Level select".visible = false
		$Settings.visible = false
		$Leaderboard.visible = false
		$"Level select/Sart race".visible = true
		multiplayer.set_multiplayer_peer(null)
		$AnimationPlayer.play("Menu_popup")

func pause() -> void:
	$Pause.visible = true
	$AnimationPlayer.play("Menu_popup")
	if !online:
		get_tree().paused = true
	
	
func unpause() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	if $Settings.visible == true:
		$Settings.visible = false
		$Pause.visible = true
		$AnimationPlayer.play("Menu_popup")
	else:
		$Pause.visible = false
		$AnimationPlayer.play("Menu_popup")
		if !online:
			get_tree().paused = false
		
	#$AnimationPlayer.play("Menu_popup")
	
	
	
func check_if_esc() -> void:
	if Input.is_action_just_pressed("escape") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		unpause()
	
 #--------------------MENU FUNCTONS----------------------------------#
func _on_log_in_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$Log.visible = true
	$Log/Log.visible = true
	$Log/Name.text = ""
	$Log/Password.text = ""
	$Log/Repeat.visible = false
	$Log/Label3.visible = false
	$Log/Sign.visible = false
	$AnimationPlayer.play("Menu_popup")
	
func _on_log_out_pressed() -> void:
	saves.change_log_status("not logged", false)
	_on_back_pressed()
	

func _on_test_track_pressed() -> void:
	var instace = test.instantiate()
	add_child(instace)
	$Menu.visible = false

func _on_exit_pressed() -> void:
	get_tree().quit()
	$AnimationPlayer.play("Menu_popup")
	
	
func _on_sign_up_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$Log.visible = true
	$Log/Sign.visible = true
	$Log/Repeat.visible = true
	$Log/Label3.visible = true
	$Log/Log.visible = false
	$Log/Name.text = ""
	$Log/Password.text = ""
	$Log/Repeat.text = ""
	$AnimationPlayer.play("Menu_popup")
	
func _on_back_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	_ready()
	$Log.visible = false
	$Log/Log.visible = false
	$Log/Sign.visible = false
	$Log/Repeat.visible = true
	$Log/Label3.visible = true
	$Menu.visible = true
	$Log/Name.text = ""
	$Log/Password.text = ""
	$Log/Repeat.text = ""
	$Log/Error.text = ""
	$AnimationPlayer.play("Menu_popup")

#----------LOG IN AND SIGN IN FUNCTIONS--------------------------#
func _on_log_pressed() -> void:
	var surname = $Log/Name.text
	var password = $Log/Password.text
	password = str(hash(password))
	
	if db.check_if_account_exist(surname):
		if db.check_account_password(surname, password):
			saves.change_log_status(surname, true)
			#_ready()
			_on_back_pressed()
		else:
			$Log/Error.text = "Invalid Password"
	else:
		$Log/Error.text = "Name not found"
	
func _on_sign_pressed() -> void:
	$Log/Sign.visible = true
	if $Log/Name.text:
		if $Log/Password.text.length() > 7:
			
			if not db.check_if_account_exist($Log/Name.text):
				if $Log/Password.text == $Log/Repeat.text and $Log/Password.text:
					#print(hash($Log/Password.text))
					var hash_password = str(hash($Log/Password.text))
					db.sign_account($Log/Name.text,hash_password)
					_on_back_pressed()
				else:
					$Log/Error.text = "The password doesn't match"
			else:
				$Log/Error.text = "This name already exists"
		else:
			$Log/Error.text = "8 characters minimum"
	else:
		$Log/Error.text =  "Enter the name"

func hash(data):
	var hasher = HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(data)
	var hash =  hasher.finish
	#int(hash)
	#hash.int_to_hex
	#print (hash)
	return str(hash)

func check_if_logged() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	if logged_in == true:
		$"Menu/Log in".visible = false
		$"Menu/Sign up".visible = false
		$"Menu/Log out".visible = true
		$Menu/Multplayer.visible = true
		$Menu/Sigleplayer.visible = true
		$"Menu/Delete account".visible = true
	else:
		$"Menu/Log in".visible = true
		$"Menu/Sign up".visible = true
		$"Menu/Log out".visible = false
		$Menu/Multplayer.visible = false
		$Menu/Sigleplayer.visible = false
		$"Menu/Delete account".visible = false
	$AnimationPlayer.play("Menu_popup")

#----------------------DELETE ACCOUNT FUNCTIONS---------------------#
func _on_delete_account_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$"Delete account".visible = true
	$AnimationPlayer.play("Menu_popup")
	var surname = saves.get_player_name()
	$"Delete account/delete_text".text = str("Are you sure ",surname," ?")
	
func _on_back_delete_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = true
	$"Delete account".visible = false
	_ready()
	$AnimationPlayer.play("Menu_popup")
	
func _on_delete_pressed() -> void:
	var password = str(hash($"Delete account/delete_password".text))
	var surname = saves.get_player_name()
	if db.check_account_password(surname,password):
		db.delete_account(surname)
		saves.change_log_status("not logged", false)
		saves.delete_player(surname)
		_on_back_delete_pressed()
		_ready()
	else:
		$"Delete account/Pass text".text = "Invalid Password"

#---------------------SETTINGS FUNCTIONS-----------------------#
func _on_options_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	if racing:
		$Settings.visible = true
		$Pause.visible = false
	else:
		$Menu.visible = false
		$Settings.visible = true
		
	$AnimationPlayer.play("Menu_popup")
	
func _on_options_back_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	if racing:
		$Settings.visible = false
		$Pause.visible = true
	else:
		$Menu.visible = true
		$Settings.visible = false
		
	$AnimationPlayer.play("Menu_popup")
	
func _on_audio_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)
	saves.save_setting("Volume",value)
	
func _on_window_type_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
	saves.save_setting("Window",index)

func _on_resolution_item_selected(index: int) -> void:
	match index:
		0:
			get_viewport().content_scale_size = Vector2i(1920,1080)
		1:
			get_viewport().content_scale_size = Vector2i(1280,720)
		2:
			get_viewport().content_scale_size = Vector2i(640,480)
			
	saves.save_setting("Resolution",index)
	
func _on_fov_value_changed(value: float) -> void:
	saves.save_setting("FOV", value)
	$"Settings/Fov label".text = str("FOV ",value)
	apply_fov()

func _on_reset_setting_pressed() -> void:
	saves.reset_settings()
	#var data = saves.read_save("res://settings.json")
	apply_settings()

func apply_settings() -> void:
	var data = saves.read_save("user://settings.json")
	logged_in = data["logged"]
	if logged_in:
		if not FileAccess.file_exists(str("user://",data["User"],"_settings.json")):
			saves.create_logged_file(data["User"])
		data = saves.read_save(str("user://",data["User"],"_settings.json"))
		print("apllying settings from user")

	$Menu/Toptext.text = str("Welcome ",data["User"])
	
	_on_window_type_item_selected(data["Window"])
	$Settings/Window_type.selected = data["Window"]
	
	_on_resolution_item_selected(data["Resolution"])
	$Settings/Resolution.selected = data["Resolution"]
	
	_on_audio_value_changed(data["Volume"])
	$Settings/Audio.value = data["Volume"]
	
	_on_fov_value_changed(data["FOV"])
	$Settings/Fov.value = data["FOV"]
	$"Settings/Fov label".text = str("FOV ",data["FOV"])


#----------LEVEL_SELECT-----------------------#
func _on_sigleplayer_pressed() -> void:
	$"Level select/VechBox".clear()
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$"Level select".visible = true
	$AnimationPlayer.play("Menu_popup")
	levels = db.get_levels()
	$"Level select/Level  name".text = str(levels[0])
	vechicles = db.get_vechicles()
	for i in vechicles:
		$"Level select/VechBox".add_item(i["vechiclename"])
	_on_vech_box_item_selected(0)
	
func _on_back_select_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$"Level select".visible = false
	$Menu.visible = true
	$AnimationPlayer.play("Menu_popup")
	if online:
		peer = null
		multiplayer.set_multiplayer_peer(null)
		online = false
		connectAsPeer = false
		$"Level select/Sart race".visible = true
	
func _on_up_pressed() -> void:
	var new_index = level_index+1
	level_index = new_index % (levels.size())
	$"Level select/Level  name".text =  str(levels[level_index])
	
func _on_down_pressed() -> void:
	var new_index = level_index - 1
	if new_index < 0:
		level_index = levels.size() - 1
	else:
		level_index = new_index
	$"Level select/Level  name".text =  str(levels[level_index])
	
func _on_vech_box_item_selected(index: int) -> void:
	var stats = vechicles[index]
	var energy = stats["vechicleenergy"]
	var power = stats["vechiclepower"]
	var mass = stats["vechiclemass"]
	$"Level select/Stats".text = str("Hp: ",power,"\nEnergy: ",energy,"\nMass: ",mass)

func _on_lap_box_item_selected(index: int) -> void:
	lap_index = index

func _on_sart_race_pressed() -> void:
	if online:
		var level = get_level()
		var laps = get_laps()
		load_online_level.rpc(level,laps)
		add_vechicles.rpc()
		initialise_level.rpc()
	else:
		load_level()
		create_vechicle(true)
		current_level.assign_authority(multiplayer.get_unique_id(),true)
		add_child(current_level)
		apply_fov()

@rpc("any_peer","call_local")
func add_vechicles():
	for vech in players:
		if players[vech].id == multiplayer.get_unique_id():
			create_vechicle(true)
			current_level.assign_authority(multiplayer.get_unique_id(),true)
		else:
			create_vechicle(false)
			current_level.assign_authority(players[vech].id,false)
		

@rpc("any_peer","call_local")
func initialise_level():
	current_level.online = true
	add_child(current_level)
	apply_fov()

func get_level():
	var race_level = $"Level select/Level  name".text
	current_track = race_level
	if FileAccess.file_exists(str("res://Scenes/",race_level,".tscn")):
		
		return race_level
	else:
		print(race_level,".tscn not found")


func get_laps():
	var lap = int($"Level select/LapBox".get_item_text(lap_index))
	return lap


@rpc("any_peer","call_local")
func load_online_level(race_level,laps):
	current_track = race_level
	var instance = load(str("res://Scenes/",race_level,".tscn")).instantiate()
	current_level = instance

	current_level.assign_laps(laps,race_level)
	current_level.get_player_name(saves.get_player_name())
	$"Level select".visible = false
	racing = true

func load_level():
	var race_level = $"Level select/Level  name".text
	current_track = race_level
	if FileAccess.file_exists(str("res://Scenes/",race_level,".tscn")):
		race_level = str("res://Scenes/",race_level,".tscn")
		
		var instance = load(race_level).instantiate()
		current_level = instance
		#current_level = RaceManeger.new(race_level)
		
		var lap = int($"Level select/LapBox".get_item_text(lap_index))
		current_level.assign_laps(lap,current_track)
		current_level.get_player_name(saves.get_player_name())
		#add_child(current_level)
		
		#await get_tree().create_timer(0.1).timeout
		#print(instance.race_laps)
		$"Level select".visible = false
	else:
		print(race_level,".tscn not found")
	racing = true

func create_vechicle(main):
	var vechicle = vechicles[($"Level select/VechBox".selected)]
	current_vechicle = vechicle["vechicleid"]
	current_level.create_vechicle(vechicle,main)

func append_score(laptime, racetime):
	var player = saves.get_player_name()
	db.add_score(laptime,racetime,player,current_vechicle,current_track)

#----------------------------LeaderBoard---------------------------#
func _on_leaderboard_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$Leaderboard.visible = true
	$AnimationPlayer.play("Menu_popup")
	$Leaderboard/TimeOption.select(0)
	get_players()
	get_tracks()
	var firsttrack = $Leaderboard/TrackOption.get_item_text(0)
	var firstname = $Leaderboard/PlayerOption.get_item_text(0)
	show_leaderboard(firsttrack,firstname,0)
	
func _on_exit_score_pressed() -> void:
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = true
	$Leaderboard.visible = false
	$AnimationPlayer.play("Menu_popup")

func get_tracks():
	$Leaderboard/TrackOption.clear()
	var tracks = db.get_levels()
	for level in tracks:
		$Leaderboard/TrackOption.add_item(level)

func get_players():
	$Leaderboard/PlayerOption.clear()
	$Leaderboard/PlayerOption.add_item("None")
	var players = db.get_names()
	for player in players:
		$Leaderboard/PlayerOption.add_item(player)

func show_leaderboard(choosen_track,choosen_name,index):
	var Player = $Leaderboard/Scores/Player
	Player.text = "Player\n"
	var Laptime = $Leaderboard/Scores/Laptime
	Laptime.text = "Best Lap Time\n"
	var Racetime = $Leaderboard/Scores/Racetime
	Racetime.text = "Race Time\n"
	var vechicle = $Leaderboard/Scores/Vechicle
	vechicle.text = "Vechicle\n"
	var Track = $Leaderboard/Scores/Track
	Track.text = "Track\n"
	var data = db.get_scores(choosen_track,choosen_name)
	data = db.merge_sort(data,index)
	var rows:int = 0
	var datalenght:int = data.size()
	
	while rows < 10 and rows < datalenght:
		Player.text += str(data[rows]["name"],"\n")
		Laptime.text += str(str(data[rows]["laptime"]).left(6),"\n")
		Racetime.text += str(str(data[rows]["racetime"]).left(6),"\n")
		vechicle.text += str(data[rows]["vechiclename"],"\n")
		Track.text += str(data[rows]["trackname"],"\n")
		rows += 1

func _on_track_option_item_selected(index: int) -> void:
	var trackselected = $Leaderboard/TrackOption.get_item_text(index)
	var nameselected = $Leaderboard/PlayerOption.get_item_text($Leaderboard/PlayerOption.selected)
	var timeselected = $Leaderboard/TimeOption.selected
	show_leaderboard(trackselected,nameselected,timeselected)

func _on_player_option_item_selected(index: int) -> void:
	var nameselected = $Leaderboard/PlayerOption.get_item_text(index)
	var trackselected = $Leaderboard/TrackOption.get_item_text($Leaderboard/TrackOption.selected)
	var timeselected = $Leaderboard/TimeOption.selected
	show_leaderboard(trackselected,nameselected,timeselected)

func go_to_score(track, player):
	print(track)
	print(player)
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$Leaderboard.visible = true
	$AnimationPlayer.play("Menu_popup")
	_on_leaderboard_pressed()
	
	var indx = get_playerOption_index(player)
	$Leaderboard/PlayerOption.select(indx)
	indx = get_trackOption_index(track)
	$Leaderboard/TrackOption.select(indx)
	db.clean_database(track,player)
	show_leaderboard(track, player,0)
	racing = false

func get_playerOption_index(player):
	var flag = true
	var indx = 0
	while flag:
		if $Leaderboard/PlayerOption.get_item_text(indx) == player:
			flag = false
			indx -= 1
		indx += 1
	return indx

func get_trackOption_index(track):
	var flag = true
	var indx = 0
	while flag:
		if $Leaderboard/TrackOption.get_item_text(indx) == track:
			flag = false
			indx -= 1
		indx += 1
	return indx

func _on_time_option_item_selected(index: int) -> void:
	var nameselected = $Leaderboard/PlayerOption.get_item_text($Leaderboard/PlayerOption.selected)
	var trackselected = $Leaderboard/TrackOption.get_item_text($Leaderboard/TrackOption.selected)
	show_leaderboard(trackselected,nameselected,index)
	
#Pause menu Functions
func _on_resume_pressed() -> void:
	unpause()


func _on_quit_to_menu_pressed() -> void:
	if online:
		online = false
		quit_to_menu.rpc()
	else:
		quit_to_menu()
	
@rpc("any_peer","call_local")
func quit_to_menu():
	unpause()
	if online:
		multiplayer.set_multiplayer_peer(null)
	get_tree().reload_current_scene()
	
func apply_fov():
	if racing:
		var surname = saves.get_player_name()
		var data = saves.read_logged_save(surname)
		var fov = data["FOV"]
		current_level.vech.change_fov(fov)
#------------------Multiplayer--------------------#

func _on_multplayer_pressed():
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = false
	$Mutliplayer.visible = true
	$AnimationPlayer.play("Menu_popup")
	peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	online = true
	var address = get_local_ip()
	$Mutliplayer/Ip.text = ("Your IP: " + address + "\nOther players need to use it to join")

func get_local_ip():
	var address = IP.get_local_addresses()
	for i in address:
		var split_address = i.split(".")
		if split_address.size() == 4 and split_address[0] == "10" and split_address[1] == "142":
			return i
		elif split_address.size() == 4 and split_address[0] == "192" and split_address[1] == "168":
			return i
	

func _on_exit_multiplayer_pressed():
	$AnimationPlayer.play_backwards("Menu_popup")
	$Menu.visible = true
	$Mutliplayer.visible = false
	$AnimationPlayer.play("Menu_popup")
	peer = null
	multiplayer.set_multiplayer_peer(null)
	online = false
	connectAsPeer = false
	#get_tree().reload_current_scene()
	
func _on_host_pressed():
	var address = get_local_ip()
	peer.set_bind_ip(address)
	var connectionError = peer.create_server(1055,3)
	if connectionError != OK:
		$Mutliplayer/Error.text = ("Can't host" + str(connectionError))
		
	peer.get_host().compress(ENetConnection.COMPRESS_NONE)
	multiplayer.set_multiplayer_peer(peer)
	print ("Waiting for players . . .")
	$Mutliplayer.visible = false
	_on_sigleplayer_pressed()
	get_player_info(saves.get_player_name(),multiplayer.get_unique_id())

func _on_join_pressed():
	var address = $Mutliplayer/EnterIp.text
	var split_address = address.split(".")
	
	if split_address.size() == 4 and split_address[0] == "192" and split_address[1] == "168" or split_address.size() == 4 and split_address[0] == "10" and split_address[1] == "142":
		print(address)
		if peer:
			peer = null
			multiplayer.set_multiplayer_peer(null)
		peer = ENetMultiplayerPeer.new()
		peer.create_client(address,1055)
		peer.get_host().compress(ENetConnection.COMPRESS_NONE)
		multiplayer.set_multiplayer_peer(peer)
		
		$Mutliplayer/Error.text = "No server found"
		print("No server found")
	else:
		$Mutliplayer/Error.text = "Invalid Host IP\nEnter Host IP"

@rpc("any_peer","call_local")
func verify_server():
	if multiplayer.is_server():
		print ("found server")
		client_connect.rpc()

#@rpc("any_peer","call_local")
func client_connect():
	connectAsPeer = true
	$Mutliplayer.visible = false
	$"Level select".visible = true
	_on_sigleplayer_pressed()
	$"Level select/Sart race".visible = false
	
	
func peer_connected(id):
	print ("Player connected" + str(id))

func peer_disconnected(id):
	print ("Player disconnected" + str(id))
	players.erase(id)

func connected_to_server():
	print ("Connected to server")
	get_player_info.rpc_id(1,saves.get_player_name(),multiplayer.get_unique_id())
	client_connect()


func connection_failed():
	print ("No connection")
	multiplayer.multiplayer_peer = null
	
@rpc("any_peer")
func get_player_info(playername, id):
	if !players.has(id):
		players[id] = {"name":playername,"id":id}

	if multiplayer.is_server():
		for i in players:
			get_player_info.rpc(players[i].name ,i)
			
@rpc("any_peer","call_local")
func disconnect_players():
	get_tree().reload_current_scene()

class_name save_manager
extends Node

func _init():
	if not FileAccess.file_exists("user://settings.json"):
		create_new_save()
		print ("default save doesn't exist")
	else:
		print ("default save file exist")

#-- Creates a new defualt save file when it doesn't exists
func create_new_save() -> void:
	var save = {
	"logged": false,
	"User" : "not_logged",
	"FOV" : 120,
	"Resolution" : 1,
	"Window" : 0,
	"Volume" : 50
	}
	var file = FileAccess.open("user://settings.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(save))
	file.close()
	file = null

#-- Creates a new settings file for a log in player
func create_logged_file(surname) -> void:
	var save = read_save("user://settings.json")
	var file = FileAccess.open("user://"+surname+"_settings.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(save))
	file.close()
	file = null
	
#-- Resets the defaul/logged in settings back to default
func reset_settings() -> void:
	var data = read_save("user://settings.json")
	var logged = data["logged"]
	var user = data["User"]
	var save = {
	"logged": logged,
	"User" : user,
	"FOV" : 120,
	"Resolution" : 1,
	"Window" : 0,
	"Volume" : 50
	}
	if logged:
		if FileAccess.file_exists(str("user://",data["User"],"_settings.json")):
			write_save(save,str("user://",data["User"],"_settings.json"))
			print("file exists")
		else:
			create_logged_file(data["User"])
			data = read_save(str("user://",data["User"],"_settings.json"))
			write_save(save,str("user://",data["User"],"_settings.json"))
			print("file doesn't exist")
	else:
		write_save(save,"user://settings.json")
	
#-- Overwrites the save file witha a new one
# Input data: the save file to write  -- path: the filepath that points to which file to overwrite
func write_save(data,path) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	file = null
	
#-- Reads a settings file 
# path: the filepath to which file to read
func read_save(path) -> Dictionary:
	var data = null
	var file
	while not data:
		file = FileAccess.open(path,FileAccess.READ)
		data = JSON.parse_string(file.get_as_text())
				
	file.close()
	return data
	
	#for line in data:
	#	print(line)
	
	#file = null
	

func read_logged_save(surname) -> Dictionary:
	if FileAccess.file_exists(str("user://",surname,"_settings.json")):
		var data = read_save(str("user://",surname,"_settings.json"))
		return data
	else:
		create_logged_file(surname)
		var data = read_save(str("user://",surname,"_settings.json"))
		return data

#-- Change the default settings values to update if a player is logged in or logged out
func change_log_status(surname:String, status:bool) -> void:
	var data = read_save("user://settings.json")
	data["logged"] = status
	data["User"] = surname
	write_save(data,"user://settings.json")

#-- Returns a string that contains the name of the logged in account
func get_player_name() -> String:
	var data = read_save("user://settings.json")
	var surname = data["User"]
	return surname

func delete_player(player):
	if FileAccess.file_exists(str("user://",player,"_settings.json")):
		DirAccess.remove_absolute(str("user://",player,"_settings.json"))
	else:
		print("File doesn't exist")
	
#Saves a single parameter of the setting
#save: what parameter to be updated -- info: the new value that will be saved 
func save_setting(save:String, info) -> void:
	var data = read_save("user://settings.json")
	if data["logged"] == true:
		if FileAccess.file_exists(str("user://",data["User"],"_settings.json")):
			data = read_save(str("user://",data["User"],"_settings.json"))
			data[save] = info
			write_save(data,str("user://",data["User"],"_settings.json"))
			print("file exists")
		else:
			create_logged_file(data["User"])
			data = read_save(str("user://",data["User"],"_settings.json"))
			data[save] = info
			write_save(data,str("user://",data["User"],"_settings.json"))
			print("file doesn't exist")
	else:
		data[save] = info
		write_save(data,"user://settings.json")
		print("saving to default")

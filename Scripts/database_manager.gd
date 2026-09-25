class_name Database

var database = SQLite.new()

#-- Intialises the databese when the object is being created, it checks if database alreadt exits
# and proceeds to either opening it or creating a new one
func _init() -> void:
	print("Hello")
	database.foreign_keys = true
	database.path = "res://database.db"
	if FileAccess.file_exists("res://database.db"):
		database.open_db()
		#print ("db exists")
	else:
		#print ("db doesn't exist")
		database.open_db()
		create_new_tables(database)

#-- Creates a new databe if it doesn't exist
func create_new_tables(db:SQLite) -> void:

	db.create_table( "tbl_player", {
		"id": {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"name": {"data_type":"text", "not_null":true },
		"password": {"data_type":"text", "not_null":true}
	})

	db.create_table("tbl_track",{
		"trackid": {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"trackname": {"data_type":"text"}
	})

	db.create_table("tbl_vechicle",{
		"vechicleid": {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"vechiclename": {"data_type":"text", "not_null":true},
		"vechiclemass": {"data_type":"int", "not_null":true},
		"vechiclepower": {"data_type":"int", "not_null":true},
		"vechicleenergy": {"data_type":"int", "not_null":true}
	})
	
	db.create_table("tbl_score", {
		"scoreid": {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"racetime":{"data_type": "float", "not_null":true},
		"laptime" :{"data_type": "float", "not_null" :true},
		"id": {"data_type":"int", "foreign_key":"tbl_player.id"},
		"vechicleid": {"data_type":"int", "foreign_key":"tbl_vechicle.vechicleid"},
		"trackid": {"data_type":"int", "foreign_key":"tbl_track.trackid"}
	})

	add_vechicles()
	add_tracks()

func add_vechicles() -> void:
	append_data("tbl_vechicle", {"vechiclename":"Vech1", "vechiclemass":4000, "vechiclepower":1000, "vechicleenergy":120})
	append_data("tbl_vechicle", {"vechiclename":"Vech2", "vechiclemass":2500, "vechiclepower":800, "vechicleenergy":80})

func add_tracks():
	append_data("tbl_track", {"trackname":"Track1"})
	append_data("tbl_track", {"trackname":"Track2"})
	append_data("tbl_track", {"trackname":"Track3"})

#-- Appends to a table given by the table name (table_name) with a dictionary of data (data)
func append_data(table_name:String, data:Dictionary) -> void:
	database.insert_row(table_name,data)
	
#-- returns an array whith a dictionary from a given table (table_name), what contion (where) and what columns to return (select an Array)
func retrieve_data(table_name:String, where:String, select:Array) -> Array:
	var data = database.select_rows(table_name,where,select)
	return data


#- Returns true if an entry name exists in the database otherwise it returns false
func check_if_account_exist(name:String) -> bool:
	if database.select_rows("tbl_player",str("name = '",name,"'"),["*"]):
		return true
	else:
		return false

#-- Deletes an account with the given name
func delete_account(name:String) -> void:
	var id = find_player_id(name)
	database.delete_rows("tbl_score",str("id = '",id,"'"))
	database.delete_rows("tbl_player",str("id = '",id,"'"))
	

#-- Adds a new account to the database whith its name and password
func sign_account(name:String, password:String) -> void:
	database.insert_row("tbl_player",{"name":name,"password":password})

#-- Returns true if the "password" is the same as the password in the tbl_player with the given "name"
func check_account_password(name:String, password:String) -> bool:
	if database.select_rows("tbl_player",str("name='",name,"'"),["password"])[0]["password"] == password:
		return true
	else:
		return false

func get_levels() -> Array:
	var levels =  database.select_rows("tbl_track","",["*"])
	var array:Array
	for level in levels:
		array.append(level["trackname"])
	return array

func get_names() -> Array:
	var players =  database.select_rows("tbl_player","",["*"])
	var array:Array
	for name in players:
		array.append(name["name"])
	return array

func get_vechicles():
	var vechicles = database.select_rows("tbl_vechicle","",["*"])
	return vechicles

func add_score(laptime, racetime, player,vechicleid,racelevel):
	var raceid = find_race_id(racelevel)
	var playerid = find_player_id(player)
	append_data("tbl_score",{"racetime":str(racetime),"laptime":str(laptime),"id":playerid,"vechicleid":vechicleid,"trackid":raceid})

func find_race_id(track):
	print(track)
	var id = database.select_rows("tbl_track",str("trackname='",track,"'"),["trackid"])[0]["trackid"]
	return id

func find_player_id(player):
	var id = database.select_rows("tbl_player",str("name='",player,"'"),["id"])[0]["id"]
	return id

func get_scores(track,name):
	if name == "None":
		database.query(str("SELECT tbl_score.scoreid, tbl_player.name, tbl_track.trackname, tbl_score.racetime, tbl_score.laptime, tbl_vechicle.vechiclename
FROM tbl_score
INNER JOIN tbl_player ON tbl_score.id=tbl_player.id
INNER JOIN tbl_vechicle ON tbl_score.vechicleid = tbl_vechicle.vechicleid
INNER JOIN tbl_track ON tbl_score.trackid = tbl_track.trackid
WHERE tbl_track.trackname = '",track,"'"))
	else:
		database.query(str("SELECT tbl_score.scoreid, tbl_player.name, tbl_track.trackname, tbl_score.racetime, tbl_score.laptime, tbl_vechicle.vechiclename
FROM tbl_score
INNER JOIN tbl_player ON tbl_score.id=tbl_player.id
INNER JOIN tbl_vechicle ON tbl_score.vechicleid = tbl_vechicle.vechicleid
INNER JOIN tbl_track ON tbl_score.trackid = tbl_track.trackid
WHERE tbl_track.trackname = '",track,"' AND tbl_player.name = '",name,"'"))
	#var data = database.query_result
	#print(merge_sort_lap_times(data))
	#clean_database(track,name)
	return(database.query_result)

func clean_database(track,name):
	var link_list = LinkedList.new("Laptimes")
	var data = get_scores(track,name)
	var racedata = merge_sort(data,0)
	var lapdata = merge_sort(data,1)
	#var scoreids = get_player_scoreid(name,link_list)
	for score in data:
		var array:Array = [score["scoreid"],false]
		link_list.add(array)

	var index:int = 0
	var lenght = data.size()

	while index < lenght:
		if index < 10:
			var score = [racedata[index]["scoreid"],false]
			if link_list.find(score):
				#print(link_list.get_node(score).get_data())
				link_list.get_node(score).set_data([score[0],true])
				#print(link_list.get_node([score[0],true]).get_data())
			index += 1
		else:
			index = lenght

	index = 0
	while index < lenght:
		if index < 10:
			var score = [lapdata[index]["scoreid"],false]
			if link_list.find(score):
				#print(link_list.get_node(score).get_data())
				link_list.get_node(score).set_data([score[0],true])
				#print(link_list.get_node([score[0],true]).get_data())
			index += 1
		else:
			index = lenght

	var nodes = link_list.get_all_data()
	var to_delete:Array
	for item in nodes:
		if item[1] == false:
			to_delete.append(item[0])
	#print (nodes)
	#print (to_delete)
	
	if to_delete:
		for item in to_delete:
			database.delete_rows("tbl_score",str("scoreid ='",item,"'"))
			print ("deleted",item)
	


func merge_sort(laps: Array,choice:int) -> Array:
	if laps.size() <= 1:
		return laps
	var mid = laps.size() / 2
	var left = merge_sort(laps.slice(0, mid),choice)
	var right = merge_sort(laps.slice(mid, laps.size()),choice)
	if choice == 0:
		return racetime_merge(left,right)
	else:
		return laptime_merge(left,right)

func laptime_merge(left: Array, right: Array) -> Array:
	var result = []
	var i = 0
	var j = 0
	while i < left.size() and j < right.size():
		if left[i]["laptime"] < right[j]["laptime"]:
			result.append(left[i])
			i += 1
		else:
			result.append(right[j])
			j += 1

	while i < left.size():
		result.append(left[i])
		i += 1

	while j < right.size():
		result.append(right[j])
		j += 1

	return result

func racetime_merge(left: Array, right: Array) -> Array:
	var result = []
	var i = 0
	var j = 0
	while i < left.size() and j < right.size():
		if left[i]["racetime"] < right[j]["racetime"]:
			result.append(left[i])
			i += 1
		else:
			result.append(right[j])
			j += 1

	while i < left.size():
		result.append(left[i])
		i += 1

	while j < right.size():
		result.append(right[j])
		j += 1

	return result
	

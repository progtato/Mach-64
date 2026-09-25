class_name LinkedList

var root :ListNode
var size :int= 0
var name
#var new_node

func _init(listname) -> void:
	root = null
	size = 0
	name = listname

func get_name():
	return name

func get_size() -> int:
	return size

func add(data) -> void:
	var new_node = ListNode.new(data,root)
	root = new_node
	size += 1

func remove (data) -> bool:
	var this_node = root
	var prev_node = null
	while this_node:
		if this_node.get_data() == data:
			if prev_node:
				prev_node.set_next(this_node.get_next())
			else:
				root = this_node.get_next()
			size -= 1
			return true
		else:
			prev_node = this_node
			this_node = this_node.get_next()
	return false

func find(data) -> bool:
	var this_node = root
	while this_node:
		if this_node.get_data() == data:
			return true
		else:
			this_node = this_node.get_next()
	return false

func get_node(data):
	var this_node = root
	while this_node:
		if this_node.get_data() == data:
			return this_node
		else:
			this_node = this_node.get_next()
	return false

func get_all_data():
	var array:Array
	var this_node = root
	while this_node:
		array.append(this_node.get_data())
		this_node = this_node.get_next()
	return array

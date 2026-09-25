class_name ListNode

var data
var next_node:ListNode

func _init(d,node) -> void:
	data = d
	next_node = node

func get_next() -> ListNode:
	return next_node

func set_next(node) -> void:
	next_node = node

func get_data():
	return data

func set_data(d) -> void:
	data = d

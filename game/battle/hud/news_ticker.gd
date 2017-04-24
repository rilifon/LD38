extends Panel

const MSG = preload("res://battle/hud/flowing_text.tscn")

var queue = []
var idle = true

onready var global_state = get_node("/root/GlobalState")

func _ready():
	global_state.shortcuts["newsticker"] = self
	queue_msg("Let's have a good show tonight!")

func _exit_tree():
	global_state.shortcuts.erase("newsticker")

func queue_msg(msg):
	queue.append(msg)
	if idle:
		idle = false
		_next_text()

func _next_text(unused1=null, unused2=null):
	if not queue.empty():
		var msg = queue.front()
		queue.pop_front()
		var label = MSG.instance()
		label.set_text(msg)
		add_child(label)
		label.get_node("Tween").connect("tween_complete", self, "_next_text")
	else:
		idle = true

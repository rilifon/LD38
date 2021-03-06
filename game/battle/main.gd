extends Control

const TargetPickerScene = preload("res://battle/target_picker.tscn")

const TEST_ICON = preload("res://battle/events/medpack-icon.tres")
const RESULT = preload("res://aftermath/main.tscn")

onready var zone_picker = get_node("ZonePicker")
onready var endgametimer = get_node("EndGameTimer")
onready var map = get_node("Map")
onready var zones = map.get_node("Zones")
onready var players = map.get_node("Players")
onready var event_panel = get_node("HUD/EventPanel")
onready var audience_bar = get_node("HUD/AudienceBar")
onready var time = 0

onready var normal_bgm = get_node("NormalBGM")
onready var intense_bgm = get_node("IntenseBGM")
onready var jingle = get_node("Jingle")
onready var fader = get_node("Fader")
onready var fraglist = get_node("HUD/FragList")

const Protip = preload("res://gui/protip.gd")


var intense = false

func _ready():
	fader.fade_in()
	zones.generate_border()
	for zone in zones.get_children():
		zone.connect("exit_tree", self, "_zone_closed")
	yield(get_tree(), "fixed_frame")
	for i in range(2*zones.get_child_count()):
		map.drop_player()
	set_fixed_process(true)
	get_node("HUD").add_child(Protip.show_protip("Keep an eye on the\nAudience Meter on\nthe right"))
	

func _zone_closed():
	yield(get_tree(), "fixed_frame")
	zones.generate_border()

func _on_event_chosen():
	zone_picker.disable()

func _draw_event_time():
	event_panel.draw_event(self)

func _fixed_process(delta):
	time += delta
	if players.get_child_count() <= 1:
		_start_countdown()

func _go_intense():
	if not intense:
		normal_bgm.stop()
		jingle.play()
		jingle.get_node("Timer").start()
		intense = true

func _start_countdown():
	endgametimer.start()
	set_fixed_process(false)

func _endgame():
	fader.fade_out()
	yield(fader, "done_fade_out")
	var result = RESULT.instance()
	result.total_time = time
	result.num_survivors = players.get_child_count()
	result.audience_score = audience_bar.enjoyment
	queue_free()
	get_parent().add_child(result)

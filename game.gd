extends Node

signal faded_out
signal faded_in

var _file = "user://savegame.json"
var state = {}
var level
var _music_position

func _ready():
	load_state()
	level = 0

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("cheat"):
		next_level()
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if event.is_action_pressed("mute"):
		if $Music.playing:
			_music_position = $Music.get_playback_position()
			$Music.playing = false
		else:
			$Music.play()
			$Music.seek(_music_position)
	
func current_level():
	return levels()[level]
	
func next_level():
	var levels = levels()
	level += 1
	level %= len(levels)
	#fade_out()
	#yield(self, "faded_out")
	get_tree().change_scene(levels[level % len(levels)])

func load_level(n):
	level = n-1
	next_level()

func levels():
	var names = [
		"title",
		"katamari",
		"slide_off",
		"corners",
		"assembly",
		"rearrange",
		"doors",
		"curve",
		"fork",
		"sacrifice",
		"split_up",
		"rescue",
	]
	var levels = []
	for n in names:
		levels.push_back("res://levels/"+n+".tscn")
	return levels
	
func _initial_state():
	return {}
	
func save_state() -> bool:
	var savegame = File.new()
	
	savegame.open(_file, File.WRITE)
	savegame.store_line(to_json(state))
	savegame.close()
	return true
	
func load_state() -> bool:
	var savegame = File.new()
	if not savegame.file_exists(_file):
		return false
	
	savegame.open(_file, File.READ)
	
	state = _initial_state()
	var new_state = parse_json(savegame.get_line())
	for key in new_state:
		state[key] = new_state[key]
	savegame.close()
	return true

func fade_out():
	$AnimationPlayer.play("fadeout")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("faded_out")

func fade_in():
	$AnimationPlayer.play("fadein")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("faded_in")

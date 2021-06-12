extends Node2D

onready var objects = $Objects

var EMPTY = -1

var PLAYER = 0
var SLEEPY = 1
var BLOCK = 2
var WALL = 3
var GOAL = 4

var undo_stack = []
var prev_object_count = -1

func _ready():
	$Meta/Name.text = get_tree().current_scene.filename.split("/")[-1].split(".")[0]
	var players = objects.get_used_cells_by_id(PLAYER)
	for p in players.slice(1, -1):
		objects.set_cellv(p, SLEEPY)
		
func wake_up_next():
	# FIXME: Doesn't work for more than two characters.
	var sleepy = objects.get_used_cells_by_id(SLEEPY)
	if sleepy.size() > 0:
		var players = objects.get_used_cells_by_id(PLAYER)
		if players.size() > 0:
			objects.set_cellv(players[0], SLEEPY)
			$Switch.pitch_scale = rand_range(0.7,1.3)
			$Switch.play()
		objects.set_cellv(sleepy[0], PLAYER)

func _input(event):
	if event.is_action_pressed("switch"):	
		wake_up_next()
	
	if event.is_action_pressed("undo"):
		if len(undo_stack) > 0:
			objects.queue_free()
			objects = undo_stack.pop_back()
			add_child(objects)
			unoops()
		return
	
	if event.is_action_pressed("reset"):
		if len(undo_stack) > 0:
			objects.queue_free()
			objects = undo_stack[0].duplicate()
			add_child(objects)
			unoops()
		return

	
	var dir = Vector2(0, 0)
	if event.is_action_pressed("left"):
		dir = Vector2(-1, 0)
	if event.is_action_pressed("right"):
		dir = Vector2(1, 0)
	if event.is_action_pressed("up"):
		dir = Vector2(0, -1)
	if event.is_action_pressed("down"):
		dir = Vector2(0, 1)
	
	if dir != Vector2(0, 0):
		move(dir)

func move(dir):
	var players = objects.get_used_cells_by_id(PLAYER)
	if players.size() == 0:
		return
		
	var old_state = objects.duplicate()

	
	var player = players[0]
	var to_move = []
	find_moves(player, dir, to_move)

	for p in to_move:
		if dir == Vector2(-1, 0):
			to_move.sort_custom(self, "left_to_right")
		if dir == Vector2(1, 0):
			to_move.sort_custom(self, "right_to_left")
		if dir == Vector2(0, -1):
			to_move.sort_custom(self, "top_to_bottom")
		if dir == Vector2(0, 1):
			to_move.sort_custom(self, "bottom_to_top")
		
	var moved = []
		
	for p in to_move:
		var t = objects.get_cellv(p)
		objects.set_cellv(p, EMPTY)
		if objects.get_cellv(p+dir) != GOAL:
			objects.set_cellv(p+dir, t)
		else:
			$Eat.pitch_scale = rand_range(0.8,1.2)
			$Eat.play()
			if t == PLAYER:
				wake_up_next()
		moved.push_back(p+dir)

	if moved.size() > 0:
		undo_stack.push_back(old_state)
		if won():
			$Win.play()
			yield(get_tree().create_timer(1), "timeout")
			game.next_level()
	
	var all = []
	all += objects.get_used_cells_by_id(PLAYER)
	all += objects.get_used_cells_by_id(SLEEPY)
	all += objects.get_used_cells_by_id(BLOCK)
	
	var object_count = 0
	
	while len(all) > 0:
		var object = []
		find_object(all[0], all, object)
#		var on_land = false
#		for p in object:
#			if is_land(p):
#				on_land = true
#		if not on_land:
#			for p in object:
#				objects.set_cellv(p, EMPTY)
#			oops("You pushed a piece into the water!")
#			$Drop.position = objects.map_to_world(object[0])
#			$Drop.play()
		object_count += 1
	
	if object_count < prev_object_count and prev_object_count > 0:
		#$Click.position = objects.map_to_world(pos)
		$Click.pitch_scale = rand_range(0.8,1.2)
		$Click.play()
	elif object_count > prev_object_count and object_count > 0 and prev_object_count != -1:
		$Click.pitch_scale = rand_range(-0.8,-1.2)
		$Click.play()
	
	prev_object_count = object_count

func find_object(p, all, object):
	all.erase(p)
	object.push_back(p)
	var right = (p+Vector2(1, 0)).round()
	var left = (p+Vector2(-1, 0)).round()
	var top = (p+Vector2(0, -1)).round()
	var bottom = (p+Vector2(0, 1)).round()
	
	if all.has(right) and is_piece(right) and connected(p, right):
		find_object(right, all, object)
	if all.has(left) and is_piece(left) and connected(p, left):
		find_object(left, all, object)
	if all.has(top) and is_piece(top) and connected(p, top):
		find_object(top, all, object)
	if all.has(bottom) and is_piece(bottom) and connected(p, bottom):
		find_object(bottom, all, object)


func won():
	var pieces = []
	pieces += objects.get_used_cells_by_id(PLAYER)
	var player_pieces = objects.get_used_cells_by_id(PLAYER)
	
	pieces += objects.get_used_cells_by_id(SLEEPY)
	pieces += objects.get_used_cells_by_id(BLOCK)
	
	if player_pieces.size() == 0 and pieces.size() > 0:
		oops()
	
	return pieces.size() == 0

func oops():
	$Oops.show()

func unoops():
	$Oops.hide()

func find_moves(pos, dir, to_move):
	if not can_move(pos, dir):
		return
		
	to_move.push_back(pos)
	var front = (pos+dir).round()
	var back = (pos-dir).round()
	var right = (pos+dir.rotated(PI/2)).round()
	var left = (pos+dir.rotated(-PI/2)).round()
	
	if is_piece(front) and (not to_move.has(front)):
		find_moves(front, dir, to_move)
	if is_piece(back) and (not to_move.has(back)):
		find_moves(back, dir, to_move)
	if is_piece(left) and (not to_move.has(left)):
		find_moves(left, dir, to_move)
	if is_piece(right) and (not to_move.has(right)):
		find_moves(right, dir, to_move)

func can_move(pos, dir):
	var next = objects.get_cellv(pos+dir)
	if next == EMPTY or next == GOAL:
		return true
	elif next == WALL:
		return false
	else:
		return can_move(pos+dir, dir)

func is_piece(pos):
	var id = objects.get_cellv(pos)
	return id >= 0 and id <= 2

func connected(p1, p2):
	return true
	
func left_to_right(a, b):
	return a.x <= b.x
func right_to_left(a, b):
	return a.x >= b.x
func top_to_bottom(a, b):
	return a.y <= b.y
func bottom_to_top(a, b):
	return a.y >= b.y

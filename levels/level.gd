extends Node2D

onready var objects = $Objects

var EMPTY = -1

var PLAYER = 0
var SLEEPY = 1
var BLOCK = 2
var WALL = 3
var GOAL = 4

# Called when the node enters the scene tree for the first time.
func _ready():
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
		objects.set_cellv(sleepy[0], PLAYER)

func _input(event):
	if event.is_action_pressed("switch"):	
		wake_up_next()	
	
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
	var player = objects.get_used_cells_by_id(PLAYER)[0]
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
		elif t == PLAYER:
			wake_up_next()
		moved.push_back(p+dir)


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

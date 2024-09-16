extends MarginContainer
class_name MatchBoardPanel

@onready var _witch: Witch = $Witch
@onready var PLATFORM = preload("res://Scenes/MatchBoardPanel/platform.tscn")
@onready var FALLING_PIECE = preload("res://Scenes/FallingPiece/falling_piece.tscn")
@onready var _start_wait_timer: Timer = $StartWaitTimer
#@onready var _add_items_to_waiting_area_timer: Timer = $AddItemsToWaitingAreaTimer
@onready var _waiting_area_node: MarginContainer = $FallingPieces/WaitingArea
@onready var _falling_area_node: MarginContainer = $FallingPieces/FallingArea
#@onready var _grounded_area_node: MarginContainer = $FallingPieces/GroundedArea

var _platforms: Array[Sprite2D] = []
var _waiting_area: Array = []
var _falling_pieces: Array = []
var _grounded_area: Array = []
var _three_items_chance: float = 0.01
var _falling_pieces_pool: Array[FallingPiece] = []


func _input(_event):
	if Input.is_action_just_pressed("ui_right"):
		if _witch.move_right():
			# movement was successful:
			_set_platform_visibility(_witch.column)
	if Input.is_action_just_pressed("ui_left"):
		if _witch.move_left():
			# movement was successful:
			_set_platform_visibility(_witch.column)
	if Input.is_action_just_pressed("ui_up"):
		if _witch.swap():
			# swap was successful:
			pass

func _set_platform_visibility(witch_column: int) -> void:
	if _witch == null or _platforms.is_empty():
		return
	for index in _platforms.size():
		var platform: Sprite2D = _platforms[index]
		if index == witch_column or index == witch_column + 1:
			platform.hide()
		else:
			platform.show()

func _add_items_to_waiting_area():
	var available_columns: Array[int] = []
	for index in Consts.COL_NUM:
		available_columns.append(index)
	var num_cols_to_add: int = 2 + (0 if InGame.rng.randf() > _three_items_chance else 1)
	for index in num_cols_to_add:
		var next_col_arr_index = InGame.rng.randi() % available_columns.size()
		var adding_column_num = available_columns[next_col_arr_index]
		available_columns.remove_at(next_col_arr_index)
		var falling_piece: FallingPiece = null
		if not _falling_pieces_pool.is_empty():
			falling_piece = _falling_pieces_pool.pop_back()
		else:
			falling_piece = FALLING_PIECE.instantiate()
		var type_to_add: Enums.FALLING_PIECE_TYPE = InGame.get_random_falling_piece_type()
		falling_piece.initialize(
			type_to_add,
			Vector2(
				Consts.LEFT_COL_POS_X + (Consts.COL_WIDTH * adding_column_num),
				Consts.WAITING_AREA_POS_Y
			)
		)
		_waiting_area_node.add_child(falling_piece)
		_waiting_area[adding_column_num].append(falling_piece)

func _move_waiting_to_falling():
	for col_index in _waiting_area.size():
		print("col_index = ", col_index)
		var column: Array[FallingPiece] = _waiting_area[col_index]
		if not column.is_empty():
			var falling_piece: FallingPiece = column.pop_back()
			falling_piece.reparent(_falling_area_node)
			falling_piece.begin_falling()
			_falling_pieces[col_index].append(falling_piece)

func _start_game() -> void:
	_move_waiting_to_falling()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~CLEAR DATA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_platforms = []
	_waiting_area = []
	_falling_pieces = []
	_grounded_area = []
	#~~~~~~~~~~~~~~~~~~~~~~FALLING_PIECE SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for index in Consts.COL_NUM:
		#~~~~~~~~~~~~~~~~~~~~~~PLATFORM SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		var platform: Sprite2D = PLATFORM.instantiate()
		platform.position = Vector2(
			Consts.LEFT_PLAT_POS_X + (Consts.COL_WIDTH * index),
			Consts.GROUND_LEVEL_POS_Y
		)
		add_child(platform)
		_platforms.append(platform)
		#~~~~~~~~~~~~~~~~~~~~~~~~ARRAY SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		var _waiting_area_col: Array[FallingPiece] = []
		_waiting_area.append(_waiting_area_col)
		var _falling_pieces_col: Array[FallingPiece] = []
		_falling_pieces.append(_falling_pieces_col)
		var _grounded_area_col: Array[FallingPiece] = []
		_grounded_area.append(_grounded_area_col)
		#~~~~~~~~~~~~~~~~~~~~~~~~~GAME SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_add_items_to_waiting_area()
	_set_platform_visibility(_witch.column)
	_start_wait_timer.start()


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

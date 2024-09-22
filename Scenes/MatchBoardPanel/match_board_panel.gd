extends MarginContainer
class_name MatchBoardPanel

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ======================================Variables:=================================================
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ===============================On Ready Variables================================================
@onready var _hidden_falling_piece: HiddenFallingPiece = $FallingPieces/HiddenFallingArea/HiddenFallingPiece
@onready var _witch: Witch = $Witch
@onready var _waiting_area_node: MarginContainer = $FallingPieces/WaitingArea
@onready var _falling_area_node: MarginContainer = $FallingPieces/FallingArea
@onready var _grounded_area_node: MarginContainer = $FallingPieces/GroundedArea
@onready var _swap_pause_falling_timer: Timer = $SwapPauseFallingTimer
@onready var _start_wait_timer: Timer = $StartWaitTimer

#Load Variables:
@onready var PLATFORM = preload("res://Scenes/MatchBoardPanel/platform.tscn")
@onready var FALLING_PIECE = preload("res://Scenes/FallingPiece/falling_piece.tscn")

# ================================Private Variables================================================
# flags:
var _game_started = false
var _waiting_area_is_filled = false

# columns:
var _platforms: Array[Sprite2D] = []
var _waiting_columns: Array = []
var _falling_columns: Array = []
var _ground_columns: Array = []
var _pot_columns: Array = []

var _matched_pots: int = 0
var _failures: int = 0

# ================================Management Variables=============================================
var _falling_pieces_pool: Array[FallingPiece]

# ==================================Calculated Values==============================================
var _is_falling: bool = false:
	get:
		return _hidden_falling_piece != null and _hidden_falling_piece.is_falling

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# =======================================Methods:==================================================
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ===================================Generic Methods===============================================
func initialize() -> void:
	_initialize_column_data()
	_add_pieces_to_waiting_columns()
	_set_platform_visibility(_witch.column)
	_swap_pause_falling_timer.wait_time = Consts.TOTAL_SWAP_TIME
	_start_wait_timer.start()

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		_hidden_falling_piece.instant_fall()
	if Input.is_action_just_pressed("ui_down"):
		_hidden_falling_piece.begin_fast_falling()
	if Input.is_action_just_released("ui_down"):
		_hidden_falling_piece.stop_fast_falling()
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
			_pause_falling()
			_swap_pause_falling_timer.start()
			_swap_falling_columns()
			_swap_grounded_columns()

func _pause_falling() -> void:
	if not _is_falling:
		return
	_hidden_falling_piece.stop_falling()

func _resume_falling() -> void:
	if _is_falling:
		return
	_hidden_falling_piece.begin_falling()

# ==================================Column Methods===============================================
func _initialize_column_data() -> void:
	#~~~~~~~~~~~~~~~~~~~~~~~CLEAR COL DATA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_platforms = []
	_waiting_columns = []
	_falling_columns = []
	_ground_columns = []
	_pot_columns = []
	for index in Consts.COL_NUM:
		#~~~~~~~~~~~~~~~~~~~~~~PLATFORM SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		var platform: Sprite2D = PLATFORM.instantiate()
		platform.position = Vector2(
			Methods.get_column_position_x(index),
			Consts.GROUND_LEVEL_POS_Y
		)
		add_child(platform)
		_platforms.append(platform)
		#~~~~~~~~~~~~~~~~~~~~~~~~ARRAY SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		var _waiting_col: Array[FallingPiece] = []
		_waiting_columns.append(_waiting_col)
		var _falling_col: Array[FallingPiece] = []
		_falling_columns.append(_falling_col)
		var _ground_col: Array[FallingPiece] = []
		_ground_columns.append(_ground_col)
		var _pot_col: Array[FallingPiece] = []
		_pot_columns.append(_pot_col)
		
func _on_falling_piece_update(falling_piece: FallingPiece, update_type: Enums.FALLING_PIECE_UPDATE_TYPE):
	match(update_type):
		Enums.FALLING_PIECE_UPDATE_TYPE.CLEARED:
			_clear_grounded_piece(falling_piece)
		Enums.FALLING_PIECE_UPDATE_TYPE.MOVE_INTO_POT_FINISHED:
			_move_into_pot_finished()
		Enums.FALLING_PIECE_UPDATE_TYPE.DATA_RESET:
			_data_reset_piece(falling_piece)
		Enums.FALLING_PIECE_UPDATE_TYPE.FAIL_COMPLETE:
			_finish_fail()
		_:
			pass

func _data_reset_piece(reset_piece: FallingPiece):
	_falling_pieces_pool.append(reset_piece)
	reset_piece.parent_update_signal.disconnect(_on_falling_piece_update)
	reset_piece.remove_from_tree()

func _find_piece(piece: FallingPiece, double_arr: Array, should_have_correct_x_y: bool = true) -> Vector2i:
	var col_idx_in_range = piece.column_index >= 0 and piece.column_index < double_arr.size()
	if col_idx_in_range:
		var col: Array[FallingPiece] = double_arr[piece.column_index]
		var row_idx_in_range = piece.row_index >= 0 and piece.row_index < col.size()
		if should_have_correct_x_y and row_idx_in_range and piece == double_arr[piece.column_index][piece.row_index]:
			return Vector2i(piece.column_index, piece.row_index)
		var row_index: int = col.find(piece)
		if row_index != -1:
			return Vector2i(piece.column_index, row_index)
	for col_index in double_arr.size():
		var search_col: Array[FallingPiece] = double_arr[col_index]
		var search_row_index: int = search_col.find(piece)
		if search_row_index != -1:
			return Vector2i(col_index, search_row_index)
	return Vector2i(-1, -1)
	

func _clear_grounded_piece(grounded_piece: FallingPiece):
	var ground_indices: Vector2i = _find_piece(grounded_piece, _ground_columns)
	if ground_indices.x != -1 and ground_indices.y != -1:
		var ground_col: Array[FallingPiece] = _ground_columns[ground_indices.x]
		ground_col.remove_at(ground_indices.y)
	if grounded_piece.type == Enums.FALLING_PIECE_TYPE.POT_BOTTOM:
		var pot_indices: Vector2i = _find_piece(grounded_piece, _pot_columns, false)
		if pot_indices.x != -1 and pot_indices.y != -1:
			var pot_col: Array[FallingPiece] = _pot_columns[pot_indices.x]
			pot_col.remove_at(pot_indices.y)

func _move_into_pot_finished():
	_matched_pots -= 1
	if not _check_stop_falling_counts():
		_resume_falling()

func _finish_fail():
	_failures -= 1
	if not _check_stop_falling_counts():
		_resume_falling()

func _check_stop_falling_counts() -> bool:
	return _failures > 0 or _matched_pots > 0

func _add_pieces_to_waiting_columns():
	if _waiting_area_is_filled:
		return
	_waiting_area_is_filled = true
	var available_columns: Array[int] = []
	for index in Consts.COL_NUM:
		available_columns.append(index)
	var num_cols_to_add: int = 2 + (0 if InGame.rng.randf() > InGame.three_item_chance else 1)
	for index in num_cols_to_add:
		var next_col_arr_index = InGame.rng.randi() % available_columns.size()
		var column_index = available_columns[next_col_arr_index]
		available_columns.remove_at(next_col_arr_index)
		var falling_piece: FallingPiece = null
		if not _falling_pieces_pool.is_empty():
			falling_piece = _falling_pieces_pool[0]
			_falling_pieces_pool.remove_at(0)
		else:
			falling_piece = FALLING_PIECE.instantiate()
		var type_to_add: Enums.FALLING_PIECE_TYPE = InGame.get_random_falling_piece_type()
		_waiting_area_node.add_child(falling_piece)
		falling_piece.initialize(
			type_to_add,
			column_index
		)
		_waiting_columns[column_index].append(falling_piece)
		falling_piece.parent_update_signal.connect(_on_falling_piece_update)
	#var arr: Array[int] = []
	#var match_found: bool = false
	#for index: int in _waiting_columns.size():
		#var column = _waiting_columns[index]
		#if not column.is_empty():
			#if column[0].type == Enums.FALLING_PIECE_TYPE.POT_TOP:
				#match_found = true
			#arr.append(index)
	#if match_found:
		#for index: int in arr:
			#var column: Array[FallingPiece] = _waiting_columns[index]
			#var falling_piece = FALLING_PIECE.instantiate()
			#column[0].clear()
			#_waiting_area_node.remove_child(column[0])
			#column.clear()
			#column.append(falling_piece)
			#falling_piece.initialize(
				#Enums.FALLING_PIECE_TYPE.POT_TOP,
				#Vector2(
					#Consts.LEFT_COL_POS_X + (Consts.COL_WIDTH * index),
					#Consts.WAITING_AREA_POS_Y
				#)
			#)
			#_waiting_area_node.add_child(falling_piece)

func _set_platform_visibility(witch_column: int) -> void:
	if _witch == null or _platforms.is_empty():
		return
	for index in _platforms.size():
		var platform: Sprite2D = _platforms[index]
		if index == witch_column or index == witch_column + 1:
			platform.hide()
		else:
			platform.show()

func _on_swap_finished() -> void:
	_resume_falling()
	
func _swap_falling_columns():
	_pause_falling()
	if not _falling_columns[_witch.column].is_empty() and not _ground_columns[_witch.column + 1].is_empty():
		var ground_col: Array[FallingPiece] = _ground_columns[_witch.column + 1]
		var ground_top_piece: FallingPiece = ground_col[ground_col.size() - 1]
		var falling_piece = _falling_columns[_witch.column][0]
		if ground_top_piece.landing_height <= falling_piece.position.y:
			falling_piece.swap(false, Methods.convert_falling_height_to_swap_delay(falling_piece.position.y))
			#TODO: swap to delay actually moving the column
			var temp_col = _falling_columns[_witch.column]
			_falling_columns[_witch.column] = _falling_columns[_witch.column + 1]
			_falling_columns[_witch.column + 1] = temp_col
			return
			
	if not _falling_columns[_witch.column + 1].is_empty() and not _ground_columns[_witch.column].is_empty(): 
		var ground_col: Array[FallingPiece] = _ground_columns[_witch.column]
		var ground_top_piece: FallingPiece = ground_col[ground_col.size() - 1]
		var falling_piece = _falling_columns[_witch.column + 1][0]
		if ground_top_piece.landing_height <= falling_piece.position.y:
			falling_piece.swap(true, Methods.convert_falling_height_to_swap_delay(falling_piece.position.y))
			#TODO: swap to delay actually moving the column
			var temp_col = _falling_columns[_witch.column]
			_falling_columns[_witch.column] = _falling_columns[_witch.column + 1]
			_falling_columns[_witch.column + 1] = temp_col
			return

func _swap_grounded_columns():
	if not _ground_columns[_witch.column].is_empty():
		_ground_columns[_witch.column][0].swap(false)
	if not _ground_columns[_witch.column + 1].is_empty():
		_ground_columns[_witch.column + 1][0].swap(true)
		
	# swap grounded column arrays
	#TODO: swap to delay actually moving the column
	var temp_col = _ground_columns[_witch.column]
	_ground_columns[_witch.column] = _ground_columns[_witch.column + 1]
	_ground_columns[_witch.column + 1] = temp_col
	
	# swap pot column arrays
	var temp_pot_col = _pot_columns[_witch.column]
	_pot_columns[_witch.column] = _pot_columns[_witch.column + 1]
	_pot_columns[_witch.column + 1] = temp_pot_col
	

# ==================================Other Generic Methods==========================================
func _move_waiting_to_falling():
	_waiting_area_is_filled = false
	for col_index in _waiting_columns.size():
		var column: Array[FallingPiece] = _waiting_columns[col_index]
		if not column.is_empty():
			var falling_piece: FallingPiece = column[0]
			column.clear()
			falling_piece.hidden_falling_piece = _hidden_falling_piece
			falling_piece.reparent(_falling_area_node)
			_falling_columns[col_index].append(falling_piece)

func _start_game() -> void:
	_game_started = true
	_hidden_falling_piece.reset()
	_move_waiting_to_falling()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()

func _physics_process(_delta: float) -> void:
	if not _is_falling or not _game_started:
		return
	for col_index in _falling_columns.size():
		var falling_column: Array[FallingPiece] = _falling_columns[col_index]
		if not falling_column.is_empty():
			var falling_piece: FallingPiece = falling_column[0]
			var ground_column: Array[FallingPiece] = _ground_columns[col_index]
			var landing_on_row_index = ground_column.size() - 1
			var landing_on: FallingPiece = ground_column[landing_on_row_index] if not ground_column.is_empty() else null
			var pot_column: Array[FallingPiece] = _pot_columns[col_index]
			var pot_index = pot_column.size() - 1
			var landing_on_pot: FallingPiece = pot_column[pot_index] if not pot_column.is_empty() else null
			var destination_height = landing_on.landing_height if landing_on != null else Consts.GROUND_LEVEL_POS_Y
			if not _hidden_falling_piece.is_falling:
				continue
			if _hidden_falling_piece.position.y >= destination_height:
				ground_column.append(falling_piece)
				if falling_piece.type == Enums.FALLING_PIECE_TYPE.POT_BOTTOM:
					pot_column.append(falling_piece)
				var landing_result: Enums.LANDING_ACTION_RESULT = falling_piece.land(landing_on, landing_on_pot)
				match(landing_result):
					Enums.LANDING_ACTION_RESULT.CLEAR_POT_AND_ABOVE, Enums.LANDING_ACTION_RESULT.CLEAR_ABOVE_POT_ONLY:
						_matched_pots += 1
					Enums.LANDING_ACTION_RESULT.GROUNDED:
						if falling_piece.row_index >= Consts.FAIL_ROW_INDEX:
							_failures += 1
							falling_piece.fail()
				falling_column.clear()
				falling_piece.reparent(_grounded_area_node)
				
				#match landing_result:
					#Enums.LANDING_ACTION_RESULT.GROUNDED:
					#_:
						#pass
						#match falling_piece.type:
							#Enums.FALLING_PIECE_TYPE.POT_BOTTOM:
								#landing_on_pot_col.append(falling_piece)
								#landing_col.append(falling_piece)
							#Enums.FALLING_PIECE_TYPE.POT_TOP:
								#if landing_on_pot == null:
									#falling_piece.clear()
								#else:
									#_not_swapping = true
									#landing_col.append(falling_piece)
									#_pot_column_indices_waiting_clearing.append(col_index)
									#_pot_wait_start_timer.start()
							#_:
								#landing_col.append(falling_piece)
	if not _waiting_area_is_filled and _hidden_falling_piece.position.y >= Consts.ADD_WAITING_AREA_POS_Y:
		_add_pieces_to_waiting_columns()
	if _check_stop_falling_counts() and _is_falling:
		_pause_falling()
	var is_empty = true
	for col: Array in _falling_columns:
		if not col.is_empty():
			is_empty = false
			break
	if is_empty and _is_falling:
		_hidden_falling_piece.reset()
		if not _waiting_area_is_filled:
			_add_pieces_to_waiting_columns()
		_move_waiting_to_falling()

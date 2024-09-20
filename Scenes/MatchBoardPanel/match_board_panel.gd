extends MarginContainer
class_name MatchBoardPanel

@onready var _witch: Witch = $Witch
@onready var PLATFORM = preload("res://Scenes/MatchBoardPanel/platform.tscn")
@onready var FALLING_PIECE = preload("res://Scenes/FallingPiece/falling_piece.tscn")
@onready var _start_wait_timer: Timer = $StartWaitTimer
@onready var _waiting_area_node: MarginContainer = $FallingPieces/WaitingArea
@onready var _falling_area_node: MarginContainer = $FallingPieces/FallingArea
@onready var _grounded_area_node: MarginContainer = $FallingPieces/GroundedArea
@onready var _swap_pause_falling_timer: Timer = $SwapPauseFallingTimer
@onready var _pot_wait_start_timer: Timer = $PotWaitStartTimer

var _is_potting: bool = false
var _is_potting_array: Array[bool] = [false, false, false, false]
var _platforms: Array[Sprite2D] = []
var _waiting_area: Array = []
var _falling_pieces: Array = []
var _grounded_area: Array = []
var _pot_columns: Array = []
var _three_items_chance: float = 0.01
var _falling_pieces_pool: Array[FallingPiece] = []
var _started = false
var _not_swapping = false

var _pot_column_indices_waiting_clearing: Array[int] = []
var _waiting_area_is_filled: bool = false


func _input(_event):
	if _is_potting or _not_swapping:
		return
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
			_swap_pause_falling_timer.start()
			_swap_falling_columns()
			_swap_grounded_columns()

func _after_pause_falling():
	for col_index in _falling_pieces.size():
		var column: Array[FallingPiece] = _falling_pieces[col_index]
		if not column.is_empty():
			column[0].begin_falling()

func _pause_falling():
	for col_index in _falling_pieces.size():
		var column: Array[FallingPiece] = _falling_pieces[col_index]
		if not column.is_empty():
			column[0]._is_falling = false
	

func _swap_falling_columns():
	_pause_falling()
	if not _falling_pieces[_witch.column].is_empty() and not _grounded_area[_witch.column + 1].is_empty():
		var grounded_column: Array[FallingPiece] = _grounded_area[_witch.column + 1]
		var grounded_top_piece: FallingPiece = grounded_column[grounded_column.size() - 1]
		var falling_piece = _falling_pieces[_witch.column][0]
		if grounded_top_piece.landing_height <= falling_piece.position.y:
			falling_piece.swap(false, Methods.convert_falling_height_to_swap_delay(falling_piece.position.y))
			var temp_col = _falling_pieces[_witch.column]
			_falling_pieces[_witch.column] = _falling_pieces[_witch.column + 1]
			_falling_pieces[_witch.column + 1] = temp_col
			return
			
	if not _falling_pieces[_witch.column + 1].is_empty() and not _grounded_area[_witch.column].is_empty(): 
		var grounded_column: Array[FallingPiece] = _grounded_area[_witch.column]
		var grounded_top_piece: FallingPiece = grounded_column[grounded_column.size() - 1]
		var falling_piece = _falling_pieces[_witch.column + 1][0]
		if grounded_top_piece.landing_height <= falling_piece.position.y:
			falling_piece.swap(true, Methods.convert_falling_height_to_swap_delay(falling_piece.position.y))
			var temp_col = _falling_pieces[_witch.column]
			_falling_pieces[_witch.column] = _falling_pieces[_witch.column + 1]
			_falling_pieces[_witch.column + 1] = temp_col
			return

func _swap_grounded_columns():
	if not _grounded_area[_witch.column].is_empty():
		_grounded_area[_witch.column][0].swap(false)
	if not _grounded_area[_witch.column + 1].is_empty():
		_grounded_area[_witch.column + 1][0].swap(true)
		
	# swap grounded column arrays
	var temp_col = _grounded_area[_witch.column]
	_grounded_area[_witch.column] = _grounded_area[_witch.column + 1]
	_grounded_area[_witch.column + 1] = temp_col
	
	# swap pot column arrays
	var temp_pot_col = _pot_columns[_witch.column]
	_pot_columns[_witch.column] = _pot_columns[_witch.column + 1]
	_pot_columns[_witch.column + 1] = temp_pot_col
	

func _set_platform_visibility(witch_column: int) -> void:
	if _witch == null or _platforms.is_empty():
		return
	for index in _platforms.size():
		var platform: Sprite2D = _platforms[index]
		if index == witch_column or index == witch_column + 1:
			platform.hide()
		else:
			platform.show()

func _falling_piece_was_released(falling_piece):
	_falling_pieces_pool.append(falling_piece)

func _add_items_to_waiting_area():
	if _waiting_area_is_filled:
		return
	_waiting_area_is_filled = true
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
			falling_piece = _falling_pieces_pool[0]
			_falling_pieces_pool.remove_at(0)
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
	var arr: Array[int] = []
	var match_found: bool = false
	for index: int in _waiting_area.size():
		var column = _waiting_area[index]
		if not column.is_empty():
			if column[0].type == Enums.FALLING_PIECE_TYPE.POT_TOP:
				match_found = true
			arr.append(index)
	if match_found:
		for index: int in arr:
			var column: Array[FallingPiece] = _waiting_area[index]
			var falling_piece = FALLING_PIECE.instantiate()
			column[0].clear()
			_waiting_area_node.remove_child(column[0])
			column.clear()
			column.append(falling_piece)
			falling_piece.initialize(
				Enums.FALLING_PIECE_TYPE.POT_TOP,
				Vector2(
					Consts.LEFT_COL_POS_X + (Consts.COL_WIDTH * index),
					Consts.WAITING_AREA_POS_Y
				)
			)
			_waiting_area_node.add_child(falling_piece)

func _move_waiting_to_falling():
	_waiting_area_is_filled = false
	for col_index in _waiting_area.size():
		var column: Array[FallingPiece] = _waiting_area[col_index]
		if not column.is_empty():
			var falling_piece: FallingPiece = column[0]
			column.clear()
			falling_piece.reparent(_falling_area_node)
			falling_piece.begin_falling()
			_falling_pieces[col_index].append(falling_piece)


func _start_game() -> void:
	_started = true
	_move_waiting_to_falling()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~CLEAR DATA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_platforms = []
	_waiting_area = []
	_falling_pieces = []
	_grounded_area = []
	_pot_columns = []
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
		var _pot_col: Array[FallingPiece] = []
		_pot_columns.append(_pot_col)
		#~~~~~~~~~~~~~~~~~~~~~~~~~GAME SETUP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_add_items_to_waiting_area() 	
	_set_platform_visibility(_witch.column)
	_start_wait_timer.start()
	_swap_pause_falling_timer.wait_time = Consts.TOTAL_SWAP_TIME

func _pot_swallow_callable(pot: FallingPiece, col_index: int, pot_index: int) -> Callable:
	return func ():
		if pot.above == null:
			_grounded_area[col_index].remove_at(pot_index)
			var pot_col = _pot_columns[col_index]
			pot_col.remove_at(pot_col.size() - 1)
			pot.clear()
			_is_potting_array[col_index] = false
			_after_pot_swallow()
			return
		# call recursively until all falling pieces above pot are cleared.
		_grounded_area[col_index].remove_at(pot_index + 1)
		var tween = pot.above.into_pot()
		if tween != null:
			tween.tween_callback(_pot_swallow_callable(pot, col_index, pot_index))

func _after_pot_swallow():
	for potting in _is_potting_array:
		if potting:
			return
	_is_potting = false
	_not_swapping = false
	_after_pause_falling()

func _pot_swallow(pot: FallingPiece, col_index: int, pot_index: int):
	_pause_falling()
	return _pot_swallow_callable(pot, col_index, pot_index).call()

func _clear_pots():
	_is_potting = true
	for col_index in _pot_column_indices_waiting_clearing:
		var pot_col: Array[FallingPiece] = _pot_columns[col_index]
		var landing_col: Array[FallingPiece] = _grounded_area[col_index]
		var landing_on_pot: FallingPiece = pot_col[pot_col.size() - 1]
		var pot_index: int = landing_col.find(landing_on_pot)
		_is_potting_array[col_index] = true
		_pot_swallow(landing_on_pot, col_index, pot_index)
	pass

func _physics_process(_delta: float) -> void:
	if _is_potting or not _started:
		return
	for col_index in _falling_pieces.size():
		var column: Array[FallingPiece] = _falling_pieces[col_index]
		if not column.is_empty():
			var landing_col: Array[FallingPiece] = _grounded_area[col_index]
			var landing_on_index = landing_col.size() - 1
			var landing_on: FallingPiece = landing_col[landing_on_index] if not landing_col.is_empty() else null
			var landing_on_pot_col: Array[FallingPiece] = _pot_columns[col_index]
			var landing_on_pot_index = landing_on_pot_col.size() - 1
			var landing_on_pot: FallingPiece = landing_on_pot_col[landing_on_pot_index] if not landing_on_pot_col.is_empty() else null
			var destination_height = landing_on.landing_height if landing_on != null else Consts.GROUND_LEVEL_POS_Y
			var falling_piece: FallingPiece = column[0]
			if not falling_piece.is_falling:
				break
			if not _waiting_area_is_filled and falling_piece.position.y >= Consts.ADD_WAITING_AREA_POS_Y:
				_add_items_to_waiting_area()
			if falling_piece.position.y >= destination_height:
				var landing_type = falling_piece.land(landing_on, destination_height)
				match landing_type:
					Enums.FALLING_PIECE_LANDING_TYPE.CLEARED:
						landing_col.remove_at(landing_on_index)
						if landing_on.type == Enums.FALLING_PIECE_TYPE.POT_BOTTOM:
							landing_on_pot_col.remove_at(landing_on_pot_index)
					_:
						match falling_piece.type:
							Enums.FALLING_PIECE_TYPE.POT_BOTTOM:
								landing_on_pot_col.append(falling_piece)
								landing_col.append(falling_piece)
							Enums.FALLING_PIECE_TYPE.POT_TOP:
								if landing_on_pot == null:
									falling_piece.clear()
								else:
									_not_swapping = true
									landing_col.append(falling_piece)
									_pot_column_indices_waiting_clearing.append(col_index)
									_pot_wait_start_timer.start()
							_:
								landing_col.append(falling_piece)
				column.clear()
				falling_piece.reparent(_grounded_area_node)
				
	var is_empty = true
	for col: Array in _falling_pieces:
		if not col.is_empty():
			is_empty = false
			break
	if is_empty and not _not_swapping:
		if not _waiting_area_is_filled:
			_add_items_to_waiting_area()
		_move_waiting_to_falling()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_swap_finished() -> void:
	_after_pause_falling()

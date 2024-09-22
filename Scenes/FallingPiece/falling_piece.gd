@tool
extends Sprite2D
class_name FallingPiece
signal parent_update_signal(falling_piece: FallingPiece, update_type: Enums.FALLING_PIECE_UPDATE_TYPE)
signal group_cleared_signal(pieces_cleared: Array[FallingPiece], result_of: Enums.LANDING_ACTION_RESULT)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ======================================Variables:=================================================
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ===============================On Ready Variables================================================
@onready var _animation_tree: FallingPieceAnimationTree = $AnimationTree
@onready var _fail_timer: Timer = $FailTimer

# ===============================Exported Variables================================================
@export var hidden_falling_piece: HiddenFallingPiece = null
@export var column_index: int = -1
@export var row_index: int = -1

# Linked List Values
@export var above: FallingPiece = null
@export var below: FallingPiece = null

@export var result_when_removed: Enums.ON_REMOVED_RESULT = Enums.ON_REMOVED_RESULT.SUCCESS

# ======================Tried Initialize Before Ready Variables====================================
@export var _early_initialize_type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED

# ================================Physics Variables================================================
var _fractional_position: Vector2 = Vector2.ZERO

# ===============================Swapping Variables================================================
var _swapping_tween: Tween = null
var _into_pot_tween: Tween = null
var _into_pot_triggered: bool = false

# Delayed Swap Variables
var _delayed_swap_time_remaining = 0.0
var _delayed_swap_is_swapping_left = false

# ==================================Calculated Values==============================================
var is_ready: bool = false:
	get:
		return _animation_tree != null
		
var is_swapping: bool = false:
	get:
		return _swapping_tween != null

var is_falling: bool = false:
	get:
		return hidden_falling_piece != null

var is_moving_into_pot: bool = false:
	get:
		return _into_pot_tween != null

var type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
	get:
		if not is_ready:
			return Enums.FALLING_PIECE_TYPE.UNINITIALIZED
		return _animation_tree.type

var col_pos_x: float = -1.0:
	get:
		return Methods.get_column_position_x(column_index)

var landing_height: int = -1:
	get:
		return Methods.get_row_position_y(row_index + 1) as int

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# =======================================Methods:==================================================
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ===================================Generic Methods===============================================
func initialize(new_type: Enums.FALLING_PIECE_TYPE, new_column_index: int = -1) -> bool:
	_swapping_tween = null
	_into_pot_tween = null
	_into_pot_triggered = false
	above = null
	below = null
	column_index = new_column_index
	row_index = -1
	_delayed_swap_is_swapping_left = false
	_delayed_swap_time_remaining = 0.0
	result_when_removed == Enums.ON_REMOVED_RESULT.SUCCESS
	hidden_falling_piece = null
	if not is_ready:
		_early_initialize_type = new_type
		return false
	_early_initialize_type = Enums.FALLING_PIECE_TYPE.UNINITIALIZED
	var new_position = get_start_position()
	_fractional_position = new_position
	set_position_from_fractional_position()
	if new_type == Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
		_animation_tree.reset_data()
		return true
	else:
		return _animation_tree.intialize(new_type)
	
func reset_data() -> bool:
	parent_update_signal.emit(self, Enums.FALLING_PIECE_UPDATE_TYPE.DATA_RESET)
	return true

func remove_from_tree() -> void:
	var result = initialize(Enums.FALLING_PIECE_TYPE.UNINITIALIZED)
	above = null
	below = null
	var parent = self.get_parent()
	if parent != null:
		parent.remove_child(self)

# ==================================Location Methods===============================================
func get_start_position() -> Vector2:
	return Vector2(Methods.get_column_position_x(column_index), Methods.get_row_position_y())

# ===================================Landing Methods===============================================
# Below are primarily Animation and LL Methods
func _get_landing_action_result(landing_on: FallingPiece, landing_on_pot: FallingPiece) -> Enums.LANDING_ACTION_RESULT:
	var piece_def: FallingTypeResourceDefinition = InGame.get_falling_type_resource_definition(type)
	match(piece_def.landing_action_type):
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR:
			if landing_on == null:
				return Enums.LANDING_ACTION_RESULT.GROUNDED
			if landing_on.type == type:
				return Enums.LANDING_ACTION_RESULT.CLEAR_MATCHED
			return Enums.LANDING_ACTION_RESULT.GROUNDED
		Enums.LANDING_ACTION_TYPE.TO_POT_AND_POT_CLEAR:
			if landing_on_pot != null:
				return Enums.LANDING_ACTION_RESULT.CLEAR_POT_AND_ABOVE
			return Enums.LANDING_ACTION_RESULT.CLEAR_SELF_ONLY
		Enums.LANDING_ACTION_TYPE.TO_POT_CLEAR:
			if landing_on_pot != null:
				return Enums.LANDING_ACTION_RESULT.CLEAR_ABOVE_POT_ONLY
			return Enums.LANDING_ACTION_RESULT.CLEAR_SELF_ONLY
	return Enums.LANDING_ACTION_RESULT.GROUNDED

# Default Falling Piece Methods:
func ground(landing_on: FallingPiece) -> bool:
	if not is_ready:
		return false
	if _animation_tree.ground():
		if landing_on == null:
			row_index = 0
		else:
			row_index = landing_on.row_index + 1
		if landing_on != null:
			landing_on.above = self
			below = landing_on
		_fractional_position.y = Methods.get_row_position_y(row_index)
		return true
	return false

func delink_node() -> void:
	if above != null:
		# loop through linked list updating row_indices.
		var above_loop = above
		while(above_loop != null):
			above_loop.row_index = above_loop.row_index - 1
			above_loop = above_loop.above
		# Middle Node, reconnect linked list
		# set above's below to below delinked node (self)
		above.below = below
		# set below's above to above delinked node (self)
		below.above = above
	elif below != null:
		# Middle Node, reconnect linked list
		# set below's above to above delinked node (self)
		below.above = null
	# clear references to list from self
	parent_update_signal.emit(self, Enums.FALLING_PIECE_UPDATE_TYPE.CLEARED)

func clear() -> bool:
	if not is_ready:
		return false
	delink_node()
	return _animation_tree.clear()

# Partial pot Methods:
func _after_pot() -> void:
	_into_pot_tween = null

func _queue_into_pot() -> Tween:
	if is_moving_into_pot:
		return
	_into_pot_tween = get_tree().create_tween()
	_into_pot_tween.tween_property(self, "_fractional_position:y", Consts.ROW_HEIGHT, Consts.QUEUE_INTO_POT_TIME).as_relative()
	_into_pot_tween.tween_callback(_after_pot)
	if above != null:
		# return the last called queue_into_pot
		var tween = above._queue_into_pot()
		if tween != null:
			return tween
	return _into_pot_tween

func _animate_into_pot(pot: FallingPiece) -> Tween:
	if not is_ready:
		return null
	_animation_tree.into_pot()
	var type_index = type as int
	if type_index < 0 or type_index > 3:
		_into_pot_tween = get_tree().create_tween()
		_into_pot_tween.tween_property(self, "_fractional_position:y", Methods.get_row_position_y(pot.row_index + 1), Consts.QUEUE_INTO_POT_TIME)
		#_into_pot_tween.tween_property(self, "_fractional_position:y", Methods.get_row_position_y(row_index), Consts.INTO_POT_TIME)
		_into_pot_tween.tween_callback(_after_pot)
		return _into_pot_tween
	_into_pot_tween = get_tree().create_tween()
	_into_pot_tween.tween_property(self, "_fractional_position:y", Methods.get_row_position_y(pot.row_index + 1) + Consts.INTO_POT_HEIGHT, Consts.INTO_POT_TIME)
	_into_pot_tween.tween_callback(_after_pot)
	return _into_pot_tween

func into_pot(pot: FallingPiece) -> Tween:
	var return_tween = null
	return_tween = _animate_into_pot(pot)
	if return_tween == null:
		return null
	if above != null:
		# return the longer tween of the above pot's time
		var tween = above._queue_into_pot()
		if tween != null:
			return_tween = tween
	delink_node()
	return return_tween

# Full pot Methods:
func _after_move_into_pot():
	parent_update_signal.emit(self, Enums.FALLING_PIECE_UPDATE_TYPE.MOVE_INTO_POT_FINISHED)
	_into_pot_triggered = false

func _move_into_pot_callable(pot: FallingPiece, clear_pot: bool) -> Callable:
	return func ():
		if pot.above == null or pot.above.above == null:
			if pot.above != null:
				var tween = pot.above.into_pot(pot)
			if clear_pot:
				pot.clear()
			_after_move_into_pot()
			return
		var tween = pot.above.into_pot(pot)
		if tween != null:
			tween.tween_callback(_move_into_pot_callable(pot, clear_pot))

func _move_above_pot_into_pot(pot: FallingPiece, clear_pot = true):
	if _into_pot_triggered:
		return
	_into_pot_triggered = true
	return _move_into_pot_callable(pot, clear_pot).call()

### returns true if it was a clear
func land(landing_on: FallingPiece, landing_on_pot: FallingPiece) -> Enums.LANDING_ACTION_RESULT:
	end_falling()
	ground(landing_on)
	var landing_result = _get_landing_action_result(landing_on, landing_on_pot)
	match(landing_result):
		Enums.LANDING_ACTION_RESULT.CLEAR_MATCHED:
			clear()
			var below_loop = below
			while (below_loop != null and below_loop.type == type):
				below_loop.clear()
				below_loop = below_loop.below
		Enums.LANDING_ACTION_RESULT.CLEAR_POT_AND_ABOVE:
			result_when_removed = Enums.ON_REMOVED_RESULT.NO_EFFECT
			_move_above_pot_into_pot(landing_on_pot)
		Enums.LANDING_ACTION_RESULT.CLEAR_SELF_ONLY:
			result_when_removed = Enums.ON_REMOVED_RESULT.NO_EFFECT
			clear()
		Enums.LANDING_ACTION_RESULT.CLEAR_ABOVE_POT_ONLY:
			result_when_removed = Enums.ON_REMOVED_RESULT.NO_EFFECT
			_move_above_pot_into_pot(landing_on_pot, false)
		_:
			pass
	return landing_result
# =================================Fail Column Methods=============================================
func _on_fail_timer_timeout() -> void:
	if below != null:
		below.fail()
	clear()
	
func fail() -> void:
	result_when_removed = Enums.ON_REMOVED_RESULT.NEGATIVE_EFFECT
	if below == null:
		parent_update_signal.emit(self, Enums.FALLING_PIECE_UPDATE_TYPE.FAIL_COMPLETE)
	_fail_timer.start()
# ===================================Physics Methods===============================================
# These are functions dealing with placing self

func set_position_from_fractional_position() -> void:
	position = Vector2(floor(_fractional_position.x), ceil(_fractional_position.y))

func begin_falling(new_hidden_falling_piece):
	hidden_falling_piece = new_hidden_falling_piece

func end_falling():
	hidden_falling_piece = null

func _after_swap() -> void:
	_swapping_tween = null

func swap(should_swap_left: bool, delay: float = 0.0) -> void:
	if is_swapping or column_index < 0:
		return
	if delay > 0:
		_delayed_swap_time_remaining = delay
		_delayed_swap_is_swapping_left = should_swap_left
		return
	var end_column_index = column_index + (-1 if should_swap_left else 1)
	var end_position_x = Methods.get_column_position_x(end_column_index)
	_swapping_tween = get_tree().create_tween()
	_swapping_tween.tween_property(self, "_fractional_position:x", end_position_x, Consts.WITCH_SWAP_TIME)
	_swapping_tween.tween_callback(_after_swap)
	column_index = end_column_index
	if above != null:
		above.swap(should_swap_left, Consts.SWAP_ABOVE_DELAY)

# ==================================Other Generic Methods==========================================
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _early_initialize_type != Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
		initialize(_early_initialize_type, column_index)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_falling:
		# if currently tracking a hidden_falling_piece, then set position.y
		# to integer value
		_fractional_position.y = hidden_falling_piece.position.y
	if _delayed_swap_time_remaining > 0:
		_delayed_swap_time_remaining -= delta
		if _delayed_swap_time_remaining <= 0:
			_delayed_swap_time_remaining = 0
			swap(_delayed_swap_is_swapping_left)
	position = Vector2(ceil(_fractional_position.x), floor(_fractional_position.y))

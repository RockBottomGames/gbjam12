@tool
extends CharacterBody2D
class_name FallingPiece
signal was_cleared(falling_piece: FallingPiece)

@onready var _animation_tree: FallingPieceAnimationTree = $FallingPiece/AnimationTree

var swapping_tween: Tween = null
var above: FallingPiece = null
var below: FallingPiece = null 
var level: int = 0
var _fractional_position: Vector2 = Vector2.ZERO
var _is_falling: bool = false
var _is_swapping: bool = false
var _is_swapping_left: bool = false
var _grounded_pos_y: int = -1
var _final_pos_x: int = -1
var _swap_above_time: float = 0.0
var _delayed_swap: float = 0.0

var is_initialized: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_initialized

var is_grounded: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_grounded

var is_falling: bool = false:
	# Update speed and reset the rotation.
	get:
		return _is_falling

var is_cleared: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_cleared

var landing_height: int = 0:
	# Update speed and reset the rotation.
	get:
		return (position.y - Consts.FALLING_PIECE_HEIGHT) as int
		
@export var type_to_add: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED
@export var position_to_set: Vector2 = Vector2.ZERO

var type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return Enums.FALLING_PIECE_TYPE.UNINITIALIZED
		return _animation_tree.type

func initialize(new_type: Enums.FALLING_PIECE_TYPE, new_position: Vector2) -> bool:
	type_to_add = new_type
	position_to_set = new_position
	if _animation_tree == null:
		return false
	position = new_position as Vector2i
	_fractional_position = new_position
	return _animation_tree.intialize(new_type)
	
func landing_is_a_clear(landing_on: FallingPiece) -> bool:
	if landing_on == null:
		return false
	if not is_initialized or not landing_on.is_initialized:
		return false
	return type == landing_on.type

### returns true if it was a clear
func land(landing_on: FallingPiece, destination_height: int) -> Enums.FALLING_PIECE_LANDING_TYPE:
	_is_falling = false
	position.y = destination_height
	_grounded_pos_y = destination_height
	if landing_on == null:
		ground(landing_on)
		return Enums.FALLING_PIECE_LANDING_TYPE.GROUNDED
	if landing_is_a_clear(landing_on):
		landing_on.clear()
		clear()
		return Enums.FALLING_PIECE_LANDING_TYPE.CLEARED
	ground(landing_on)
	return Enums.FALLING_PIECE_LANDING_TYPE.GROUNDED

func ground(landing_on: FallingPiece) -> bool:
	if _animation_tree == null:
		return false
	if _animation_tree.ground():
		if landing_on != null:
			landing_on.above = self
			below = landing_on
		return true
	return false

func clear(is_self_clear: bool = false) -> bool:
	if _animation_tree == null:
		return false
	if not is_self_clear and below != null:
		below.above = null
		below = null
	return _animation_tree.clear()

func release_data() -> bool:
	if _animation_tree == null:
		return false
	was_cleared.emit(self)
	_animation_tree.reset()
	if swapping_tween != null:
		swapping_tween.kill()
		swapping_tween = null
	_is_falling = false
	above = null
	below = null 
	level = 0
	return true

func begin_falling():
	_is_falling = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_swap_above_time = 0.0
	if type_to_add != Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
		initialize(type_to_add, position_to_set)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	position = _fractional_position
	var new_velocity = Vector2.ZERO
	if is_grounded:
		position.y = _grounded_pos_y
	if _delayed_swap > 0:
		_delayed_swap -= _delta
		if _delayed_swap <= 0:
			swap(_is_swapping_left)
	if _is_swapping and _swap_above_time > 0:
		_swap_above_time -= _delta
		if _swap_above_time <= 0:
			_on_swap_above_time()
	if !_is_falling:
		_fractional_position = position
		position = _fractional_position as Vector2i
		return
	new_velocity.y = Consts.FASTEST_FALLING_SPEED if Input.is_action_pressed("ui_down") else InGame.falling_speed
	velocity = new_velocity
	move_and_slide()
	_fractional_position = position
	position = _fractional_position as Vector2i

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _after_swap() -> void:
	_is_swapping = false
	swapping_tween = null

func swap(left: bool, delay: float = 0.0) -> void:
	if swapping_tween != null:
		return
	_is_swapping_left = left
	if delay > 0:
		_delayed_swap = delay
		return
	var swap_relative_x = (-Consts.COL_WIDTH) if left else Consts.COL_WIDTH
	swapping_tween = get_tree().create_tween()
	swapping_tween.tween_property(self, "_fractional_position:x", swap_relative_x, Consts.WITCH_SWAP_TIME).as_relative()
	_final_pos_x = (position.x + swap_relative_x) as int
	swapping_tween.tween_callback(_after_swap)
	_is_swapping = true
	_swap_above_time = Consts.SWAP_TOP_DELAY

func _on_swap_above_time() -> void:
	_is_swapping = false
	_swap_above_time = 0.0
	if above != null:
		above.swap(_is_swapping_left)

@tool
extends Sprite2D
class_name FallingPiece
signal was_cleared(type: int, was_grounded: bool)

@onready var _animation_tree: FallingPieceAnimationTree = $AnimationTree
var falling_tween: Tween = null
var swapping_tween: Tween = null
var above: FallingPiece = null
var below: FallingPiece = null 
var level: int = 0
var _fractional_position: Vector2 = Vector2.ZERO

@export var is_initialized: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_initialized

@export var is_grounded: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_grounded

@export var is_cleared: bool = false:
	# Update speed and reset the rotation.
	get:
		if _animation_tree == null:
			return false
		return _animation_tree.is_cleared
		
@export var type_to_add: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED
@export var position_to_set: Vector2 = Vector2.ZERO

@export var type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
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
func land(landing_on: FallingPiece) -> bool:
	if falling_tween != null:
		falling_tween.kill()
		falling_tween = null
	if landing_on == null:
		ground(landing_on)
		return false
	if landing_is_a_clear(landing_on):
		landing_on.clear()
		clear()
		return true
	ground(landing_on)
	return false

func ground(landing_on: FallingPiece) -> bool:
	if _animation_tree == null:
		return false
	if _animation_tree.ground():
		landing_on.above = self
		below = landing_on
		return true
	return false

func clear() -> bool:
	if _animation_tree == null:
		return false
	if below != null:
		below.above = null
		below = null
	return _animation_tree.clear()

func release_data() -> bool:
	if _animation_tree == null:
		return false
	was_cleared.emit(type, is_grounded)
	_animation_tree.reset()
	if falling_tween != null:
		falling_tween.kill()
		falling_tween = null
	if swapping_tween != null:
		swapping_tween.kill()
		swapping_tween = null
	above = null
	below = null 
	level = 0
	return true

func begin_falling():
	falling_tween = create_tween()
	# Interpolate the value using a custom curve.
	falling_tween.tween_property(self, "_fractional_position:y", Consts.GROUND_LEVEL_POS_Y, InGame.falling_time)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type_to_add != Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
		initialize(type_to_add, position_to_set)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = _fractional_position as Vector2i

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = _fractional_position as Vector2i 

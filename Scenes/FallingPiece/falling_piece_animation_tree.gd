@tool
extends AnimationTree
class_name FallingPieceAnimationTree

var is_initialized: bool = false:
	# Update speed and reset the rotation.
	get:
		return _is_initialized
		
var is_grounded: bool = false:
	# Update speed and reset the rotation.
	get:
		return _is_grounded
		
var is_cleared: bool = false:
	# Update speed and reset the rotation.
	get:
		return _is_cleared
		
var type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
	# Update speed and reset the rotation.
	get:
		return _type

@export var _is_initialized: bool = false
@export var _is_grounded: bool = false
@export var _is_cleared: bool = false
@export var _type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED

func intialize(new_type: Enums.FALLING_PIECE_TYPE) -> bool:
	if _is_initialized:
		return false
	match new_type:
		Enums.FALLING_PIECE_TYPE.EYE_OF_NEWT, Enums.FALLING_PIECE_TYPE.GIANTS_THUMB, Enums.FALLING_PIECE_TYPE.VAMPIRES_TEETH, Enums.FALLING_PIECE_TYPE.WING_OF_BAT:
			_is_grounded = false
			_is_cleared = false
			_type = new_type
			_is_initialized = true
			return true
		_:
			return false

func ground() -> bool:
	if not _is_initialized or _is_grounded or _is_cleared:
		return false
	_is_grounded = true
	return true

func clear() -> bool:
	if not _is_initialized or _is_cleared:
		return false
	_is_cleared = true
	return true

func reset():
	_is_grounded = false
	_is_cleared = false
	_is_initialized = false
	_type = Enums.FALLING_PIECE_TYPE.UNINITIALIZED

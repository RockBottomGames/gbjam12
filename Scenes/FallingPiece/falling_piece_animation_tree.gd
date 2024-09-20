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

func _initialize_blend_tree_parameters_by_type():
	set("parameters/time_reset/seek_request", fmod((Time.get_ticks_msec() as float) / 1000.0, 2.0))
	var type_index: int = _type as int
	set("parameters/falling_animations/transition_request", str("state_", type_index))
	set("parameters/grounded_animations/transition_request", str("state_", type_index))
	if type_index >= 0 and type_index <= 3:
		set("parameters/into_pot_animations/transition_request", str("state_", type_index))
	set("parameters/synced_transitions/transition_request", "falling")
	set("parameters/reset_transitions/transition_request", "synced_animations")
	
func _set_grounded_blend_tree_parameters():
	set("parameters/synced_transitions/transition_request", "grounded")
	
func _set_cleared_blend_tree_parameters():
	set("parameters/reset_transitions/transition_request", "cleared")
	
func _set_into_pot_blend_tree_parameters():
	var type_index: int = _type as int
	if type_index >= 0 and type_index <= 3:
		set("parameters/reset_transitions/transition_request", "into_pot")
	else:
		set("parameters/reset_transitions/transition_request", "cleared")
	
func _reset_blend_tree_parameters():
	set("parameters/falling_animations/transition_request", "state_0")
	set("parameters/grounded_animations/transition_request", "state_0")
	set("parameters/into_pot_animations/transition_request", "state_0")
	set("parameters/synced_transitions/transition_request", "uninitialized")
	set("parameters/reset_transitions/transition_request", "synced_animations")

func intialize(new_type: Enums.FALLING_PIECE_TYPE) -> bool:
	if _is_initialized:
		return false
	match new_type:
		Enums.FALLING_PIECE_TYPE.EYE_OF_NEWT, Enums.FALLING_PIECE_TYPE.GIANTS_THUMB, Enums.FALLING_PIECE_TYPE.VAMPIRES_TEETH, Enums.FALLING_PIECE_TYPE.WING_OF_BAT, Enums.FALLING_PIECE_TYPE.POT_BOTTOM, Enums.FALLING_PIECE_TYPE.POT_TOP:
			
			#set("parameters/time_reset/seek_request", fmod((Time.get_ticks_msec() as float) / 1000.0,2.0))
			_is_grounded = false
			_is_cleared = false
			_type = new_type
			_initialize_blend_tree_parameters_by_type()
			_is_initialized = true
			return true
		_:
			return false

func ground() -> bool:
	if not _is_initialized or _is_grounded or _is_cleared:
		return false
	_set_grounded_blend_tree_parameters()
	_is_grounded = true
	return true
	
func into_pot() -> bool:
	if not _is_initialized or _is_cleared:
		return false
	_set_into_pot_blend_tree_parameters()
	_is_cleared = true
	return true

func clear() -> bool:
	if not _is_initialized or _is_cleared:
		return false
	_set_cleared_blend_tree_parameters()
	_is_cleared = true
	return true

func reset():
	_is_grounded = false
	_is_cleared = false
	_is_initialized = false
	_reset_blend_tree_parameters()
	_type = Enums.FALLING_PIECE_TYPE.UNINITIALIZED

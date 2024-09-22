@tool
extends Resource
class_name FallingTypeResourceDefinition

var _type : Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED
var type : Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED:
	get:
		return _type

var _landing_action_type : Enums.LANDING_ACTION_TYPE = Enums.LANDING_ACTION_TYPE.UNINITIALIZED
var landing_action_type : Enums.LANDING_ACTION_TYPE = Enums.LANDING_ACTION_TYPE.UNINITIALIZED:
	get:
		return _landing_action_type

var _weight 
var weight : float = 0.0:
	get:
		return _weight

func clone_with_new_weight(new_weight: float) -> FallingTypeResourceDefinition:
	return FallingTypeResourceDefinition.new(self.type, self.landing_action_type, new_weight)
	
func clone() -> FallingTypeResourceDefinition:
	return FallingTypeResourceDefinition.new(self.type, self.landing_action_type, self.weight)

func _init(
	new_type: Enums.FALLING_PIECE_TYPE = Enums.FALLING_PIECE_TYPE.UNINITIALIZED,
	new_landing_action_type: Enums.LANDING_ACTION_TYPE = Enums.LANDING_ACTION_TYPE.UNINITIALIZED,
	new_weight: float = 0.0
):
	_type = new_type
	_landing_action_type = new_landing_action_type
	_weight = new_weight
	

extends Node

var rng = RandomNumberGenerator.new()

var falling_pieces_weights: Array[float] = []
var falling_pieces_total_weight: int = 0:
	# Update speed and reset the rotation.
	get:
		if falling_pieces_weights.is_empty():
			return 0
		return falling_pieces_weights.reduce(func(accum, number): return accum + number, 0)

var falling_speed: float = 1.0

func reset_falling_pieces_weights() -> void:
	falling_pieces_weights = []
	for index in Consts.FALLING_PIECE_TYPES_NUM:
		falling_pieces_weights.append(Consts.FALLING_PIECE_STARTING_WEIGHT)

func get_random_falling_piece_type() -> Enums.FALLING_PIECE_TYPE:
	var random_num = rng.randi() % falling_pieces_total_weight
	var accum_weight: float = 0
	var found_index: int = -1
	for index in Consts.FALLING_PIECE_TYPES_NUM:
		accum_weight += falling_pieces_weights[index]
		if random_num < accum_weight:
			found_index = index
			break
	return found_index as Enums.FALLING_PIECE_TYPE

func reset_falling_type_lookup() -> void:
	_fallingTypeResourceDefinitionLookup.clear()
	var lookup: Dictionary = Consts.FALLING_TYPE_RESOURCE_DEFAULT_VALUE_LOOKUP
	for falling_piece_type: Enums.FALLING_PIECE_TYPE in lookup:
		var falling_type_resource: FallingTypeResourceDefinition = lookup[falling_piece_type]
		if falling_type_resource.weight > 0.0:
			_fallingTypeResourceDefinitionLookup[falling_piece_type] = falling_type_resource

#dictionary of resources
var _fallingTypeResourceDefinitionLookup: Dictionary = {}

func get_falling_type_resource_definition(type: Enums.FALLING_PIECE_TYPE) -> FallingTypeResourceDefinition:
	if not _fallingTypeResourceDefinitionLookup.has(type):
		return null
	return _fallingTypeResourceDefinitionLookup[type]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_falling_type_lookup()
	rng.randomize()
	reset_falling_pieces_weights()

# ======================================= Variables that vary =====================================

var three_item_chance = Consts.INITIAL_THREE_ITEM_CHANCE

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

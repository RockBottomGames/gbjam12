extends Node

var rng = RandomNumberGenerator.new()

var falling_pieces_weights: Array[int] = []
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
	var accum_weight: int = 0
	var found_index: int = -1
	for index in Consts.FALLING_PIECE_TYPES_NUM:
		accum_weight += falling_pieces_weights[index]
		if random_num < accum_weight:
			found_index = index
			break
	return found_index as Enums.FALLING_PIECE_TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	reset_falling_pieces_weights()


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

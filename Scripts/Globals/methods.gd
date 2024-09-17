class_name Methods

static func convert_falling_height_to_swap_delay(height: float) -> float:
	var zeroed_height: float = height - Consts.TOPMOST_PIECE_HEIGHT
	var zeroed_ground_level: float = Consts.GROUND_LEVEL_POS_Y - Consts.TOPMOST_PIECE_HEIGHT
	var actual_height: float = zeroed_ground_level - zeroed_height
	return ((actual_height / zeroed_ground_level) as int) * Consts.FULL_SWAP_CASCADE_TIME

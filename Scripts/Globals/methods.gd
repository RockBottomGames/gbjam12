class_name Methods

static func convert_falling_height_to_swap_delay(height: float) -> float:
	var zeroed_height: float = height - Consts.TOPMOST_PIECE_HEIGHT
	var zeroed_ground_level: float = Consts.GROUND_LEVEL_POS_Y - Consts.TOPMOST_PIECE_HEIGHT
	var actual_height: float = zeroed_ground_level - zeroed_height
	return ((actual_height / zeroed_ground_level) as int) * Consts.FULL_SWAP_CASCADE_TIME

static func get_column_position_x(column_index) -> float:
	if column_index < 0 or column_index > Consts.MAX_COL_INDEX:
		return -1
	return Consts.LEFT_COL_POS_X + (column_index * Consts.COL_WIDTH)

static func get_row_position_y(row_index = -1) -> float:
	# If no row is explicitly given it is expected to be in the waiting row.
	if row_index == -1:
		return Consts.WAITING_ROW_Y
	# Using ROW_NUM instead of MAX_ROW_INDEX because death row is 1+
	if row_index < -1 or row_index > Consts.ROW_NUM:
		return -1
	return Consts.GROUND_ROW_Y - (row_index * Consts.ROW_HEIGHT)

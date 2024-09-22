class_name Consts

# ========================Timer Values=========================================
const TIME_BEFORE_FALLING: float = 0.5

# =======================Column Values=========================================
const COL_NUM: int = 4
const COL_WIDTH: int = 22
const MAX_COL_INDEX: int = COL_NUM - 1

	# Pixel Positions
const LEFT_COL_POS_X: int = 4

# TODO: To Move Into Classes:
	# Witch Values
const MAX_WITCH_COL_INDEX: int = MAX_COL_INDEX - 1

# TODO: To Remove:
const LEFT_PLAT_POS_X: int = 3

# =========================Row Values==========================================
const ROW_NUM = 8
const MAX_ROW_INDEX: int = ROW_NUM - 1

# TODO: To Replace top with bottom:
const FALLING_PIECE_HEIGHT: int = 12
const ROW_HEIGHT: int = 12

# TODO: To Replace top with bottom:
const GROUND_LEVEL_POS_Y: int = 116
const GROUND_ROW_Y: int = 116

# TODO: To Replace top with bottom:
const WAITING_AREA_POS_Y: int = 17
const WAITING_ROW_Y: int = 17

# TODO: To Replace top with bottom:
const ADD_WAITING_AREA_POS_Y: int = 23
const REFRESH_WAITING_ROW_AT_Y: int = 23

# TODO: To Replace top with bottom:
const TOPMOST_PIECE_HEIGHT: int = GROUND_LEVEL_POS_Y - (7 * FALLING_PIECE_HEIGHT)
const TOP_ROW_Y: int = GROUND_ROW_Y - (MAX_ROW_INDEX * ROW_HEIGHT)

# TODO: To Replace top with bottom:
const DEATH_HEIGHT: float = TOPMOST_PIECE_HEIGHT - FALLING_PIECE_HEIGHT
const FAIL_ROW_INDEX: int = ROW_NUM


# =======================Falling Pieces========================================
const FASTEST_FALLING_SPEED: float = 75.0

const INTO_POT_TIME: float = 0.1
const INTO_POT_HEIGHT: int = 5
const QUEUE_INTO_POT_TIME: float = 0.2

# TODO: To Replace top with bottom:
const SWAP_TOP_DELAY: float = 0.03
const SWAP_ABOVE_DELAY: float = 0.03

# TODO: To Replace top with bottom or bottom method:
const FULL_SWAP_CASCADE_TIME: float = (7 * SWAP_TOP_DELAY)
const MAX_CASCADE_TIME: float = (MAX_ROW_INDEX * SWAP_ABOVE_DELAY)
# or Methods.CalculateSwapTime(CurrentColRowCount) -> ((CurrentColRowCount - 1) * SWAP_ABOVE_DELAY)

# TODO To Replace top with bottom or bottom method:
const TOTAL_SWAP_TIME: float = WITCH_SWAP_TIME + FULL_SWAP_CASCADE_TIME + SWAP_TOP_DELAY
const MAX_SWAP_TIME: float = WITCH_SWAP_TIME + MAX_CASCADE_TIME + SWAP_ABOVE_DELAY


# TODO: To Replace following list of variables with bottom dictionary of resources:
# list of variables
const FALLING_PIECE_TYPES_NUM: int = 6
const FALLING_PIECE_STARTING_WEIGHT: float = 10.0
const FALLING_POT_TOP_STARTING_WEIGHT: float = 2

#dictionary of resources
static var FALLING_TYPE_RESOURCE_DEFAULT_VALUE_LOOKUP: Dictionary = {
	Enums.FALLING_PIECE_TYPE.UNINITIALIZED: FallingTypeResourceDefinition.new(),
	Enums.FALLING_PIECE_TYPE.EYE_OF_NEWT: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.EYE_OF_NEWT,
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR,
		FALLING_PIECE_STARTING_WEIGHT
	),
	Enums.FALLING_PIECE_TYPE.GIANTS_THUMB: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.GIANTS_THUMB,
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR,
		FALLING_PIECE_STARTING_WEIGHT
	),
	Enums.FALLING_PIECE_TYPE.VAMPIRES_TEETH: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.VAMPIRES_TEETH,
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR,
		FALLING_PIECE_STARTING_WEIGHT
	),
	Enums.FALLING_PIECE_TYPE.WING_OF_BAT: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.WING_OF_BAT,
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR,
		FALLING_PIECE_STARTING_WEIGHT
	),
	Enums.FALLING_PIECE_TYPE.POT_BOTTOM: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.POT_BOTTOM,
		Enums.LANDING_ACTION_TYPE.MATCH_CLEAR,
		FALLING_PIECE_STARTING_WEIGHT
	),
	Enums.FALLING_PIECE_TYPE.POT_TOP: FallingTypeResourceDefinition.new(
		Enums.FALLING_PIECE_TYPE.POT_TOP,
		Enums.LANDING_ACTION_TYPE.TO_POT_AND_POT_CLEAR,
		FALLING_POT_TOP_STARTING_WEIGHT
	),
}

# ==============================Witch==========================================
const WITCH_SWAP_TIME: float = 0.1

# ============================Game Values======================================
const INITIAL_THREE_ITEM_CHANCE: float = 0.01

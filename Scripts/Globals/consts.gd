class_name Consts

const COL_WIDTH: int = 22
const COL_NUM: int = 4
const MAX_COL_INDEX: int = COL_NUM - 1
const MAX_WITCH_COL_INDEX: int = MAX_COL_INDEX - 1
const LEFT_COL_POS_X: int = 4
const GROUND_LEVEL_POS_Y: int = 116
const LEFT_PLAT_POS_X: int = 3
const WAITING_AREA_POS_Y: int = 17
const ADD_WAITING_AREA_POS_Y: int = 23
const FALLING_PIECE_HEIGHT: int = 12

const FALLING_PIECE_TYPES_NUM: int = 6
const FALLING_PIECE_STARTING_WEIGHT: int = 10
const FASTEST_FALLING_SPEED: float = 75.0
const TOTAL_GROUNDED_AREA: float = 96.0
const TOPMOST_PIECE_HEIGHT = GROUND_LEVEL_POS_Y - (7 * FALLING_PIECE_HEIGHT)
const DEATH_HEIGHT: float = TOPMOST_PIECE_HEIGHT - FALLING_PIECE_HEIGHT

const INTO_POT_TIME: float = 0.1
const INTO_POT_HEIGHT: int = 5
const QUEUE_INTO_POT_TIME: float = 0.24
const WITCH_SWAP_TIME: float = 0.1
const SWAP_TOP_DELAY: float = 0.03
const FULL_SWAP_CASCADE_TIME: float = (7 * SWAP_TOP_DELAY)
const TOTAL_SWAP_TIME: float = WITCH_SWAP_TIME + FULL_SWAP_CASCADE_TIME + SWAP_TOP_DELAY

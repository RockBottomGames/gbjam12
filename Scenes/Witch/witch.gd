extends Sprite2D
class_name Witch

@export var _is_swapping: bool = false
@export var _is_moving: bool = false
@export var _starting_position: Vector2 = Vector2.ZERO
@export var _column: int = 0

@onready var animation_tree: WitchAnimationTree = $AnimationTree
@onready var switch_cooldown_timer: Timer = $SwitchCooldownTimer
@onready var move_cooldown_timer: Timer = $MoveCooldownTimer

@export var facing_forward: bool = false:
	# Update speed and reset the rotation.
	get:
		if animation_tree == null:
			return true
		return animation_tree.facing_forward

@export var column: int = 0:
	# Update speed and reset the rotation.
	get:
		return _column

func swap() -> bool:
	if _is_swapping:
		return false
	if !animation_tree.begin_switch():
		return false
	_is_swapping = true
	switch_cooldown_timer.start()
	return true

func move_left() -> bool:
	if _is_moving or (animation_tree!= null and animation_tree.is_switching) or _column < 1:
		return false
	_column -= 1
	_correct_column_num()
	_update_position()
	_start_move()
	return true
	
func move_right() -> bool:
	if _is_moving or (animation_tree!= null and animation_tree.is_switching) or _column >= Consts.MAX_WITCH_COL_INDEX:
		return false
	_column += 1
	_correct_column_num()
	_update_position()
	_start_move()
	return true
	
func _start_move() -> void:
	if _is_moving:
		return
	_is_moving = true
	move_cooldown_timer.start()

func _correct_column_num() -> void:
	if _column < 0:
		_column = 0
	elif _column > Consts.MAX_WITCH_COL_INDEX:
		_column = Consts.MAX_WITCH_COL_INDEX

func _update_position() -> void:
	position = _starting_position + Vector2(Consts.COL_WIDTH * _column, 0)

func _on_switch_cooldown_timer_timeout() -> void:
	_is_swapping = false
	
func _on_move_cooldown_timer_timeout() -> void:
	_is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _starting_position == Vector2.ZERO:
		_starting_position = position
	if _column != 0:
		_update_position()


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

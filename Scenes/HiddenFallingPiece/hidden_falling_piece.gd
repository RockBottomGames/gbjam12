extends CharacterBody2D
class_name HiddenFallingPiece

@onready var _start_falling_timer: Timer = $StartFallingTimer

@export var speed: float = InGame.falling_speed
@export var fast_speed: float = Consts.FASTEST_FALLING_SPEED

var _is_falling: bool = false
var is_falling: bool = false:
	get:
		return _is_falling
		
var _is_fast_falling: bool = false

func reset() -> void:
	stop_falling()
	position.y = Consts.WAITING_AREA_POS_Y
	_start_falling_timer.start()

func begin_falling() -> void:
	_is_falling = true

func stop_falling() -> void:
	_is_falling = false

func begin_fast_falling() -> void:
	_is_fast_falling = true

func stop_fast_falling() -> void:
	_is_fast_falling = false
	
func instant_fall() -> void:
	if _is_falling:
		position.y = Consts.GROUND_LEVEL_POS_Y

func _on_start_falling_timer_timeout() -> void:
	begin_falling()

func _ready() -> void:
	_start_falling_timer.wait_time = Consts.TIME_BEFORE_FALLING
	
func _physics_process(_delta: float) -> void:
	var new_velocity = Vector2.ZERO
	if _is_falling:
		new_velocity.y = fast_speed if _is_fast_falling else speed
	velocity = new_velocity
	move_and_slide()

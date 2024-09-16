extends AnimationTree
class_name WitchAnimationTree

@export var _is_switching: bool = false

@export var is_switching: bool = false:
	# Update speed and reset the rotation.
	get:
		return _is_switching

@export var _facing_forward: bool = true
@export var facing_forward: bool = false:
	# Update speed and reset the rotation.
	get:
		return _facing_forward

func begin_switch() -> bool:
	if _is_switching:
		return false
	_is_switching = true
	return true

func _end_switch(new_facing_forward: bool) -> void:
	_is_switching = false
	_facing_forward = new_facing_forward

func _end_switch_facing_forward() -> void:
	_end_switch(true)
	
func _end_switch_facing_backward() -> void:
	_end_switch(false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

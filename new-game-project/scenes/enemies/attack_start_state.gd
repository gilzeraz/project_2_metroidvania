class_name AttackStartState
extends State
## Controls attack telegraphing sequence and animation locking.
##
## Halts character velocity, plays the attack telegraph animation, and
## transitions to the dive state upon animation completion.


## State to transition to once the telegraphing animation finishes.
@export var dive_state: State

var _animation_done: bool = false


func enter() -> void:
	_animation_done = false
	actor.velocity = Vector2.ZERO
	actor.sprite.play("attack_start")
	actor.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func physics_update(_delta: float) -> State:
	if _animation_done:
		return dive_state

	return null


# Sets the animation completion flag when attack_start animation finishes
func _on_animation_finished() -> void:
	_animation_done = true

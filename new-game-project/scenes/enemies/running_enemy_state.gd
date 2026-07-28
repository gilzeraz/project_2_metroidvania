class_name RunningState
extends State
## Running behavior state for the enemy unit.
##
## Forces a directional turn on entry and drives high-speed movement for a set 
## duration before transitioning to a designated follow-up state.


const RAY_DISTANCE: float = 20.0

## State to transition to once the running timer expires.
@export var next_state: State

## Duration in seconds that this high-speed run behavior remains active.
@export var run_duration: float = 3.0

# Remaining time in seconds before the running state terminates.
var _run_timer: float = 0.0


func enter() -> void:
	actor.facing_direction *= -1
	_run_timer = run_duration
	


func physics_update(delta: float) -> State:
	_run_timer -= delta
	if _run_timer <= 0.0:
		return next_state

	if actor.is_on_wall():
		actor.facing_direction *= -1
		
	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta
	
	actor.ray.position.x = (actor.running_speed * delta + RAY_DISTANCE) * actor.facing_direction
	
	if not actor.ray.is_colliding():
		actor.facing_direction *= -1
		
	actor.velocity.x = actor.facing_direction * actor.running_speed
	actor.move_and_slide()
	
	return null

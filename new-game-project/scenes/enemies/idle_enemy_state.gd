class_name IdleEnemyState
extends State
## Controls default idle behavior, floating hover math, and vision transitions.
##
## Manages idle timers, floating height restoration for aerial enemies, and
## conditional state transitions to chase or attack states.


## State to transition to when executing an immediate attack reaction.
@export var attack_state: State
## Default next state to transition to after idle wait duration expires.
@export var next_state: State = null
## Duration in seconds to remain in idle before transitioning to next_state.
@export var wait_time: float = 2.0
## Amplitude multiplier for floating vertical oscillation.
@export var float_amplitude: float = 4.0
## Frequency speed for floating vertical oscillation.
@export var float_speed: float = 2.0
## State to transition to when a player is detected within pursuit conditions.
@export var chase_state: State
## Vertical speed applied when returning to baseline patrol altitude.
@export var return_speed: float = 30.0
## Distance tolerance threshold to consider baseline altitude reached for chasing.
@export var chase_ready_distance: float = 6.0


var current_wait_time: float = 0.0
var is_archer: bool = false
var idle_y: float = 0.0
var time: float = 0.0


func enter() -> void:
	actor.sprite.play("idle")
	current_wait_time = 0.0

	if actor is FlyingMonster:
		idle_y = actor.patrol_y

	if actor is Boss:
		actor.is_comboing = false


func physics_update(delta: float) -> State:
	if actor is FlyingMonster:
		time += delta
		actor.velocity = Vector2.ZERO
		var target_y: float = idle_y + sin(time * float_speed) * float_amplitude
		actor.global_position.y = move_toward(actor.global_position.y, target_y, return_speed * delta)

		if actor.player_visible and absf(actor.global_position.y - idle_y) <= chase_ready_distance:
			return chase_state

	if is_archer and actor.player_visible:
		if next_state is not EnemyAttackState:
			return attack_state

	current_wait_time += delta
	if current_wait_time >= wait_time:
		return next_state

	return null

class_name EnemyPatrolState
extends State
## Controls horizontal patrol movement, turns at walls or ledges, and optionally reacts to the player.


## Seconds spent idle after turning around before resuming patrol.
const WAIT_TIME: float = 2.0

## Whether this unit ignores the player and stays on patrol forever.
@export var ignore_player: bool = false
## State to transition to when the player is detected. Unused if [param ignore_player] is true.
@export var attack_state: State
## State to transition to after turning around. Leave empty to turn instantly, with no idle pause.
@export var idle_state: State

var _just_entered: bool = false


## Starts the patrol animation and flags this as a fresh entry into the state.
func enter() -> void:
	actor.sprite.play("patrol")
	_just_entered = true


## Moves the actor forward, turns around at walls or ledges, and checks for the player unless ignored.
func physics_update(delta: float) -> State:
	if not ignore_player and actor.player_visible:
		return attack_state
		
	actor.velocity.y += actor.get_gravity().y * delta
	
	if actor.is_on_wall() or not actor.ray.is_colliding():
		if idle_state and not _just_entered:
			idle_state.wait_time = WAIT_TIME
			idle_state.next_state = self
			return idle_state
			
		actor.facing_direction *= -1
		
	actor.velocity.x = float(actor.facing_direction) * actor.speed
	actor.move_and_slide()
	_just_entered = false
	
	return null

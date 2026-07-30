class_name FlyingEnemyChaseState
extends State
## Controls airborne enemy pursuit movement and vertical position tracking.


#region Properties
## Frequency speed for vertical sine wave floating oscillation.
const HOVER_SINE_SPEED: float = 4.0
## Amplitude multiplier for vertical sine wave floating oscillation.
const HOVER_SINE_AMPLITUDE: float = 2.0

## State to transition to when losing line-of-sight with the player.
@export var idle_state: State
## State to transition to when within horizontal attack distance.
@export var attack_state: State
## Target height maintained above player position in pixels.
@export var height_offset: float = 150.0
## Minimum horizontal distance threshold required to trigger an attack.
@export var attack_range_x: float = 40.0
## Speed applied when adjusting vertical altitude towards target height.
@export var vertical_speed: float = 40.0

var time: float = 0.0
#endregion


func enter() -> void:
	actor.sprite.play("fly")
	time = 0.0
	actor.patrol_y = actor.global_position.y


func physics_update(delta: float) -> State:
	if not actor.player_visible:
		return idle_state

	time += delta

	var target_x: float = Player.player.global_position.x
	actor.global_position.x = move_toward(
		actor.global_position.x,
		target_x,
		actor.speed * delta
	)

	var distance_x: float = Player.player.global_position.x - actor.global_position.x
	if distance_x != 0.0:
		actor.facing_direction = int(sign(-distance_x))

	var target_y: float = Player.player.global_position.y - height_offset
	actor.global_position.y = move_toward(
		actor.global_position.y,
		target_y,
		vertical_speed * delta
	)
	actor.global_position.y += sin(time * HOVER_SINE_SPEED) * HOVER_SINE_AMPLITUDE

	if absf(distance_x) <= attack_range_x:
		return attack_state

	return null

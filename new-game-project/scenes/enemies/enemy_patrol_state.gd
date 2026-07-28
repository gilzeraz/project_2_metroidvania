class_name EnemyPatrolState
extends State
## Controls horizontal patrol movement and boundary detection for ground units.
##
## Moves the actor within ground boundaries, reverses facing direction on walls or
## ledge cliffs, and transitions to idle or attack states upon detection conditions.


## State to transition to when a player body enters vision or detection range.
@export var attack_state: State
## State to transition to when reaching patrol limits or obstacles.
@export var idle_state: State

var just_entered: bool = false

@onready var detection_area: Area2D = $"../../DetectionArea"


func enter() -> void:
	actor.sprite.play("patrol")
	just_entered = true


func physics_update(delta: float) -> State:
	if actor.player_visible:
		return attack_state

	actor.velocity.y += actor.get_gravity().y * delta

	if actor.is_on_wall() or not actor.ray.is_colliding():
		if not just_entered:
			idle_state.wait_time = 2.0
			idle_state.next_state = self
			return idle_state

		actor.facing_direction *= -1

	actor.velocity.x = float(actor.facing_direction) * actor.speed
	actor.move_and_slide()

	just_entered = false

	return null

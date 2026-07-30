class_name BossHurtState
extends State
## Hurt recovery state for the enemy boss unit.


## State to transition to once the hurt animation completes.
@export var move_state: State

var hurt_finished: bool = false


func enter() -> void:
	hurt_finished = false
	
	actor.velocity.x = 0.0
	actor.sprite.play("hurt")
	
	if actor is Boss:
		actor.is_comboing = false
	
	if not actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.connect(_on_animation_finished)


func physics_update(_delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta
	else:
		actor.velocity.x = 0.0
		
	actor.move_and_slide()

	if hurt_finished: return move_state
		
	return null


func exit() -> void:
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished() -> void:
	if actor.sprite.animation == "hurt":
		hurt_finished = true

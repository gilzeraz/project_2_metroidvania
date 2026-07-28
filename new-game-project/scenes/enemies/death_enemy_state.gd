class_name DeathEnemyState
extends State
## Controls enemy unit death sequence and node queue cleanup.
##
## Halts horizontal movement, applies gravity for ground units, plays the death
## animation, and safely removes the actor from the scene tree.


func enter() -> void:
	actor.velocity.x = 0.0
	actor.sprite.play("death")
	actor.sprite.animation_finished.connect(_on_death_finished)


func physics_update(delta: float) -> State:
	if actor is not FlyingMonster:
		actor.velocity.y += actor.get_gravity().y * delta

	actor.move_and_slide()

	return null


# Safely queue-frees the actor node when the death animation finishes
func _on_death_finished() -> void:
	actor.queue_free()

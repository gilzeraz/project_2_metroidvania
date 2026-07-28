class_name DeathBoss
extends State
## Controls boss death sequence, collision disabling, and node queue cleanup.
##
## Disables physical collisions, detection areas, and combat hitboxes to prevent
## interaction during the death animation before removing the actor from the scene tree.


func enter() -> void:
	actor.velocity = Vector2.ZERO

	actor.sprite.play("death")

	if not actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.connect(_on_animation_finished)


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * delta
	else:
		actor.velocity.x = 0.0

	actor.move_and_slide()

	return null


# Safely queue-frees the actor node when the death animation finishes playing
func _on_animation_finished() -> void:
	if actor.sprite.animation == "death":
		actor.queue_free()

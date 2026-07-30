class_name EnemyDeathState
extends State
## Controls enemy unit death sequence and node queue cleanup.


func enter() -> void:
	actor.velocity.x = 0.0
	actor.sprite.play("death")
	actor.sprite.animation_finished.connect(_on_death_finished)


func physics_update(delta: float) -> State:
	if actor is not FlyingMonster:
		actor.velocity.y += actor.get_gravity().y * delta

	actor.move_and_slide()

	return null


func _on_death_finished() -> void:
	actor.queue_free()

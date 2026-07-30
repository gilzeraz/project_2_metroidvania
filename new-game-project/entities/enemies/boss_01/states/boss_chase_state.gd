class_name EnemyChaseState
extends State
## Controls enemy unit pursuit movement towards the player.


func enter() -> void:
	actor.sprite.play("walk")


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta

	if not actor.player_near:
		return actor.idle_state

	var direction: float = signf(Player.player.global_position.x - actor.global_position.x)
	actor.velocity.x = direction * actor.speed
	actor.move_and_slide()

	return null

class_name EnemyShootState
extends State
## Ranged combat state for projectile-firing enemy units.
##
## Tracks player positioning, manages horizontal orientation, and instantiates
## projectile scenes at designated animation frames.


## Packed scene of the projectile entity to be instantiated.
@export var arrow_scene: PackedScene

@export var idle_state: State

## State to transition to if the player target is lost during combat.
@export var patrol_state: State

## Vertical position offset applied to targeting calculations.
const TARGET_Y_OFFSET: float = -40.0


func enter() -> void:
	if not actor.player_visible:
		idle_state.next_state = patrol_state
		state_machine.change_state(idle_state)
	
	actor.velocity.x = 0.0
	actor.move_and_slide()
	actor.sprite.play("attack")
	
	if not actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.connect(_on_animation_finished)


func physics_update(delta: float) -> State:
	actor.velocity.y += actor.get_gravity().y * delta
	

	if not actor.player_near:
		return patrol_state

	_face_player()

	return null


func exit() -> void:
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)


# Rotates the actor horizontally to directly face the current player target
func _face_player() -> void:
	var dir_to_player: float = Player.player.global_position.x - actor.global_position.x
	actor._set_facing_direction(1 if dir_to_player > 0.0 else -1)


# Instantiates and initializes a projectile instance towards the target
func _shoot() -> void:
	if not arrow_scene or not actor.player_near:
		return
		
	var arrow: Node2D = arrow_scene.instantiate() as Node2D
	actor.get_parent().add_child(arrow)
	arrow.global_position = actor.arrow_point.global_position

	var target_position: Vector2 = Player.player.global_position + Vector2(0.0, TARGET_Y_OFFSET)
	arrow.set_direction((target_position - arrow.global_position).normalized())


func _on_animation_finished() -> void:
	_shoot()
	idle_state.wait_time = 1.0
	idle_state.next_state = self
	state_machine.change_state(idle_state)

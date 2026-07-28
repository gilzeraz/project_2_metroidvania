class_name AttackDiveState
extends State
## Controls committed diving attack movement towards a locked target position.
##
## Locks initial target coordinates, moves at high velocity, and transitions
## to impact state upon reaching the location, hitting a player, or colliding.


## State to transition to upon impact or reaching target coordinates.
@export var impact_state: State
## Linear velocity magnitude applied during the dive attack movement.
@export var dive_speed: float = 240.0
## Distance tolerance threshold in pixels to register arrival at target coordinates.
@export var arrival_distance: float = 12.0

var _hit_player: bool = false
var _target_position: Vector2 = Vector2.ZERO


func enter() -> void:
	_hit_player = false
	_target_position = Player.player.global_position
	actor.sprite.play("attack_middle")
	actor.attack_area.body_entered.connect(_on_attack_area_body_entered)


func physics_update(_delta: float) -> State:
	if _hit_player:
		return impact_state

	var direction: Vector2 = (_target_position - actor.global_position)
	if direction.length() <= arrival_distance:
		return impact_state

	direction = direction.normalized()
	actor.velocity = direction * dive_speed

	if direction.x != 0.0:
		actor.facing_direction = int(sign(direction.x))

	actor.move_and_slide()

	if actor.is_on_floor():
		return impact_state

	return null


func exit() -> void:
	if actor.attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		actor.attack_area.body_entered.disconnect(_on_attack_area_body_entered)


# Flags target hit when a Player enters the attack collision area
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_hit_player = true

class_name FlyingKickBoss
extends State
## Flying kick gap-closer combat state for the enemy boss unit.
##
## Performs a high-velocity horizontal leap in the actor's facing direction, 
## checking for the attack hit frame mid-air and applying physical damage.


## State to transition to once the flying kick animation completes.
@export var move_state: State

## Velocity multiplier applied to the actor's base movement speed during the leap.
@export var dash_speed_multiplier: float = 2.5

## Amount of damage dealt to the target upon a successful hit.
@export var damage: int = 25

## Animation frame index where weapon collision checking is initiated.
@export var hit_frame: int = 2

## Duration in seconds the combat area remains active during the leap.
@export var active_duration: float = 0.2

var attack_finished: bool = false

var dash_direction: int = 1

var _hit_triggered: bool = false


func enter() -> void:
	attack_finished = false
	_hit_triggered = false
	
	dash_direction = actor.facing_direction
	actor.sprite.play("flying_kick")
	
	if not actor.sprite.frame_changed.is_connected(_on_frame_changed):
		actor.sprite.frame_changed.connect(_on_frame_changed)
	if not actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.connect(_on_animation_finished)
		
	if actor.attack_area and not actor.attack_area.body_entered.is_connected(_on_body_entered):
		actor.attack_area.body_entered.connect(_on_body_entered)


func physics_update(delta: float) -> State:
	# Half gravity is applied to create a floating leap effect
	if not actor.is_on_floor():
		actor.velocity += (actor.get_gravity() * 0.5) * delta
	
	actor.velocity.x = dash_direction * (actor.speed * dash_speed_multiplier)
	actor.move_and_slide()

	if attack_finished:
		return move_state
		
	return null


func exit() -> void:
	if actor.sprite.frame_changed.is_connected(_on_frame_changed):
		actor.sprite.frame_changed.disconnect(_on_frame_changed)
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)
	
	if actor.attack_area:
		if actor.attack_area.body_entered.is_connected(_on_body_entered):
			actor.attack_area.body_entered.disconnect(_on_body_entered)
		_set_attack_monitoring(false)


func _on_frame_changed() -> void:
	if actor.sprite.animation == "flying_kick" and actor.sprite.frame == hit_frame:
		if not _hit_triggered:
			_hit_triggered = true
			_trigger_hit()


func _on_animation_finished() -> void:
	if actor.sprite.animation == "flying_kick":
		attack_finished = true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)


# Enables physical collision queries and sets an expiration lifetime timer
func _trigger_hit() -> void:
	_set_attack_monitoring(true)
	await get_tree().create_timer(active_duration).timeout
	_set_attack_monitoring(false)


# Updates the physics detection state of the damage source area
func _set_attack_monitoring(active: bool) -> void:
	if actor.attack_area:
		actor.attack_area.set_deferred("monitoring", active)

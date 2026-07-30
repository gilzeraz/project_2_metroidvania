class_name AttackComboState
extends State
## Controls the full dive-attack sequence: telegraph, dive, and impact recovery.


#region Properties
enum Phase { TELEGRAPH, DIVE, IMPACT }

## Speed applied to the actor while diving toward the locked target.
@export var dive_speed: float = 240.0
## Distance threshold, in pixels, to count as arrived at the target.
@export var arrival_distance: float = 12.0
## Damage applied to the player during the impact phase.
@export var damage: int = 1
## State to transition to once the whole attack sequence finishes.
@export var next_state: State

var _phase: Phase = Phase.TELEGRAPH
var _animation_done: bool = false
var _hit_player: bool = false
var _target_position := Vector2.ZERO
#endregion


## Starts the sequence in the telegraph phase.
func enter() -> void:
	_enter_telegraph()


## Routes physics processing to whichever phase is currently active.
func physics_update(_delta: float) -> State:
	match _phase:
		Phase.TELEGRAPH: return _update_telegraph()
		Phase.DIVE: return _update_dive()
		Phase.IMPACT: return _update_impact()
		
	return null


## Cleans up any signal connection left over from an interrupted phase.
func exit() -> void:
	_disconnect_signals()


## Starts the telegraph phase: locks velocity and plays the warning animation.
func _enter_telegraph() -> void:
	_phase = Phase.TELEGRAPH
	_animation_done = false
	actor.velocity = Vector2.ZERO
	actor.sprite.play("attack_start")
	actor.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


## Waits for the telegraph animation to finish, then advances to the dive phase.
func _update_telegraph() -> State:
	if _animation_done:
		_enter_dive()
	return null


## Starts the dive phase: locks the target position and listens for a player hit.
func _enter_dive() -> void:
	_phase = Phase.DIVE
	_hit_player = false
	_target_position = Player.player.global_position
	actor.sprite.play("attack_middle")
	actor.attack_area.body_entered.connect(_on_attack_area_body_entered)


## Moves the actor toward the locked target until it arrives, hits the player, or lands.
func _update_dive() -> State:
	if _hit_player:
		_enter_impact()
		return null
		
	var direction: Vector2 = _target_position - actor.global_position
	
	if direction.length() <= arrival_distance:
		_enter_impact()
		return null
		
	direction = direction.normalized()
	actor.velocity = direction * dive_speed
	
	if direction.x != 0.0:
		actor.facing_direction = int(sign(direction.x))
		
	actor.move_and_slide()
	
	if actor.is_on_floor():
		_enter_impact()
		
	return null


## Starts the impact phase: stops movement and plays the recovery animation.
func _enter_impact() -> void:
	if actor.attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		actor.attack_area.body_entered.disconnect(_on_attack_area_body_entered)
	_phase = Phase.IMPACT
	_animation_done = false
	actor.velocity = Vector2.ZERO
	actor.sprite.play("attack_end")
	actor.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


## Applies damage to overlapping players while the recovery animation plays.
func _update_impact() -> State:
	if _animation_done:
		return next_state
	for body: Node2D in actor.attack_area.get_overlapping_bodies():
		if body is Player:
			body.take_damage(damage, actor)
	return null


## Disconnects every signal this state may have connected during its phases.
func _disconnect_signals() -> void:
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)
	if actor.attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		actor.attack_area.body_entered.disconnect(_on_attack_area_body_entered)


func _on_animation_finished() -> void:
	_animation_done = true


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_hit_player = true

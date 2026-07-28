class_name CrouchKickBoss
extends State

## Crouch kick combat state for the enemy boss unit.
##
## Manages low-sweep attack mechanics with custom frame triggers, active collision
## windows, and custom state cooldown tracking.


## State to transition to once the sweeping animation completes.
@export var move_state: State

## Amount of damage dealt to the target upon a successful hit.
@export var damage: int = 18

## Animation frame index where weapon collision checking is initiated.
@export var hit_frame: int = 2

## Duration in seconds the combat area remains active to register damage.
@export var active_duration: float = 0.12

## Cooldown duration in seconds before this attack state can be selected again.
@export var cooldown: float = 2.0

## Tracking flag to signal completion of the state animation cycle.
var attack_finished: bool = false

# Internal tracking flag to prevent duplicate trigger calls on the targeted frame.
var _hit_triggered: bool = false

# Controls whether signal connections with the actor properties are established.
var _signals_connected: bool = false

# Remaining time in seconds before the cooldown period expires.
var _cooldown_timer: float = 0.0


## Processes cooldown updates globally even when this state is not currently active
func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta


func enter() -> void:
	if not _signals_connected and actor:
		_connect_actor_signals()
		
	attack_finished = false
	_hit_triggered = false
	
	# Start cooldown immediately on entry to prevent instant consecutive attacks
	_cooldown_timer = cooldown
	
	actor.velocity.x = 0.0
	actor.sprite.play("crouch_kick")


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta
		
	actor.move_and_slide()

	if attack_finished: 
		return move_state
		
	return null


func exit() -> void:
	# Keep the hitbox disabled to prevent passive collision queries on transition
	_set_attack_monitoring(false)


## Public helper to check if this state is off cooldown and ready to be triggered.
func is_ready() -> bool:
	return _cooldown_timer <= 0.0


## Establishes required signal connections dynamically once the actor reference is active
func _connect_actor_signals() -> void:
	if not actor:
		return
		
	actor.sprite.frame_changed.connect(_on_frame_changed)
	actor.sprite.animation_finished.connect(_on_animation_finished)
	
	if actor.attack_area:
		actor.attack_area.body_entered.connect(_on_body_entered)
		
	_signals_connected = true


## Handles frame-by-frame verification to execute the damage query sequence
func _on_frame_changed() -> void:
	if state_machine.current_state != self:
		return
		
	if actor.sprite.animation == "crouch_kick" and actor.sprite.frame == hit_frame:
		if not _hit_triggered:
			_hit_triggered = true
			_trigger_hit()


## Signals complete animation execution to trigger standard state transitions
func _on_animation_finished() -> void:
	if state_machine.current_state != self:
		return
		
	if actor.sprite.animation == "crouch_kick":
		attack_finished = true


## Detects target intrusion on the active combat boundary and inflicts damage
func _on_body_entered(body: Node) -> void:
	if state_machine.current_state != self:
		return
		
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)


## Enables physical collision queries and schedules expiration lifetime
func _trigger_hit() -> void:
	_set_attack_monitoring(true)
	await get_tree().create_timer(active_duration).timeout
	_set_attack_monitoring(false)


## Updates the physics detection state of the damage source area
func _set_attack_monitoring(active: bool) -> void:
	if actor.attack_area:
		actor.attack_area.set_deferred("monitoring", active)

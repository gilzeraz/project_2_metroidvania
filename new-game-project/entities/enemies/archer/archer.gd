class_name Archer
extends BaseEnemy
## Ranged enemy entity managing directional aiming, raycast positioning, and arrow spawns.
##
## Configures archer behavior flags, adjusts raycast offsets according to facing direction,
## and updates arrow spawn point markers.


@onready var attack_enemy_state: EnemyShootState = $StateMachine/AttackEnemyState
@onready var idle: EnemyIdleState = $StateMachine/Idle
@onready var ray: RayCast2D = $RayCast2D
@onready var arrow_point: Marker2D = $ArrowPoint


func _ready() -> void:
	super()
	idle.is_archer = true


## Overrides facing direction setter to adjust raycast offset and arrow spawn position
func _set_facing_direction(direction: int) -> void:
	super(direction)

	if ray:
		ray.position.x = -absf(ray.position.x) if direction < 0 else absf(ray.position.x)

	if arrow_point:
		arrow_point.position.x = absf(arrow_point.position.x) * float(facing_direction)

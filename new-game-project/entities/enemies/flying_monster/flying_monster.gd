class_name FlyingMonster
extends BaseEnemy
## Aerial enemy entity tracking vertical patrol baselines and initial spawn points.
##
## Manages spawn position retention and updates patrol elevation anchors used by
## aerial idle and return states.


var spawn_position := Vector2.ZERO
var patrol_y: float = 0.0

@onready var idle_enemy_state: EnemyIdleState = $StateMachine/IdleEnemyState


func _ready() -> void:
	super()
	spawn_position = global_position
	patrol_y = global_position.y

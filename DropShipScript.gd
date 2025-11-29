extends CharacterBody2D
var EndPoint = Vector2(0,0)
var EnemyObj = preload("res://Enemy.tscn")
var SpawnNumber = 1
var EnemyType = "Pawn"
var Spawned = false

func _ready() -> void:
	look_at(EndPoint)
	velocity = 200.0 * Vector2(cos(rotation),sin(rotation))
	await get_tree().create_timer(150.0).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	if sqrt(pow(position.x - EndPoint.x,2) + pow(position.y - EndPoint.y,2)) < 50.0 and !Spawned:
		SpawnUnits()
	move_and_slide()

func SpawnUnits():
	Spawned = true
	for i in range(0,SpawnNumber):
		var NewObj = EnemyObj.instantiate()
		NewObj.position = position + Vector2(randf_range(-25.0,25.0),randf_range(-25.0,25.0))
		NewObj.EnemyType = EnemyType
		get_parent().add_child(NewObj)

extends Node2D
@export_enum("Pawn","Bishop","Knight","Rook") var EnemyType: String
@export var SpawnNumber = 1
@export var WaitTime = 45.0
var DropShipObj = preload("res://DropShip.tscn")

func _ready() -> void:
	await get_tree().create_timer(WaitTime).timeout
	CreateDropShip()
	_ready()

func CreateDropShip():
	var NewObj = DropShipObj.instantiate()
	NewObj.position = Vector2(10000,randf_range(-3000,3000))
	NewObj.SpawnNumber = SpawnNumber
	NewObj.EnemyType = EnemyType
	NewObj.EndPoint = position
	get_parent().add_child(NewObj)

extends Node
var Health = 10.0 # Player Health (Mainly for Display)
var Damage = 1.0 # Player Damage
var Firerate = 0.2 # Player Firerate
var PropLayer = null
var PlayerTypes = {
	"Plant": ["Seed","Take Over",Color(0.0, 3.353, 0.0),0,10,120.0,[Vector2(6.0,0.0)]],
	"Pawn": ["Melee","Self Destruct",Color(5.51, 5.158, 0.0, 0.839),1,2,125.0,[Vector2(10.0,0.0)]],
	"Bishop": ["Bolt","Electric Pulse",Color(5.51, 5.158, 0.0, 0.839),2,4,110.0,[Vector2(11.0,-5.0)]],
	"Knight": ["Laser","Dash",Color(5.51, 5.158, 0.0, 0.839),3,5,130.0,[Vector2(8.0,-11.5),Vector2(8.0,11.5)]],
	"Rook": ["Plasma","Plasma Burst",Color(5.51, 5.158, 0.0, 0.839),4,12,105.0,[Vector2(10.0,0.0)]]
}
var Maps = ["res://Tutorial.tscn","res://Map1.tscn","res://Map2.tscn","res://Map3.tscn"];
var MapNames = ["Tutorial","Outlying Outpost","Island Base","Offshore Lair"]
var CurrentMap = 0
var MapWon = false
var CurrentPlayerType = "Plant"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

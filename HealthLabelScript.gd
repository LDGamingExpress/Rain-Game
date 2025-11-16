extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = ("Health:\n" + str(int(Globals.Health)) + "/" + str(Globals.PlayerTypes[Globals.CurrentPlayerType][4])) # Displays current health

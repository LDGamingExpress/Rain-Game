extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var PlantBonus = get_parent().get_parent().get_parent().PlantBonus
	text = ("Health:\n" + str(int(Globals.Health)) + "/" + str(int(Globals.PlayerTypes[Globals.CurrentPlayerType][4] * PlantBonus))) # Displays current health

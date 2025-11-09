extends Sprite2D
@onready var ParticlesO := preload("res://HealthParticles.tscn") # loads health particles to display after pickup

func _on_pickup_area_body_entered(body): # Detects when an object enters the pickup area
	if body.is_in_group("Player"): # Checks that object is the player
		body.Health = 10 # Sets player health to 10
		var HealthParticle = ParticlesO.instantiate() # instantiates the pickup particles
		HealthParticle.position = position # sets pickup particles instance's position to pickup position
		get_parent().add_child(HealthParticle) # adds pickup particles to scene as child of pickup's parent
		queue_free() # deletes pickup

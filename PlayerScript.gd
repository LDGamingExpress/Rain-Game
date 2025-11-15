extends CharacterBody2D
@onready var BulletObj := preload("res://Bullet.tscn") # Bullet object to be spawned

const SPEED = 70.0 # Speed of the player
var Firerate = 0.2 # How long the player has to wait between shots
var Damage = 1 # Damage of the player
var Health = 10 # Health of the player
var FireReady = 1 # 1 means the player is ready to fire, 0 means the player needs to wait to fire

func _physics_process(delta):
	Globals.Health = Health # Sets globally stored health to current health (global is mainly used for display)
	look_at(get_global_mouse_position()) # Faces player towards cursor
	
	velocity = velocity * 0.8 # Applies friction
	
	# Camera zoom controls
	if Input.is_action_just_released("ZoomIn"): # Checks if player is trying to zoom in
		$PlayerCam.zoom += Vector2(0.05,0.05) # Zooms in the camera
	if Input.is_action_just_released("ZoomOut"): # Checks if player is trying to zoom out
		$PlayerCam.zoom -= Vector2(0.05,0.05) # Zooms out the camera
	
	# Stops player if velocity is too low from friction (prevents sliding)
	if (abs(velocity.x) + abs(velocity.y)) < 15: # Checks if velocity is low
		velocity = Vector2(0,0) # Changes velocity to 0
	
	# Basic movement controls
	if Input.is_action_pressed("Left"): # Checks if input for left is pressed
		velocity.x = -SPEED
		#velocity = SPEED * Vector2(cos(rotation - PI/2),sin(rotation - PI/2)) # Moves left relative of rotation
	if Input.is_action_pressed("Right"): # Checks if input for right is pressed
		velocity.x = SPEED
		#velocity = SPEED * Vector2(cos(rotation + PI/2),sin(rotation + PI/2)) # Moves right relative of rotation
	if Input.is_action_pressed("Forward"): # Checks if input for forward is pressed
		velocity.y = -SPEED
		#velocity = SPEED * Vector2(cos(rotation),sin(rotation)) # Moves forward relative of rotation
	if Input.is_action_pressed("Backward"): # Checks if input for backward is pressed
		velocity.y = SPEED
		#velocity = -SPEED * Vector2(cos(rotation),sin(rotation)) # Moves backward relative of rotation
	
	# Shooting controls
	if Input.is_action_pressed("Shoot"): # Checks if input for shooting is pressed
		if FireReady == 1: # Checks if gun is ready to fire
				$GunParticles.restart() # Particles are activated
				PrepNextFire() # Gun is prepared to fire again
				var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
				NewBul.position = $GunParticles.global_position # Sets bullet to gun position
				NewBul.rotation = rotation # Rotates bullet to match rotation
				NewBul.Team = "Player" # Sets team to match group
				NewBul.Damage = Damage # Gives bullet player's damage
				get_parent().add_child(NewBul) # Creates bullet as child of parent

	move_and_slide() # Moves player based on velocity

func PrepNextFire(): # Prepares to fire after last shot
	FireReady = 0 # Prevents gun from firing
	await get_tree().create_timer(Firerate).timeout # Waits out firerate
	FireReady = 1 # Allows gun to fire again

func TakeDamage(DamageTaken): # Handles damage from hostiles
	Health -= DamageTaken # Subtracts damage from health
	$BloodParticles.restart() # Activates blood particles
	if Health <= 0: # Checks if the health is 0 or less
		await get_tree().create_timer(1).timeout # Gives 1 second for particles to finish
		print("GameOver") # Prints gameover to indicate player should be dead
		# Game over is not currently implemented but can be done by either creating a menu to only show upon death
		# Or send the player to a separate game over scene

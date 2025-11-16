extends CharacterBody2D
@onready var BulletObj := preload("res://Bullet.tscn") # Bullet object to be spawned
@onready var MeleeObj := preload("res://MeleeNode.tscn")
@onready var ExplosionObj := preload("res://Explosion.tscn")

const SPEED = 70.0 # Speed of the player
var Firerate = 0.2 # How long the player has to wait between shots
var Specialrate = 1.0
var Damage = 1.0 # Damage of the player
var Health = 10.0 # Health of the player
var FireReady = 1 # 1 means the player is ready to fire, 0 means the player needs to wait to fire
var SpecialReady = 1
var ShootType = "Seed"
var SpecialType = "Take Over"
var NearEnemies = []

func _ready() -> void:
	CheckTypeStats()

func CheckTypeStats():
	ShootType = Globals.PlayerTypes[Globals.CurrentPlayerType][0]
	SpecialType = Globals.PlayerTypes[Globals.CurrentPlayerType][1]
	$BloodParticles.self_modulate = Globals.PlayerTypes[Globals.CurrentPlayerType][2]
	$PlayerSprite.frame = Globals.PlayerTypes[Globals.CurrentPlayerType][3]
	Health = Globals.PlayerTypes[Globals.CurrentPlayerType][4]
	match ShootType:
		"Seed":
			Firerate = 0.2
			Damage = 1.0
		"Melee":
			Firerate = 0.5
			Damage = 0.5
	match SpecialType:
		"Take Over":
			Specialrate = 1.0
		"Self Destruct":
			Specialrate = 10.0

func _physics_process(delta):
	Globals.Health = Health # Sets globally stored health to current health (global is mainly used for display)
	look_at(get_global_mouse_position()) # Faces player towards cursor
	
	velocity = velocity * 0.8 # Applies friction
	
	# Camera zoom controls
	if Input.is_action_just_released("ZoomIn") and $PlayerCam.zoom.x < 6.0: # Checks if player is trying to zoom in
		$PlayerCam.zoom += Vector2(0.05,0.05) # Zooms in the camera
	if Input.is_action_just_released("ZoomOut") and $PlayerCam.zoom.x > 0.5: # Checks if player is trying to zoom out
		$PlayerCam.zoom -= Vector2(0.05,0.05) # Zooms out the camera
	
	# Stops player if velocity is too low from friction (prevents sliding)
	if (abs(velocity.x) + abs(velocity.y)) < 15: # Checks if velocity is low
		velocity = Vector2(0,0) # Changes velocity to 0
	
	var Moving = false
	# Basic movement controls
	if Input.is_action_pressed("Left"): # Checks if input for left is pressed
		velocity.x = -SPEED
		Moving = true
		#velocity = SPEED * Vector2(cos(rotation - PI/2),sin(rotation - PI/2)) # Moves left relative of rotation
	if Input.is_action_pressed("Right"): # Checks if input for right is pressed
		velocity.x = SPEED
		Moving = true
		#velocity = SPEED * Vector2(cos(rotation + PI/2),sin(rotation + PI/2)) # Moves right relative of rotation
	if Input.is_action_pressed("Forward"): # Checks if input for forward is pressed
		velocity.y = -SPEED
		Moving = true
		#velocity = SPEED * Vector2(cos(rotation),sin(rotation)) # Moves forward relative of rotation
	if Input.is_action_pressed("Backward"): # Checks if input for backward is pressed
		velocity.y = SPEED
		Moving = true
		#velocity = -SPEED * Vector2(cos(rotation),sin(rotation)) # Moves backward relative of rotation
	if Moving:
		$AnimationPlayer.play("Walking")
	else:
		$AnimationPlayer.play("Idle")
	# Shooting controls
	if Input.is_action_pressed("Shoot"): # Checks if input for shooting is pressed
		if FireReady == 1: # Checks if gun is ready to fire
			match ShootType:
				"Seed":
					$GunParticles.self_modulate = Color(0.702, 0.976, 0.616, 0.651)
					$GunParticles.restart() # Particles are activated
					PrepNextFire() # Gun is prepared to fire again
					var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
					NewBul.position = $GunParticles.global_position # Sets bullet to gun position
					NewBul.rotation = rotation # Rotates bullet to match rotation
					NewBul.Team = "Player" # Sets team to match group
					NewBul.Damage = Damage # Gives bullet player's damage
					get_parent().add_child(NewBul) # Creates bullet as child of parent
				"Melee":
					var NewObj = MeleeObj.instantiate()
					NewObj.position = Vector2(7,0)
					NewObj.Team = "Player"
					NewObj.Damage = Damage
					add_child(NewObj)
					PrepNextFire() # Gun is prepared to fire again
	if Input.is_action_just_pressed("Special"):
		if SpecialReady == 1:
			match SpecialType:
				"Take Over":
					TakeOver()
					PrepNextSpecial()
				"Self Destruct":
					SelfDestruct()
					PrepNextSpecial()
	
	move_and_slide() # Moves player based on velocity

func PrepNextFire(): # Prepares to fire after last shot
	FireReady = 0 # Prevents gun from firing
	await get_tree().create_timer(Firerate).timeout # Waits out firerate
	FireReady = 1 # Allows gun to fire again

func PrepNextSpecial(): # Prepares to fire after last shot
	SpecialReady = 0 # Prevents gun from firing
	await get_tree().create_timer(Specialrate).timeout # Waits out firerate
	SpecialReady = 1 # Allows gun to fire again

func TakeDamage(DamageTaken): # Handles damage from hostiles
	Health -= DamageTaken # Subtracts damage from health
	$BloodParticles.restart() # Activates blood particles
	if Health <= 0: # Checks if the health is 0 or less
		if Globals.CurrentPlayerType != "Plant":
			Globals.CurrentPlayerType = "Plant"
			CheckTypeStats()
		else:
			await get_tree().create_timer(1).timeout # Gives 1 second for particles to finish
			print("GameOver") # Prints gameover to indicate player should be dead
			# Game over is not currently implemented but can be done by either creating a menu to only show upon death
			# Or send the player to a separate game over scene

func TakeOver():
	if NearEnemies[0] != null:
		Globals.CurrentPlayerType = NearEnemies[0].EnemyType
		CheckTypeStats()
		position = NearEnemies[0].position
		NearEnemies[0].queue_free()

func SelfDestruct():
	$SpecialAnimationPlayer.play("Self Destruct")
	await get_tree().create_timer(1.0).timeout
	var NewObj = ExplosionObj.instantiate()
	NewObj.position = global_position
	NewObj.Team = "Player"
	NewObj.Damage = 8
	get_parent().add_child(NewObj)
	Globals.CurrentPlayerType = "Plant"
	CheckTypeStats()
	$SpecialAnimationPlayer.play("RESET")

func _on_take_over_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		NearEnemies.append(body)


func _on_take_over_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		NearEnemies.erase(body)

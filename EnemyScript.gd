extends CharacterBody2D
@onready var BulletObj := preload("res://Bullet.tscn") # Bullet object to be spawned
@onready var CorpseObj := preload("res://Corpse.tscn") # Corpse object to be spawned
@onready var MeleeObj := preload("res://MeleeNode.tscn")
@onready var ExplosionObj := preload("res://Explosion.tscn")

var HostilesFound = [] # Array to contain nodes of hostiles to attack within range
var SPEED = 100.0 # Speed of the enemy
var Firerate = 0.2 # How long the enemy has to wait between shots
var Specialrate = 1.0
var Damage = 1 # Damage of the player
var Health = 10 # Health of the player
var FireReady = 1 # 1 means the player is ready to fire, 0 means the player needs to wait to fire
var SpecialReady = 1
var ShootType = "Melee"
var SpecialType = "Self Destruct"
@export_enum("Pawn","Bishop","Knight","Rook") var EnemyType: String

var Movement = "Random" # Current movement type
# Random - enemy moves around randomly
# Targeted - enemy goes after a particular enemy
# Shooting - enemy is stationary to shoot
var Target = position # position enemy is moving to
var rng = RandomNumberGenerator.new() # random number generator
var LastPos = Vector2(0,0) # Last Position
var AttackRange = 200
var SpecialRange = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func CheckTypeStats():
	ShootType = Globals.PlayerTypes[EnemyType][0]
	SpecialType = Globals.PlayerTypes[EnemyType][1]
	$BloodParticles.self_modulate = Globals.PlayerTypes[EnemyType][2]
	$AnimatedSprite2D.frame = Globals.PlayerTypes[EnemyType][3] - 1
	Health = Globals.PlayerTypes[EnemyType][4]
	SPEED = Globals.PlayerTypes[EnemyType][5]
	match ShootType:
		"Seed":
			Firerate = 0.2
			Damage = 1.0
			AttackRange = 200
		"Melee":
			Firerate = 0.5
			Damage = 0.5
			AttackRange = 30
		"Bolt":
			Firerate = 0.75
			Damage = 1.0
			AttackRange = 350
		"Laser":
			Firerate = 0.5
			Damage = 0.5
			AttackRange = 400
		"Plasma":
			Firerate = 2.5
			Damage = 5.0
			AttackRange = 200
	match SpecialType:
		"Take Over":
			Specialrate = 1.0
		"Self Destruct":
			Specialrate = 10.0
			SpecialRange = 50
		"Electric Pulse":
			Specialrate = 15.0
			SpecialRange = 120
		"Dash":
			Specialrate = 5.0
			SpecialRange = 350
		"Plasma Burst":
			Specialrate = 10.0
			SpecialRange = 280
	$GunParticles.position = Globals.PlayerTypes[EnemyType][6][0]
	if len(Globals.PlayerTypes[EnemyType][6]) > 1:
		$GunParticles2.position = Globals.PlayerTypes[EnemyType][6][1]

func _ready():
	Health = 3 # Starting health, can be modified or randomized
	Damage = 1 # Starting damage, can be modified or randomized
	Target = position + Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
	# Sets the target to random position near the enemy
	CheckTypeStats()


func _physics_process(_delta):
	if Globals.MapWon:
		var NewObj = ExplosionObj.instantiate()
		NewObj.position = global_position
		NewObj.Team = "Enemies"
		NewObj.Damage = 8
		get_parent().add_child(NewObj)
		queue_free()
	if Health > 0: # Only lets the enemy move or shoot if alive
		velocity = velocity * 0.8 # Applies friction
		if (abs(velocity.x) + abs(velocity.y)) < 15: # Checks if velocity is low
			velocity = Vector2(0,0) # Changes velocity to 0
		if len(HostilesFound) > 0 and Movement != "Targeted" and Movement != "Shooting": # Checks that the enemy has found hostiles and is not currently targeting anyone
			Movement = "Targeted" # Changes movement type to targeted
			Target = HostilesFound[rng.randi_range(0,len(HostilesFound) - 1)] # Picks target at random from hostile array
		if Movement == "Targeted": # Checks if already targeting someone
			if !is_instance_valid(Target): # Checks if target no longer exists
				if HostilesFound.find(Target,0) != -1: # Checks that it was not removed already from hostiles
					HostilesFound.remove_at(HostilesFound.find(Target,0)) # Removes Target from hostiles
				Target = position + Vector2(rng.randi_range(-10,10),rng.randi_range(-10,10)) - 20 * Vector2(cos(-rotation),sin(-rotation))
				# Sets a new target position
				Movement = "Random" # Sets movement type to random
			#elif sqrt(pow((position.x - LastPos.x),2) + pow((position.y - LastPos.y),2)) < 0.5: # Checks if they are stuck
			#	Target = position + Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
				# Sets a new target position
			#	Movement = "Random" # Sets movement type to random
			elif sqrt(pow((position.x - Target.position.x),2) + pow((position.y - Target.position.y),2)) < AttackRange:
				# Checks if the enemy is within a certain distance of their target
				Movement = "Shooting" # Changes movement type to shooting
				velocity.x = 0 # Halts x-axis movement
				velocity.y = 0 # Halts z-axis movement
				$AnimationPlayer.play("Idle")
		if len(HostilesFound) == 0: # Checks if there are no hostiles in range
			if Movement == "Random": # Checks if the enemy is already moving randomly
				if (abs(position.x - Target.x) + abs(position.y - Target.y)) < 15 or sqrt(pow((position.x - LastPos.x),2) + pow((position.y - LastPos.y),2)) < 0.5:
					# Checks if the enemy has already reached their target or if they are stuck
					Target = position + Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50)) - 20 * Vector2(cos(-rotation),sin(-rotation))
					# Sets a new target position
			else:
				var TPos = Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
				Target = position + TPos
				#var GoodPos = false
				#while GoodPos == false:
				#	var TPos = Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
				#	$PathDetector.target_position = TPos
				#	await get_tree().create_timer(0.001).timeout
				#	if !$PathDetector.is_colliding():
				#		GoodPos = true
				#		Target = position + TPos
				#		# Sets a new target position
				#	else:
				#		print("Oh noes! Bad target!")
			Movement = "Random"
			# Sets movement type to random if it was not already
		if Movement == "Random":
			look_at(Vector2(Target.x,Target.y)) # Looks at target
			velocity = SPEED * Vector2(cos(rotation),sin(rotation)) # Applies velocity forwards
			$AnimationPlayer.play("Walking")
		if Movement == "Targeted":
			look_at(Vector2(Target.position.x,Target.position.y)) # Looks at target
			$AnimationPlayer.play("Walking")
			velocity = SPEED * Vector2(cos(rotation),sin(rotation)) # Applies velocity forwards
		if Movement == "Shooting":
			if !is_instance_valid(Target): # Checks if target no longer exists
				if HostilesFound.find(Target,0) != -1: # Checks that it was not removed already from hostiles
					HostilesFound.remove_at(HostilesFound.find(Target,0)) # Removes Target from hostiles
				Target = position + Vector2(rng.randi_range(-10,10),rng.randi_range(-10,10)) - 20 * Vector2(cos(-rotation),sin(-rotation))
				# Sets a new target position
				Movement = "Random" # Sets movement type to random
			elif sqrt(pow((position.x - Target.position.x),2) + pow((position.y - Target.position.y),2)) < SpecialRange and SpecialReady == 1:
				if randf_range(0.0,50.0) > 30.0:
					PrepNextSpecial()
					look_at(Vector2(Target.position.x,Target.position.y)) # Looks at target
					match SpecialType:
						"Self Destruct":
							SelfDestruct()
						"Electric Pulse":
							ElectricPulse()
						"Dash":
							Dash()
						"Plasma Burst":
							PlasmaBurst()
			elif sqrt(pow((position.x - Target.position.x),2) + pow((position.y - Target.position.y),2)) > AttackRange:
				Movement = "Targeted" # Changes movement type to targeted
			elif FireReady == 1: # Checks if gun is ready to fire
				look_at(Vector2(Target.position.x,Target.position.y)) # Looks at target
				match ShootType:
					"Seed":
						$GunParticles.restart() # Particles are activated
						PrepNextFire() # Gun is prepared to fire again
						var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
						NewBul.position = $GunParticles.global_position # Sets bullet to gun position
						NewBul.rotation = rotation # Rotates bullet to match rotation
						NewBul.Team = "Enemies" # Sets team to match group
						NewBul.Damage = Damage # Gives bullet enemy's damage
						NewBul.Frame = 0
						get_parent().add_child(NewBul) # Creates bullet as child of parent
					"Melee":
						var NewObj = MeleeObj.instantiate()
						NewObj.position = Vector2(7,0)
						NewObj.Team = "Enemies"
						NewObj.Damage = Damage
						add_child(NewObj)
						PrepNextFire() # Gun is prepared to fire again
					"Bolt":
						$GunParticles.restart() # Particles are activated
						PrepNextFire() # Gun is prepared to fire again
						var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
						NewBul.position = $GunParticles.global_position # Sets bullet to gun position
						NewBul.rotation = rotation # Rotates bullet to match rotation
						NewBul.Team = "Enemies" # Sets team to match group
						NewBul.Damage = Damage # Gives bullet enemy's damage
						NewBul.Frame = 1
						get_parent().add_child(NewBul) # Creates bullet as child of parent
					"Laser":
						$GunParticles.restart() # Particles are activated
						PrepNextFire() # Gun is prepared to fire again
						var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
						NewBul.position = $GunParticles.global_position # Sets bullet to gun position
						NewBul.rotation = rotation # Rotates bullet to match rotation
						NewBul.Team = "Enemies" # Sets team to match group
						NewBul.Damage = Damage # Gives bullet enemy's damage
						NewBul.Frame = 2
						get_parent().add_child(NewBul) # Creates bullet as child of parent
						$GunParticles2.restart() # Particles are activated
						PrepNextFire() # Gun is prepared to fire again
						var NewBul2 = BulletObj.instantiate() # Instantiates/Creates bullet object
						NewBul2.position = $GunParticles2.global_position # Sets bullet to gun position
						NewBul2.rotation = rotation # Rotates bullet to match rotation
						NewBul2.Team = "Enemies" # Sets team to match group
						NewBul2.Damage = Damage # Gives bullet enemy's damage
						NewBul2.Frame = 2
						get_parent().add_child(NewBul2) # Creates bullet as child of parent
					"Plasma":
						$GunParticles.restart() # Particles are activated
						PrepNextFire() # Gun is prepared to fire again
						var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
						NewBul.position = $GunParticles.global_position # Sets bullet to gun position
						NewBul.rotation = rotation # Rotates bullet to match rotation
						NewBul.Team = "Enemies" # Sets team to match group
						NewBul.Damage = Damage # Gives bullet enemy's damage
						NewBul.Frame = 3
						get_parent().add_child(NewBul) # Creates bullet as child of parent
			else:
				look_at(Vector2(Target.position.x,Target.position.y)) # Looks at target
		LastPos = position
		move_and_slide() # Moves enemy based on velocity

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
		$AnimatedSprite2D.visible = false
		await get_tree().create_timer(0.4).timeout # Gives 1 second for particles to finish
		var NewC = CorpseObj.instantiate() # Instantiates/Creates corpse object
		NewC.position = position # Sets corpse to position
		NewC.rotation = rotation # Rotates corpse to match rotation
		get_parent().add_child(NewC) # Creates corpse as child of parent
		queue_free() # Deletes enemy


func _on_detection_area_body_entered(body): # Activates when an object enters the detection area
	if body.is_in_group("Player") or body.is_in_group("Allies"): # Checks if object is a hostile
		HostilesFound.append(body) # Adds hostile to hostile list


func _on_detection_area_body_exited(body): # Activates when an object leaves the detection area
	if body.is_in_group("Player") or body.is_in_group("Allies"): # Checks if object is a hostile
		if HostilesFound.find(body,0) != -1: # Checks that it was not removed already
			HostilesFound.remove_at(HostilesFound.find(body,0)) # Removes hostile from hostile list

func SelfDestruct():
	$SpecialAnimationPlayer.play("Self Destruct")
	await get_tree().create_timer(1.0).timeout
	var NewObj = ExplosionObj.instantiate()
	NewObj.position = global_position
	NewObj.Team = "Enemies"
	NewObj.Damage = 8
	get_parent().add_child(NewObj)
	queue_free()

func ElectricPulse():
	$EffectParticles.self_modulate = Color(4.455, 4.455, 0.0, 0.278)
	$SpecialAnimationPlayer.play("Electric Pulse")
	await get_tree().create_timer(2.5).timeout
	for i in range(0,15):
		var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
		NewBul.position = global_position # Sets bullet to gun position
		NewBul.rotation = i * 2*PI/16 # Rotates bullet to match rotation
		NewBul.Team = "Enemies" # Sets team to match group
		NewBul.Damage = Damage # Gives bullet enemy's damage
		NewBul.Frame = 1
		get_parent().add_child(NewBul) # Creates bullet as child of parent

func Dash():
	$SpecialAnimationPlayer.play("DashReady")
	await get_tree().create_timer(1.0).timeout
	$EffectParticles.self_modulate = Color(1.543, 1.543, 1.53, 0.278)
	$SpecialAnimationPlayer.play("DashNow")
	velocity += 3000.0 * Vector2(cos(rotation),sin(rotation))

func PlasmaBurst():
	$EffectParticles.self_modulate = Color(2.253, 0.0, 1.966, 0.278)
	$SpecialAnimationPlayer.play("Electric Pulse")
	await get_tree().create_timer(2.5).timeout
	for i in range(0,25):
		var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
		NewBul.position = global_position # Sets bullet to gun position
		NewBul.rotation = i * 2*PI/26 # Rotates bullet to match rotation
		NewBul.Team = "Enemies" # Sets team to match group
		NewBul.Damage = Damage # Gives bullet enemy's damage
		NewBul.Frame = 3
		get_parent().add_child(NewBul) # Creates bullet as child of parent

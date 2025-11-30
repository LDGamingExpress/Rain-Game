extends CharacterBody2D
@onready var BulletObj := preload("res://Bullet.tscn") # Bullet object to be spawned
@onready var MeleeObj := preload("res://MeleeNode.tscn")
@onready var ExplosionObj := preload("res://Explosion.tscn")

var Music = [preload("res://Music/Cyber City Scramble.mp3"),preload("res://Music/Dark Future.mp3")]

var SPEED = 70.0 # Speed of the player
var Firerate = 0.2 # How long the player has to wait between shots
var Specialrate = 1.0
var Damage = 1.0 # Damage of the player
var Health = 10.0 # Health of the player
var FireReady = 1 # 1 means the player is ready to fire, 0 means the player needs to wait to fire
var SpecialReady = 1
var ShootType = "Seed"
var SpecialType = "Take Over"
var NearEnemies = []
var PlantBonus = 1.0

var RainMachine = null
var Note = null
var Reading = false

func _ready() -> void:
	$PlayerCam/CanvasLayer/MapTitle.text = Globals.MapNames[Globals.CurrentMap]
	CheckTypeStats()
	MusicPlayer()

func CheckTypeStats():
	ShootType = Globals.PlayerTypes[Globals.CurrentPlayerType][0]
	SpecialType = Globals.PlayerTypes[Globals.CurrentPlayerType][1]
	$BloodParticles.self_modulate = Globals.PlayerTypes[Globals.CurrentPlayerType][2]
	$PlayerSprite.frame = Globals.PlayerTypes[Globals.CurrentPlayerType][3]
	Health = Globals.PlayerTypes[Globals.CurrentPlayerType][4] * PlantBonus
	SPEED = Globals.PlayerTypes[Globals.CurrentPlayerType][5] * PlantBonus
	match ShootType:
		"Seed":
			Firerate = 0.2
			Damage = 1.0
		"Melee":
			Firerate = 0.5
			Damage = 0.5
		"Bolt":
			Firerate = 0.75
			Damage = 1.0
		"Laser":
			Firerate = 0.5
			Damage = 0.5
		"Plasma":
			Firerate = 2.5
			Damage = 5.0
	match SpecialType:
		"Take Over":
			Specialrate = 1.0
		"Self Destruct":
			Specialrate = 10.0
		"Electric Pulse":
			Specialrate = 15.0
		"Dash":
			Specialrate = 5.0
		"Plasma Burst":
			Specialrate = 10.0
	Damage = Damage * PlantBonus
	Specialrate = Specialrate - (PlantBonus - 1.0)
	$PlayerCam/CanvasLayer/VBoxContainer/SpecialLabel.text = SpecialType
	$GunParticles.position = Globals.PlayerTypes[Globals.CurrentPlayerType][6][0]
	if len(Globals.PlayerTypes[Globals.CurrentPlayerType][6]) > 1:
		$GunParticles2.position = Globals.PlayerTypes[Globals.CurrentPlayerType][6][1]

func _physics_process(_delta):
	if SpecialReady == 1:
		$PlayerCam/CanvasLayer/VBoxContainer/SpecialReady.text = "Ready"
	else:
		$PlayerCam/CanvasLayer/VBoxContainer/SpecialReady.text = str(ceil($SpecialTimer.time_left*100.0)/100.0)
		
	
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
		velocity = velocity/sqrt(pow(velocity.x,2) + pow(velocity.y,2))*SPEED
		#velocity = SPEED * Vector2(cos(rotation),sin(rotation)) # Moves forward relative of rotation
	if Input.is_action_pressed("Backward"): # Checks if input for backward is pressed
		velocity.y = SPEED
		Moving = true
		velocity = velocity/sqrt(pow(velocity.x,2) + pow(velocity.y,2))*SPEED
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
				"Bolt":
					$GunParticles.restart() # Particles are activated
					PrepNextFire() # Gun is prepared to fire again
					var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
					NewBul.position = $GunParticles.global_position # Sets bullet to gun position
					NewBul.rotation = rotation # Rotates bullet to match rotation
					NewBul.Team = "Player" # Sets team to match group
					NewBul.Damage = Damage # Gives bullet enemy's damage
					NewBul.Frame = 1
					get_parent().add_child(NewBul) # Creates bullet as child of parent
				"Laser":
					$GunParticles.restart() # Particles are activated
					PrepNextFire() # Gun is prepared to fire again
					var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
					NewBul.position = $GunParticles.global_position # Sets bullet to gun position
					NewBul.rotation = rotation # Rotates bullet to match rotation
					NewBul.Team = "Player" # Sets team to match group
					NewBul.Damage = Damage # Gives bullet enemy's damage
					NewBul.Frame = 2
					get_parent().add_child(NewBul) # Creates bullet as child of parent
					$GunParticles2.restart() # Particles are activated
					PrepNextFire() # Gun is prepared to fire again
					var NewBul2 = BulletObj.instantiate() # Instantiates/Creates bullet object
					NewBul2.position = $GunParticles2.global_position # Sets bullet to gun position
					NewBul2.rotation = rotation # Rotates bullet to match rotation
					NewBul2.Team = "Player" # Sets team to match group
					NewBul2.Damage = Damage # Gives bullet enemy's damage
					NewBul2.Frame = 2
					get_parent().add_child(NewBul2) # Creates bullet as child of parent
				"Plasma":
					$GunParticles.restart() # Particles are activated
					PrepNextFire() # Gun is prepared to fire again
					var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
					NewBul.position = $GunParticles.global_position # Sets bullet to gun position
					NewBul.rotation = rotation # Rotates bullet to match rotation
					NewBul.Team = "Player" # Sets team to match group
					NewBul.Damage = Damage # Gives bullet enemy's damage
					NewBul.Frame = 3
					get_parent().add_child(NewBul) # Creates bullet as child of parent
	if Input.is_action_just_pressed("Special"):
		if SpecialReady == 1:
			match SpecialType:
				"Take Over":
					TakeOver()
					PrepNextSpecial()
				"Self Destruct":
					SelfDestruct()
					PrepNextSpecial()
				"Electric Pulse":
					ElectricPulse()
					PrepNextSpecial()
				"Dash":
					Dash()
					PrepNextSpecial()
				"Plasma Burst":
					PlasmaBurst()
					PrepNextSpecial()
	if Input.is_action_just_pressed("Interact"):
		if RainMachine != null:
			if RainMachine.get_child(0).frame == 0:
				RainMachine.get_child(0).frame = 1
				RainMachine.get_child(3).get_child(0).visible = false
				var NewObj = ExplosionObj.instantiate()
				NewObj.position = RainMachine.global_position
				NewObj.Team = "Player"
				get_parent().add_child(NewObj)
				$RainParticles.emitting = true
				Globals.MapWon = true
				$PlayerCam/CanvasLayer/Win.visible = true
				#print("Win")
		var JustOpened = false
		if Note != null:
			if Reading == false:
				JustOpened = true
				Reading = true
				$PlayerCam/CanvasLayer/NoteContainer.visible = true
				$PlayerCam/CanvasLayer/NoteContainer/VBoxContainer/Label.text = Note.get_meta("Title")
				$PlayerCam/CanvasLayer/NoteContainer/VBoxContainer/Label2.text = Note.get_meta("Contents")
		if Reading == true and !JustOpened:
			Reading = false
			$PlayerCam/CanvasLayer/NoteContainer.visible = false
	move_and_slide() # Moves player based on velocity

func PrepNextFire(): # Prepares to fire after last shot
	FireReady = 0 # Prevents gun from firing
	await get_tree().create_timer(Firerate).timeout # Waits out firerate
	FireReady = 1 # Allows gun to fire again

func PrepNextSpecial(): # Prepares to fire after last shot
	SpecialReady = 0 # Prevents gun from firing
	$SpecialTimer.wait_time = Specialrate
	$SpecialTimer.start()
	await $SpecialTimer.timeout
	#await get_tree().create_timer(Specialrate).timeout # Waits out firerate
	SpecialReady = 1 # Allows gun to fire again

func TakeDamage(DamageTaken): # Handles damage from hostiles
	Health -= DamageTaken # Subtracts damage from health
	$BloodParticles.restart() # Activates blood particles
	if Health <= 0: # Checks if the health is 0 or less
		if Globals.CurrentPlayerType != "Plant":
			Globals.CurrentPlayerType = "Plant"
			CheckTypeStats()
		else:
			#await get_tree().create_timer(1).timeout # Gives 1 second for particles to finish
			$PlayerSprite.visible = false
			get_tree().paused = true
			$PlayerCam/CanvasLayer/GameOver.visible = true
			#print("GameOver") # Prints gameover to indicate player should be dead
			# Game over is not currently implemented but can be done by either creating a menu to only show upon death
			# Or send the player to a separate game over scene

func TakeOver():
	if len(NearEnemies) > 0:
		if NearEnemies[0] != null:
			Globals.CurrentPlayerType = NearEnemies[0].EnemyType
			CheckTypeStats()
			position = NearEnemies[0].position
			NearEnemies[0].queue_free()

func SelfDestruct():
	$SpecialAnimationPlayer.play("Self Destruct")
	await get_tree().create_timer(1.0).timeout
	if Globals.CurrentPlayerType != "Plant":
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
	if body.is_in_group("RainMachine"):
		RainMachine = body
		body.get_child(3).visible = true
	if body.is_in_group("PlantMatter"):
		var NewObj = load("res://ImpactParticles.tscn").instantiate()
		NewObj.position = body.position
		NewObj.self_modulate = Color(0.0, 0.672, 0.0, 1.0)
		get_parent().add_child(NewObj)
		body.queue_free()
		PlantBonus += 0.25
		CheckTypeStats()
	if body.is_in_group("Notes"):
		Note = body
		body.get_child(2).visible = true


func _on_take_over_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		NearEnemies.erase(body)
	if body.is_in_group("RainMachine"):
		RainMachine = null
		body.get_child(3).visible = false
	if body.is_in_group("Notes"):
		#if Note == body and Reading == false:
		body.get_child(2).visible = false
		Note = null

func ElectricPulse():
	$EffectParticles.self_modulate = Color(4.455, 4.455, 0.0, 0.278)
	$SpecialAnimationPlayer.play("Electric Pulse")
	await get_tree().create_timer(2.5).timeout
	if Globals.CurrentPlayerType != "Plant":
		for i in range(0,15):
			var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
			NewBul.position = global_position # Sets bullet to gun position
			NewBul.rotation = i * 2*PI/16 # Rotates bullet to match rotation
			NewBul.Team = "Player" # Sets team to match group
			NewBul.Damage = Damage # Gives bullet enemy's damage
			NewBul.Frame = 1
			get_parent().add_child(NewBul) # Creates bullet as child of parent

func Dash():
	$SpecialAnimationPlayer.play("DashReady")
	await get_tree().create_timer(1.0).timeout
	if Globals.CurrentPlayerType != "Plant":
		$EffectParticles.self_modulate = Color(1.543, 1.543, 1.53, 0.278)
		$SpecialAnimationPlayer.play("DashNow")
		velocity += 3000.0 * Vector2(cos(rotation),sin(rotation))
		move_and_slide()

func PlasmaBurst():
	$EffectParticles.self_modulate = Color(2.253, 0.0, 1.966, 0.278)
	$SpecialAnimationPlayer.play("Electric Pulse")
	await get_tree().create_timer(2.5).timeout
	if Globals.CurrentPlayerType != "Plant":
		for i in range(0,25):
			var NewBul = BulletObj.instantiate() # Instantiates/Creates bullet object
			NewBul.position = global_position # Sets bullet to gun position
			NewBul.rotation = i * 2*PI/26 # Rotates bullet to match rotation
			NewBul.Team = "Player" # Sets team to match group
			NewBul.Damage = Damage # Gives bullet enemy's damage
			NewBul.Frame = 3
			get_parent().add_child(NewBul) # Creates bullet as child of parent

func MusicPlayer():
	$MusicPlayer.stream = Music[randi_range(0,len(Music)-1)]
	$MusicPlayer.play()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_next_map_pressed() -> void:
	get_tree().paused = false
	Globals.CurrentMap += 1
	print(Globals.CurrentMap)
	if Globals.CurrentMap <= len(Globals.Maps) - 1:
		Globals.MapWon = false
		get_tree().change_scene_to_file(Globals.Maps[Globals.CurrentMap])

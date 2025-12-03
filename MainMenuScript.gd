extends Control

var Music = [preload("res://Music/Cyber City Scramble.mp3"),preload("res://Music/Dark Future.mp3")]

func _ready() -> void:
	MusicPlayer()

func MusicPlayer():
	$MusicPlayer.stream = Music[randi_range(0,len(Music)-1)]
	$MusicPlayer.play()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Tutorial.tscn")


func _on_select_map_pressed() -> void:
	if $Camera2D/CanvasLayer/MenuContainer/MapSelection.visible:
		$Camera2D/CanvasLayer/MenuContainer/HSeparator.visible = false
		$Camera2D/CanvasLayer/MenuContainer/MapSelection.visible = false
		$Camera2D/CanvasLayer/MenuContainer/HSeparator2.visible = false
	else:
		$Camera2D/CanvasLayer/MenuContainer/HSeparator.visible = true
		$Camera2D/CanvasLayer/MenuContainer/MapSelection.visible = true
		$Camera2D/CanvasLayer/MenuContainer/HSeparator2.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_tutorial_pressed() -> void:
	Globals.CurrentMap = 0
	get_tree().change_scene_to_file("res://Tutorial.tscn")


func _on_map_1_pressed() -> void:
	Globals.CurrentMap = 1
	get_tree().change_scene_to_file("res://Map1.tscn")


func _on_map_2_pressed() -> void:
	Globals.CurrentMap = 2
	get_tree().change_scene_to_file("res://Map2.tscn")


func _on_map_3_pressed() -> void:
	Globals.CurrentMap = 3
	get_tree().change_scene_to_file("res://Map3.tscn")


func _on_map_4_pressed() -> void:
	Globals.CurrentMap = 4
	get_tree().change_scene_to_file("res://Map4.tscn")

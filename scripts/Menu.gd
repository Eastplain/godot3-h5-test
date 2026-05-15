extends Control

func _ready():
	$StartBtn.connect("pressed", self, "_on_start")

func _on_start():
	get_tree().change_scene("res://scenes/Main.tscn")

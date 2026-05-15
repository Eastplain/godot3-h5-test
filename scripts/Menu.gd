extends Control

const VERSION = "v0.2.0"

func _ready():
	$VersionLabel.text = VERSION
	$StartBtn.connect("pressed", self, "_on_start")

func _on_start():
	get_tree().change_scene("res://scenes/Main.tscn")

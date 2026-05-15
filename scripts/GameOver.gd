extends CanvasLayer

func _ready():
	$RetryBtn.connect("pressed", self, "_on_retry")
	$HomeBtn.connect("pressed", self, "_on_home")

func _on_retry():
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_home():
	get_tree().change_scene("res://scenes/Menu.tscn")

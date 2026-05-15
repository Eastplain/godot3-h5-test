extends CanvasLayer

func _ready():
	_load_fonts()
	$RetryBtn.connect("pressed", self, "_on_retry")
	$HomeBtn.connect("pressed", self, "_on_home")

func _load_fonts():
	var fd = DynamicFontData.new()
	fd.font_path = "res://resource/font/simhei.ttf"
	var t = DynamicFont.new(); t.font_data = fd; t.size = 44
	var b = DynamicFont.new(); b.font_data = fd; b.size = 26
	$Title.set("custom_fonts/font", t)
	$RetryBtn.set("custom_fonts/font", b)
	$HomeBtn.set("custom_fonts/font", b)

func _on_retry():
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_home():
	get_tree().change_scene("res://scenes/Menu.tscn")

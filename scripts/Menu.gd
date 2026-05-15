extends Control

func _ready():
	_load_fonts()
	$StartBtn.connect("pressed", self, "_on_start")

func _load_fonts():
	var fd = DynamicFontData.new()
	fd.font_path = "res://resource/font/simhei.ttf"
	var t = DynamicFont.new(); t.font_data = fd; t.size = 52
	var s = DynamicFont.new(); s.font_data = fd; s.size = 24
	var b = DynamicFont.new(); b.font_data = fd; b.size = 30
	$Title.set("custom_fonts/font", t)
	$Subtitle.set("custom_fonts/font", s)
	$StartBtn.set("custom_fonts/font", b)

func _on_start():
	get_tree().change_scene("res://scenes/Main.tscn")

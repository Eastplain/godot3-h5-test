extends Control

const VERSION = "v0.1.0"

func _ready():
	_load_fonts()
	$VersionLabel.text = VERSION
	$StartBtn.connect("pressed", self, "_on_start")

func _load_fonts():
	var fd = DynamicFontData.new()
	fd.font_path = "res://resource/font/simhei.ttf"
	var t = DynamicFont.new(); t.font_data = fd; t.size = 52
	var s = DynamicFont.new(); s.font_data = fd; s.size = 24
	var b = DynamicFont.new(); b.font_data = fd; b.size = 30
	var v = DynamicFont.new(); v.font_data = fd; v.size = 14
	$Title.set("custom_fonts/font", t)
	$Subtitle.set("custom_fonts/font", s)
	$StartBtn.set("custom_fonts/font", b)
	$VersionLabel.set("custom_fonts/font", v)

func _on_start():
	get_tree().change_scene("res://scenes/Main.tscn")

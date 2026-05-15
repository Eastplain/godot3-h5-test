extends Control

enum FruitType { EMPTY, ORANGE, APPLE, GRAPE, LEMON, WATERMELON, BLUEBERRY, CHERRY, PEACH }
export(FruitType) var fruit_type = FruitType.ORANGE setget _set_type
export(bool) var draw_bg = true

func _set_type(v):
	fruit_type = v
	update()

func _draw():
	if draw_bg:
		draw_rect(Rect2(Vector2(), rect_size), Color(0.2, 0.2, 0.26))

	match fruit_type:
		FruitType.ORANGE:     _draw_orange()
		FruitType.APPLE:      _draw_apple()
		FruitType.GRAPE:      _draw_grape()
		FruitType.LEMON:      _draw_lemon()
		FruitType.WATERMELON: _draw_watermelon()
		FruitType.BLUEBERRY:  _draw_blueberry()
		FruitType.CHERRY:     _draw_cherry()
		FruitType.PEACH:      _draw_peach()

# ── 橘子 ──
func _draw_orange():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.38
	var b = _octagon(cx,cy,r); var c = Vector2(cx,cy)
	draw_colored_polygon(b, Color(1,0.55,0.05))
	draw_colored_polygon(PoolVector2Array([c,b[0],b[1]]), Color(1,0.68,0.15))
	draw_colored_polygon(PoolVector2Array([c,b[2],b[3]]), Color(0.95,0.48,0))
	draw_colored_polygon(PoolVector2Array([c,b[4],b[5]]), Color(0.85,0.38,0))
	draw_colored_polygon(PoolVector2Array([c,b[6],b[7]]), Color(1,0.6,0.1))
	draw_colored_polygon(PoolVector2Array([Vector2(cx-2,cy-r), Vector2(cx+2,cy-r), Vector2(cx,cy-r-6)]), Color(0.25,0.55,0.1))

# ── 苹果 ──
func _draw_apple():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.35
	var b = PoolVector2Array([Vector2(cx,cy-r-4), Vector2(cx+r*0.6,cy-r), Vector2(cx+r,cy), Vector2(cx+r*0.6,cy+r), Vector2(cx,cy+r-2), Vector2(cx-r*0.6,cy+r), Vector2(cx-r,cy), Vector2(cx-r*0.6,cy-r)])
	var c = Vector2(cx,cy)
	draw_colored_polygon(b, Color(0.85,0.12,0.12))
	draw_colored_polygon(PoolVector2Array([c,b[0],b[1]]), Color(0.95,0.28,0.22))
	draw_colored_polygon(PoolVector2Array([c,b[3],b[4]]), Color(0.7,0.08,0.08))
	draw_colored_polygon(PoolVector2Array([Vector2(cx-1.5,cy-r-4),Vector2(cx+1.5,cy-r-4),Vector2(cx,cy-r-10)]), Color(0.4,0.2,0.05))
	draw_colored_polygon(PoolVector2Array([Vector2(cx+2,cy-r-6),Vector2(cx+12,cy-r-10),Vector2(cx+10,cy-r-4)]), Color(0.25,0.65,0.12))

# ── 葡萄 ──
func _draw_grape():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.13
	var ps = [Vector2(cx,cy-r*1.5), Vector2(cx-r*1.2,cy-r*0.5), Vector2(cx+r*1.2,cy-r*0.5), Vector2(cx-r*0.8,cy+r*1), Vector2(cx+r*0.8,cy+r*1), Vector2(cx,cy+r*0.3)]
	var cs = [Color(0.5,0.12,0.58), Color(0.55,0.15,0.6), Color(0.6,0.2,0.65), Color(0.48,0.1,0.55), Color(0.52,0.13,0.56), Color(0.45,0.08,0.5)]
	for i in range(6): draw_circle(ps[i], r, cs[i])
	draw_line(Vector2(cx,cy-r*1.8), Vector2(cx+2,cy-r*3.2), Color(0.3,0.5,0.1), 2)

# ── 柠檬 ──
func _draw_lemon():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var rw = min(s.x,s.y)*0.28; var rh = rw*1.5
	var b = PoolVector2Array()
	for i in range(12):
		var a = i * TAU / 12
		b.append(Vector2(cx + cos(a) * rw, cy + sin(a) * rh))
	var c = Vector2(cx,cy)
	draw_colored_polygon(b, Color(1,0.85,0.1))
	draw_colored_polygon(PoolVector2Array([c,b[0],b[1]]), Color(1,0.95,0.3))
	draw_colored_polygon(PoolVector2Array([c,b[6],b[7]]), Color(0.9,0.75,0.05))
	draw_colored_polygon(PoolVector2Array([Vector2(cx,cy-rh-1),Vector2(cx-3,cy-rh+3),Vector2(cx+3,cy-rh+3)]), Color(0.3,0.55,0.1))

# ── 西瓜切片 ──
func _draw_watermelon():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.38
	var ri = PoolVector2Array(); var inn = PoolVector2Array()
	for i in range(7):
		var a = PI * i / 6
		ri.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
		inn.append(Vector2(cx + cos(a) * r * 0.85, cy + sin(a) * r * 0.85))
	draw_colored_polygon(ri, Color(0.2,0.65,0.2))
	draw_colored_polygon(inn, Color(0.9,0.12,0.12))
	draw_circle(Vector2(cx-r*0.3,cy-r*0.3), 2.5, Color(0.1,0.1,0.1))
	draw_circle(Vector2(cx+r*0.25,cy-r*0.35), 2.5, Color(0.1,0.1,0.1))
	draw_circle(Vector2(cx,cy-r*0.1), 2.5, Color(0.1,0.1,0.1))

# ── 蓝莓 ──
func _draw_blueberry():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.32
	draw_circle(Vector2(cx,cy), r, Color(0.2,0.35,0.85))
	draw_circle(Vector2(cx-r*0.3,cy-r*0.3), r*0.35, Color(0.35,0.5,0.95))
	draw_colored_polygon(PoolVector2Array([Vector2(cx-4,cy-r),Vector2(cx-2,cy-r-5),Vector2(cx,cy-r-2),Vector2(cx+2,cy-r-5),Vector2(cx+4,cy-r)]), Color(0.3,0.5,0.15))

# ── 樱桃 ──
func _draw_cherry():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.2
	draw_circle(Vector2(cx-r*0.8,cy+r*0.3), r, Color(0.75,0.08,0.08))
	draw_circle(Vector2(cx+r*0.8,cy+r*0.3), r, Color(0.8,0.1,0.1))
	draw_circle(Vector2(cx-r*1.0,cy+r*0.1), r*0.35, Color(0.9,0.25,0.25))
	draw_circle(Vector2(cx+r*0.6,cy+r*0.1), r*0.35, Color(0.95,0.3,0.3))
	draw_line(Vector2(cx-r*0.8,cy-r*0.7), Vector2(cx-1,cy-r*1.8), Color(0.3,0.5,0.1), 2)
	draw_line(Vector2(cx+r*0.8,cy-r*0.7), Vector2(cx+1,cy-r*1.8), Color(0.3,0.5,0.1), 2)
	draw_colored_polygon(PoolVector2Array([Vector2(cx-2,cy-r*1.8),Vector2(cx+8,cy-r*2.2),Vector2(cx+6,cy-r*1.6)]), Color(0.25,0.6,0.1))

# ── 桃子 ──
func _draw_peach():
	var s = rect_size; var cx = s.x/2; var cy = s.y/2; var r = min(s.x,s.y)*0.35
	var b = _octagon(cx,cy+2,r); var c = Vector2(cx,cy)
	draw_colored_polygon(b, Color(1,0.7,0.5))
	draw_colored_polygon(PoolVector2Array([c,b[0],b[1]]), Color(1,0.82,0.62))
	draw_colored_polygon(PoolVector2Array([c,b[4],b[5]]), Color(0.95,0.6,0.4))
	draw_line(Vector2(cx,cy-r-2), Vector2(cx,cy+r), Color(0.9,0.55,0.35), 1.5)
	draw_colored_polygon(PoolVector2Array([Vector2(cx+1,cy-r-2),Vector2(cx+10,cy-r-8),Vector2(cx+8,cy-r-2)]), Color(0.25,0.6,0.1))

func _octagon(cx, cy, r) -> PoolVector2Array:
	var pts = PoolVector2Array()
	for i in range(8):
		var a = i * TAU / 8 - TAU / 16
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	return pts

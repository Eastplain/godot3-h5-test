extends Control

onready var match_areas = [
	$CenterArea/MatchArea0, $CenterArea/MatchArea1, $CenterArea/MatchArea2
]
onready var bottom_slots = [
	$BottomBoxes/Choice0, $BottomBoxes/Choice1, $BottomBoxes/Choice2,
	$BottomBoxes/Choice3, $BottomBoxes/Choice4
]

var slot_contents = {}

var dragging = false
var drag_source = null
var drag_source_area = null
var drag_type = -1
var drag_preview = null
var animating = true
var _anim_phase = 0

var score = 0
var hard_mode = false  # false=普通, true=困难

func _ready():
	randomize()

	_layout_areas()

	for slot in bottom_slots:
		var t = randi() % 7 + 1
		slot_contents[slot] = t
		slot.fruit_type = t

	for area in match_areas:
		area.connect("matched", self, "_on_matched")

	drag_preview = preload("res://scenes/tiles/FruitTile.tscn").instance()
	drag_preview.draw_bg = false
	drag_preview.rect_min_size = Vector2(64, 64)
	drag_preview.visible = false
	add_child(drag_preview)

	for area in match_areas:
		area.margin_left = -600.0
		area.margin_right = -336.0

	_phase_bottom()


# ── 入场 ──

func _phase_bottom():
	_anim_phase = 0
	for slot in bottom_slots:
		slot.margin_top = 300.0
		slot.margin_bottom = 360.0

	for i in range(bottom_slots.size()):
		var slot = bottom_slots[i]
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(slot, "margin_top", 300.0, 0.0, 0.4, Tween.TRANS_QUINT, Tween.EASE_OUT, i * 0.12)
		tween.interpolate_property(slot, "margin_bottom", 360.0, 60.0, 0.4, Tween.TRANS_QUINT, Tween.EASE_OUT, i * 0.12)
		tween.start()

	var delay = bottom_slots.size() * 0.12 + 0.4
	var timer = get_tree().create_timer(delay)
	timer.connect("timeout", self, "_phase_area")

func _phase_area():
	_anim_phase = 1
	for area in match_areas:
		if hard_mode:
			area.random_fill()
		else:
			area.random_fill_normal()

	for i in range(match_areas.size()):
		var area = match_areas[i]
		area.margin_left = -600.0
		area.margin_right = -336.0
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(area, "margin_left", -600.0, 0.0, 0.35, Tween.TRANS_QUINT, Tween.EASE_OUT, i * 0.1)
		tween.interpolate_property(area, "margin_right", -336.0, 264.0, 0.35, Tween.TRANS_QUINT, Tween.EASE_OUT, i * 0.1)
		tween.start()

	var delay = match_areas.size() * 0.1 + 0.35
	var timer = get_tree().create_timer(delay)
	timer.connect("timeout", self, "_anim_all_done")

func _anim_all_done():
	animating = false


# ── 消除发车 ──

func _on_matched(area, amount):
	score += amount
	$TopBar/ScoreLabel.text = "Score: " + str(score)
	_animate_area_replace(area)

func _animate_area_replace(area):
	animating = true
	var idx = match_areas.find(area)
	if idx < 0:
		return

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(area, "margin_left", 0.0, 600.0, 0.45, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.interpolate_property(area, "margin_right", 264.0, 864.0, 0.45, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.connect("tween_completed", self, "_on_area_exit", [area])
	tween.start()

func _on_area_exit(obj, key, area):
	area.clear_all()
	if hard_mode:
		area.random_fill()
	else:
		area.random_fill_normal()
	area.margin_left = -600.0
	area.margin_right = -336.0

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(area, "margin_left", -600.0, 0.0, 0.4, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.interpolate_property(area, "margin_right", -336.0, 264.0, 0.4, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.connect("tween_completed", self, "_on_area_enter", [area])
	tween.start()

func _on_area_enter(obj, key, area):
	animating = false


# ── 输入 ──

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_touch_down(event.position)
		else:
			if dragging:
				_handle_touch_up(event.position)

	if event is InputEventScreenDrag and dragging:
		drag_preview.rect_position = event.position - Vector2(32, 32)

func _handle_touch_down(pos):
	if animating:
		return

	for slot in bottom_slots:
		if not _rect_contains(slot, pos):
			continue
		if slot_contents[slot] <= 0:
			continue
		_do_drag(slot, null, slot_contents[slot], pos)
		return

	for area in match_areas:
		var result = area.pickup_at(pos)
		if result.type > 0:
			_do_drag(result.slot, area, result.type, pos)
			return

func _do_drag(slot_node, area_ref, fruit_type, pos):
	dragging = true
	drag_source = slot_node
	drag_source_area = area_ref
	drag_type = fruit_type

	if area_ref == null:
		slot_node.fruit_type = 0

	drag_preview.fruit_type = drag_type
	drag_preview.rect_position = pos - Vector2(32, 32)
	drag_preview.visible = true

func _handle_touch_up(pos):
	drag_preview.visible = false

	for area in match_areas:
		if area.accept_drop(drag_type, pos):
			if drag_source_area == null:
				_refill_bottom(drag_source)
			dragging = false
			drag_source_area = null
			return

	if drag_source_area != null:
		drag_source_area.set_slot(drag_source, drag_type)
	else:
		drag_source.fruit_type = drag_type
		slot_contents[drag_source] = drag_type
	dragging = false
	drag_source_area = null


# ── 智能补货 ──

func _refill_bottom(slot_node):
	if hard_mode:
		_refill_hard(slot_node)
	else:
		_refill_normal(slot_node)


func _refill_normal(slot_node):
	var counts = _get_fruit_counts()
	var cand = []
	if randi() % 10 < 3:
		# 30% 选最少的
		var min_c = 999
		for t in range(1, 8):
			var c = counts.get(t, 0)
			if c < min_c:
				min_c = c; cand = [t]
			elif c == min_c:
				cand.append(t)
	else:
		# 50% 选最多的
		var max_c = -1
		for t in range(1, 8):
			var c = counts.get(t, 0)
			if c > max_c:
				max_c = c; cand = [t]
			elif c == max_c:
				cand.append(t)
	var chosen = cand[randi() % cand.size()]
	slot_contents[slot_node] = chosen
	slot_node.fruit_type = chosen


func _refill_hard(slot_node):
	var counts = _get_fruit_counts()
	var missing = []
	for t in range(1, 8):
		if counts.get(t, 0) <= 0:
			missing.append(t)

	var chosen
	if missing.size() > 0:
		chosen = missing[randi() % missing.size()]
	else:
		var min_c = 999
		var cand = []
		for t in range(1, 8):
			var c = counts.get(t, 0)
			if c < min_c:
				min_c = c; cand = [t]
			elif c == min_c:
				cand.append(t)
		chosen = cand[randi() % cand.size()]

	slot_contents[slot_node] = chosen
	slot_node.fruit_type = chosen


func _get_fruit_counts():
	var counts = {}
	for t in range(1, 8):
		counts[t] = 0

	for slot in bottom_slots:
		var t = slot_contents[slot]
		if t > 0:
			counts[t] = counts[t] + 1

	for area in match_areas:
		for slot in area.slots:
			var t = area.slot_contents.get(slot, -1)
			if t > 0:
				counts[t] = counts[t] + 1

	return counts


# ── 布局 ──

func _notification(what):
	if what == NOTIFICATION_RESIZED and match_areas:
		_layout_areas()

func _layout_areas():
	var area_w = 264.0
	var area_h = 80.0
	var gap = 40.0
	var count = match_areas.size()
	var total_h = count * area_h + (count - 1) * gap

	var ca = $CenterArea
	ca.margin_left = -area_w / 2
	ca.margin_right = area_w / 2
	ca.margin_top = -total_h / 2
	ca.margin_bottom = total_h / 2

	for i in range(count):
		if not match_areas[i]:
			continue
		var y = i * (area_h + gap)
		match_areas[i].margin_left = 0
		match_areas[i].margin_right = area_w
		match_areas[i].margin_top = y
		match_areas[i].margin_bottom = y + area_h

func _rect_contains(node, point):
	var r = Rect2(node.rect_global_position, node.rect_size)
	return r.has_point(point)

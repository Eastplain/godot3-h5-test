extends Control

signal matched(area, score_amount)

onready var slots = [$Slot0, $Slot1, $Slot2]
var slot_contents = {}

func _ready():
	for slot in slots:
		slot_contents[slot] = -1
		slot.fruit_type = 0


# 困难模式：2 个不同水果
func random_fill():
	var f1 = randi() % 7 + 1
	var f2 = f1
	while f2 == f1:
		f2 = randi() % 7 + 1

	var indices = [0, 1, 2]
	for i in range(indices.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp

	slot_contents[slots[indices[0]]] = f1
	slots[indices[0]].fruit_type = f1
	slot_contents[slots[indices[1]]] = f2
	slots[indices[1]].fruit_type = f2


# 普通模式：1-2 个随机水果（可相同）
func random_fill_normal():
	var count = 1 + randi() % 2
	var indices = [0, 1, 2]
	for i in range(indices.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp
	for i in range(count):
		var idx = indices[i]
		var f = randi() % 7 + 1
		slot_contents[slots[idx]] = f
		slots[idx].fruit_type = f


# 清空所有格
func clear_all():
	for slot in slots:
		slot_contents[slot] = -1
		slot.fruit_type = 0


# 拾取某个位置的水果（返回水果类型和slot，若无则type=-1）
func pickup_at(pos):
	for slot in slots:
		var r = Rect2(slot.rect_global_position, slot.rect_size)
		if r.has_point(pos) and slot_contents[slot] > 0:
			var f = slot_contents[slot]
			slot_contents[slot] = -1
			slot.fruit_type = 0
			return {"type": f, "slot": slot}
	return {"type": -1, "slot": null}


# 设置某个slot的水果
func set_slot(slot_node, fruit_type):
	slot_contents[slot_node] = fruit_type
	slot_node.fruit_type = fruit_type


# 放入空槽
func accept_drop(fruit_type, pos) -> bool:
	for slot in slots:
		if slot_contents[slot] >= 0:
			continue
		var r = Rect2(slot.rect_global_position, slot.rect_size)
		if not r.has_point(pos):
			continue
		slot_contents[slot] = fruit_type
		slot.fruit_type = fruit_type
		_check_match()
		return true
	return false


func _check_match():
	var t0 = slot_contents[slots[0]]
	var t1 = slot_contents[slots[1]]
	var t2 = slot_contents[slots[2]]
	if t0 > 0 and t0 == t1 and t1 == t2:
		emit_signal("matched", self, 1)

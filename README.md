# 🍉 水果三消 - Match3 Demo (Godot 3.6)

Godot 3.6 开发的竖屏水果三消游戏。H5 导出可直接在手机浏览器上运行。

## 🎮 玩法

- **底部 5 个待选框**：随机生成水果（橘子/苹果/葡萄/柠檬/西瓜/蓝莓/樱桃/桃子），按住拖拽到上方消除区
- **3 个消除组（MatchArea）**：每组 3 个空槽，接受被拖入的水果
- **三消判定**：同一组内 3 个水果相同时 → 整组向右滑出（装车发车效果）→ 重置后从左侧滑入新的 1-2 个水果
- **跨组拖拽**：消除区内的水果也可以拖拽到其他消除组
- **自动补货**：底部槽每次消耗后立即生成新的水果

### 🎯 双难度模式

| 模式 | 消除组刷新 | 底部补货策略 |
|------|-----------|-------------|
| **普通** | 1-2 个随机水果 | 30% 补最少 / 70% 补最多 |
| **困难** | 2 个必定不同的水果 | 优先补缺失水果，都有则补最少 |

`hard_mode` 变量在 `scripts/Main.gd` 第 22 行，`false`=普通，`true`=困难。

## 🏗 项目结构

```
match3-demo/
├── project.godot                  # 项目配置
├── export_presets.cfg             # H5 导出配置
├── .gitignore
│
├── scenes/
│   ├── Menu.tscn                  # 主菜单场景
│   ├── Main.tscn                  # 游戏主场景
│   └── tiles/
│       ├── FruitTile.tscn         # 水果预制件（Control + _draw 手绘）
│       └── MatchArea.tscn         # 消除组预制件（3 槽 + 独立匹配逻辑）
│
├── scripts/
│   ├── Menu.gd                    # 菜单逻辑 → 点击"开始游戏"进入 Main
│   ├── Main.gd                    # 游戏主逻辑：入场动画、拖拽、补货、发车
│   ├── DebugFrame.gd              # 16:9 调试框（可删）
│   └── tiles/
│       ├── FruitTile.gd           # 7 种水果的手绘 _draw() 实现
│       └── MatchArea.gd           # 消除组逻辑：random_fill、pickup_at、accept_drop、_check_match
│
└── docs/                          # GitHub Pages H5 导出目录
```

## 🧩 核心技术点

### 1. 手绘水果（`_draw()` + `draw_colored_polygon`）

Godot 3 没有单独的 "Rect" 节点。每种水果用 `draw_colored_polygon(PoolVector2Array, Color)` 绘制低多边形八边形/椭圆 + 三角形切面表现立体感。水果图形画在暗色框底之上（不替换框），拖拽预览则关掉框底（`draw_bg=false`）。

```gdscript
enum FruitType { EMPTY, ORANGE, APPLE, GRAPE, LEMON, WATERMELON, BLUEBERRY, CHERRY, PEACH }
export(FruitType) var fruit_type setget _set_type
export(bool) var draw_bg = true

func _draw():
    if draw_bg:
        draw_rect(Rect2(Vector2(), rect_size), Color(0.2, 0.2, 0.26))
    match fruit_type:
        FruitType.ORANGE: _draw_orange()
        # ...
```

### 2. 跨平台输入（鼠标 + 触摸）

```ini
# project.godot
[input_devices]
pointing/emulate_touch_from_mouse=true
```

统一处理 `InputEventScreenTouch` + `InputEventScreenDrag`，鼠标和手指走同一路径。

### 3. 入场动画（Tween 链）

两段式动画：底部 5 槽先依次从下方滑入 → 消除组再从左侧依次滑入（每行带 1-2 个初始水果）。

```gdscript
var tween = Tween.new()
add_child(tween)
tween.interpolate_property(slot, "margin_top", 300.0, 0.0, 0.4, Tween.TRANS_QUINT, Tween.EASE_OUT, delay)
tween.start()
```

### 4. 消除组件生命周期（MatchArea）

MatchArea 是独立预制件，自己管理 3 个槽的状态和匹配判定。Main.gd 通过信号 `matched(area, score)` 接收消除通知，驱动发车动画。

```gdscript
# MatchArea 核心方法
random_fill()          # 困难模式：2 个不同水果
random_fill_normal()   # 普通模式：1-2 个随机水果
clear_all()            # 清空所有槽
pickup_at(pos)         # 拾取某位置的水果（跨组拖拽用）
accept_drop(type, pos) # 放入空槽
_set_slot(node, type)  # 设置指定槽位
```

### 5. 智能补货算法

从**所有槽位**（底部 + 所有消除组）统计每种水果的数量，做到：

```
缺水果 → 补缺失的
全都有 → 根据难度选最少/最多的
```

### 6. 发车动画（三消成功）

三消匹配后：
1. 整组向右滑出（`margin_left: 0 → 600`，`Tween.TRANS_QUINT + EASE_IN`）
2. 重置（`clear_all()` + `random_fill()`）
3. 定位到左侧幕外（`margin_left: -600`）
4. 从左侧滑入（`margin_left: -600 → 0`，`EASE_OUT`）

### 7. 屏幕适配（Control 锚点）

```ini
# project.godot
window/stretch/mode="2d"
window/stretch/aspect="expand"
```

- **TopBar**：`anchor_right=1` 全宽固定顶部
- **CenterArea**：`anchor_left/top/right/bottom=0.5` 四边居中，代码动态设置尺寸
- **BottomBoxes**：`anchor_left=0.5, anchor_top=1.0` 底部居中
- **MatchAreas**：Y 位置由 `_layout_areas()` 代码动态计算

## 🌐 H5 导出 & 部署

已配置 GitHub Pages，访问：

**https://eastplain.github.io/godot3-h5-test/**

### iOS Safari 兼容

iOS 上可能遇到"进度条走完 → 转圈卡死"问题。已在 `export_presets.cfg` 中配置：

```ini
variant/export_type=0           # 单线程模式
html/head_include="..."         # touch-action:none + touchstart 监听器激活上下文
```

### 部署流程

```bash
# 1. Godot 3 编辑器导出 H5 到 export/web/index.html
# 2. 拷贝到 docs/
cp export/web/* docs/
# 3. 推送到 GitHub
git add docs/ && git commit -m "H5 build" && git push
```

## 🔧 开发环境

- **引擎**：Godot 3.6.2 stable
- **编辑器**：Windows（Godot 3 无 MCP 支持，.tscn 手动编辑）
- **MCP**：Godot 4 MCP 仅用于参考（版本不兼容）
- **API 查询**：`godot-rag` skill 的 `--version 3.6` 模式
- **H5 部署**：GitHub Pages（`docs/` 目录）

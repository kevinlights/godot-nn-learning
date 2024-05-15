extends Area2D

class_name Ball

#signal botHit
#signal playerHit

var initialVel = 300 
var vel = initialVel # 初始速度
var horizontal = 1
var vertical = 0
var k

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# 处理上下边缘碰撞
	if position.y <= 30:
		bounce(-30)
	if position.y >= 730:
		bounce(30)
	# 左
	if position.x <= 0: # AI 得分
		# 触发 Game 中的 onBotHit 方法
		get_node("..").onBotHit(k)
		#botHit.emit(k)
		restart(1) # player 发球 ?
	# 右
	if position.x >= 1366: # player 得分
		get_node("..").onPlayerHit(k)
		#playerHit.emit(k)
		restart(-1)
	
	run(delta)

func run(delta):
	position += Vector2(horizontal, vertical) * vel * delta

func restart(newHorizontal):
	horizontal = newHorizontal
	#垂直方向加一些随机，模拟不同发球角度
	vertical = 0 + randf_range(-0.5, 0.5)
	# 球的初始位置，暂时放在中心
	position = Vector2(683, 384)

# 球的反弹，这里只设置垂直方向的变化，方向不变，并对值进行一些调整，模拟现实中的摩擦力，会损失一部分垂直速度
func bounce(d):
	vertical += d * -0.01
	
	

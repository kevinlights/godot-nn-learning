extends Node

class_name Racket

var vel = 250
var player


func _init(playerNode):
	player = playerNode

# direction: -1=向上移动，1=向下移动
func walk(direction, delta):
	# 移动到边界，则停止
	if player.position.y < 30 and direction == -1:
		return
	
	if player.position.y > 270 and direction == 1:
		return
	# 使用球拍的对象位置发生移动
	player.position += Vector2(0, direction) * vel * delta
	
# 球拍击中球时，球在水平方向向相反运动
func hit(ball: Ball):
	ball.horizontal = -ball.horizontal
	ball.bounce(40) # 球拍反弹速度快一些
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Area2D

class_name Bot

var NN = preload ("res://lib/Neural Network/Brain.gd")

var weightsIH = [[0, 0, 0], [0, 0, 0]]
var weightsHO = [[0, 0], [0, 0]]

var biasH = [[0], [0]]
var biasO = [[0], [0]]

var nn
var racket
var k
var bot_name # 随机生成名字

var points = 0
var lose = 0
var lessThan05 = 0

const name_prefix = ["王", "李", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴", "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"]
const name_middle = ["伟", "芳", "静", "强", "娜", "敏", "磊", "军", "洋", "杰", "娟", "霞", "勇", "艳", "波", "涛", "辉", "玲", "华", "丹", "民", "国", "宏", "宇", "博", "文", "辉", "翔", "飞", "鹏", "龙", "虎", "凤", "燕", "霞", "婷", "丽", "颖", "欣", "怡", "悦", "欢", "乐", "嘉", "宜", "安", "平", "宁", "和", "美", "善", "真", "诚", "仁", "义", "礼", "智", "信", "金", "银", "铜", "铁", "钢", "石", "玉", "珠", "宝", "光", "明", "亮", "力", "勇", "壮", "硕", "厚", "实", "坚", "稳", "固", "专", "精", "通", "达", "慧", "思", "考", "谋", "略", "宏", "宇", "博", "文", "学", "识", "才", "智", "慧", "颖", "悟", "觉", "省", "审", "观", "察", "探", "究", "研", "索", "详", "细", "精", "密", "严", "谨", "慎", "稳", "妥", "确", "实", "效", "率", "果", "断", "决", "定", "行", "动", "做", "为", "执", "行", "践", "履", "从", "顺", "接", "受", "承", "担", "负", "任", "务", "工", "作", "劳", "动", "努", "力", "勤", "奋", "刻", "苦", "苦", "耐", "劳", "奋", "斗", "拼", "搏", "竞", "赛", "比", "赛", "较", "量", "争", "取", "夺", "取", "获", "得", "成", "功", "胜", "利", "优", "胜", "胜", "出", "超", "越", "突", "破", "创", "造", "发", "明", "新", "颖", "独",]
const name_suffix = ["伟", "芳", "静", "强", "娜", "敏", "磊", "军", "洋", "杰", "娟", "霞", "勇", "艳", "波", "涛", "辉", "玲", "华", "丹"]

func init(newWeightsIH, newWeightsHO, newBiasH, newBiasO):
	weightsIH = newWeightsIH
	weightsHO = newWeightsHO
	
	biasH = newBiasH
	biasO = newBiasO

	# bot_name = name_prefix[randi() % name_prefix.size()] + " " \
	# 	+ name_prefix[randi() % name_prefix.size()] + " " \
	# 	+ name_prefix[randi() % name_prefix.size()]

	bot_name = name_prefix[randi() % name_prefix.size()] \
		+ name_prefix[randi() % name_prefix.size()] \
		+ name_prefix[randi() % name_prefix.size()]
	
	racket = Racket.new(self)
	nn = NN.new({
		"input_nodes": 3,
		"hidden_nodes": 6,
		"output_nodes": 2,
		
		"weights_ih": Matrix.new(weightsIH),
		"weights_ho": Matrix.new(weightsHO),
		
		"bias_h": Matrix.new(biasH),
		"bias_o": Matrix.new(biasO)
	})
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ball
	var balls = get_tree().get_nodes_in_group("ball")
	
	for i in balls:
		# 只处理自己对应的球
		if (i.k == k):
			ball = i
	if ball:
		# 距离球的位置：当前位置与球的位置
		#var distanceOfBall = position.x - ball.position.x - 64 - 12 +  93 - 30
		#var distanceOfBall = position.x - ball.position.x + 100
		# print("distanceOfBall=", distanceOfBall)
		var distanceOfBall = position.x - ball.position.x # 简化处理成 x 之差
		var ballY = ball.position.y
		var ballVelocity = ball.vel
	
		# var normalizedValues = Vector3(position.y, distanceOfBall, ballY).normalized()
		var normalizedValues = Vector4(position.y, distanceOfBall, ballY, ballVelocity).normalized()

		
		#print([normalizedValues.x, normalizedValues.y, normalizedValues.z])
		var nnPredict = nn.predict([normalizedValues.x, normalizedValues.y, normalizedValues.z, normalizedValues.w])

		#print("nnPredict: ", nnPredict)
		if (nnPredict[0] >= 1):
			# 向下移动
			racket.walk(1, delta)
			
		if (nnPredict[1] >= 1):
			# 向上移动
			racket.walk( - 1, delta)

func _on_area_entered(ball: Ball):
	if ball.k == k:
		# 球来了，判断是否是自己对应的球
		racket.hit(ball)
		get_node("..").onBotHit(k)

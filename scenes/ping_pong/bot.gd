extends Area2D

class_name Bot

var NN = preload("res://lib/Neural Network/Brain.gd")
@onready var game = $"."

var weightsIH = [[0, 0, 0], [0, 0, 0]]
var weightsHO = [[0, 0], [0, 0]]

var biasH = [[0], [0]]
var biasO = [[0], [0]]

var nn
var racket
var k

var points = 0
var lose = 0
var lessThan05 = 0


func init(newWeightsIH, newWeightsHO, newBiasH, newBiasO):
	weightsIH = newWeightsIH
	weightsHO = newWeightsHO
	
	biasH = newBiasH
	biasO = newBiasO
	
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
	var balls = get_tree().get_nodes_in_group("")
	
	for i in balls:
		# 只处理自己对应的球
		if(i.k == k):
			ball = i
	if ball:
		# 距离球的位置：当前位置
		#var distanceOfBall = position.x - ball.position.x - 64 - 12 +  93 - 30
		# print("distanceOfBall=", distanceOfBall)
		var distanceOfBall = position.x - ball.position.x # 简化处理成 x 之差
		var ballY = ball.position.y
		var ballVelocity = ball.vel
	
		var normalizedValues = Vector3(position.y, distanceOfBall, ballY).normalized()
		
		#print([normalizedValues.x, normalizedValues.y, normalizedValues.z])
		var nnPredict = nn.predict([normalizedValues.x, normalizedValues.y, normalizedValues.z])

		#print(nnPredict)
		if(nnPredict[0] >= 1):
			racket.walk(1, delta)
			
		if(nnPredict[1] >= 1):	
			racket.walk(-1, delta)


func _on_area_entered(ball: Ball):
	if ball.k == k:
		# 球来了，判断是否是自己对应的球
		racket.hit(ball)

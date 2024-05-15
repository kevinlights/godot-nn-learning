extends Node2D

var GeneticAlgorithm = preload("res://lib/Genetic/Algorithm.gd")
const botScn = preload("res://games/ping_pong/bot.tscn")
const ballScn = preload("res://games/ping_pong/ball.tscn")
@onready var playerLabel = $PlayerScore/Label
@onready var botLabel = $AIScore/Label2
@onready var best_rating = $GeneticInfo/BestRating
@onready var generation = $GeneticInfo/Generation
@onready var time_label = $Timer/TimeLabel
@onready var avg_lifetime = $GeneticInfo/AvgLifetime
@onready var population_label = $GeneticInfo/Population


const save_path = "user://genetic_top_chromosome.save"

var genetic
var playerScore = 0
var botScore = 0
var time = 0
var numberPopulation = 30
var initializeWithThatWeights = null

@export var isPlay: bool = false
#var initializeWithThatWeights = [0.80117901334392, -0.66901837430714, -0.52845502307405, 0.05880103066812, -0.73453974858919, -0.0796239889588, -0.12428542470532, 0.30518798441505, 0.85899762900494, -0.08190592403411, 0.47327935482996, -0.86326190250845, -0.69742893002237, 0.95990391231876, -0.63878387542086, -0.8503956144581, -0.59480842259092, -0.45214571929147, 0.20914894404746, -0.60743953447193, 0.97109704294534, -0.63724922311874, 0.45990465709022, -0.42945681739216, -0.59722126449732, -0.79992202477882, -0.59122138474528, -0.73086854761705, 0.2056413130883, 0.75774561997752, -0.45376233604866, -0.96554940595748, -0.04750574110891, 0.41143160782741, -0.95331035386667, 0.49499454810343, 0.47438286446786, -0.14477792127091]

#var numberPopulation = 1
#var initializeWithThatWeights = [0.28398900342884, -0.60453478648872, 0.55492583934538, -0.05810648940862, -0.91899430285108, 0.70069946458545, -0.86265010385303, 0.04880271009415, 0.42889309262115, 0.40570440328159, 0.33891300344427, -0.71753507004232, 0.7195791124843, -0.14277705684791, -0.76325680131208, -0.79758179128695, -0.96025617526922, -0.07370477893306, 0.60174757097763, -0.03262570606235, -0.59723506044814, 0.26665747949679, -0.74511767117094, 0.4267707639295, -0.25251423957189, -0.88329778095058, -0.75657513328442, 0.35145239642274, -0.83864439018043, 0.63421435340017, 0.97568805393627, 0.46982245992626, -0.08194632666399, -0.70956490277373, 0.93720645309891, 0.45905771712662, 0.86677297747542, -0.86100708330097]

var instances = []
var balls = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if isPlay:
		numberPopulation = 1
		initializeWithThatWeights = [-0.17791726534954, 0.56531091198556, 0.17127137021365, -0.35409071728011, -0.77203535664811, -0.14772685296586, -0.91572151461719, -0.05759373628576, 0.18616152233176, -0.40068327925061, -0.28312052452514, 0.98658467533502, -0.41413520874465, 0.68963129772125, -0.90224254422412, 0.31793738102075, 0.73543265816527, 0.69341185141943, -0.78114651218119, -0.72235752698003, 0.21940343403652, 0.7153821622703, 0.21925748337227, 0.77943066317042, -0.13616072638008, 0.62742974281299, -0.84131736839207, 0.30349987040562, -0.32906911546436, 0.94077225071319, 0.07033259216061, -0.04502562009561, -0.41674743733517, -0.16370546543671, 0.85214243191028, -0.5782441005697, 0.6433441759407, -0.49278584092837]
	genetic = GeneticAlgorithm.GeneticAlgorithm.new(numberPopulation, 0.1)
	genetic.initializePopulation(initializeWithThatWeights)
	
	displayPopulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	time_label.text = str(round(time))
	
# 删除种群，但是参数保留
func deletePopulation():
	for instance in instances:
		# 这一句暂时没用
		# genetic.population[instance.k].setPointsAndLose(instance.points, instance.lose)
		# 设置个体的生存率
		genetic.population[instance.k].fitness()
		# 将当前个体销毁
		instance.queue_free()
	# 挨个销毁球
	for instance in balls:
		instance.queue_free()

	# 清空数组
	instances = []
	balls = []

# 在场景中显示种群
func displayPopulation():
	var k = 0
	randomize()
	var kColor = [randf(), randf(), randf()]
	print("population size: ", genetic.population.size())
	population_label.text = "Population: " + str(len(genetic.population))
	# 打印当前种群世代
	generation.text = "Generation: " + str(genetic.generation)
	for i in range(genetic.population.size()):
		var pongbot = botScn.instantiate()
		
		pongbot.k = k
		
		pongbot.modulate = Color(kColor[0], kColor[1], kColor[2])
		
		var values = genetic.population[i].chromosome
		
		var weightsIH = [[values[0], values[1], values[2]], [values[3], values[4], values[5]], [values[6], values[7], values[8]], [values[9], values[10], values[11]], [values[12], values[13], values[14]], [values[15], values[16], values[17]]]
		var weightsHO = [[values[18], values[19], values[20], values[21], values[22], values[23]], [values[24], values[25], values[26], values[27], values[28], values[29]]]
		
		var biasH = [[values[30]], [values[31]], [values[32]], [values[33]], [values[34]], [values[35]]]
		var biasO = [[values[36]], [values[37]]]
		
		pongbot.init(weightsIH, weightsHO, biasH, biasO)
		
		# 球拍默认可以在中间，模拟实际情形，但会导致 AI 出现惰性，不建议
		#pongbot.position = Vector2(500, 145)
		# 建议放到顶部或底部，增强 AI 的驱动力
		pongbot.position = Vector2(500, 45)
		var ball = ballScn.instantiate()
		
		ball.add_to_group("ball")
		#ball.connect("playerHit", onPlayerHit)
		#ball.connect("botHit", onBotHit)
			
		ball.restart(1)
		ball.k = k
		ball.modulate = Color(kColor[0], kColor[1], kColor[2])
		add_child(ball)
			
		balls.append(ball)
			
		randomize()
		kColor = [randf(), randf(), randf()]
		k += 1
		
		add_child(pongbot)
		instances.append(pongbot)
	
# 玩家得分：清空屏幕重新开始训练
# 但是参数未变，在原有的参数基础上进行训练，提高准确度
func onPlayerHit(k):
	#print("onPlayerHit", k)
	playerScore += 1
	
	for i in range(instances.size()):
		# 遍历个体和球
		var instance = instances[i]
		var ball = balls[i]
		
		if instance.k == k:
			# 跟玩家击中的球的索引进行比较，只处理被击中得分的球和相应的个体
			genetic.population[instance.k].setLifeTime(time) # 设置生存时间
			genetic.population[instance.k].fitness() # 设置生存率
			instance.queue_free() # 将当前处理的个体销毁
			ball.queue_free() # 将当前的球销毁
			instances.erase(instance) # 从数组中移除个体
			balls.erase(ball)
			break

	if not instances.size():
		# 如果当前没有 AI 实体了，就重新训练
		restart()
	playerLabel.text = str(playerScore)
	
func onBotHit(k):
	#print("onBotHit", k)
	botScore += 1
	botLabel.text = str(botScore)

# 重启方法
func restart():
	time = 0
	playerScore = 0
	botScore = 0
	
	# 将当前的世代加1
	genetic.generation += 1
	
	# 清空屏幕上的显示得分
	playerLabel.text = "0"
	botLabel.text = "0"
	
	# 删除种群
	deletePopulation()
	# 按照生存率排序种群
	genetic.sortPopulation()
	
	# 显示当前最好的生存率
	best_rating.text = "Best Rating: " + str(round(genetic.bestSolution.rating))
	
	# 计算种群平均生存率（生存时间）
	var average = 0
	for i in genetic.population:
		# print(i.rating)
		average += i.rating
	
	average /= genetic.population.size()
	
	# 创建新种群，即产生 2 个新个体
	genetic.createNewPopulation()
	# 在场景中绘制种群
	displayPopulation()
	
	#print("NEW POPULATION")
	#for item in genetic.population:
		#print(item.chromosome)	

	
	avg_lifetime.text = "Avg Lifetime: " + str(round(average))
	
	print("average lifetime: ", average)
	print("bestSolution: ", genetic.bestSolution.chromosome)
	print("bestSolution size: ", len(genetic.bestSolution.chromosome))
	# save top N chromosome to file
	saveTopNChromosome()

func saveTopNChromosome(n=10):
	var topN = []
	if n > len(genetic.population):
		n = len(genetic.population)
	for i in range(n):
		topN.append(genetic.population[i].chromosome)
	var top_n_data = JSON.stringify({
		"generation": genetic.generation,
		"top_n_chromosome": topN
	})
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(top_n_data)
	print("chromosome data was saved")
	
func loadChromosome():
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json_str = file.get_line()
		var json = JSON.new()
		var parsed = json.parse(json_str)
		if not parsed == OK:
			print("parse error", json.get_error_message(), json.get_error_line())
			continue
		var top_n_data = json.get_data()
		return top_n_data

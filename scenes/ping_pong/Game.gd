extends Node2D

var GeneticAlgorithm = preload("res://lib/Genetic/Algorithm.gd")
const botScn = preload("res://scenes/ping_pong/bot.tscn")
const ballScn = preload("res://scenes/ping_pong/ball.tscn")
@onready var playerLabel = $PlayerScore/Label
@onready var botLabel = $AIScore/Label2
@onready var best_rating = $GeneticInfo/BestRating
@onready var generation = $GeneticInfo/Generation
@onready var time_label = $Timer/TimeLabel


var genetic
var playerScore = 0
var botScore = 0
var time = 0
var numberPopulation = 30
#var initializeWithThatWeights = null
var initializeWithThatWeights = [0.80117901334392, -0.66901837430714, -0.52845502307405, 0.05880103066812, -0.73453974858919, -0.0796239889588, -0.12428542470532, 0.30518798441505, 0.85899762900494, -0.08190592403411, 0.47327935482996, -0.86326190250845, -0.69742893002237, 0.95990391231876, -0.63878387542086, -0.8503956144581, -0.59480842259092, -0.45214571929147, 0.20914894404746, -0.60743953447193, 0.97109704294534, -0.63724922311874, 0.45990465709022, -0.42945681739216, -0.59722126449732, -0.79992202477882, -0.59122138474528, -0.73086854761705, 0.2056413130883, 0.75774561997752, -0.45376233604866, -0.96554940595748, -0.04750574110891, 0.41143160782741, -0.95331035386667, 0.49499454810343, 0.47438286446786, -0.14477792127091]
var instances = []
var balls = []

# Called when the node enters the scene tree for the first time.
func _ready():
	genetic = GeneticAlgorithm.GeneticAlgorithm.new(numberPopulation, 0.1)
	genetic.initializePopulation(initializeWithThatWeights)
	
	setPopulation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	time_label.text = str(round(time))
	

func deletePopulation():
	for instance in instances:
		genetic.population[instance.k].setPointsAndLose(instance.points, instance.lose)
		genetic.population[instance.k].fitness()
		instance.queue_free()
		
	for instance in balls:
		instance.queue_free()

	instances = []
	balls = []


func setPopulation():
	var k = 0
	randomize()
	var kColor = [randf(), randf(), randf()]
	print("population size: ", genetic.population.size())
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
		
		#pongbot.position = Vector2(500, 145)
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
	

func onPlayerHit(k):
	#print("onPlayerHit", k)
	playerScore += 1
	
	for i in range(instances.size()):
		var instance = instances[i]
		var ball = balls[i]
		
		if instance.k == k:
			genetic.population[instance.k].setLifeTime(time)
			genetic.population[instance.k].fitness()
			instance.queue_free()
			ball.queue_free()
			instances.erase(instance)
			balls.erase(ball)
			break

	if not instances.size():
		restart()
	playerLabel.text = str(playerScore)
	
func onBotHit(k):
	#print("onBotHit", k)
	botScore += 1
	botLabel.text = str(botScore)


func restart():
	time = 0
	playerScore = 0
	botScore = 0
	
	genetic.generation += 1
	
	playerLabel.text = "0"
	botLabel.text = "0"
	
	deletePopulation()
	genetic.sortPopulation()
	
	best_rating.text = "Best Rating: " + str(genetic.bestSolution.rating)
	
	var average = 0
	
	for i in genetic.population:
		print(i.rating)
		average += i.rating
	
	average /= genetic.population.size()
	
	genetic.createNewPopulation()
	setPopulation()
	
	#print("NEW POPULATION")
	#for item in genetic.population:
		#print(item.chromosome)	

	generation.text = "Generation: " + str(genetic.generation)
	
	print(genetic.bestSolution.chromosome)

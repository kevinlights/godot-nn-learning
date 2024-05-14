extends Node

# 个体类
class Individual:
	var generation # 世代
	var chromosome # 染色体
	var pointsDid 
	var lifeTime # 生活时间
	var rating # 生存率
	
	func _init(numberOfChromosomes = null, chromosome = [], generation = 1):
		self.generation = generation
		self.chromosome = chromosome
		self.pointsDid = 0
		self.lifeTime = 0
		
		if(numberOfChromosomes): # 第一代需要随机生成染色体
			generateFirstGeneration(numberOfChromosomes)

	func setLifeTime(newLifeTime):
		self.lifeTime = newLifeTime

	func generateFirstGeneration(numberOfChromosomes):
		for i in range(numberOfChromosomes):
			# 随机化生成染色体，值为 -1 到 1 中间
			randomize()
			self.chromosome.append(randf_range(-1, 1))

	func setChromosome(newChromosome):
		self.chromosome = newChromosome

	# 交叉，产生下一代，一次产生 2 个新个体
	func crossover(anotherIndividual):
		randomize()
		# 在自身染色体数量中随机选取一些，先计算出交叉点
		var crossoverPoint = round(randf() * self.chromosome.size())
	
		var chromoOneOne = []
		var chromoOneTwo = []
		var chromoTwoOne = []
		var chromoTwoTwo = []
		
		# 将每个个体的染色体分成左右两个区域, 1, 2
		# 再利用算法进行交叉，得到下一代的染色体构成
		
		# 逐个取交叉点数量的另一个体 B 的染色体，记作 B1
		for i in range(0, crossoverPoint, 1):
			chromoOneOne.append(anotherIndividual.chromosome[i])
		# 从交叉点开始，取出自身 A 的染色体，记作 A2
		for i in range(crossoverPoint, self.chromosome.size(), 1):
			chromoOneTwo.append(self.chromosome[i])
		# 取出自身 A 剩下的染色体，记作 A1
		for i in range(0, crossoverPoint, 1):
			chromoTwoOne.append(self.chromosome[i])
		# 从交叉点开始，取出另一个体 B 的染色体 B2
		for i in range(crossoverPoint, anotherIndividual.chromosome.size(), 1):
			chromoTwoTwo.append(anotherIndividual.chromosome[i])
		# 下一代1 染色体来源于 A2 + B1
		var childOneChromosome = chromoOneOne + chromoOneTwo
		# 下一代2 染色体来源于 A1 + B2
		var childTwoChromosome = chromoTwoOne + chromoTwoTwo

		var children = [Individual.new(null, childOneChromosome, self.generation + 1), Individual.new(null, childTwoChromosome, self.generation + 1)]

		return children
	
	# 适应度用生活时间计算
	func fitness():
		self.rating = self.lifeTime
	
	# 变异，小于变异概率则对染色体进行变异
	func mutate(mutateProbability):
		for i in range(len(self.chromosome)):
			randomize()
			if randf() < mutateProbability:
				randomize()
				self.chromosome[i] = randf_range(-1, 1)

# 遗传算法类
class GeneticAlgorithm:
	var populationLength # 种群数量
	var mutationRate # 变异率
	var population # 种群
	var generation # 世代
	var bestSolution # 最好的生存方案
	
	func _init(populationLen, mutationR):
		self.populationLength = populationLen
		self.mutationRate = mutationR

		self.population = []
		self.generation = 1
		self.bestSolution = 0

	# 初始化种群，提供初始化权重数据，作为染色体数组初始化值，目前需要 长度为 38 的数组，取决于要构建的神经网络结构
	func initializePopulation(initializeWeights):
		for i in range(self.populationLength):
			var individual
			
			if(initializeWeights): 
				individual = Individual.new(38, initializeWeights, 1)
			else:
				individual = Individual.new(38, [], 1)

			self.population.append(individual)

	# 按生存时间进行倒序排列后，第一个就是最好的生存方案
	func sortPopulation():
		self.population.sort_custom(customComparison)
		self.bestSolution = self.population[0]
	
	func customComparison(a, b):
		return a.rating > b.rating

	# 获取种群全体的生存率之和
	func getRatingSum():
		var sum = 0

		for individual in self.population:
			sum += individual.rating
	
		return sum

	func showBestSolutionNumber():
		return self.bestSolution.rating

	# 随机选择父辈
	func selectFather():
		var father = -1
		# 随机获取种群部分总生存率，用于判断是否达到了父辈选择的标准
		randomize()
		var randomValue = randf() * self.getRatingSum()

		var sum = 0
		var i = 0
		# 对每个个体进行生存率累加，达到父辈的选择标准化，就认为可以进行交叉等
		while i < len(self.population) and sum < randomValue:
			sum += self.population[i].rating
			# 这里应该根据随机的结果，索引向后递增
			father += 1
			i += 1

		return father

	# 产生新种群，即下一代种群
	func createNewPopulation():
		var newPopulation = []
		
		if generation > 1:
			# 第二代开始，先对种群进行排序，再依次取出前几位的种群个体，
			# 因为产生了新种群后，会大于种群的数量（目前是初始化种群时固定的数值），
			# 那么末尾的个体就会被淘汰掉
			self.sortPopulation()
			var npopulation = []
			
			for i in range(self.populationLength):
				npopulation.append(self.population[i])
			
			self.population = npopulation
		# 设置当前最好的生存方案
		self.bestSolution = self.population[0]
		
		# 接下来进行下一代的生成
		for i in range(0, self.populationLength, 2):
			# 选取两个父辈
			var fatherOne = self.selectFather()
			var fatherTwo = self.selectFather()
			# 进行父辈交叉，并产生 2 个新的个体
			var children = self.population[fatherOne].crossover(self.population[fatherTwo])

			# 对新个体进行变异
			children[0].mutate(self.mutationRate)
			children[1].mutate(self.mutationRate)

			newPopulation.append(children[0])
			newPopulation.append(children[1])
		
		# 扩充种群
		self.population = newPopulation + self.population

@tool
extends TileMap

@export var genTerrain: bool
@export var clearTerrain: bool
@export var mapWidth: int = 86
@export var mapHeight: int = 50
# 生成地形随机数种子
@export var terrainSeed: int = 123456789

@export var waterThreshold: float = -0.4
@export var sandThreshold: float = -0.45
@export var soilThreshold: float = -0.5
@export var grassThreshold: float = -0.7


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if genTerrain:
		genTerrain = false
		GenerateTerrain()
	if clearTerrain:
		clearTerrain = false
		clear()

	
func GenerateTerrain():
	print("generating terrain...")
	
	# 快速噪声算法
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	# 生成随机数
	var rng = RandomNumberGenerator.new()
	
	if terrainSeed == 0:
		noise.seed = rng.randi()
	else:
		noise.seed = terrainSeed
	var noise_vals = []
	for x in range(mapWidth):
		for y in range(mapHeight):
			var val = noise.get_noise_2d(x, y)
			noise_vals.append(val)
			# 默认是岩石
			var atlas_coords = Vector2i(1, 0)
			# 顺序很重要，决定了先生成什么
			
			if val > waterThreshold: # 水是底层
				atlas_coords = Vector2i(0,0)
			elif val > sandThreshold: # 然后是沙子
				atlas_coords = Vector2i(0,1)
			elif val > soilThreshold: # 沙子上层是土壤
				atlas_coords = Vector2i(2,0)
			elif val > grassThreshold: # 土壤上层长草
				atlas_coords = Vector2i(3,0)
			
			
			
			set_cell(0, Vector2i(x, y), 0, atlas_coords)
	print(noise_vals.min(), ", ", noise_vals.max())

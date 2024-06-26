class_name NeuralNetwork

var Matrix = preload("./Matrix.gd")
var MatrixOperator = preload("./MatrixOperator.gd")

var input_nodes := 0
var hidden_nodes := 0
var output_nodes := 0
 
var weights_ih: Matrix # input -> hidden
var weights_ho: Matrix # hidden -> output
var bias_h: Matrix
var bias_o: Matrix

var learning_rate = 1
var mutation_rate = 0.1

#var active_func = sigmoid
#var d_active_func = dsigmoid

var active_func = reLU
var d_active_func = dreLU

const save_path = "user://brain_data.json"

# CONSTRUCTORS
func _init(a, b = 1, c = 1):
	randomize()
	
	if a is int:
		construct_from_sizes(a, b, c)
	else:
		construct_from_nn(a)

# save brain data to file
func save():
	var brain_data = JSON.stringify({
		"input_nodes": input_nodes,
		"hidden_nodes": hidden_nodes,
		"output_nodes": output_nodes,
		"weights_ih": weights_ih.save(),
		"weights_ho": weights_ho.save(),
		"bias_h": bias_h.save(),
		"bias_o": bias_o.save(),
	})
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(brain_data)
	print("brain data was saved")

# load brain data from file
func load():
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
		var brain_data = json.get_data()
		#print(brain_data)
		input_nodes = brain_data["input_nodes"]
		hidden_nodes = brain_data["hidden_nodes"]
		output_nodes = brain_data["output_nodes"]
		weights_ih = Matrix.new(hidden_nodes, input_nodes)
		weights_ih.load(brain_data["weights_ih"])
		weights_ho = Matrix.new(output_nodes, hidden_nodes)
		weights_ho.load(brain_data["weights_ho"])
		bias_h = Matrix.new(hidden_nodes, 1)
		bias_o = Matrix.new(output_nodes, 1)
		bias_h.load(brain_data["bias_h"])
		bias_o.load(brain_data["bias_o"])
		print("loaded brain data from file")
		

func construct_from_sizes(a, b, c):
	input_nodes = a
	hidden_nodes = b
	output_nodes = c
	
	weights_ih = Matrix.new(hidden_nodes, input_nodes)
	weights_ho = Matrix.new(output_nodes, hidden_nodes)
	weights_ih.randomize()
	weights_ho.randomize()
	
	bias_h = Matrix.new(hidden_nodes, 1)
	bias_o = Matrix.new(output_nodes, 1)
	bias_h.randomize()
	bias_o.randomize()

func construct_from_nn(a):
	input_nodes = a.input_nodes
	hidden_nodes = a.hidden_nodes
	output_nodes = a.output_nodes
	
	weights_ih = a.weights_ih.duplicate()
	weights_ho = a.weights_ho.duplicate()
	
	bias_h = a.bias_h.duplicate()
	bias_o = a.bias_o.duplicate()

func predict(input_array: Array) -> Array:
	var inputs = Matrix.new(input_array)
	
	var hidden = MatrixOperator.multiply(weights_ih, inputs)
	hidden.add(bias_h)
	#hidden.map(sigmoid)
	hidden.map(active_func)
	
	var outputs = MatrixOperator.multiply(weights_ho, hidden)
	outputs.add(bias_o)
	#outputs.map(sigmoid)
	outputs.map(active_func)
	
	return outputs.to_array()

func train(input_array, target_array):
	var inputs = Matrix.new(input_array)
	
	var hidden = MatrixOperator.multiply(weights_ih, inputs)
	hidden.add(bias_h)
	hidden.map(active_func)
	
	var outputs = MatrixOperator.multiply(weights_ho, hidden)
	outputs.add(bias_o)
	outputs.map(active_func)
	
	var targets = Matrix.new(target_array)
	
	var output_errors = MatrixOperator.subtract(targets, outputs)
	
	var gradients = MatrixOperator.map(outputs, d_active_func)
	gradients.multiply(output_errors)
	gradients.multiply(learning_rate)
	
	var hidden_T = MatrixOperator.transpose(hidden)
	var weight_ho_deltas = MatrixOperator.multiply(gradients, hidden_T)
	
	weights_ho.add(weight_ho_deltas)
	bias_o.add(gradients)
	
	var who_t = MatrixOperator.transpose(weights_ho)
	var hidden_errors = MatrixOperator.multiply(who_t, output_errors)
	
	var hidden_gradients = MatrixOperator.map(hidden, d_active_func)
	hidden_gradients.multiply(hidden_errors)
	hidden_gradients.multiply(learning_rate)
	
	var inputs_T = MatrixOperator.transpose(inputs)
	var weight_ih_deltas = MatrixOperator.multiply(hidden_gradients, inputs_T)
	
	weights_ih.add(weight_ih_deltas)
	bias_h.add(hidden_gradients)

func mutate():
	weights_ih.map(mutation_func)
	weights_ho.map(mutation_func)
	bias_h.map(mutation_func)
	bias_o.map(mutation_func)

func duplicate():
	return get_script().new(self)

func mutation_func(val):
	if randf() < mutation_rate:
		return val + randf_range(-0.1, 0.1)
	else:
		return val

func sigmoid(x):
	return 1 / (1 + exp(-x))

func dsigmoid(y):
	return y * (1 - y)


func reLU(x):
	if(x < 0):
		return 0
	else:
		return x

func dreLU(y):
	if(y < 0):
		return 0
	else:
		return 1

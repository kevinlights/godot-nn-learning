extends Control

var NN = preload("res://lib/Neural Network/Brain.gd")

@onready var guess_color_c = $GuessColor
@onready var guess = $Guess
@onready var r_txt = $R
@onready var g_txt = $G
@onready var b_txt = $B

var r: float
var g: float
var b: float

var brain

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	brain = NN.new(3, 10, 2)
	
	#for i in range(1000):
		#pick_color()
		#train_color()
	
	#reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		pick_color()
		change_background()


func train_color():
	if (r + g + b > 1.5):
		brain.train([r, g, b], [0, 1])
	else:
		brain.train([r, g, b], [1, 0])
		
func pick_color():
	r = randf()
	g = randf()
	b = randf()
	
	show_color()

func show_color():
	r_txt.text = "R: " + str(r)
	g_txt.text = "G: " + str(b)
	b_txt.text = "B: " + str(r)
	
func change_background():
	guess_color_c.color = Color(r, g, b)
	
func guess_color():
	var guesses = brain.predict([r, g, b])
	print(guesses)
	if guesses[0] > guesses[1]:
		guess.text = "guess it is white"
	else:
		guess.text = "guess it is black"
		
		
func reset(): 
	pick_color()
	change_background()
	guess_color()
	

func _on_left_button_pressed():
	brain.train([r, g, b], [1, 0])
	reset()


func _on_right_button_pressed():
	brain.train([r, g, b], [0, 1])
	reset()


func _on_save_button_pressed():
	brain.save()


func _on_load_button_pressed():
	brain.load()
	reset()


func _on_init_train_button_pressed():
	for i in range(1000):
		pick_color()
		train_color()
	reset()

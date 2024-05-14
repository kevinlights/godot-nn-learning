extends Area2D

class_name Player

var racket

# Called when the node enters the scene tree for the first time.
func _ready():
	racket = Racket.new(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(ball: Ball):
	racket.hit(ball)

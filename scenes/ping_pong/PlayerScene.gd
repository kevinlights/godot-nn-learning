extends Area2D

# this scene node is just for training
# 仅用于训练，后续可用 Player 来接球

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(ball: Ball):
	ball.horizontal = -(ball.horizontal)
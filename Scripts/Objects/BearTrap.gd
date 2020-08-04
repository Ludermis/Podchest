extends Node2D

var endPosition
var whoSummoned
var id

var animationPlayed = false setget setAnimationPlayed

func setAnimationPlayed (v):
	if v == true && !animationPlayed:
		$AnimatedSprite.play("default")
	animationPlayed = v

func tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func _ready():
	connect("tree_exited", self, "tree_exited")
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	pass

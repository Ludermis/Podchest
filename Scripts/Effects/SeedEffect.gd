extends Node2D

var drawArea = false
var areaOfEffect : int = 1

func _ready():
	pass

func _draw():
	if drawArea:
		var color = Vars.teams[Vars.myTeam]["color"].blend(Color(1,1,1,0.5))
		color.a = 0.5
		draw_set_transform(to_local(Vars.optimizeVector(position - Vector2(32,32),64)) + Vector2(32 / scale.x,32 / scale.y),0,Vector2(1.0 / scale.x, 1.0 / scale.y))
		for x in range(1,areaOfEffect / 2 + 2):
			for y in range (-areaOfEffect / 2 + (x - 1),areaOfEffect / 2 + 1 - (x - 1)):
				draw_rect(Rect2(y * 64, (x - 1) * 64,64,64),color)
		for x in range(1,areaOfEffect / 2 + 1):
			for y in range (-areaOfEffect / 2 + x,areaOfEffect / 2 + 1 - x):
				draw_rect(Rect2(y * 64, -x * 64, 64, 64),color)
		#draw_rect(Rect2(0,0,64,64),Color.blue)

func _process (delta):
	update()

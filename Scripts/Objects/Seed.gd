extends Sprite

var whoSummoned
var id
var materialScale setget setMaterialScale

func setMaterialScale (ms):
	materialScale = ms
	$Particles2D.process_material.scale = materialScale

func tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func _ready():
	connect("tree_exited", self, "tree_exited")
	if Vars.myTeam != Vars.objects[whoSummoned]["team"]:
		modulate = Vars.teams[Vars.objects[whoSummoned]["team"]]["color"].blend(Color(1,1,1,0.3))

func _process(delta):
	pass

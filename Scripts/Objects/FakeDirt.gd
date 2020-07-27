extends Sprite

var maxSize
var realColor
var whoSummoned
var id

func _ready():
	maxSize = scale.x
	scale.x = 0.4
	scale.y = 0.4
	if !Vars.objects.has(whoSummoned):
		get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
		queue_free()
		return
	Vars.objects[whoSummoned]["fakeDirts"][position] = id
	get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,whoSummoned,{"fakeDirts": Vars.objects[whoSummoned].fakeDirts})
	connect("tree_exited", self, "tree_exited")

func tree_exited():
	if Vars.objects.has(whoSummoned):
		if Vars.objects[whoSummoned]["fakeDirts"].has(position):
			Vars.objects[whoSummoned]["fakeDirts"].erase(position)
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func _process(delta):
	if modulate == realColor && scale.x == maxSize && scale.y == maxSize:
		set_process(false)
	if modulate != realColor:
		if !Vars.objects.has(whoSummoned):
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()
			return
		modulate.r = lerp(modulate.r,realColor.r,delta * 2)
		modulate.g = lerp(modulate.g,realColor.g,delta * 2)
		modulate.b = lerp(modulate.b,realColor.b,delta * 2)
		if abs((modulate.r - realColor.r)) + abs((modulate.g - realColor.g)) + abs((modulate.b - realColor.b)) < 0.01:
			modulate = realColor
	if scale.x == maxSize:
		return
	scale.x = min(scale.x + delta * 2, maxSize)
	scale.y = min(scale.y + delta * 2, maxSize)

extends "res://Scripts/Base/Impact.gd"

var ownerNode
var timeRemaining
var impactName = "RootImpact"
var animStart
var animEnd

func _init():
	type = "constant"

func getSharedData ():
	var data = {}
	data["timeRemaining"] = timeRemaining
	return data

func begin():
	if Client.selfPeerID == Vars.roomMaster:
		Vars.objects[ownerNode].canMove = false
		var dict = {"canMove": false}
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,ownerNode,{"canMove": false})
		if animStart != null:
			Vars.objects[ownerNode].animation = animStart
			dict["animation"] = animStart
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,ownerNode,dict)

func update(delta):
	if Client.selfPeerID == Vars.roomMaster:
		Vars.objects[ownerNode].canMove = false
		var dict = {"canMove": false}
		timeRemaining -= delta
		if animEnd != null && timeRemaining <= 0.1:
			Vars.objects[ownerNode].animation = animEnd
			dict["animation"] = animEnd
		if timeRemaining <= 0:
			end()
			return
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,ownerNode,dict)
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,ownerNode,"updateImpactInfo",[id,getSharedData()])

func end():
	if Client.selfPeerID == Vars.roomMaster:
		Vars.objects[ownerNode].canMove = true
		Vars.objects[ownerNode].impacts.erase(id)
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,ownerNode,{"canMove": true})
		Vars.objects[ownerNode].get_tree().root.get_node("Main").rpc_id(1,"objectCalled",Client.selfPeerID,ownerNode,"removeImpact",[id])

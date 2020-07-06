extends "res://Scripts/Base/Character.gd"

func _init():
	characterName = "Xedarin"

func _physics_process(delta):
	animationHandler()
	if id == Client.selfPeerID:
		inputHandler()
		movementHandler()
		skillSystem()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)

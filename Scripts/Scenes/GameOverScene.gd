extends Node2D


func _ready():
	rpc_id(1,"leaveRoom",Client.selfPeerID)
	if Vars.endGameStats["winner"] == Vars.myTeam:
		$"Title".text = "VICTORY"
		$"Title".modulate = Color.lime
	elif Vars.endGameStats["winner"] != -1:
		$"Title".text = "DEFEAT"
		$"Title".modulate = Color.red
	else:
		$"Title".text = "DRAW"
		$"Title".modulate = Color.blue
	$Score1.modulate = Vars.teams[1]["color"]
	$Score1.text = str(Vars.endGameStats["scores"][1])
	$Score2.modulate = Vars.teams[2]["color"]
	$Score2.text = str(Vars.endGameStats["scores"][2])
	$Team1Players.text = ""
	$Team2Players.text = ""
	$Team1PlayerScores.text = ""
	$Team2PlayerScores.text = ""
	for i in Vars.endGameStats["playerInfos"][1]:
		var pName = Vars.endGameStats["playerInfos"][1][i]["name"]
		$Team1Players.text = $Team1Players.text + str(pName) + "\n"
		$Team1PlayerScores.text = $Team1PlayerScores.text + str(Vars.endGameStats["playerInfos"][1][i]["dirtCreatedScore"] + Vars.endGameStats["playerInfos"][1][i]["dirtChangedScore"]) + "\n"
	for i in Vars.endGameStats["playerInfos"][2]:
		var pName = Vars.endGameStats["playerInfos"][2][i]["name"]
		$Team2Players.text = $Team2Players.text + str(pName) + "\n"
		$Team2PlayerScores.text = $Team2PlayerScores.text + str(Vars.endGameStats["playerInfos"][2][i]["dirtCreatedScore"] + Vars.endGameStats["playerInfos"][2][i]["dirtChangedScore"]) + "\n"
	$PlayerRect.texture = load("res://Sprites/UI/Characters/" + str(Vars.endGameStats["yourCharacter"]) + ".png")
	if Vars.endGameStats["goldEarned"] == -1:
		$CoinLabel.text = "You did not play."
	elif Vars.endGameStats["goldEarned"] == 0:
		$CoinLabel.text = "Login to earn gold."
	else:
		$CoinLabel.text = "+" + str(Vars.endGameStats["goldEarned"])
	
	Vars.clearVars()

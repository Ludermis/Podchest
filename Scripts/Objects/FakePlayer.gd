extends KinematicBody2D


var velocity = Vector2.ZERO
var acceleration = 64
var maxSpeed = 384
var id
var canMove = true
var animation = "idle" setget setAnimation
var desiredDirection = "down" setget setDesiredDirection
var direction = "down"
var playerName = "Guest" setget setPlayerName
var skin = "" setget setSkin
var directionsInt = {1: "down", 2: "downRight", 3: "right", 4: "upRight", 5: "up", 6: "upLeft", 7: "left", 8: "downLeft"}
var directionsString = {"down": 1,"downRight": 2,"right": 3,"upRight": 4,"up": 5,"upLeft": 6,"left": 7,"downLeft": 8}
var disguised setget setDisguised
var whoSummoned
var pressed = {"right": false, "left": false, "up": false, "down": false}

func setSkin (newSkin):
	skin = newSkin
	if skin != "":
		var atlas = load("res://Sprites/Characters/" + skin.to_lower() + ".png")
		$Skin/Body.texture.atlas = atlas
		$Skin/Head.texture.atlas = atlas
		$Skin/Leg1.texture.atlas = atlas
		$Skin/Leg2.texture.atlas = atlas
		$Skin/Hand1.texture.atlas = atlas
		$Skin/Hand2.texture.atlas = atlas

func setDesiredDirection (dir):
	desiredDirection = dir

func setPlayerName (pName):
	playerName = pName
	$NameLabel.text = playerName

func setAnimation (anim):
	animation = anim

func animationHandler ():
	if animation == "idle":
		$Skin/AnimationPlayer.play(direction + "Idle")
	elif animation == "walk":
		$Skin/AnimationPlayer.play(direction + "Walk")
	elif animation == "cast":
		$Skin/AnimationPlayer.play("cast")

func findNextDirection ():
	if desiredDirection == direction:
		return
	var dir = 1
	if directionsString[direction] < directionsString[desiredDirection]:
		dir = 1
		if abs(directionsString[direction] - directionsString[desiredDirection]) > 4:
			dir = -1
	else:
		dir = -1
		if abs(directionsString[direction] - directionsString[desiredDirection]) > 4:
			dir = 1
	var next = directionsString[direction] + dir
	if next == 9:
		next = 1
	elif next == 0:
		next = 8
	direction = directionsInt[next]

func setDisguised (who):
	disguised = who
	$NameLabel.text = Vars.objects[disguised].playerName
	$NameLabel.modulate = Vars.teams[Vars.objects[disguised]["team"]]["color"].blend(Color(1,1,1,0.5))
	add_child(load("res://Prefabs/Skins/" + Vars.objects[disguised]["characterName"] + ".tscn").instance())

func _on_DirectionTimer_timeout():
	if animation == "walk" || animation == "idle":
		findNextDirection()

func tree_exited():
	if Vars.objects.has(id):
		Vars.objects.erase(id)

func inputHandler():
	if canMove:
		if pressed["down"] && !pressed["right"] && !pressed["left"]:
			animation = "walk"
			desiredDirection = "down"
		elif pressed["up"] && !pressed["right"] && !pressed["left"]:
			animation = "walk"
			desiredDirection = "up"
		elif pressed["right"] && !pressed["up"] && !pressed["down"]:
			animation = "walk"
			desiredDirection = "right"
		elif pressed["left"] && !pressed["up"] && !pressed["down"]:
			animation = "walk"
			desiredDirection = "left"
		elif pressed["right"] && pressed["up"]:
			animation = "walk"
			desiredDirection = "upRight"
		elif pressed["left"] && pressed["up"]:
			animation = "walk"
			desiredDirection = "upLeft"
		elif pressed["right"] && pressed["down"]:
			animation = "walk"
			desiredDirection = "downRight"
		elif pressed["left"] && pressed["down"]:
			animation = "walk"
			desiredDirection = "downLeft"
		else:
			animation = "idle"

func _init():
	disguised = id

func movementHandler ():
	if canMove:
		if pressed["right"]:
			velocity.x = min(velocity.x + acceleration, maxSpeed)
		elif pressed["left"]:
			velocity.x = max(velocity.x - acceleration, -maxSpeed)
		else:
			velocity.x = lerp(velocity.x,0,Vars.friction)
		if pressed["down"]:
			velocity.y = min(velocity.y + acceleration, maxSpeed)
		elif pressed["up"]:
			velocity.y = max(velocity.y - acceleration, -maxSpeed)
		else:
			velocity.y = lerp(velocity.y,0,Vars.friction)
	else:
		velocity.y = lerp(velocity.y,0,Vars.friction)
		velocity.x = lerp(velocity.x,0,Vars.friction)
	velocity = move_and_slide(velocity,Vector2.UP)
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			pressed["left"] = !pressed["left"]
			pressed["right"] = !pressed["right"]
			pressed["up"] = !pressed["up"]
			pressed["down"] = !pressed["down"]

func _on_DirtTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		if !Vars.objects.has(whoSummoned):
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()
			return
		var vec = Vars.optimizeVector(position + Vector2(32,32),64)
		if !Vars.objects[whoSummoned].fakeDirts.has(vec) && (!Vars.dirts.has(vec) || Vars.dirts[vec]["team"] == Vars.objects[whoSummoned].team):
			Vars.objects[whoSummoned].fakeDirts[vec] = -1
			get_tree().root.get_node("Main").rpc_id(1,"objectCreated",Client.selfPeerID,"res://Prefabs/Objects/FakeDirt.tscn",{"whoSummoned": whoSummoned, "position": vec, "realColor": Vars.teams[Vars.objects[disguised]["team"]]["color"]})

func _ready():
	connect("tree_exited", self, "tree_exited")
	var rnd = randi() % 2
	if rnd == 1:
		pressed["right"] = true
	else:
		pressed["left"] = true
	rnd = randi() % 3
	if rnd == 1:
		pressed["up"] = true
	elif rnd == 2:
		pressed["down"] = true
	
	set_physics_process(true)
	$DirtTimer.start()

func _physics_process(delta):
	animationHandler()
	if Client.selfPeerID == Vars.roomMaster:
		if !Vars.objects.has(whoSummoned):
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()
			return
		if Vars.objects[whoSummoned]["disguised"] == whoSummoned:
			get_tree().root.get_node("Main").rpc_id(1,"objectRemoved",Client.selfPeerID,id)
			queue_free()
			return
		inputHandler()
		movementHandler()
		var sendingDict = {"position": position, "animation": animation, "desiredDirection": desiredDirection, "pressed": pressed}
		get_tree().root.get_node("Main").rpc_id(1,"objectUpdated",Client.selfPeerID,id,sendingDict)


func _on_ChangeDirectionTimer_timeout():
	if Client.selfPeerID == Vars.roomMaster:
		pressed = {"right": false, "left": false, "up": false, "down": false}
		var rnd = randi() % 2
		if rnd == 1:
			pressed["right"] = true
		else:
			pressed["left"] = true
		rnd = randi() % 3
		if rnd == 1:
			pressed["up"] = true
		elif rnd == 2:
			pressed["down"] = true

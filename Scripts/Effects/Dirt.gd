extends AnimatedSprite

var id : int
var maxSize
var realColor

func _ready():
	maxSize = scale.x
	scale.x = 0
	scale.y = 0

func _process(delta):
	if modulate != realColor:
		modulate.r = lerp(modulate.r,realColor.r,delta * 4)
		modulate.g = lerp(modulate.g,realColor.g,delta * 4)
		modulate.b = lerp(modulate.b,realColor.b,delta * 4)
	if scale.x == maxSize:
		return
	scale.x = min(scale.x + delta / 2, maxSize)
	scale.y = min(scale.y + delta / 2, maxSize)

extends Sprite

var maxSize
var realColor

func _ready():
	maxSize = scale.x
	scale.x = 0.4
	scale.y = 0.4

func _process(delta):
	if modulate == realColor && scale.x == maxSize && scale.y == maxSize:
		set_process(false)
	if modulate != realColor:
		modulate.r = lerp(modulate.r,realColor.r,delta * 4)
		modulate.g = lerp(modulate.g,realColor.g,delta * 4)
		modulate.b = lerp(modulate.b,realColor.b,delta * 4)
		if abs((modulate.r - realColor.r) + (modulate.g - realColor.g) + (modulate.b - realColor.b)) < 0.1:
			modulate = realColor
	if scale.x == maxSize:
		return
	scale.x = min(scale.x + delta * 2, maxSize)
	scale.y = min(scale.y + delta * 2, maxSize)

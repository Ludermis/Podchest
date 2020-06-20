extends Camera2D

var zoomLevel = 5

func _ready():
	zoom.x = zoomLevel * (2.0 / 5.0)
	zoom.y = zoomLevel * (2.0 / 5.0)

func _process (delta):
	if zoom.x != zoomLevel * (2.0 / 5.0) || zoom.y != zoomLevel * (2.0 / 5.0):
		zoom.x = lerp(zoom.x, zoomLevel * (2.0 / 5.0), delta * 3)
		zoom.y = lerp(zoom.y, zoomLevel * (2.0 / 5.0), delta * 3)
		if abs(zoom.x - zoomLevel * (2.0 / 5.0)) + abs(zoom.y - zoomLevel * (2.0 / 5.0)) < 0.01:
			zoom.x = zoomLevel * (2.0 / 5.0)
			zoom.y = zoomLevel * (2.0 / 5.0)

extends StaticBody

export var paused = true
func _ready():
	GLOBAL.towers.append(self)

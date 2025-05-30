extends PointLight2D

var difficulty: String # "easy", "medium", "hard"

var max_range := {
	"easy": 1.7,
	"medium": 1.2,
	"hard": 0.7
}

func _ready():
	Global.get_difficulty(self)
	self.set_scale(Vector2(max_range.get(difficulty, 0),max_range.get(difficulty, 0)))

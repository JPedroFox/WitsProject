extends AudioStreamPlayer

@export var fade_time := 3.0 # segundos para fade-in e fade-out

var is_fading_in := false
var is_fading_out := false
var fade_timer := 0.0
func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.volume_db = -80.0

func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0  # Silêncio total
	return 20.0 * log(value) / log(10.0)

func _physics_process(delta):
	if is_fading_in:
		fade_timer += delta
		var t = clamp(fade_timer / fade_time, 0, 1)
		self.volume_db = lerp(-80.0, linear_to_db(Settings.music_volume/100)-10, t)
		if t >= 1.0:
			is_fading_in = false

	elif is_fading_out:
		fade_timer += delta
		var t = clamp(fade_timer / fade_time, 0, 1)
		self.volume_db = lerp(linear_to_db(Settings.music_volume/100)-10, -80.0, t)
		if t >= 1.0:
			is_fading_out = false
			self.stop()

func play_music():
	if not self.playing:
		self.play()
	self.volume_db = -80
	fade_timer = 0.0
	is_fading_in = true
	is_fading_out = false

func stop_music():
	if self.playing:
		fade_timer = 0.0
		is_fading_out = true
		is_fading_in = false

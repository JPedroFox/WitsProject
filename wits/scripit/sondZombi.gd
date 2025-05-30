extends AudioStreamPlayer2D

# Referência ao AudioStreamPlayer2D
@onready var audio_player = self
# Temporizador para controlar os intervalos de reprodução
var timer = Timer.new()

func _ready():
	# Adiciona o temporizador como filho do nó atual
	add_child(timer)
	# Conecta o sinal "timeout" do temporizador à função _on_timer_timeout
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# Inicia o temporizador com um intervalo aleatório
	start_random_timer()

func start_random_timer():
	# Define o tempo de espera do temporizador para um valor aleatório entre 1 e 5 segundos
	timer.wait_time = randf_range(1.0, 5.0)
	# Inicia o temporizador
	timer.start()

func _on_timer_timeout():
	# Reproduz o áudio
	audio_player.play()
	# Reinicia o temporizador com um novo intervalo aleatório
	start_random_timer()

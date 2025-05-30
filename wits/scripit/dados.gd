extends Control

@onready var StatEntryScene = preload("res://cenas/StatEntry.tscn")
@onready var lista_completo = $Tabs/Completed/ScrollContainer/CompletedList
@onready var lista_morto = $Tabs/Dead/ScrollContainer/DeadList

func _ready():
	carregar_estatisticas_criptografadas()

func carregar_estatisticas_criptografadas():
	# Remove todos os filhos de lista_completo
	for child in lista_completo.get_children():
		child.queue_free()

	# Remove todos os filhos de lista_morto
	for child in lista_morto.get_children():
		child.queue_free()

	var lista_completed = DadosCripto.carregar_estatisticas("completed")
	var lista_dead = DadosCripto.carregar_estatisticas("dead")

	var colocacao = 1
	for entrada in lista_completed:
		var e = StatEntryScene.instantiate()
		e.get_node("Colocacao").text = str(colocacao) + "."
		e.get_node("Nome").text = entrada["nome"]
		e.get_node("Tempo").text = str(time_form(entrada["tempo"]))
		e.get_node("Zumbis").text = str(int(entrada["zumbis"]))
		e.get_node("dificuldade").text = str(entrada["dificuldade"])
		lista_completo.add_child(e)
		colocacao += 1

	colocacao = 1
	for entrada in lista_dead:
		var e = StatEntryScene.instantiate()
		e.get_node("Colocacao").text = str(colocacao) + "° "
		e.get_node("Nome").text = entrada["nome"]
		e.get_node("Tempo").text = str(time_form(entrada["tempo"]))
		e.get_node("Zumbis").text = str(int(entrada["zumbis"]))
		e.get_node("dificuldade").text = str(entrada["dificuldade"])
		lista_morto.add_child(e)
		colocacao += 1

func time_form(total_milliseconds: int):
	@warning_ignore("integer_division")
	var minutes = total_milliseconds / 60000
	@warning_ignore("integer_division")
	var seconds = (total_milliseconds / 1000) % 60
	var milliseconds = total_milliseconds % 1000
	return "%02d:%02d:%03d" % [int(minutes), int(seconds), int(milliseconds)]

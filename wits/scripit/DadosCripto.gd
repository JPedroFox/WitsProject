extends Node

const PATHS = {
	"completed": "user://completed.save",
	"dead": "user://dead.save"
}

const SENHA = "WitsFoxGames"  # mantenha isso seguro e consistente

const DIFICULDADE_PESO = {
	"hard": 3,
	"medium": 2,
	"easy": 1
}

func calcular_media(tempo: float, zumbis: int) -> float:
	return pow(zumbis, 1.5) / pow(tempo, 0.5)

func salvar_estatistica(tipo: String, nome: String, tempo: float, zumbis: int, dificuldade: String):
	if not PATHS.has(tipo):
		push_error("Tipo inválido: " + tipo)
		return

	var caminho = PATHS[tipo]
	var dados = {"jogadas": []}

	# Carrega dados anteriores
	if FileAccess.file_exists(caminho):
		var arquivo = FileAccess.open_encrypted_with_pass(caminho, FileAccess.READ, SENHA)
		if arquivo == null:
			push_error("Erro ao abrir o arquivo criptografado.")
			return

		var texto = arquivo.get_as_text()
		arquivo.close()

		var dados_carregados = JSON.parse_string(texto)
		if typeof(dados_carregados) == TYPE_DICTIONARY and dados_carregados.has("jogadas"):
			dados = dados_carregados
		else:
			print("⚠️ Erro ao carregar dados anteriores ou estrutura inválida.")

	# Cria nova entrada
	var entrada = {
		"nome": nome,
		"tempo": tempo,
		"zumbis": zumbis,
		"dificuldade": dificuldade,
		"media": calcular_media(tempo, zumbis)
	}

	# Verifica duplicatas
	for existente in dados["jogadas"]:
		if existente == entrada:
			print("⚠️ Entrada duplicada detectada. Não será adicionada novamente.")
			return

	# Adiciona nova entrada
	dados["jogadas"].append(entrada)

	# Limita a 100
	if dados["jogadas"].size() > 100:
		dados["jogadas"] = dados["jogadas"].slice(-100, 100)

	# ORDENAÇÃO PERSONALIZADA POR DIFICULDADE E MÉDIA
	var ordem_dificuldade = ["hard", "medium", "easy"]
	dados["jogadas"].sort_custom(func(a, b):
		var d1 = a.get("dificuldade", "easy")
		var d2 = b.get("dificuldade", "easy")

		var p1 = ordem_dificuldade.find(d1)
		var p2 = ordem_dificuldade.find(d2)

		if p1 == p2:
			# Se for mesma dificuldade, ordenar por média descrescente
			return b["media"] < a["media"]
		else:
			# Ordenar pela posição da dificuldade
			return p1 < p2
	)

	# Salva com criptografia por senha
	var json_text = JSON.stringify(dados)
	var file = FileAccess.open_encrypted_with_pass(caminho, FileAccess.WRITE, SENHA)
	if file == null:
		push_error("Erro ao abrir o arquivo criptografado para escrita.")
		return
	file.store_string(json_text)
	file.close()

func carregar_estatisticas(tipo: String) -> Array:
	if not PATHS.has(tipo):
		push_error("Tipo inválido: " + tipo)
		return []

	var caminho = PATHS[tipo]
	if not FileAccess.file_exists(caminho):
		return []

	var file = FileAccess.open_encrypted_with_pass(caminho, FileAccess.READ, SENHA)
	if file == null:
		push_error("Erro ao abrir o arquivo criptografado.")
		return []

	var texto = file.get_as_text()
	file.close()

	var dados = JSON.parse_string(texto)
	if typeof(dados) != TYPE_DICTIONARY or not dados.has("jogadas"):
		return []

	var lista = dados["jogadas"]
	lista.sort_custom(func(a, b):
		var peso_a = DIFICULDADE_PESO.get(a.get("dificuldade", "easy"), 0)
		var peso_b = DIFICULDADE_PESO.get(b.get("dificuldade", "easy"), 0)

		if peso_a == peso_b:
			return b["media"] < a["media"]  # Ordena por média desc.
		else:
			return peso_b < peso_a  # Ordena por dificuldade desc.
	)
	return lista

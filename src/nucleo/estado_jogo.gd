class_name EstadoJogo
extends RefCounted

enum Situacao { JOGANDO, VITORIA, DERROTA }

signal creditos_alterados(valor: int)
signal poluicao_alterada(valor: float)
signal rodada_alterada(valor: int)
signal arvore_selecionada_alterada(arvore: DadosArvore)
signal situacao_alterada(situacao: Situacao)

var creditos: int = 0:
	set(valor):
		if creditos == valor:
			return
		creditos = valor
		creditos_alterados.emit(creditos)

var poluicao: float = 0.0:
	set(valor):
		if is_equal_approx(poluicao, valor):
			return
		poluicao = valor
		poluicao_alterada.emit(poluicao)

var rodada: int = 1:
	set(valor):
		if rodada == valor:
			return
		rodada = valor
		rodada_alterada.emit(rodada)

var arvore_selecionada: DadosArvore = null:
	set(valor):
		if arvore_selecionada == valor:
			return
		arvore_selecionada = valor
		arvore_selecionada_alterada.emit(arvore_selecionada)

var situacao: Situacao = Situacao.JOGANDO:
	set(valor):
		if situacao == valor:
			return
		situacao = valor
		situacao_alterada.emit(situacao)


func reiniciar(config: ConfigJogo) -> void:
	creditos = config.creditos_iniciais
	poluicao = config.poluicao_inicial
	rodada = 1
	arvore_selecionada = null
	situacao = Situacao.JOGANDO

class_name ArvorePlantada
extends RefCounted

signal vida_alterada(atual: float, maxima: float)

var dados: DadosArvore
var vida: float


func _init(dados_arvore: DadosArvore) -> void:
	dados = dados_arvore
	vida = dados.vida_maxima


func receber_dano(quantidade: float) -> void:
	vida = clampf(vida - quantidade, 0.0, dados.vida_maxima)
	vida_alterada.emit(vida, dados.vida_maxima)


func esta_morta() -> bool:
	return vida <= 0.0

class_name SistemaPoluicao
extends RefCounted

var _config: ConfigJogo


func _init(config: ConfigJogo) -> void:
	_config = config


func resolver_rodada(
	poluicao_atual: float,
	numero_rodada: int,
	arvores: Array[ArvorePlantada]
) -> ResultadoRodada:
	assert(false, "SistemaPoluicao.resolver_rodada ainda nao foi implementado.")
	return null

class_name GerenciadorJogo
extends Node

signal plantio_falhou(motivo: String)
signal rodada_resolvida(resultado: ResultadoRodada)
signal jogo_finalizado(vitoria: bool, rodada_final: int)

var estado: EstadoJogo

var _config: ConfigJogo
var _tabuleiro: Tabuleiro
var _catalogo: CatalogoArvores
var _sistema_poluicao: SistemaPoluicao


func configurar(config: ConfigJogo, tabuleiro: Tabuleiro, catalogo: CatalogoArvores) -> void:
	_config = config
	_tabuleiro = tabuleiro
	_catalogo = catalogo
	_sistema_poluicao = SistemaPoluicao.new(config)
	estado = EstadoJogo.new()
	estado.reiniciar(config)


func selecionar_arvore(dados: DadosArvore) -> void:
	estado.arvore_selecionada = dados


func tentar_plantar(indice_celula: int) -> bool:
	assert(false, "GerenciadorJogo.tentar_plantar ainda nao foi implementado.")
	return false


func avancar_rodada() -> void:
	assert(false, "GerenciadorJogo.avancar_rodada ainda nao foi implementado.")


func reiniciar() -> void:
	if _tabuleiro != null:
		_tabuleiro.limpar()
	if estado != null:
		estado.reiniciar(_config)

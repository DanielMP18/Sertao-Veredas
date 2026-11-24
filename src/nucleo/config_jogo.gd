class_name ConfigJogo
extends Resource

@export_group("Início")
@export var creditos_iniciais: int = 30
@export var poluicao_inicial: float = 150.0

@export_group("Poluição")
@export var poluicao_base_por_rodada: float = 10.0
@export var crescimento_poluicao_por_rodada: float = 1.0
@export var limite_vitoria_poluicao: float = 0.0

@export_group("Dano")
@export var dano_por_poluicao: float = 0.06

@export_group("Economia")
@export var creditos_por_rodada: int = 5
@export var creditos_por_poluicao_removida: float = 0.2

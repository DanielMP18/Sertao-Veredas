class_name Celula
extends Button

signal clicada(indice: int)

var indice: int = -1
var _arvore: ArvorePlantada


func _ready() -> void:
	pressed.connect(_ao_pressionar)


func configurar(indice_celula: int) -> void:
	indice = indice_celula


func definir_arvore(arvore: ArvorePlantada) -> void:
	_arvore = arvore


func remover_arvore() -> void:
	_arvore = null


func _ao_pressionar() -> void:
	clicada.emit(indice)

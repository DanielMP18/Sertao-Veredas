class_name ItemLoja
extends Button

signal escolhido(dados: DadosArvore)

var _dados: DadosArvore


func _ready() -> void:
	pressed.connect(_ao_pressionar)


func configurar(dados: DadosArvore) -> void:
	_dados = dados


func definir_disponivel(valor: bool) -> void:
	disabled = not valor


func definir_destaque(valor: bool) -> void:
	button_pressed = valor


func _ao_pressionar() -> void:
	escolhido.emit(_dados)

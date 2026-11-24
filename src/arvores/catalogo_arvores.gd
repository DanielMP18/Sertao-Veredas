class_name CatalogoArvores
extends Resource

@export var arvores: Array[DadosArvore] = []


func obter_por_id(id_arvore: StringName) -> DadosArvore:
	for arvore in arvores:
		if arvore != null and arvore.id == id_arvore:
			return arvore
	return null


func obter_menor_custo() -> int:
	var encontrou_arvore := false
	var menor_custo := 0

	for arvore in arvores:
		if arvore == null:
			continue
		if not encontrou_arvore or arvore.custo < menor_custo:
			menor_custo = arvore.custo
			encontrou_arvore = true

	assert(encontrou_arvore, "CatalogoArvores precisa conter ao menos uma arvore.")
	return menor_custo

# Sertão Veredas — Tarefas do MVP por integrante

Leia a seção 1 a 4 (todos) e depois a sua seção (5 a 8).

## 1. Regras gerais

- GDScript com **tipagem estática** (`var x: int`, `-> void`), indentação com **tab**.
- Nomes de arquivo em `snake_case`; `class_name` em `PascalCase`.
- **Todos os identificadores em português, sem acentos**: classes, variáveis, métodos, sinais, arquivos e pastas (ex.: `creditos`, `plantar_arvore`, `ArvorePlantada`). Só ficam em inglês os nomes do próprio Godot (`_ready`, `_init`, `extends`, `Control`, `Button`, `pressed`...).
- Nenhum número de balanceamento fixo no código: tudo vem de `ConfigJogo` ou `DadosArvore`.
- Todo texto visível ao jogador em **português**.
- Sem assets externos. Visual provisório com `ColorRect`, `StyleBox`, `Label` e `Button`.
- Cada pessoa mexe **só na sua pasta** (seção 3). Precisa de mudança na pasta de outra pessoa? Peça a ela.
- Commits e branches seguem o `CONTRIBUTING.md`. Commitar sempre os arquivos `.uid`.
- Nada de lógica de jogo em cenas de UI, e nada de UI em `core/`.
- Regra de comunicação: **chamar métodos para baixo, emitir sinais para cima**. Quem não é a `Principal` não busca o nó de outro módulo (`get_node("../...")` é proibido).

## 2. Regras do jogo no MVP (fonte única de verdade)

**Objetivo:** zerar a poluição. Não há limite de rodadas: o jogo continua até o jogador **vencer** (poluição chega a 0) ou **perder** (todas as árvores morreram).

A poluição é um nível acumulado. Ela começa alta (`poluicao_inicial`), sobe a cada rodada e só cai pela ação das árvores. Rodada `n` começa em 1. Ao clicar em "Avançar rodada", a rodada atual é resolvida nesta ordem:

1. `geracao = poluicao_base_por_rodada + crescimento_poluicao_por_rodada * (n - 1)`
2. `poluicao_com_geracao = poluicao_atual + geracao`
3. `removida = min(soma da purificacao das árvores vivas, poluicao_com_geracao)`
4. `poluicao_final = poluicao_com_geracao - removida`
5. **Vitória:** se `poluicao_final <= limite_vitoria_poluicao` (0 por padrão), o jogo termina com vitória e **não há dano** nessa rodada.
6. Senão, cada árvore viva sofre o mesmo dano, **proporcional à poluição que sobrou**: `dano = poluicao_final * dano_por_poluicao`. Quanto menos poluição sobra, menos dano: por isso purificar mais protege as árvores.
7. Árvores com vida <= 0 morrem e são removidas do tabuleiro.
8. `creditos_ganhos = creditos_por_rodada + int(removida * creditos_por_poluicao_removida)`
9. `rodada += 1`

Plantar: o jogador seleciona uma semente na loja e clica numa célula vazia. O custo é cobrido **no ato de plantar** (não há inventário de sementes).

**Derrota**, após resolver a rodada: **(a)** o jogador já plantou pelo menos uma árvore e o tabuleiro ficou sem árvores, ou **(b)** não há árvores e os créditos são menores que o custo da semente mais barata (travamento).

Valores iniciais sugeridos (a P1 ajusta no `.tres`): 30 créditos, poluição inicial 150, geração base 10, crescimento 1, `dano_por_poluicao` 0,06, 5 créditos por rodada, 0,2 crédito por unidade removida. Árvore básica: custo 10, vida 30, purificação 5.

Esses valores vêm de uma simulação simples feita fora do Godot: comprar e plantar sempre que possível vence por volta da rodada 18, e o resultado é sensível aos números (por exemplo, 3 créditos por rodada em vez de 5 já leva à derrota). Ou seja, a margem é apertada de propósito; ajustem jogando.

## 3. Pastas e donos

| Pasta | Dono |
|---|---|
| `src/nucleo/`, `dados/config_jogo.tres` | P1 |
| `src/tabuleiro/` | P2 |
| `src/arvores/`, `src/loja/`, `dados/arvores/` | P3 |
| `src/principal/`, `src/interface/`, `assets/`, `testes/teste_principal*`, `project.godot` | P4 |

Cada pessoa também cria seus testes em `testes/` com o prefixo do módulo (`teste_poluicao_*`, `teste_tabuleiro_*`, `teste_loja_*`).
Sugestão: criar `.github/CODEOWNERS` apontando cada pasta para seu dono.

## 4. Fase 0 — contratos (fazer primeiro, em PRs pequenos)

Os módulos dependem de poucas classes em comum. Para ninguém ficar bloqueado, a ordem de merge é:

1. **P3** publica `DadosArvore`, `CatalogoArvores`, `ArvorePlantada` e a árvore `aroeira.tres`. (30 a 60 min)
2. **P1** e **P2** publicam seus esqueletos depois do merge da P3: P1 com `ConfigJogo`, `EstadoJogo`, `ResultadoRodada`; P2 com `Tabuleiro` e `Celula` com as assinaturas abaixo (métodos podem ter corpo provisório).
3. **P4** publica a `principal.tscn` vazia e o ajuste de `project.godot` (a configuração do renderizador, janela e `.editorconfig` já está no patch deste pacote).
4. Todos puxam a `main` e começam a Fase 1.

Contratos (assinaturas exatas, **não mudar sem avisar o grupo**):

```gdscript
# src/arvores/dados_arvore.gd  (P3)
class_name DadosArvore
extends Resource

@export var id: StringName
@export var nome: String
@export_multiline var descricao: String
@export var custo: int = 10
@export var vida_maxima: float = 30.0      # resistência
@export var purificacao: float = 5.0     # poluição removida por rodada
@export var cor: Color = Color.FOREST_GREEN  # visual provisório
@export var textura: Texture2D            # opcional
```

```gdscript
# src/arvores/catalogo_arvores.gd  (P3)
class_name CatalogoArvores
extends Resource

@export var arvores: Array[DadosArvore] = []

func obter_por_id(id_arvore: StringName) -> DadosArvore
func obter_menor_custo() -> int
```

```gdscript
# src/arvores/arvore_plantada.gd  (P3)
class_name ArvorePlantada
extends RefCounted

signal vida_alterada(atual: float, maxima: float)

var dados: DadosArvore
var vida: float

func _init(dados_arvore: DadosArvore) -> void
func receber_dano(quantidade: float) -> void
func esta_morta() -> bool
```

```gdscript
# src/nucleo/config_jogo.gd  (P1)
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
@export var dano_por_poluicao: float = 0.06  # dano = poluição restante * este valor
@export_group("Economia")
@export var creditos_por_rodada: int = 5
@export var creditos_por_poluicao_removida: float = 0.2
```

```gdscript
# src/nucleo/estado_jogo.gd  (P1)
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
		creditos = valor
		creditos_alterados.emit(creditos)
# rodada, poluicao, arvore_selecionada e situacao seguem o mesmo padrão
# (setter que emite o sinal correspondente).

func reiniciar(config: ConfigJogo) -> void  # creditos e poluicao iniciais, rodada=1, situacao=JOGANDO, arvore_selecionada=null
```

```gdscript
# src/nucleo/resultado_rodada.gd  (P1)
class_name ResultadoRodada
extends RefCounted

var numero_rodada: int
var poluicao_antes: float
var poluicao_gerada: float
var poluicao_removida: float
var poluicao_depois: float
var dano_por_arvore: float  # 0 em caso de vitória
var creditos_ganhos: int
var mortas: int  # preenchido pelo GerenciadorJogo
```

```gdscript
# src/tabuleiro/tabuleiro.gd  (P2)
class_name Tabuleiro
extends Control

signal celula_pressionada(indice: int)

func plantar_arvore(indice: int, arvore: ArvorePlantada) -> bool
func celula_vazia(indice: int) -> bool
func obter_arvores() -> Array[ArvorePlantada]            # só árvores vivas
func aplicar_dano(quantidade: float) -> Array[ArvorePlantada]  # aplica, remove as mortas e devolve
func quantidade_arvores() -> int
func limpar() -> void
```

```gdscript
# src/nucleo/sistema_poluicao.gd  (P1)
class_name SistemaPoluicao
extends RefCounted

func _init(config: ConfigJogo) -> void
func resolver_rodada(poluicao_atual: float, numero_rodada: int, arvores: Array[ArvorePlantada]) -> ResultadoRodada
```

```gdscript
# src/nucleo/gerenciador_jogo.gd  (P1)
class_name GerenciadorJogo
extends Node

signal plantio_falhou(motivo: String)
signal rodada_resolvida(resultado: ResultadoRodada)
signal jogo_finalizado(vitoria: bool, rodada_final: int)

var estado: EstadoJogo

func configurar(config: ConfigJogo, tabuleiro: Tabuleiro, catalogo: CatalogoArvores) -> void
func selecionar_arvore(dados: DadosArvore) -> void
func tentar_plantar(indice_celula: int) -> bool
func avancar_rodada() -> void
func reiniciar() -> void
```

```gdscript
# src/loja/painel_loja.gd  (P3)
class_name PainelLoja
extends PanelContainer

signal arvore_escolhida(dados: DadosArvore)

func configurar(catalogo: CatalogoArvores) -> void
func atualizar_disponibilidade(creditos: int) -> void
func definir_selecionada(dados: DadosArvore) -> void  # null limpa o destaque
```

```gdscript
# src/interface/interface_jogo.gd  (P4)
class_name InterfaceJogo
extends Control

signal avancar_rodada_pressionado

func vincular_estado(estado: EstadoJogo) -> void  # lê os valores atuais e liga os sinais
func mostrar_resultado_rodada(resultado: ResultadoRodada) -> void
func mostrar_mensagem(texto: String) -> void
```

```gdscript
# src/interface/painel_fim_de_jogo.gd  (P4)
class_name PainelFimDeJogo
extends Control

signal reinicio_pressionado

func mostrar_resumo(vitoria: bool, rodada_final: int) -> void
```

---

## 5. Pessoa 1 — Núcleo e simulação (`src/nucleo/`, `dados/config_jogo.tres`)

**Arquivos:** `config_jogo.gd`, `estado_jogo.gd`, `resultado_rodada.gd`, `sistema_poluicao.gd`, `gerenciador_jogo.gd`, `dados/config_jogo.tres`.

1. **`ConfigJogo` e `config_jogo.tres`:** criar o script (contrato acima) e o recurso `.tres` pelo Inspector com os valores sugeridos da seção 2. Esses são os únicos números de balanceamento do jogo; o resto da equipe pede ajustes a você.
2. **`EstadoJogo`:** setters que emitem sinais. `reiniciar(config)` define `creditos = creditos_iniciais`, `poluicao = poluicao_inicial` (150, não 0), `rodada = 1`, `situacao = JOGANDO`, `arvore_selecionada = null`. O `reiniciar()` do `GerenciadorJogo` deve **reaproveitar o mesmo `EstadoJogo`** (chamando `estado.reiniciar(config)`), nunca criar um novo, porque a interface está ligada a ele.
3. **`SistemaPoluicao.resolver_rodada`:** implementa os passos 1 a 6 e 8 da seção 2 e devolve um `ResultadoRodada`. Deve ser **lógica pura** (sem nós, sem acessar a cena), para ser testável isoladamente. Preenche `dano_por_arvore` (`poluicao_final * dano_por_poluicao`, ou 0 se `poluicao_final <= limite_vitoria_poluicao`), mas **não** aplica o dano e **não** decide vitória: isso é do `GerenciadorJogo`.
4. **`GerenciadorJogo`:**
   - `configurar(...)`: guarda as referências, cria `SistemaPoluicao.new(config)`, cria `estado` e chama `estado.reiniciar(config)`.
   - `selecionar_arvore(dados)`: grava em `estado.arvore_selecionada`.
   - `tentar_plantar(indice_celula)`: valida nesta ordem e, em caso de falha, emite `plantio_falhou` e devolve `false`:
     - jogo não está `JOGANDO`;
     - semente selecionada (`"Selecione uma semente primeiro."`);
     - célula vazia (`"Esta célula já está ocupada."`);
     - créditos suficientes (`"Créditos ambientais insuficientes."`).
     Se tudo passar: `estado.creditos -= custo`, `tabuleiro.plantar_arvore(indice_celula, ArvorePlantada.new(dados))`, marca que já plantou alguma árvore, devolve `true`.
   - `avancar_rodada()`: ignora se o jogo não está `JOGANDO`. Chama `resolver_rodada` e atualiza `estado.poluicao` com `resultado.poluicao_depois`. Se `poluicao_depois <= limite_vitoria_poluicao`: `estado.situacao = VITORIA`, emite `rodada_resolvida` e `jogo_finalizado(true, estado.rodada)` e para por aí. Senão: `tabuleiro.aplicar_dano(resultado.dano_por_arvore)`, preenche `resultado.mortas`, soma `creditos_ganhos` a `estado.creditos`, emite `rodada_resolvida`, faz `estado.rodada += 1` e verifica a derrota (regras da seção 2); se for derrota, `estado.situacao = DERROTA` e emite `jogo_finalizado(false, estado.rodada - 1)`.
   - `reiniciar()`: `tabuleiro.limpar()`, `estado.reiniciar(config)`, zera a marca de "já plantou".
5. **Teste:** `testes/teste_sistema_poluicao.tscn` com um script que monta `ArvorePlantada` falsas e imprime/`assert`a os resultados de: nenhuma árvore (poluição só sobe), árvores insuficientes (poluição final > 0, dano proporcional) e árvores suficientes (poluição chega a 0, `dano_por_arvore = 0`). Teste também o dano em duas poluições diferentes para confirmar que ele **não** é constante.

**Não mexer:** nada em `src/tabuleiro`, `src/arvores`, `src/loja`, `src/interface`.
**Pronto quando:** o teste passa e o `GerenciadorJogo` compila contra os esqueletos das outras pessoas.
**Sugestão de branches:** `feat/estado-do-jogo`, `feat/simulacao-poluicao`, `feat/gerenciador-do-jogo`.

## 6. Pessoa 2 — Tabuleiro e plantio (`src/tabuleiro/`)

**Arquivos:** `tabuleiro.tscn/.gd`, `celula.tscn/.gd`.

1. **`Celula` (`extends Button`):**
   - Sinal próprio `clicada(indice: int)`. Não use o nome `pressed`, que já existe no `Button`. Emite `clicada` no `pressed` do botão.
   - `configurar(indice_celula: int)`, `definir_arvore(arvore: ArvorePlantada)`, `remover_arvore()`, propriedade `indice`.
   - Visual provisório: célula vazia mostra `"Vazio"`; com árvore mostra o nome e a vida (`"Aroeira\n30/30"`) e usa `arvore.dados.cor`. Ao plantar, conectar em `arvore.vida_alterada` para atualizar o texto, e **desconectar em `remover_arvore()`**.
2. **`Tabuleiro`:**
   - Cena: `Control` raiz com um `GridContainer` (`columns = 3`, propriedade do próprio Godot). Exporte `@export var colunas := 3`, `@export var linhas := 3` e `@export var cena_celula: PackedScene`; instancie `colunas * linhas` células no `_ready()` e conecte `clicada` ao seu sinal `celula_pressionada`.
   - `plantar_arvore`: devolve `false` se o índice for inválido ou a célula estiver ocupada.
   - `aplicar_dano(quantidade)`: chama `receber_dano` em cada árvore, remove as mortas (`remover_arvore()`) e devolve a lista das removidas. Com `quantidade = 0` não faz nada.
   - `obter_arvores()` devolve só as vivas; `quantidade_arvores()` o número delas; `limpar()` esvazia tudo.
3. **Teste:** `testes/teste_tabuleiro.tscn`, uma cena que instancia o `Tabuleiro`, planta árvores falsas por clique, e tem um botão "Dano 10" chamando `aplicar_dano(10)`.

**Não mexer:** `GerenciadorJogo` e qualquer regra de compra: o tabuleiro **não sabe** de créditos nem de semente selecionada; só avisa qual célula foi clicada.
**Pronto quando:** clicar planta (via teste), a vida aparece, árvores mortas somem da célula, `limpar()` limpa tudo.
**Sugestão de branches:** `feat/celula-do-tabuleiro`, `feat/tabuleiro-3x3`.

## 7. Pessoa 3 — Árvores e economia (`src/arvores/`, `src/loja/`, `dados/arvores/`)

**Arquivos:** `dados_arvore.gd`, `catalogo_arvores.gd`, `arvore_plantada.gd`, `painel_loja.tscn/.gd`, `item_loja.tscn/.gd`, `dados/arvores/aroeira.tres`, `dados/arvores/catalogo_arvores.tres`.

1. **Fase 0 (prioridade, todo mundo espera por isso):** criar `DadosArvore`, `CatalogoArvores`, `ArvorePlantada` exatamente como no contrato, e os `.tres`: `aroeira.tres` (id `aroeira`, nome `Aroeira`, custo 10, vida 30, purificação 5) e `catalogo_arvores.tres` contendo a aroeira. Abrir PR e avisar o grupo.
2. **`CatalogoArvores`:** `obter_por_id` e `obter_menor_custo()` (menor `custo` entre as árvores; o `GerenciadorJogo` usa para detectar travamento).
3. **`ArvorePlantada`:** `_init` copia `vida_maxima` para `vida`; `receber_dano` reduz sem passar de 0 e emite `vida_alterada(vida, dados.vida_maxima)`; `esta_morta()` é `vida <= 0`.
4. **`ItemLoja`** (cena de um item): mostra nome, custo, vida e purificação; sinal `escolhido(dados: DadosArvore)`; `configurar(dados)`, `definir_disponivel(valor: bool)` (desabilita o botão se não dá para comprar), `definir_destaque(valor: bool)`.
5. **`PainelLoja`:**
   - `configurar(catalogo)` instancia um `ItemLoja` por árvore do catálogo (nada de lista fixa no código).
   - Ao receber `escolhido`, emite `arvore_escolhida(dados)`.
   - `atualizar_disponibilidade(creditos)` chama `definir_disponivel(creditos >= dados.custo)` em cada item.
   - `definir_selecionada(dados)` destaca o item correspondente; `null` remove o destaque.
6. **Teste:** `testes/teste_painel_loja.tscn`: instancia o painel com o catálogo real, mostra no console qual árvore foi selecionada e tem um campo/botão para simular créditos.

**Não mexer:** o painel **não desconta créditos nem decide a compra**; só informa a seleção. Quem valida é o `GerenciadorJogo`.
**Pronto quando:** o catálogo gera os itens, clicar emite `arvore_escolhida` e o item fica desabilitado com créditos insuficientes. Adicionar uma espécie nova deve exigir só criar um `.tres` e incluí-lo no catálogo.
**Sugestão de branches:** `feat/dados-das-arvores`, `feat/painel-da-loja`.

## 8. Pessoa 4 — Interface e integração (`src/principal/`, `src/interface/`, `assets/`, `project.godot`)

**Arquivos:** `principal.tscn/.gd`, `interface_jogo.tscn/.gd`, `painel_fim_de_jogo.tscn/.gd`, tema em `assets/temas/`.

1. **Configuração do projeto (já pronta no patch deste pacote):** renderizador GL Compatibility, janela 1280×720, `.editorconfig` com tab para `.gd`, estrutura de pastas. Abrir PR `chore(projeto): ajusta renderizador, janela e estrutura de pastas`. Quando a `principal.tscn` existir, definir `run/main_scene` em Project Settings.
2. **`InterfaceJogo`:**
   - Mostra rodada, créditos ambientais, poluição de CO₂ (rótulos em português), e o botão `"Avançar rodada"` que emite `avancar_rodada_pressionado`.
   - `vincular_estado(estado)` **lê os valores atuais imediatamente** e conecta `creditos_alterados`, `poluicao_alterada`, `rodada_alterada`. Desabilita o botão quando `situacao_alterada` indicar qualquer situação diferente de `JOGANDO`.
   - `mostrar_resultado_rodada(resultado)`: resumo curto da rodada (gerada, removida, árvores mortas, créditos ganhos).
   - `mostrar_mensagem(texto)`: mostra o feedback de `plantio_falhou` (some após alguns segundos).
3. **`PainelFimDeJogo`:** `mostrar_resumo(vitoria, rodada_final)` mostra `"Você zerou a poluição na rodada X!"` em caso de vitória, ou `"Todas as árvores morreram na rodada X"` em caso de derrota, e o botão `"Reiniciar"`, que emite `reinicio_pressionado`. Começa escondido.
4. **`Principal`:**
   - Árvore da cena: `Principal (Node)` → `GerenciadorJogo`, `Tabuleiro` (instância), `CamadaInterface` (`CanvasLayer`) → `InterfaceJogo`, `PainelLoja`, `PainelFimDeJogo`.
   - Carregar os dados com `preload` (constantes `CONFIG_JOGO` e `CATALOGO`, no código abaixo).
   - Ligações no `_ready()`:

```gdscript
const CONFIG_JOGO := preload("res://dados/config_jogo.tres")
const CATALOGO := preload("res://dados/arvores/catalogo_arvores.tres")

@onready var gerenciador: GerenciadorJogo = $GerenciadorJogo
@onready var tabuleiro: Tabuleiro = $Tabuleiro
@onready var interface: InterfaceJogo = $CamadaInterface/InterfaceJogo
@onready var loja: PainelLoja = $CamadaInterface/PainelLoja
@onready var painel_fim: PainelFimDeJogo = $CamadaInterface/PainelFimDeJogo

func _ready() -> void:
	gerenciador.configurar(CONFIG_JOGO, tabuleiro, CATALOGO)
	loja.configurar(CATALOGO)
	interface.vincular_estado(gerenciador.estado)
	loja.atualizar_disponibilidade(gerenciador.estado.creditos)

	loja.arvore_escolhida.connect(gerenciador.selecionar_arvore)
	tabuleiro.celula_pressionada.connect(gerenciador.tentar_plantar)
	interface.avancar_rodada_pressionado.connect(gerenciador.avancar_rodada)
	gerenciador.plantio_falhou.connect(interface.mostrar_mensagem)
	gerenciador.rodada_resolvida.connect(interface.mostrar_resultado_rodada)
	gerenciador.jogo_finalizado.connect(painel_fim.mostrar_resumo)
	painel_fim.reinicio_pressionado.connect(gerenciador.reiniciar)
	gerenciador.estado.creditos_alterados.connect(loja.atualizar_disponibilidade)
	gerenciador.estado.arvore_selecionada_alterada.connect(loja.definir_selecionada)
```

5. **Testes de integração:** roteiro manual no `docs/` (ou `testes/`): comprar e plantar, tentar plantar sem semente, sem crédito, em célula ocupada, avançar rodadas até a poluição matar as árvores (derrota), jogar até zerar a poluição (vitória) e reiniciar.
6. **Arte provisória:** só com nós de UI e `StyleBox`; nada de imagem externa sem aprovação do grupo.

**Não mexer:** nas regras do jogo. Se algo não conecta, o problema é de contrato: abra a conversa com o dono do módulo.
**Pronto quando:** abrir o jogo, comprar, plantar, avançar rodada, ver a poluição subir e descer, árvores morrerem, vitória, derrota e reinício funcionam do começo ao fim.
**Sugestão de branches:** `ui/interface`, `ui/tela-fim-de-jogo`, `feat/cena-principal`.

## 9. Checklist do MVP

| # | Item do MVP | Responsável |
|---|---|---|
| 1 | Cena principal | P4 |
| 2 | Tabuleiro 3×3 funcional | P2 |
| 3 | Moeda inicial | P1 |
| 4 | Espécie básica de árvore | P3 |
| 5 | Interface de compra de sementes | P3 |
| 6 | Selecionar semente e plantar | P3 + P2 + P1 (integração P4) |
| 7 | Botão de avançar rodada | P4 |
| 8 | Poluição aumenta por rodada | P1 |
| 9 | Remoção de poluição por árvore | P1 |
| 10 | Resistência e morte das árvores | P3 (`ArvorePlantada`) + P2 (remoção) + P1 (dano) |
| 11 | Atualização visual dos indicadores | P4 |
| extra | Vitória (poluição zerada) e derrota (árvores mortas) | P1 (regra) + P4 (tela) |

# Guia de contribuição

Este guia define um formato único para as mensagens de commit do projeto
Sertão-Veredas, um jogo desenvolvido no Godot.

## Formato dos commits

Use o seguinte padrão:

```text
<tipo>(<escopo>): <resumo>
```

- Escreva em português.
- Use letras minúsculas no tipo, no escopo e no início do resumo.
- Escreva o resumo no presente, de forma direta, sem ponto final.
- Mantenha cada commit focado em uma alteração relacionada.
- Use um escopo curto para indicar a parte do jogo afetada.
- A autoria dos commits deve corresponder aos contribuidores responsáveis. Não
  atribua coautoria a ferramentas de inteligência artificial nem adicione
  trailers `Co-authored-by` para elas.

## Tipos

- `feat`: adiciona uma funcionalidade ou mecânica.
- `fix`: corrige um erro.
- `art`: adiciona ou modifica artes, cenários, animações ou outros recursos visuais.
- `audio`: adiciona ou modifica músicas e efeitos sonoros.
- `ui`: altera menus, HUD ou outros elementos da interface.
- `refactor`: reorganiza o código sem alterar o comportamento do jogo.
- `perf`: melhora o desempenho.
- `test`: adiciona ou modifica testes.
- `docs`: altera documentação.
- `chore`: manutenção, configuração ou atualização de ferramentas.

## Exemplos

```text
feat(jogabilidade): adiciona coleta de sementes
fix(personagem): corrige colisão ao pular
art(cenario): adiciona vegetação da caatinga
audio(ambiente): adiciona sons de pássaros
ui(menu): ajusta a tela inicial
refactor(inventario): separa a lógica dos itens
perf(cenario): reduz o custo de renderização da vegetação
docs(contribuicao): define o padrão de commits
chore(projeto): atualiza configurações do Godot
```

## Branches e colaboração

Como o projeto será desenvolvido em equipe, mantenha a branch `main` estável:

- Não faça alterações diretamente na `main`.
- Crie uma branch curta para cada tarefa e use o formato `<tipo>/<descricao>`.
- Abra um pull request para integrar a mudança na `main` e peça a revisão de
  pelo menos outra pessoa da equipe.
- Teste a mudança no Godot antes de pedir a revisão e novamente após resolver
  conflitos.
- Apague a branch depois que o pull request for integrado.

Exemplos de nomes:

```text
feat/inventario
fix/colisao-personagem
art/cenario-caatinga
docs/guia-de-contribuicao
```

Arquivos de cena (`.tscn`) e recursos (`.tres`) podem ser difíceis de combinar
quando várias pessoas os alteram ao mesmo tempo. Combine quem vai trabalhar
neles, evite mudanças simultâneas no mesmo arquivo e, se houver conflito,
resolva-o no editor de texto ou no Godot e abra o projeto para conferir que a
cena ou o recurso continua funcionando. A pasta `.godot/` é gerada pelo editor
e não deve ser adicionada aos commits.

## Quando incluir mais detalhes

Se o resumo não explicar a motivação ou o impacto da alteração, acrescente um
corpo separado por uma linha em branco. Descreva o problema e a solução sem
repetir o resumo.

```text
fix(personagem): corrige colisão ao pular

Evita que o personagem atravesse plataformas ao aterrissar pela lateral.
```

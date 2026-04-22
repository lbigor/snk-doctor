---
id: log-silencioso
sintomas:
  - "catch (Exception ignored)"
  - "catch (Exception e) {}"
  - "nao sei por que o lote foi cortado"
  - "nao sei por que o item foi pulado"
  - "o log nao mostrou nada"
  - "parou sem FATAL"
  - "cortou sem motivo"
  - "skip sem mensagem"
severity: warn
aplicacao: semi-automatica
deps:
  - snk-slack instalada no projeto
---

# Sintoma

Item, lote, rodada ou ramo de negocio foi pulado/cortado em producao mas
nao existe log Slack explicando **o motivo**. O caminho feliz emitiu
`INICIO`/`FIM` normalmente, porem o evento de exclusao silenciosa nao
deixou rastro — impossivel diagnosticar sem revisar o codigo linha a
linha.

Tambem se aplica quando o codigo tem `catch (Exception ignored) {}`, `catch (Exception e) {}`
sem log, ou quando um metodo novo foi adicionado num projeto com
`SlackLogger` disponivel mas ele nao e propagado (o metodo usa
`SlackLogger.NOOP` por dentro).

# Causa

Violacao da **regra de instrumentacao obrigatoria** documentada em
[`snk-slack/SKILL.md`](https://github.com/lbigor/snk-slack/blob/main/SKILL.md#regra-de-instrumentacao-obrigatoria-em-cada-ramo).

Projetos Sankhya com `snk-slack` ativa devem emitir `slack.debug` em cada
ramo novo/alterado:

- Bypass/atalho (early return) precisa logar motivo antes do `return`
- Leituras de `MGECoreParameter` precisam logar: valor lido, caso
  ausente/vazio, e `catch` com `e.getClass().getSimpleName()`
- `catch (Exception ignored)` e proibido
- Antes de loops grandes, emitir resumo (qtd, limites, params)
- Metodos auxiliares novos recebem `SlackLogger` como parametro

Quando a regra e violada, o log-silencioso aparece em producao e so e
detectado quando alguem reclama.

# Fix automatico

A skill deve:

1. **Rastrear arquivos alterados recentemente** (`git log --since="30 days ago" --name-only --pretty=format: | sort -u`).
2. **Para cada `.java`** com `SlackLogger` no escopo (import de `br.com.lbi.slack.SlackLogger`):
   - `grep -nE "catch\s*\(\s*Exception\s+ignored\s*\)|catch\s*\(\s*Exception\s+\w+\s*\)\s*\{\s*\}"`
   - `grep -nE "^\s*return\s*(;|itens;|item;|null;|list;)"` em metodos
     que comecam com `if` — sinaliza early return sem log
   - `grep -nE "MGECoreParameter\.getParameterAsString" -A 5` — confirmar
     que existem 3 `slack.debug` no bloco (lido, ausente, exception)
   - `grep -nE "SlackLogger\.NOOP"` — sinaliza auxiliar que deveria
     receber `SlackLogger` por parametro
3. **Gerar patch** inserindo `slack.debug(TAG, mensagem)` nos ramos
   detectados. Para `catch (Exception ignored)`, renomear para `e` e
   inserir log apropriado.
4. **Abrir PR** com titulo `fix(slack): instrumenta ramos silenciosos
   em <arquivo>` e corpo explicando a regra violada, linkando pra
   `snk-slack/SKILL.md#regra-de-instrumentacao-obrigatoria-em-cada-ramo`.

Como e `semi-automatica`, a skill mostra o patch antes de commitar e
espera OK do usuario — detecao de ramo correto pode ter falsos positivos.

# Fix manual (fallback)

1. Abrir o `.java` suspeito.
2. Para cada `return` em early-exit: adicionar `slack.debug(TAG, "NOME_BYPASS motivo=...")` antes.
3. Para cada leitura de `MGECoreParameter`: garantir 3 logs separados (valor, ausente, exception).
4. Para cada `catch (Exception ignored)`: renomear para `e` e emitir `slack.debug(TAG, e.getClass().getSimpleName() + ": " + e.getMessage())`.
5. Para cada metodo auxiliar novo: passar `SlackLogger slack` como parametro em vez de `SlackLogger.NOOP`.
6. Buildar (`snk-deploy`) e testar em homologacao.

# Referencias

- [snk-slack/SKILL.md — Regra de instrumentacao obrigatoria](https://github.com/lbigor/snk-slack/blob/main/SKILL.md#regra-de-instrumentacao-obrigatoria-em-cada-ramo)
- [snk-slack/BOAS_PRATICAS.md — Instrumentacao obrigatoria em cada ramo](https://github.com/lbigor/snk-slack/blob/main/BOAS_PRATICAS.md#instrumentacao-obrigatoria-em-cada-ramo)
- Exemplo real: `Utils.filtrarPorValidade` em `snk-fabmed-empenho-automatico` (PR #1)

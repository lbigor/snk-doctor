---
name: snk-doctor
description: Skill mestra de diagnóstico Sankhya. Lê logs Slack, casa com base de conhecimento, aplica fix automaticamente. Acionar quando usuário descreve "rodada X falhou", "por que não completou", "erro em produção".
type: skill
---

# snk-doctor — fluxo

## Gatilhos

A skill deve disparar quando o usuário disser coisas como:

- "a rodada X não completou"
- "por que esse projeto parou"
- "deu erro em produção, o log está no Slack"
- "não sei o que houve com o empenho automático ontem"
- cola stacktrace de projeto Sankhya no chat
- "de onde veio esse erro abc12345?"
- "qual PR gerou esse build?"
- cola footer `v: abc12345 · feat/x · PR #42`

## Fluxo

1. **Identificar input.** ID da rodada, stacktrace colado, sintoma textual. Se o usuário só
   descrever o sintoma, pedir um dos três: tag do log Slack, trecho do stacktrace ou nome
   da classe que falhou.
2. **Coletar evidências.**
   - Se MCP `slack` estiver disponível: `mcp__slack__slack_search_messages` ou
     `slack_get_channel_history` no canal configurado em `$SNKDOCTOR_SLACK_CHANNEL`
     (ou o canal que o projeto usa com `snk-slack` — padrão `#logsankhya`).
     Procurar a última tag antes do silêncio (`[FATAL]`, `[ERRO]`, `[SKIP]`,
     ausência de `[FIM]`).
   - Ler os arquivos Java referenciados no stacktrace.
   - `git log -n 5` nos arquivos suspeitos pra entender o que mudou.
   - Se a mensagem contém footer `v: <hash>`, consultar o release correspondente via
     `gh release view --repo <repo-alvo>` — retorna branch, commit e PR automaticamente.
3. **Casar com kb/.** Iterar sobre `kb/*.md`, ler frontmatter `sintomas:` e casar contra
   a evidência coletada. Quem casar mais sintomas ganha — empate vai pro mais específico.
4. **Decidir ação.**
   - `aplicacao: automatica` + match confiante → aplicar fix, commitar, abrir PR, reportar.
   - `aplicacao: semi-automatica` → preparar patch, mostrar ao usuário, esperar OK antes
     de commitar.
   - `aplicacao: manual` → **nunca** auto-aplicar. Só exibir o checklist do fix manual.
   - Sem match → fazer 2-3 perguntas direcionadas, criar `kb/<novo>.md`, abrir PR na skill.
5. **Reportar.** Link do PR, resumo do que foi mudado, link do caso na kb/ que bateu.

## Invariantes

- Nunca commitar direto em `main` — sempre PR com branch dedicada.
- Sempre preservar o stacktrace original no corpo do commit (bloco ``` ``` ```).
- Se `aplicacao: manual`, nunca auto-aplicar — só sugerir.
- Antes de aplicar fix automático em código Java, validar que o arquivo compila após a
  edição (ou ao menos que o padrão de substituição é seguro — ex.: regex exata).
- Toda SQL gerada ou corrigida passa pela regra global de null-safety
  (`ISNULL`/`NVL` em campos de valor) antes de commitar.

## Dependências

- `snk-slack` — lib Java `br.com.lbi.slack` usada pelos projetos Sankhya.
- `snk-dicionario` — catálogo de tabelas/campos Sankhya (ex-`sankhya_core.md`).
- `snk-jape` — padrões corretos de JAPE (ex-`sankhya_api.md`).
- MCP `slack` — leitura do canal `#logsankhya` via `mcp__slack__*`.

## Formato dos casos em kb/

Ver [kb/README.md](kb/README.md) para o schema do frontmatter e o template.

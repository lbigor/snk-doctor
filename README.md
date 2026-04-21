# snk-doctor

[![Discussions](https://img.shields.io/github/discussions/lbigor/snk-doctor)](https://github.com/lbigor/snk-doctor/discussions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> A skill que diagnostica e conserta sozinha — quando sabe. E aprende quando não sabe.

**Problema:** erro em produção, você caça stacktrace, pesquisa, testa fix, reza.
**Solução:** skill lê logs, casa com base de conhecimento, aplica fix, abre PR.
**Você faz:** `"Claude, a rodada X não completou, resolve."`

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/lbigor/snk-doctor/main/install.sh | bash
```

Depende de (opcional mas recomendado):

- [snk-slack](https://github.com/lbigor/snk-slack) — pra ler logs
- [snk-dicionario](https://github.com/lbigor/snk-dicionario) — pra validar campos no fix
- [snk-jape](https://github.com/lbigor/snk-jape) — pra corrigir código JAPE
- MCP `slack` — pra ler canal `#logsankhya` diretamente

## Como funciona

1. Usuário relata sintoma ("rodada X não completou", stacktrace, erro de build).
2. A skill coleta evidências (Slack via MCP se disponível, arquivos Java referenciados).
3. Cruza com `kb/*.md` — base de conhecimento viva, um arquivo por caso.
4. Se match confiante: aplica o fix e abre PR.
5. Se não: coleta 2-3 pontos com o usuário, cria `kb/*.md` novo, abre PR — a skill aprende.

Veja [SKILL.md](SKILL.md) pro fluxo completo, [BOAS_PRATICAS.md](BOAS_PRATICAS.md) pra
saber quando aplicar fix automático vs manual, e [CONTRIBUTING.md](CONTRIBUTING.md) pra
adicionar um caso novo na base de conhecimento.

## Casos cobertos hoje

| Caso | Aplicação | Severity |
|---|---|---|
| [flush-timeout](kb/flush-timeout.md) | semi-automática | fatal |
| [jape-prepare-pk](kb/jape-prepare-pk.md) | automática | erro |
| [sql-null-valor](kb/sql-null-valor.md) | automática | silencioso |
| [gson-classpath](kb/gson-classpath.md) | manual | compile |
| [slack-rate-limit](kb/slack-rate-limit.md) | automática | warning |
| [find-by-hash](kb/find-by-hash.md) | automática | info |

MIT · Contato: lbigor@icloud.com

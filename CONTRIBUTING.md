# Contribuindo

Obrigado por contribuir! A skill cresce na medida em que a `kb/` cresce — cada caso
novo torna a skill mais útil pra todo mundo.

## Workflow geral

1. Fork do repo.
2. Branch a partir de `main`: `git checkout -b kb/<id-curto>` ou `fix/<resumo>`.
3. Commits pequenos, descritivos. Mensagem em português ou inglês, consistente com o
   histórico.
4. Rode `./test.sh` antes de abrir PR.
5. Abra PR contra `main`. O template de PR ajuda a cobrir o essencial.

## Adicionando um caso novo na kb/

1. Crie um arquivo em `kb/<id-curto>.md` com o frontmatter padrão (ver `kb/README.md`).
2. Descreva o sintoma em linguagem humana — como aparece no log, na tela ou na fala do
   usuário. Um item por bullet em `sintomas:`.
3. Explique a causa **tecnicamente** — o que o código/ambiente fez pra produzir o
   sintoma. Não basta "deu erro": diga qual invariante quebrou.
4. Forneça o fix: script, patch, instrução passo a passo, ou regex de substituição.
5. Marque `aplicacao: automatica` **apenas se** o fix passa a checklist do
   [BOAS_PRATICAS.md](BOAS_PRATICAS.md). Na dúvida, marque `semi-automatica` ou
   `manual`.
6. Teste localmente com `./test.sh` — valida frontmatter, markdown e links.
7. Abra PR. No corpo, inclua:
   - Link pro log/stacktrace real que motivou (pode ser print com dados mascarados).
   - Como você reproduziu.
   - Por que o fix é seguro (se marcou `automatica`).

## Alterando um caso existente

- Mudanças em `sintomas:` são livres — só testar depois.
- Mudanças em "Fix automático" exigem descrever no PR por que o fix anterior não
  bastava (ex.: cobria só um subtipo do bug).
- Nunca apagar um caso. Se ficou obsoleto, substituir o conteúdo por um redirect:
  "Este caso foi absorvido por `kb/<novo-id>.md`."

## Estilo de texto

- Português neutro, tom direto, sem adjetivação.
- Sem emojis.
- Blocos de código com linguagem explícita (```java, ```sql, ```bash).
- Sem linhas > 100 colunas.

## CI

O CI roda em cada PR:

- `markdownlint` (config em `.markdownlint.json`).
- Valida frontmatter YAML de cada `kb/*.md`.
- Checa links relativos.
- Executa `./test.sh`.

PRs com CI vermelho não são mergeados.

## Contato

Dúvidas: abrir issue no repo ou mandar e-mail para <lbigor@icloud.com>.

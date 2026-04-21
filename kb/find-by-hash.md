---
id: find-by-hash
sintomas:
  - "v: [a-f0-9]{8}"
  - "qual PR causou"
  - "de onde veio esse erro"
  - "qual deploy gerou"
severity: info
aplicacao: automatica
deps:
  - gh CLI
  - projeto Sankhya versionado em GitHub
---

# Sintoma

Usuário vê um footer `v: abc12345 · feat/fix-estoque · PR #42` numa mensagem
de erro no Slack e quer investigar o PR/commit original.

Ou o usuário cola o hash curto do JAR (sempre 8 chars hex) e pergunta
"que deploy é esse?".

# Causa

Não é "causa" — é **rastreio reverso**. O JAR que disparou o log foi empacotado
pelo snk-deploy e contém um manifest embutido. O hash é um identificador curto
do build (SHA-256 dos primeiros bytes de `commit + timestamp`).

# Fix automático

Consultar GitHub Releases do repo do projeto Sankhya:

```bash
# Descobrir o repo alvo (do cwd ou do manifest)
cd /caminho/para/projeto-sankhya
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Listar release pelo hash
HASH="abc12345"
gh release view "v*-${HASH}" --repo "$REPO" --json name,body,createdAt,assets,tagName
```

Ou buscar pelo manifest direto no JAR (se o usuário anexar):

```bash
unzip -p projeto-20260421-abc12345.jar META-INF/snk-deploy/manifest.json | jq
```

A skill deve:

1. Identificar hash no input (8 chars hex).
2. Tentar `gh release view` no repo atual (cwd).
3. Se não achar, buscar em todos os repos Sankhya conhecidos (cache de
   `gh repo list lbigor --limit 100`).
4. Retornar:
   - Branch
   - Commit (link)
   - PR (número, título, link, autor)
   - Timestamp do build
   - Comparação: `git log <hash_anterior>..<hash_atual>` se o usuário quiser
     ver o diff

# Fix manual (fallback)

Se `gh release` não estiver disponível:

1. `unzip -p <jar> META-INF/snk-deploy/manifest.json` — mostra manifest
   diretamente
2. Abrir o PR do manifest no browser: `gh pr view <numero> --web`

# Referências

- [snk-deploy](https://github.com/lbigor/snk-deploy) — gera o manifest
- [snk-slack](https://github.com/lbigor/snk-slack) — insere o footer com hash

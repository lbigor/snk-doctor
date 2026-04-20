# PR: <resumo curto>

## Tipo

- [ ] Novo caso em `kb/`
- [ ] Correção de caso existente
- [ ] Mudança na skill (`SKILL.md`, `BOAS_PRATICAS.md`, etc.)
- [ ] Infra (CI, install.sh, test.sh)
- [ ] Docs

## O que mudou

<descrição objetiva>

## Para casos novos em kb/

- [ ] Frontmatter com `id`, `sintomas`, `severity`, `aplicacao` preenchidos.
- [ ] `id` igual ao basename do arquivo.
- [ ] Seções "# Sintoma", "# Causa", "# Fix automático", "# Fix manual",
      "# Referências" presentes.
- [ ] Se `aplicacao: automatica`, o fix passa a checklist do
      [BOAS_PRATICAS.md](../BOAS_PRATICAS.md).
- [ ] Log/stacktrace real que motivou o caso anexado (com dados mascarados).
- [ ] Rodei `./test.sh` localmente e passou.

## Evidência / reprodução

<cole aqui o stacktrace, o trecho do log ou a query que reproduz>

## Risco

<baixo/médio/alto — e por quê>

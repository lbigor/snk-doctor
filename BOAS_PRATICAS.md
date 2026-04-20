# Boas práticas

## Quando a skill aplica fix sozinha

Só quando **todas** as condições abaixo se cumprem:

1. O caso em `kb/*.md` está marcado com `aplicacao: automatica`.
2. O match de sintomas é inequívoco (≥ 3 sintomas distintos batendo, ou 1 sintoma
   altamente específico como stacktrace identificando linha/classe).
3. O fix é **local** — muda 1 a N arquivos bem delimitados, sem alterar schema de banco,
   sem tocar em credenciais, sem mexer em build/release.
4. O padrão de substituição é **determinístico**: regex exata, AST match confiável ou
   replace literal. Nada que envolva reescrever código aberto.

Se qualquer condição falhar: cair pro fluxo semi-automático (prepara patch, mostra ao
usuário, espera OK).

## Quando só sugerir (nunca auto-aplicar)

- `aplicacao: manual` no frontmatter do caso. Sempre.
- Fix depende de ação fora do repo (configuração no Sankhya W, ajuste de IDE, toque em
  JAR no classpath, criação de preferência `LOGSLACK`).
- Fix envolve schema de banco (criar coluna, alterar tipo, migração).
- Fix envolve desabilitar algo (hook, validação, pre-commit) — nunca sem o usuário
  confirmar.

## Como validar antes de mergear o PR que a skill abriu

Checklist mínima:

1. Ler o stacktrace original no corpo do commit. Confirma que o arquivo tocado é o da
   falha.
2. Rodar o CI (ele roda automático no push).
3. Se for código Java: abrir no IntelliJ e conferir que **Problems → Errors** está zero.
4. Se for SQL: confirmar tabela-alvo (TGFPAR vs TGFCTT vs TGFFIN) e que campos de valor
   têm `ISNULL`/`NVL`.
5. Se for fix em produção (branch `hotfix/*`): conferir que foi testado em dev antes.

## Como adicionar caso novo na kb/

Ver [CONTRIBUTING.md](CONTRIBUTING.md) seção "Adicionando um caso novo na kb/".

Resumo: crie `kb/<id>.md` com o frontmatter padrão, descreva sintoma em linguagem
humana, causa tecnicamente, forneça fix, marque `aplicacao: automatica` **só** se
passar a checklist das condições acima. Teste com `./test.sh` e abra PR.

## Anti-padrões

- **Auto-aplicar fix sem ter o stacktrace.** Sem stacktrace, match é chute.
- **Confundir sintoma com causa.** "Rodada sem FIM" pode ser flush-timeout, OOM ou
  deadlock — casar sintoma + ao menos uma pista da causa.
- **Adicionar caso à kb/ sem reproduzir.** Se não dá pra reproduzir, documenta como
  `aplicacao: manual` e descreve o fix em checklist.
- **Fundir dois casos em um kb/.** Cada caso é um arquivo. Se dois casos compartilham
  sintoma, linkar um no outro em "Referências".

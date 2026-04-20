---
id: sql-null-valor
sintomas:
  - "item com estoque não aparece no empenho"
  - "SUM retornou NULL"
  - "linha sumiu do relatório"
  - "ESTOQUE - RESERVADO > 0 não filtra"
  - "RESERVADO NULL"
  - "WMSBLOQUEADO NULL"
  - "QTDNEG NULL"
  - "VLRUNIT NULL"
severity: silencioso
aplicacao: automatica
deps:
  - snk-dicionario
---

# Sintoma

Uma query SQL parece correta mas **descarta silenciosamente** linhas que deveriam
entrar, ou retorna `NULL` em agregações. Exemplos reais:

- Item com estoque físico não é empenhado automaticamente porque `RESERVADO` estava
  NULL e `ESTOQUE - RESERVADO > 0` avalia como NULL (falso no WHERE).
- Relatório financeiro mostra total `NULL` porque `SUM(VLRUNIT)` sobre coluna toda NULL
  retorna NULL em vez de 0.
- `CASE WHEN QTDNEG > 0 THEN ... END` nunca entra no ramo positivo quando `QTDNEG` é
  NULL.

# Causa

Campos numéricos de valor em tabelas Sankhya (`QTDNEG`, `QTDPED`, `QTDCAN`, `ESTOQUE`,
`RESERVADO`, `WMSBLOQUEADO`, `VLRUNIT`, `VLRTOT`, saldos) frequentemente aceitam NULL —
o ERP não preenche sempre com zero. Em SQL:

- `NULL - 5 = NULL`
- `NULL > 0 = NULL` (tratado como FALSE em `WHERE`).
- `SUM(coluna)` sobre valores todos NULL retorna NULL, não 0.
- `NULL + 10 = NULL` — contamina expressões inteiras.

A invariante violada: "campo de valor numérico sempre tem valor" — falso em Sankhya.

Ver CLAUDE.md global, seção "Queries SQL — null-safety em campos de valor".

# Fix automático

Envolver todo campo de valor em `ISNULL(campo, 0)` (SQL Server / Sankhya padrão) ou
`NVL(campo, 0)` (Oracle). Aplicar em **qualquer contexto**: `WHERE`, `SELECT`, `JOIN`,
`SUM`, `CASE`.

Campos-alvo (lista mantida; expandir via `snk-dicionario` conforme necessário):

```text
QTDNEG  QTDPED  QTDCAN  QTDENT  QTDENTREGUE  QTDATEND
ESTOQUE  RESERVADO  WMSBLOQUEADO  PENDENTE
VLRUNIT  VLRTOT  VLRDESC  VLRIPI  VLRICMS  VLRNOTA
SALDO  SALDOABERTO  SALDOCONTABIL
```

Heurística do replace:

1. Detectar o dialeto (procurar `ISNULL(` já presente → SQL Server; `NVL(` → Oracle;
   se nenhum, default SQL Server para contexto Sankhya).
2. Para cada campo na lista, envolver ocorrências cruas (não já dentro de
   `ISNULL(`/`NVL(`) com a função correspondente e default `0`.
3. Para `SUM(campo)` — substituir por `SUM(ISNULL(campo, 0))` (e não o contrário:
   `ISNULL(SUM(...), 0)` não cobre linhas individuais NULL).

Commit sugerido: `fix(sql): null-safety em campos de valor`.

# Fix manual (fallback)

1. Localizar a query (DAO, `.sql`, string Java, view).
2. Identificar campos de valor — usar `snk-dicionario` ou `sankhya_core.md` pra
   confirmar tipo numérico.
3. Envolver cada ocorrência com `ISNULL(..., 0)` ou `NVL(..., 0)`.
4. Ao migrar entre bancos: trocar `ISNULL` ↔ `NVL`, comportamento idêntico.
5. Em DAOs com `FinderWrapper` (JAPE): o predicado vai como SQL literal, `ISNULL` se
   aplica igual.
6. Rodar a query em dev contra registros conhecidos com campo NULL e validar que
   voltam no resultado.

# Referências

- CLAUDE.md global, seção "Queries SQL — null-safety em campos de valor".
- Incidente recorrente: item com estoque real não aparecia no empenho automático por
  `RESERVADO` NULL em TGFEST.
- `snk-dicionario`: lista canônica de campos numéricos por tabela.

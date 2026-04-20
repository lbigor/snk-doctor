---
id: jape-prepare-pk
sintomas:
  - "prepareToUpdateByPK"
  - "cannot find symbol method prepareToUpdateByPK(java.math.BigDecimal)"
  - "no suitable method found for prepareToUpdateByPK"
  - "NullPointerException at JapeWrapper.prepareToUpdateByPK"
severity: compile
aplicacao: automatica
deps:
  - snk-jape
---

# Sintoma

Erro de compilação ou `NullPointerException` em runtime apontando para chamadas como:

```java
dao.prepareToUpdateByPK(new BigDecimal("123"));
```

Mensagem típica do compilador:

> cannot find symbol: method prepareToUpdateByPK(java.math.BigDecimal)

# Causa

A API `JapeWrapper.prepareToUpdateByPK` do framework Sankhya exige **array de
`Object[]`** mesmo quando a PK é simples. A assinatura correta é:

```java
FluidUpdateVO prepareToUpdateByPK(Object[] pk);
```

Passar um `BigDecimal` direto não compila (ou compila via auto-boxing e estoura com NPE
no acesso interno).

Ver CLAUDE.md global, seção "JAPE API — Erros Mais Comuns".

# Fix automático

Substituir **todas** as ocorrências do padrão:

```java
.prepareToUpdateByPK(<expr>)
```

onde `<expr>` é um único argumento que não começa com `new Object[]`, por:

```java
.prepareToUpdateByPK(new Object[]{<expr>})
```

Regex (POSIX estendida):

```text
\.prepareToUpdateByPK\(\s*(?!new\s+Object\s*\[)([^)]+?)\s*\)
```

Replace:

```text
.prepareToUpdateByPK(new Object[]{$1})
```

A skill aplica esse replace arquivo por arquivo, commitando cada arquivo num commit
separado com mensagem `fix(jape): wrap prepareToUpdateByPK arg in Object[]`.

# Fix manual (fallback)

1. Buscar no projeto: `grep -rn "prepareToUpdateByPK(" src/`.
2. Para cada ocorrência que passa um único argumento cru, envolver em `new Object[]{}`.
3. Conferir que o import `br.com.sankhya.jape.wrapper.fluid.FluidUpdateVO` está
   presente na classe.
4. Recompilar. IntelliJ → Problems → Errors deve ficar zero.

# Referências

- CLAUDE.md global, seção "JAPE API — Erros Mais Comuns".
- `sankhya_api.md`, classe `JapeWrapper`.
- Memória do usuário: `feedback_sankhya_api.md`.

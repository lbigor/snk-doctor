---
id: gson-classpath
sintomas:
  - "cannot find symbol com.google.gson"
  - "package com.google.gson does not exist"
  - "SlackMessage não compila"
  - "import com.google.gson.Gson"
severity: compile
aplicacao: manual
deps:
  - snk-slack
---

# Sintoma

Ao compilar um projeto Sankhya que usa `br.com.lbi.slack`, o compilador reclama:

```text
error: package com.google.gson does not exist
import com.google.gson.Gson;
                      ^
error: cannot find symbol
  symbol:   class Gson
  location: class br.com.lbi.slack.SlackMessage
```

Geralmente acontece logo depois de copiar a lib para um projeto novo.

# Causa

A classe `br.com.lbi.slack.SlackMessage` serializa o payload do webhook via Gson. O JAR
`gson-*.jar` não vem por padrão no classpath dos projetos Sankhya — precisa ser
adicionado manualmente.

No Sankhya ERP o JAR já existe embarcado em
`mge/WEB-INF/lib/gson-*.jar` (ou similar, dependendo da versão), mas a IDE usa
classpath próprio e não enxerga automaticamente.

# Fix automático

**Não automatizável pela skill.** O caminho do JAR depende de:

- Versão do Sankhya instalada na máquina do dev.
- Estrutura do `.classpath` (IntelliJ, Eclipse, manual).
- Path absoluto (frequentemente dentro do iCloud Drive, variando por usuário).

A skill **só indica** o checklist abaixo.

# Fix manual (fallback)

1. Localizar o JAR no Sankhya instalado:

   ```bash
   find ~/Library -name "gson-*.jar" 2>/dev/null | head
   find /Applications -name "gson-*.jar" 2>/dev/null | head
   ```

2. Se não achar, baixar uma versão compatível (ex.: `gson-2.10.1.jar`) de
   <https://mvnrepository.com/artifact/com.google.code.gson/gson>.
3. Adicionar ao classpath do projeto:
   - **IntelliJ:** Project Structure → Modules → Dependencies → `+` → JARs or
     directories → selecionar o `.jar` → Scope: Compile.
   - **Eclipse / `.classpath` manual:** adicionar entry `<classpathentry kind="lib"
     path="caminho/gson-X.Y.Z.jar"/>` no `.classpath`.
4. Recompilar. Os erros de `com.google.gson` desaparecem.
5. Commitar o `.classpath` se o time compartilha configuração de IDE — caso contrário,
   deixar local.

**Nunca** rodar `javac` manualmente para tentar contornar — classpath do Sankhya
envolve dezenas de JARs, alguns em path absoluto no iCloud. Use a IDE.

# Referências

- `~/Documents/Claude/sankhya_slack.md`, seção "Instalar em novo projeto Sankhya".
- `snk-slack` repo, seção "Pré-requisitos".

# kb/ — base de conhecimento viva

Cada arquivo `kb/<id>.md` descreve um caso: sintoma observável, causa técnica e fix.
A skill lê esta pasta toda vez que é acionada e usa o frontmatter YAML pra casar com o
input do usuário.

## Schema do frontmatter

```yaml
---
id: flush-timeout            # kebab-case, único. Bate com o nome do arquivo.
sintomas:                    # lista de strings procuradas no input (log, fala, stacktrace)
  - "buffer acumulou"
  - "thread morta"
severity: fatal              # fatal | erro | warning | silencioso | compile
aplicacao: semi-automatica   # automatica | semi-automatica | manual
deps:                        # outras skills necessárias pra aplicar o fix (opcional)
  - snk-slack
---
```

### Campos

- `id` — obrigatório, único, kebab-case, igual ao basename do arquivo sem `.md`.
- `sintomas` — obrigatório, lista de strings (case-insensitive). Curtas e específicas.
  Evite substrings genéricas ("erro", "exception") — não discriminam.
- `severity` — obrigatório. Um de:
  - `fatal` — processo morre sem completar.
  - `erro` — exception visível, mas processo continua.
  - `warning` — degradação, sem falha.
  - `silencioso` — resultado errado sem sinal (ex.: filtro que descarta linhas válidas).
  - `compile` — erro em tempo de build.
- `aplicacao` — obrigatório. Um de:
  - `automatica` — skill aplica fix sem pedir confirmação (usa critérios do
    [BOAS_PRATICAS.md](../BOAS_PRATICAS.md)).
  - `semi-automatica` — prepara patch, pede OK antes de commitar.
  - `manual` — só sugere checklist; nunca auto-aplica.
- `deps` — opcional, lista. Skills necessárias pra o fix funcionar.

## Estrutura do corpo

Quatro seções, nessa ordem:

```markdown
# Sintoma
<linguagem humana: como aparece no log, no console, na fala do usuário>

# Causa
<o que aconteceu tecnicamente — qual invariante quebrou>

# Fix automático
<script, patch unificado, ou instrução precisa>
Se aplicacao: manual, esta seção pode estar vazia ou dizer "não automatizável".

# Fix manual (fallback)
<checklist passo a passo — sempre preenchido, mesmo quando automática existe>

# Referências
<links: commit de exemplo, doc interna, issue, stackoverflow, memória>
```

## Template

Copie `_template.md` como ponto de partida.

## Convenções

- Nome do arquivo em kebab-case, curto, descritivo.
- Sem emojis no conteúdo.
- Blocos de código sempre com linguagem explícita (```java, ```sql, ```bash).
- Linhas ≤ 100 colunas.

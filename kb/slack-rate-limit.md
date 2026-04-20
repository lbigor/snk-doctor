---
id: slack-rate-limit
sintomas:
  - "429"
  - "too many requests"
  - "rate_limited"
  - "Slack webhook 429"
  - "Retry-After"
severity: warning
aplicacao: automatica
deps:
  - snk-slack
---

# Sintoma

Log do projeto Sankhya mostra respostas HTTP `429 Too Many Requests` ao postar no
webhook Slack. Mensagens esporádicas somem do canal `#logsankhya` ou chegam atrasadas.
Header `Retry-After` pode aparecer no dump.

# Causa

O webhook Slack aplica rate-limit próprio, por workspace e por webhook URL. Quando a
lib `br.com.lbi.slack` dispara muitas mensagens em pouco tempo (loops intensivos sem
batching), Slack responde 429 e descarta o payload.

Versões recentes de `snk-slack` tratam isso automaticamente: ao receber 429, a lib faz
`Thread.sleep(1100)` e tenta de novo (backoff simples, mas suficiente pro caso
típico). Versões antigas não têm esse tratamento — a mensagem é perdida.

# Fix automático

Se a skill detectar:

1. Sintoma 429 no log.
2. Versão do `snk-slack` incorporada no projeto sem o tratamento (inspecionar
   `SlackLogger.java` — procurar `Thread.sleep(1100)` ou
   `if (status == 429)`).

Então recomendar **upgrade da lib** copiando os 5 arquivos atualizados do projeto
gabarito (`snk-fabmed-empenho-automatico` ou equivalente) para o projeto afetado. Esse
upgrade é determinístico (replace de arquivos), então é seguro para `aplicacao:
automatica`.

Passos executados pela skill:

1. Localizar `src/br/com/lbi/slack/` no projeto afetado.
2. Copiar os 5 arquivos da versão de referência.
3. Abrir PR com mensagem `chore(slack): upgrade lib para tratar HTTP 429 com backoff`.
4. No corpo do PR, incluir trecho do log mostrando o 429 original.

Se a lib **já tem** o tratamento e mesmo assim o 429 aparece com frequência, é sinal
de volume excessivo — o fix correto é reduzir o número de `slack.log()` em loops
grandes (logar apenas marcos: início, fim, erros, checkpoints). Nesse caso cai para
`aplicacao: semi-automatica`.

# Fix manual (fallback)

1. Abrir `src/br/com/lbi/slack/SlackLogger.java` no projeto.
2. Verificar se o método `post()` trata `429`:

   ```java
   if (conn.getResponseCode() == 429) {
       Thread.sleep(1100);
       // retry uma vez
   }
   ```

3. Se não tratar, copiar a versão atualizada de `~/Documents/Claude/sankhya_slack.md`
   seção "Instalar em novo projeto Sankhya" ou do repo `snk-slack`.
4. Se já tratar e o 429 persiste: reduzir frequência de logs no código-cliente —
   logar só marcos relevantes, não cada item de loop.

# Referências

- `~/Documents/Claude/sankhya_slack.md`, seção "Rate-limit Slack".
- Slack API docs: <https://api.slack.com/docs/rate-limits>.
- `snk-slack` repo, `SlackLogger.java`.

---
id: flush-timeout
sintomas:
  - "buffer acumulou"
  - "thread morta"
  - "rodada sem FIM nem FATAL"
  - "última tag foi ESTOQUE"
  - "log para de chegar no Slack"
  - "sem [FIM]"
severity: fatal
aplicacao: semi-automatica
deps:
  - snk-slack
---

# Sintoma

A rodada de um projeto Java Sankhya começou, logou várias tags (`[INICIO]`, `[ESTOQUE]`,
`[ITEM]` etc.) no canal `#logsankhya` e **parou** sem nunca emitir `[FIM]` nem `[FATAL]`.
No Sankhya W a ação aparece como encerrada ou travada, dependendo do entry point.

Sinal típico: última mensagem recebida no Slack é uma tag de meio de loop (ex.:
`[ESTOQUE]`) e o silêncio vem logo depois — sem exception, sem stacktrace, sem aviso.

# Causa

A lib `br.com.lbi.slack` enfileira mensagens em um buffer e envia em lote. Quando o loop
itera milhares de vezes em curto espaço de tempo, o buffer cresce mais rápido do que o
worker consegue drenar. Se o processo morre (timeout do Sankhya, deadlock, OOM) antes de
um `slack.flush()` explícito, as últimas N mensagens nunca chegam ao canal — inclusive
o `[FIM]` ou o `[FATAL]` do `catch`.

Resultado: o log parece travado no meio do processamento quando, na verdade, o erro
aconteceu adiante mas não foi transmitido.

Ver `~/Documents/Claude/sankhya_slack.md` seção "Pitfall conhecido — flush".

# Fix automático

Inserir `slack.flush()` periodicamente dentro de loops grandes (> 500 iterações) e
**sempre** antes de `throw` no `catch`. Padrão:

```java
for (int i = 0; i < itens.size(); i++) {
    processa(itens.get(i));
    slack.log("[ITEM] " + i);
    if (i % 500 == 0) {
        slack.flush();          // drena buffer a cada 500 iterações
    }
}
```

E no entry point:

```java
try {
    executa();
    slack.log("[FIM] ok");
    slack.flush();
} catch (Throwable t) {
    slack.log("[FATAL] " + t.getMessage());
    slack.flush();              // CRÍTICO — sem isso o FATAL some
    throw t;
}
```

A skill pode aplicar isso automaticamente procurando por loops `for`/`while` contendo
`slack.log(` e injetando `flush()` a cada 500 iterações, **após mostrar o patch ao
usuário**. Por isso é `semi-automatica`.

# Fix manual (fallback)

1. Abrir o arquivo Java do entry point (classe que implementa `AcaoRotinaJava` ou
   `EventoProgramavelJava`).
2. Garantir o padrão `try/flush/catch FATAL/flush/throw` no método público.
3. Identificar loops com `slack.log(` dentro — em cada um, inserir `slack.flush()` a
   cada N iterações (N ≈ 500 é seguro).
4. Recompilar na IDE.
5. Rodar teste de fumaça com dataset pequeno e conferir que `[FIM]` chega.
6. Rodar com dataset real e confirmar que `[FATAL]` aparece se a rodada abortar.

# Referências

- `~/Documents/Claude/sankhya_slack.md` — pitfall do flush.
- `snk-slack` lib: `src/br/com/lbi/slack/SlackLogger.java` — método `flush()`.
- CLAUDE.md global: seção "Logs Slack (ERP Sankhya)".

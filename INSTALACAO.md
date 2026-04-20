# Instalação

## Pré-requisitos

- **Claude Code** instalado (`claude --version`).
- **Git** e **GitHub CLI** (`gh`) configurados, se for contribuir na kb/.
- **MCP `slack`** (opcional, fortemente recomendado) — dá acesso ao canal `#logsankhya`
  para a skill ler logs automaticamente. Veja `~/Documents/Claude/sankhya_slack.md`.

## Instalação via install.sh

```bash
curl -fsSL https://raw.githubusercontent.com/lbigor/snk-doctor/main/install.sh | bash
```

O script:

1. Clona o repo para `~/.claude/skills/snk-doctor`.
2. Registra `SKILL.md` como skill no Claude Code.
3. Verifica se as skills dependentes (`snk-slack`, `snk-dicionario`, `snk-jape`) estão
   presentes e imprime aviso caso faltem — não são obrigatórias, mas sem elas a skill
   cobre menos casos.

## Instalação manual

```bash
git clone https://github.com/lbigor/snk-doctor ~/.claude/skills/snk-doctor
```

Depois, em qualquer sessão do Claude Code:

```
> leia ~/.claude/skills/snk-doctor/SKILL.md e ative
```

## Verificação

Na sessão ativa, pergunte:

```
> snk-doctor está carregada?
```

Claude deve responder confirmando e listando os casos atualmente cobertos em `kb/`.

## Atualização

```bash
cd ~/.claude/skills/snk-doctor && git pull --ff-only
```

Toda vez que um novo `kb/*.md` for mergeado no `main`, o `git pull` já distribui — a
skill passa a reconhecer o caso novo sem nenhuma outra ação.

## Desinstalação

```bash
rm -rf ~/.claude/skills/snk-doctor
```

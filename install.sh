#!/usr/bin/env bash
# install.sh — instala snk-doctor como skill do Claude Code
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/lbigor/snk-doctor/main/install.sh | bash
#
# Ou local:
#   ./install.sh

set -euo pipefail

REPO_URL="https://github.com/lbigor/snk-doctor.git"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/snk-doctor"

echo "==> snk-doctor installer"
echo "    destino: $TARGET"

mkdir -p "$(dirname "$TARGET")"

if [ -d "$TARGET/.git" ]; then
  echo "==> repo já presente, atualizando via git pull"
  git -C "$TARGET" pull --ff-only
else
  echo "==> clonando $REPO_URL"
  git clone --depth 1 "$REPO_URL" "$TARGET"
fi

echo "==> verificando skills dependentes (opcionais)"
SKILLS_DIR="$(dirname "$TARGET")"
for dep in snk-slack snk-dicionario snk-jape; do
  if [ -d "$SKILLS_DIR/$dep" ]; then
    echo "    [ok] $dep encontrada"
  else
    echo "    [warn] $dep ausente — snk-doctor funciona, mas cobre menos casos"
  fi
done

echo "==> verificando MCP slack (opcional)"
if grep -q '"slack"' "$HOME/.claude.json" 2>/dev/null; then
  echo "    [ok] MCP slack registrado em ~/.claude.json"
else
  echo "    [warn] MCP slack não registrado — skill não lerá #logsankhya sozinha"
fi

echo ""
echo "==> pronto. Em uma sessão do Claude Code:"
echo "    > leia $TARGET/SKILL.md e ative"
echo ""
echo "   Casos atualmente cobertos:"
ls "$TARGET/kb/" | grep -v '^_' | grep -v '^README' | sed 's/\.md$//' | sed 's/^/    - /'

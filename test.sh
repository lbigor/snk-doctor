#!/usr/bin/env bash
# test.sh — valida integridade da skill e da base de conhecimento.
#
# Checa:
#   1. Todo kb/*.md (exceto README e _template) tem frontmatter YAML válido.
#   2. Campos obrigatórios presentes: id, sintomas, severity, aplicacao.
#   3. Valores de enums válidos (severity, aplicacao).
#   4. id bate com o nome do arquivo.
#   5. SKILL.md, README.md, LICENSE, INSTALACAO.md, BOAS_PRATICAS.md, CONTRIBUTING.md
#      presentes.
#
# Saída: exit 0 se tudo ok, exit 1 se algo falhar.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

fail=0
ok=0

say_ok()   { printf "  [ok]   %s\n" "$1"; ok=$((ok+1)); }
say_fail() { printf "  [FAIL] %s\n" "$1"; fail=$((fail+1)); }

echo "==> arquivos top-level obrigatórios"
for f in README.md SKILL.md LICENSE INSTALACAO.md BOAS_PRATICAS.md CONTRIBUTING.md install.sh; do
  if [ -f "$f" ]; then
    say_ok "$f"
  else
    say_fail "$f ausente"
  fi
done

echo ""
echo "==> validando kb/*.md"

SEVERITY_RE='^(fatal|erro|warning|silencioso|compile|info)$'
APLICACAO_RE='^(automatica|semi-automatica|manual)$'

for f in kb/*.md; do
  base="$(basename "$f" .md)"
  # pular README e _template
  [ "$base" = "README" ] && continue
  [ "$base" = "_template" ] && continue

  # extrai frontmatter (entre primeiras duas linhas '---')
  fm="$(awk '/^---$/{n++; next} n==1{print}' "$f")"

  if [ -z "$fm" ]; then
    say_fail "$f: frontmatter ausente ou malformado"
    continue
  fi

  id="$(printf '%s\n' "$fm" | awk -F': *' '/^id:/{print $2; exit}')"
  sev="$(printf '%s\n' "$fm" | awk -F': *' '/^severity:/{print $2; exit}')"
  apl="$(printf '%s\n' "$fm" | awk -F': *' '/^aplicacao:/{print $2; exit}')"
  has_sint="$(printf '%s\n' "$fm" | awk '/^sintomas:/{print "yes"; exit}')"

  errors=""
  [ -z "$id" ]       && errors="$errors id-ausente"
  [ -z "$sev" ]      && errors="$errors severity-ausente"
  [ -z "$apl" ]      && errors="$errors aplicacao-ausente"
  [ -z "$has_sint" ] && errors="$errors sintomas-ausentes"

  if [ -n "$id" ] && [ "$id" != "$base" ]; then
    errors="$errors id!=filename($id!=$base)"
  fi
  if [ -n "$sev" ] && ! printf '%s' "$sev" | grep -Eq "$SEVERITY_RE"; then
    errors="$errors severity-invalida($sev)"
  fi
  if [ -n "$apl" ] && ! printf '%s' "$apl" | grep -Eq "$APLICACAO_RE"; then
    errors="$errors aplicacao-invalida($apl)"
  fi

  # seções obrigatórias no corpo
  for sec in "# Sintoma" "# Causa" "# Fix automático" "# Fix manual" "# Referências"; do
    if ! grep -qF "$sec" "$f"; then
      errors="$errors falta-secao:'$sec'"
    fi
  done

  if [ -z "$errors" ]; then
    say_ok "kb/$base.md"
  else
    say_fail "kb/$base.md —$errors"
  fi
done

echo ""
echo "==> verificação find-by-hash"
FBH="kb/find-by-hash.md"
if [ -f "$FBH" ]; then
  if grep -qE '"v: \[a-f0-9\]\{8\}"' "$FBH"; then
    say_ok "$FBH contém regex de hash em sintomas"
  else
    say_fail "$FBH sem regex de hash (v: [a-f0-9]{8}) em sintomas"
  fi
else
  say_fail "$FBH ausente"
fi

echo ""
echo "==> resumo: $ok ok, $fail falhas"
exit $fail

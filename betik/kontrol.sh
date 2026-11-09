#!/usr/bin/env bash
# Claude Code sızıntı kontrolü. SADECE OKUR: hiçbir dosyayı değiştirmez, silmez, internete bir şey göndermez.
# Şifreleri ve e-postanı ekrana yazmaz, maskeleyerek gösterir.
# Kullanım: bash betik/kontrol.sh            (ana klasörünü tarar)
#           bash betik/kontrol.sh ~/projeler (yalnız o klasörü tarar)
set -u
KOK="${1:-$HOME}"
CLAUDE_DIR="$HOME/.claude"
SIR_DESENI='(sk-ant-[A-Za-z0-9_-]{8,}|sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|[Bb]earer [A-Za-z0-9._-]{20,}|(api[_-]?key|token|secret|password|passwd|sifre)[\"'"'"' ]*[:=][\"'"'"' ]*[^\"'"'"' ,)]{8,})'

maskele() { sed -E 's/([A-Za-z0-9_-]{4})[A-Za-z0-9._\/+=-]{6,}/\1****/g'; }
baslik() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

baslik "1) Claude Code sürümü"
if command -v claude >/dev/null 2>&1; then
  claude --version 2>/dev/null
  echo "Eskiyse güncelle: claude update"
else
  echo "claude komutu bulunamadı (bu bilgisayarda kurulu olmayabilir)."
fi

baslik "2) settings.local.json dosyaları ($KOK altında)"
DOSYALAR=$(find "$KOK" -path "*/.claude/settings.local.json" -not -path "*/node_modules/*" 2>/dev/null)
if [ -z "$DOSYALAR" ]; then
  echo "Hiç dosya bulunamadı."
else
  SAYI=$(printf '%s\n' "$DOSYALAR" | wc -l | tr -d ' ')
  echo "$SAYI dosya bulundu."
fi

TOPLAM_SIR=0; TOPLAM_GIT=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  PROJE=$(dirname "$(dirname "$f")")
  IZIN=$(python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(len(d.get('permissions',{}).get('allow',[])))" "$f" 2>/dev/null || echo "?")
  SIR=$(grep -Eo "$SIR_DESENI" "$f" 2>/dev/null | wc -l | tr -d ' ')
  GIT="git'te değil"
  if git -C "$PROJE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git -C "$PROJE" ls-files --error-unmatch ".claude/settings.local.json" >/dev/null 2>&1; then
      GIT="!!! GIT TAKİBİNDE (push edildiyse GitHub'da)"; TOPLAM_GIT=$((TOPLAM_GIT+1))
    elif git -C "$PROJE" log --all --oneline -- ".claude/settings.local.json" 2>/dev/null | grep -q .; then
      GIT="!!! şu an takipte değil ama GIT GEÇMİŞİNDE var"; TOPLAM_GIT=$((TOPLAM_GIT+1))
    else
      GIT="git'te takip edilmiyor (iyi)"
    fi
  fi
  printf -- '- %s\n    kalıcı komut izni: %s · şifreye benzeyen satır: %s · %s\n' "$f" "$IZIN" "$SIR" "$GIT"
  if [ "$SIR" -gt 0 ]; then
    TOPLAM_SIR=$((TOPLAM_SIR+SIR))
    grep -Eo "$SIR_DESENI" "$f" 2>/dev/null | maskele | sed 's/^/      maskeli: /'
  fi
done <<< "$DOSYALAR"

baslik "3) Claude bir siteye istek atarken e-posta adresi koymuş mu?"
if [ ! -d "$CLAUDE_DIR/projects" ]; then
  echo "Konuşma kayıtları klasörü yok ($CLAUDE_DIR/projects)."
else
  echo "Konuşma kayıtların taranıyor (birkaç dakika sürebilir)..."
  python3 - "$CLAUDE_DIR/projects" <<'PY'
import json, os, re, sys
from collections import Counter
from urllib.parse import urlparse
EPOSTA = re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
# yalnız kimlik kartına (User-Agent) yazılmış e-posta: User-Agent: "... ad@alan", -A "... ad@alan", --user-agent
UA = re.compile(r'(?:user-agent["\']?\s*[:=,]\s*["\']?|\s-A\s+["\']|--user-agent[=\s]+["\']?)([^"\'\n]{0,200})', re.I)
URL = re.compile(r'https?://[^\s"\'<>)]+')
def maskele(e):
    ad, alan = e.split('@', 1)
    return ad[:1] + '***@' + alan
def komutlar(nesne):
    if isinstance(nesne, dict):
        if nesne.get('type') == 'tool_use':
            girdi = nesne.get('input', {})
            yield ' '.join(str(v) for v in girdi.values())
        for v in nesne.values():
            yield from komutlar(v)
    elif isinstance(nesne, list):
        for v in nesne:
            yield from komutlar(v)
bulgu = Counter()
for kok, _, dosyalar in os.walk(sys.argv[1]):
    for ad in dosyalar:
        if not ad.endswith('.jsonl'):
            continue
        try:
            satirlar = open(os.path.join(kok, ad), encoding='utf-8', errors='ignore')
        except OSError:
            continue
        for satir in satirlar:
            if '@' not in satir or 'tool_use' not in satir:
                continue
            try:
                kayit = json.loads(satir)
            except ValueError:
                continue
            for komut in komutlar(kayit):
                epostalar = {e for deger in UA.findall(komut) for e in EPOSTA.findall(deger)}
                if not epostalar:
                    continue
                for url in URL.findall(komut):
                    alan = urlparse(url).hostname
                    if alan and '.' in alan and alan not in ('localhost', '127.0.0.1'):
                        for e in epostalar:
                            bulgu[(alan, maskele(e))] += 1
if not bulgu:
    print("E-posta adresi koyulmuş bir istek bulunamadı.")
else:
    print("E-posta geçen istekler (site · e-posta · kaç kez):")
    for (alan, e), n in bulgu.most_common(30):
        print(f"   {alan} · {e} · {n}")
    print("Bunların bir kısmını sen istemiş olabilirsin. İstemediğin site varsa bil ki o siteye gitti.")
PY
fi

baslik "ÖZET"
echo "Şifreye benzeyen satır: $TOPLAM_SIR · git'e girmiş dosya: $TOPLAM_GIT"
if [ "$TOPLAM_SIR" -gt 0 ] || [ "$TOPLAM_GIT" -gt 0 ]; then
  echo "Ne yapacağın: DUZELT.md"
else
  echo "Görünür bir sorun yok. Yine de DUZELT.md'deki 'bundan sonra' kısmını oku."
fi
echo "Not: desen taraması her şifreyi yakalamaz. Dosyaları bir kez de kendi gözünle aç."

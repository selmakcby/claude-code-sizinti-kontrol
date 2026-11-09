---
name: sizinti-kontrol
description: Claude Code'un bu bilgisayarda şifre ya da e-posta sızdırıp sızdırmadığını kontrol eder. settings.local.json dosyalarındaki kalıcı izinleri ve içlerindeki sırları, bu dosyaların git'e girip girmediğini ve konuşma kayıtlarında User-Agent'a e-posta yazılmış istekleri tarar. "sızıntı kontrolü", "settings.local.json kontrol et", "e-postam bir siteye gitmiş mi", "bir daha sorma izinlerimi tara" dendiğinde kullan.
---

# Sızıntı kontrolü

Bu skill yalnızca **okur**. Hiçbir dosyayı değiştirmez, silmez, internete istek atmaz.

## Kurallar

- Şifre, anahtar ya da e-posta adresini **asla tam yazma**: ilk 4 karakter + `****`.
- git'te yalnız okuyan komutlar: `ls-files`, `log`, `status`.
- Düzeltme (git rm, .gitignore, dosya düzenleme) yalnız kullanıcı açıkça "yap" derse; önce ne yapacağını göster.
- Bu skill çalışırken kullanıcı bir izin sorusunda "don't ask again" seçmemeli; gerekirse hatırlat.

## Adımlar

1. Depodaki betik varsa onu çalıştır: `bash betik/kontrol.sh` (ya da `bash betik/kontrol.sh <klasör>`). Çıktıyı özetle.
2. Betik yoksa aynı işi elle yap:
   - `claude --version`
   - `find ~ -path "*/.claude/settings.local.json" -not -path "*/node_modules/*"`
   - her dosyada `permissions.allow` sayısı ve şifreye benzeyen değerler (sk-ant-, sk-, ghp_, github_pat_, AKIA, xox, AIza, Bearer, password=, token=, api_key=)
   - dosyanın git durumu: `git -C <proje> ls-files --error-unmatch .claude/settings.local.json` ve `git -C <proje> log --all --oneline -- .claude/settings.local.json`
   - `~/.claude/projects/**/*.jsonl` içinde tool_use komutlarında `User-Agent` / `-A "..."` / `--user-agent` değerinde e-posta geçen istekler → site + maskeli e-posta + sayı
3. Raporu şu sırayla ver: sürüm · dosya ve izin sayısı · şifre içerenler · git'e girmiş olanlar · e-postanın gittiği siteler · önerilen düzeltmeler (DUZELT.md).

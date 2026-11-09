# Claude Code sızıntı kontrolü

Claude Code ile ilgili iki güvenlik haberi için kendi bilgisayarını **5 dakikada** kontrol et:

1. **E-posta:** Claude Code, bazı kullanıcıların e-posta adresini girdiği web sitelerine göndermiş. Bir siteye istek atarken kimlik kartına (User-Agent) senin e-postanı yazıyor.
2. **"Bir daha sorma":** Bir izin sorusunda "Yes, and don't ask again" dediğinde o komut, **içindeki şifreyle birlikte**, projendeki `.claude/settings.local.json` dosyasına yazılıyor. Apiiro, GitHub'da herkese açık 104.185 böyle dosya taradı; 1.122'sinde gerçek bir şifre ya da anahtar vardı.

## Üç yol, birini seç

| Yol | Kime uygun | Nasıl |
|---|---|---|
| **Betik** | Terminal kullanabilen herkes | `bash betik/kontrol.sh` |
| **Prompt** | Claude Code'a yaptırmak isteyenler | [PROMPT.md](PROMPT.md) içeriğini Claude Code'a yapıştır |
| **Skill** | Claude Code'u her gün kullananlar | `.claude/skills/sizinti-kontrol` klasörünü `~/.claude/skills/` altına kopyala, sonra Claude'a "sızıntı kontrolü yap" de |

Üçü de **yalnızca okur**: hiçbir dosyayı değiştirmez, internete bir şey göndermez, bulduğu şifreleri ve e-postanı maskeleyerek gösterir.

## Betik ile

```bash
git clone https://github.com/selmakcby/claude-code-sizinti-kontrol.git
cd claude-code-sizinti-kontrol
bash betik/kontrol.sh            # ana klasörünü tarar (birkaç dakika sürebilir)
bash betik/kontrol.sh ~/projeler # yalnız bir klasörü tarar
```

> Tanımadığın birinin betiğini çalıştırmadan önce içini oku: [betik/kontrol.sh](betik/kontrol.sh). Kısa ve açıklamalı.

Betik şunlara bakar:

1. **Sürüm:** `claude --version`
2. **settings.local.json dosyaları:** her birinde kaç kalıcı izin var, içinde şifreye benzeyen değer var mı, dosya git'te takip ediliyor mu ya da git geçmişinde kalmış mı
3. **E-posta:** konuşma kayıtlarında (`~/.claude/projects`) bir siteye istek atılırken User-Agent'a e-posta yazılmış mı; hangi site, kaç kez

macOS ve Linux'ta çalışır; `bash`, `git` ve `python3` yeterli.

## Elle, tek tek

```bash
claude --version                                   # eskiyse: claude update
find ~ -path "*/.claude/settings.local.json"       # izin dosyaların
git ls-files | grep settings.local                 # proje klasöründe: git'e girmiş mi?
```

## Bir şey bulduysan

[DUZELT.md](DUZELT.md): şifreyi değiştirme, dosyayı git'ten çıkarma, `.gitignore`, git geçmişi ve bundan sonrası.

## Benim bilgisayarımda ne çıktı?

- Video çekilirken 18 `settings.local.json` dosyası; ana klasördekinde 179 kalıcı izin. Hiçbiri git'te değil, çünkü bilgisayarımda bu dosyayı her projede gizleyen genel bir kural varmış.
- E-postam, Claude bir siteden veri çekerken kimlik kartına yazılarak şu sitelere gitmiş: Wikimedia (görsel ararken), Amerikan borsa kurumu SEC (araştırma yaparken) ve bir harita servisi. Hiçbirinde bana sorulmadı.

## Kaynaklar

- E-posta şikayeti: [anthropics/claude-code #107757](https://github.com/anthropics/claude-code/issues/107757)
- Apiiro, "don't ask again" dosyalarında sızan şifreler (5 Kasım 2026): https://apiiro.com/blog/coding-agents-leaking-secrets-github-dont-ask-again
- Claude Code izinler: https://code.claude.com/docs/en/permissions

## Lisans

MIT. Kullan, değiştir, paylaş.

---

Selma · [YouTube](https://www.youtube.com/@selma.builds) · [selma.codes](https://www.selma.codes) · [Instagram](https://instagram.com/selma.builds)

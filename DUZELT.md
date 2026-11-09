# Bir şey bulduysan ne yapmalısın?

## Dosyada şifre ya da API anahtarı var

1. **Önce şifreyi değiştir.** Sağlayıcının panelinden (Anthropic, OpenAI, GitHub, AWS…) eski anahtarı iptal et, yenisini oluştur. Dosyayı temizlemek tek başına yetmez: anahtar başka bir kopyada, yedekte ya da git geçmişinde kalmış olabilir.
2. Sonra dosyadaki o satırı sil. Dosyayı bir düzenleyiciyle aç, `permissions.allow` içindeki şifreli komutu kaldır.

## Dosya git'te takip ediliyor

Proje klasöründe:

```bash
git rm --cached .claude/settings.local.json
echo ".claude/settings.local.json" >> .gitignore
git commit -m "chore: settings.local.json takipten çıkarıldı"
```

Bütün projelerde bir kerede gizlemek için genel kural:

```bash
git config --global core.excludesFile ~/.gitignore_global
echo ".claude/settings.local.json" >> ~/.gitignore_global
```

## Dosya git geçmişinde kalmış (ve GitHub'a gitmiş)

- Depo herkese açıksa o şifreyi **sızmış say** ve değiştir. Geçmişi temizlemek, birinin onu çoktan kopyalamış olma ihtimalini ortadan kaldırmaz.
- Geçmişi temizlemek istersen GitHub'ın rehberi: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

## E-postan bir siteye gitmiş

- Claude Code'u güncelle: `claude update`. Anthropic, e-postanızı göndermeden önce soran bir kontrol ekledi.
- Claude'a bir siteye istek attırırken User-Agent için kendi seçtiğin bir değer söyle (ör. "User-Agent olarak `ProjeAdi/1.0` kullan, e-postamı yazma").
- Gereksiz spam alıyorsan, o siteler için ayrı bir e-posta adresi kullanmayı düşün.

## Bundan sonra

- Şifreler `.env` dosyasında dursun, komutun içine yazılmasın. Komut şifreyi oradan okusun.
- Şifre geçen bir komutta **"Yes, and don't ask again"e basma.**
- Ayda bir `bash betik/kontrol.sh` çalıştır.

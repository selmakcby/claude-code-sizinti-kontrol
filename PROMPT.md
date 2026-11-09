# Claude Code'a yapıştırılacak prompt

Aşağıdaki metni olduğu gibi Claude Code'a yapıştır. Claude bilgisayarını tarar, **hiçbir dosyayı değiştirmez**, şifreleri ekrana yazmaz ve sonunda sana bir rapor verir. Düzeltme yapmadan önce her adımda senden onay ister.

> İpucu: Bu prompt'u çalıştırırken "Yes, and don't ask again" seçeneğine **basma**. Bu tarama tam da o düğmenin neye yol açtığını arıyor.

---

```text
Bilgisayarımda Claude Code kaynaklı iki güvenlik sorununu kontrol etmeni istiyorum.
Kurallar:
- SADECE OKU. Hiçbir dosyayı değiştirme, silme, taşıma; git komutlarından yalnız okuyanları kullan (ls-files, log, status).
- Bulduğun hiçbir şifreyi, anahtarı ya da e-posta adresini tam olarak ekrana yazma. İlk 4 karakterini göster, gerisini **** ile maskele.
- İnternete hiçbir istek gönderme.

1) Sürüm: `claude --version` çalıştır ve sürümü söyle. Güncelleme gerekiyorsa bana `claude update` komutunu öner, kendin çalıştırma.

2) Ana klasörümde bütün `.claude/settings.local.json` dosyalarını bul (node_modules hariç). Her biri için:
   - permissions.allow listesinde kaç kalıcı izin var,
   - bu izinlerin içinde şifre, API anahtarı, token, parola ya da kimlik numarasına benzeyen bir şey var mı (maskeli göster),
   - dosya bir git deposunun içindeyse: `git ls-files` ile takipte mi, `git log --all -- .claude/settings.local.json` ile geçmişte var mı.

3) `~/.claude/projects/` altındaki konuşma kayıtlarında (*.jsonl) senin ya da başka bir Claude oturumunun çalıştırdığı komutlarda, bir siteye istek atarken User-Agent / kimlik bilgisine e-posta adresi koyulmuş mu bak. Site adı + maskeli e-posta + kaç kez olarak listele.

4) Sonunda bana kısa bir rapor ver:
   - kaç dosya, toplam kaç kalıcı izin,
   - şifre içeren dosyalar (maskeli),
   - git'e girmiş ya da geçmişinde kalmış dosyalar,
   - e-postamın gittiği siteler,
   - her sorun için ne yapmam gerektiği (şifre değiştirme, git'ten çıkarma, .gitignore).
   Düzeltme adımlarını sadece öner; ben "yap" demeden hiçbirini uygulama.
```

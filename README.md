# Vocal Warmup App

یک اپلیکیشن Flutter برای تمرین vocal warmup بر اساس ToneGym.

## نصب Dependencies

اگر با مشکل TLS مواجه شدید، می‌توانید از میراژهای دیگر استفاده کنید:

### روش 1: استفاده از میراژ اصلی (اگر VPN دارید)
```bash
set PUB_HOSTED_URL=https://pub.dev
set FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com
flutter pub get
```

### روش 2: استفاده از میراژ Tsinghua (برای چین)
```bash
set PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
flutter pub get
```

### روش 3: استفاده از میراژ Shanghai Jiao Tong University
```bash
set PUB_HOSTED_URL=https://dart-pub.mirrors.sjtug.sjtu.edu.cn
set FLUTTER_STORAGE_BASE_URL=https://mirrors.sjtug.sjtu.edu.cn/flutter
flutter pub get
```

### روش 4: در PowerShell (Windows)
```powershell
$env:PUB_HOSTED_URL="https://pub.dev"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.googleapis.com"
flutter pub get
```

## ساختار پروژه

- `lib/models/` - مدل‌های داده (Warmup, Difficulty)
- `lib/data/` - داده‌های نمونه warmup ها
- `lib/theme/` - تنظیمات تم و رنگ‌ها
- `lib/widgets/` - ویجت‌های قابل استفاده مجدد
- `lib/screens/` - صفحات اصلی اپلیکیشن

## ویژگی‌ها

- ✅ Dark mode به عنوان پیش‌فرض
- ✅ فیلتر بر اساس سطح (Beginner, Intermediate, Advanced)
- ✅ 18 warmup آماده از ToneGym
- ✅ طراحی Material Design
- ✅ رنگ‌های Neon Cyan و Dark Blue

## اجرا

```bash
flutter run
```

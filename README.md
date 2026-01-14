# 🏟️ FERZDEVZ - MODERN RUNNER (Server Lock) 🔐

![Version](https://img.shields.io/badge/Version-2.5-blue.svg)
![Platform](https://img.shields.io/badge/Platform-SA--MP%20%7C%20open.mp-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Open.mp Ready](https://img.shields.io/badge/Open.mp-Supported-brightgreen.svg)

Solusi maintenance mode paling komprehensif dan profesional untuk server **SA-MP (0.3.7)** dan **open.mp**. Dirancang untuk stabilitas tinggi dan kemudahan penggunaan (Plug-and-Play).

---

## 📺 Visual Demo
![FERZDEVZ Banner](file:///home/ferdinand/.gemini/antigravity/brain/f5024391-d8a7-4651-9b39-e27e06f55f08/ferzdevz_lock_banner_1768373014622.png)
*Professional branding for FERZDEVZ - MODERN RUNNER.*

![Maintenance Dialog Mockup](file:///home/ferdinand/.gemini/antigravity/brain/f5024391-d8a7-4651-9b39-e27e06f55f08/locksystem_dialog_mockup_1768371847716.png)
*Tampilan profesional dialog maintenance saat pemain mencoba masuk.*

---

## 🚀 Fitur Utama | Key Features

### 🇮🇩 Bahasa Indonesia
- **`/lockmenu` (GUI)**: Manajemen maintenance melalui menu dialog interaktif yang bersih.
- **Auto-Unlock Timer**: Masukkan durasi (menit) dan server akan terbuka otomatis saat waktu habis.
- **Dual Language**: Ganti antara Bahasa Indonesia dan Inggris secara instan melalui skrip.
- **Audit Logging**: Mencatat setiap aksi penguncian ke `scriptlogs/locksystem.log` (Admin, Waktu, Alasan).
- **Discord Webhook**: Notifikasi otomatis ke server Discord Anda saat status server berubah.
- **Dynamic Hostname**: Menambahkan tag `[LOCKED]` otomatis pada nama server di server browser.
- **IP Whitelisting**: Izinkan developer atau admin tertentu masuk tanpa perlu login RCON.

### 🇺🇸 English
- **`/lockmenu` (GUI)**: Manage maintenance using a clean, interactive dialog menu.
- **Auto-Unlock Timer**: Set a duration in minutes; server restores public access automatically.
- **Dual Language Support**: Easily toggle between ID and EN in the source code.
- **Audit Logging**: Automated tracking of all lock/unlock actions in a log file.
- **Discord Integration**: Real-time alerts sent to your Discord Webhook.
- **Visual Branding**: Automatic `[LOCKED]` prefix for the server hostname.
- **Security**: Robust IP Whitelisting for developers.

---

## 🎮 Perintah | Commands
*(Hanya untuk RCON Administrator / RCON Admins Only)*

| Command | Usage | Description |
| :--- | :--- | :--- |
| `/lockmenu` | - | **(Recommended)** Buka menu manajemen visual. |
| `/lockserver` | `[Reason] [Minutes]` | Kunci server via teks (opsional timer). |
| `/unlockserver` | - | Membuka server secara manual. |
| `/lockstatus` | - | Cek status kuncian & detail sisa waktu. |

---

## ⚙️ Cara Instalasi | Installation

### 1. Persiapan File
- **open.mp User**: Gunakan `locksystem_omp.pwn`.
- **SAMP Legacy User**: Gunakan `locksystem_samp.pwn`.

### 2. Konfigurasi (Opsional)
Buka file `.pwn` dan sesuaikan bagian atas:
```pawn
#define LANG_ID // Ganti ke LANG_EN untuk Inggris
static const gDiscordWebhook[] = "URL_WEBHOOK_ANDA";
static const gIPWhitelist[][] = { "127.0.0.1" };
```

### 3. Kompilasi & Jalankan
1. Kompilasi file `.pwn` menjadi `.amx`.
2. Masukkan file `.amx` ke folder `filterscripts`.
3. Tambahkan ke `server.cfg` pada baris `filterscripts`.
4. Restart server atau jalankan `/rcon loadfs locksystem`.

---

## 📝 Audit & Keamanan
Sistem ini secara otomatis membuat log setiap kali ada perubahan status. File log dapat ditemukan di:
`scriptlogs/locksystem.log`

---

## 🛠️ Arsitektur Teknis
Plugin ini bekerja pada level **Network Hook** (open.mp) atau **OnPlayerRequestClass** (SAMP). 
- **Zero Dependencies**: Tidak membutuhkan plugin pihak ketiga untuk fungsi dasar.
- **Optimized Timers**: Menggunakan sistem timer open.mp yang modern (jika menggunakan versi OMP).

---

## 💎 Kredit | Credits
- **FERZDEVZ** - Author & Project Lead.
  - 📺 [Youtube: Ferzsampp](https://youtube.com/@Ferzsampp)
  - 📸 [Instagram: ferzchills](https://instagram.com/ferzchills)
  - 💬 [Discord: ferzdevz](https://discord.gg/ferzdevz)

---

## 📄 Lisensi
Proyek ini dilisensikan di bawah **MIT License**.

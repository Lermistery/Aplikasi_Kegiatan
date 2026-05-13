# 🌟 KegiatanKu - Aplikasi Manajemen Kegiatan Sosial & Relawan

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-%23777BB4.svg?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)

**KegiatanKu** adalah platform digital (Berbasis Web & Mobile) yang dirancang khusus untuk mempermudah pendaftaran, manajemen, dan verifikasi relawan dalam berbagai kegiatan sosial. Aplikasi ini dilengkapi dengan **sistem gamifikasi** interaktif untuk meningkatkan antusiasme peserta!

---

## 🚀 Fitur Utama

### 👤 Untuk User (Relawan)
- **Cari & Daftar Kegiatan:** Telusuri kegiatan sosial yang tersedia dan daftar hanya dengan satu klik.
- **Riwayat & Status Pendaftaran:** Pantau status pendaftaran (Menunggu Verifikasi, Diterima, atau Ditolak).
- **Gamifikasi & Poin Reward 🎁:** Dapatkan **+5 Poin** setiap pendaftaran disetujui, dan **+2 Poin** jika ditolak.
- **Tukar Hadiah (Redeem):** Kumpulkan poin dan tukarkan dengan hadiah fisik menarik seperti *Coffee Latte*, Ember, hingga Kaos Relawan Eksklusif!
- **Statistik Personal:** Lacak seberapa banyak kegiatan sosial yang telah diikuti setiap bulannya.

### 🛡️ Untuk Admin (Pengurus)
- **Manajemen Kegiatan (CRUD):** Buat, edit, tutup, atau hapus kegiatan sosial dengan mudah.
- **Verifikasi Peserta:** Setujui atau tolak pendaftar secara *real-time*. Poin user akan langsung masuk secara otomatis ketika diverifikasi.
- **Manajemen Pengguna:** Atur *role* pengguna (Admin/User) dan awasi jumlah pendaftar.
- **Dashboard Analitik:** Pantau total pendaftar, kegiatan aktif, dan total relawan yang bergabung.

---

## 🛠️ Teknologi yang Digunakan
- **Frontend App:** Flutter (Dart)
- **Frontend Web:** HTML, CSS (Bootstrap), JavaScript
- **Backend API:** PHP Native (REST API)
- **Database:** MySQL
- **Hosting / Deployment:** InfinityFree (Live Web & API)


## ⚙️ Cara Menjalankan Project (Lokal)

1. **Clone Repository:**
   ```bash
   git clone https://github.com/Lermistery/Aplikasi_Kegiatanku.git
   ```
2. **Install Dependensi Flutter:**
   ```bash
   cd aplikasi_kegiatanku
   flutter pub get
   ```
3. **Konfigurasi API:**
   - Buka file `lib/services/api_service.dart`.
   - Ubah `baseUrl` sesuai lingkungan kamu (Gunakan `http://10.0.2.2/KegiatanKu/api` untuk emulator.
4. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---
*Dibuat untuk tugas/project akhir oleh [Nama Lu]*

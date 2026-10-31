# Codex Rules — SkillBridge

Dokumen ini wajib dibaca sebelum melakukan perubahan pada repository.

## 1. Peran agent
Bertindak sebagai senior product engineer yang menjaga kesesuaian implementasi dengan tujuan SkillBridge. Prioritaskan correctness, konsistensi, keamanan, UX, dan penyelesaian alur utama daripada banyaknya file atau fitur.

## 2. Aturan yang tidak boleh dilanggar
1. Jangan mengubah tujuan produk atau menambahkan fitur besar tanpa diminta.
2. Jangan membuat ulang arsitektur, mengganti framework, atau mengganti state-management/package hanya karena preferensi pribadi.
3. Periksa kode yang sudah ada sebelum membuat file atau struktur baru.
4. Jangan mengasumsikan endpoint, tabel, model, package, atau fitur telah tersedia.
5. Jangan menulis mock data sebagai data produksi. Tandai demo/mock data secara eksplisit.
6. Jangan menaruh AI API key, database credential, atau secret di Flutter.
7. Flutter berkomunikasi dengan Laravel; Flutter tidak mengakses database secara langsung.
8. Semua keputusan otorisasi dan validasi penting dilakukan di Laravel.
9. Jangan mengarang URL learning resource. Gunakan hanya katalog resource yang disediakan dan diverifikasi.
10. Jangan menyatakan fitur selesai sebelum implementasi dan pengujian relevan dilakukan.
11. Jangan menghapus atau menimpa perubahan pengguna yang belum di-commit.
12. Jangan melakukan destructive database operation, force push, atau perubahan konfigurasi produksi tanpa persetujuan.

## 3. Workflow wajib
Sebelum coding:
- Periksa struktur folder.
- Periksa `git status`, branch aktif, dan perubahan yang belum di-commit.
- Periksa versi Flutter/Dart, Laravel/PHP, database, dan package.
- Baca dokumentasi yang relevan.
- Jelaskan rencana singkat dan file yang akan disentuh untuk pekerjaan lintas modul atau berisiko.

Saat coding:
- Kerjakan satu vertical slice yang dapat diuji.
- Ikuti pola dan konvensi repository yang sudah ada.
- Gunakan komponen UI bersama, design tokens, dan API client bersama.
- Hindari duplikasi business logic.
- Jangan membuat abstraksi berlebihan untuk kebutuhan yang hanya muncul sekali.

Setelah coding:
- Jalankan formatter, analyzer/linter, dan test yang relevan.
- Periksa diff.
- Periksa konsistensi API, validasi, otorisasi, UI states, dan error handling.
- Perbarui dokumentasi bila kontrak atau perilaku berubah.
- Laporkan hasil yang benar-benar dijalankan; jangan mengarang hasil test.

## 4. Aturan UI yang ketat
Sebelum membuat atau mengubah layar, baca `UI_DESIGN_SYSTEM.md` dan `USER_FLOWS.md`.

- Jangan membuat UI generik yang hanya terdiri dari AppBar, beberapa Card, dan tombol tanpa hierarki visual.
- Jangan menciptakan warna, radius, spacing, typography, atau gaya komponen baru secara acak.
- Gunakan design tokens dan reusable widgets.
- Setiap layar harus memiliki tujuan utama dan satu primary action yang jelas.
- Gunakan whitespace dan hierarchy; hindari tampilan padat.
- Jangan menampilkan semua informasi sekaligus. Prioritaskan informasi yang membantu keputusan pengguna.
- Buat loading, empty, error, success, disabled, dan offline states.
- Jangan menggunakan warna sebagai satu-satunya penanda status.
- Pastikan layout tetap baik pada layar kecil, teks panjang, dan ukuran font besar.
- Jangan menambahkan animasi dekoratif yang mengganggu atau memperlambat.

## 5. Aturan desain produk
SkillBridge bukan job portal, course marketplace, atau chatbot umum. Produk ini membantu pengguna memahami target karier, menilai kompetensi, mengetahui gap, belajar melalui roadmap, menunjukkan bukti kemampuan, dan mengelola lamaran.

AI adalah pendukung personalisasi, bukan sumber kebenaran tunggal. Skill gap dihitung secara deterministik oleh backend. AI boleh menjelaskan dan menyusun rekomendasi berdasarkan data serta katalog yang telah disetujui.

## 6. Penanganan ketidakjelasan
Jika detail kecil belum ditentukan, gunakan pilihan paling sederhana yang konsisten dengan dokumen dan tulis asumsi. Jika keputusan memengaruhi skema database, kontrak API, keamanan, biaya AI, atau alur utama, tanyakan/ajukan opsi sebelum mengimplementasikan.

## 7. Format laporan akhir
- Ringkasan perubahan.
- File yang dibuat/diubah.
- Keputusan teknis penting.
- Perintah pemeriksaan yang dijalankan dan hasilnya.
- Kekurangan atau risiko yang masih ada.
- Langkah berikutnya yang paling relevan.

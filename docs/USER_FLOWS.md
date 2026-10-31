# User Flows

## 1. Onboarding and authentication
1. Pengguna membuka aplikasi.
2. Melihat value proposition singkat.
3. Login atau membuat akun.
4. Setelah autentikasi, masuk ke dashboard/onboarding sesuai status akun.

Acceptance:
- Form memiliki validasi.
- Loading dan error ditampilkan.
- Password tidak pernah ditampilkan atau dicatat di log.
- Token disimpan dengan mekanisme penyimpanan aman.

## 2. Career goal
1. Pengguna melihat daftar career.
2. Mencari atau memilih career.
3. Membaca ringkasan peran dan kompetensi.
4. Menetapkan career sebagai target.

Acceptance:
- Career berasal dari backend.
- Pengguna dapat melihat deskripsi dan skill yang relevan.
- State target tersimpan dan dapat dimuat kembali.

## 3. Skill assessment
1. Sistem menampilkan skill yang relevan dengan career.
2. Pengguna menjawab pertanyaan atau memilih level sesuai metode assessment yang disepakati.
3. Pengguna meninjau jawaban.
4. Pengguna mengirim assessment.
5. Backend menyimpan hasil dan timestamp.

Acceptance:
- Skala level konsisten.
- Pengguna memahami arti level.
- Pertanyaan dan jawaban tervalidasi.
- Assessment yang belum selesai tidak dianggap sebagai hasil final.

## 4. Skill gap
1. Backend membandingkan current level dan target level.
2. Aplikasi menampilkan ringkasan gap.
3. Pengguna membuka detail per skill.
4. Aplikasi menjelaskan prioritas dan rekomendasi tindakan.

Acceptance:
- Current level, target level, dan gap terlihat.
- Unassessed dibedakan dari beginner.
- AI tidak mengubah angka perhitungan backend.

## 5. Learning roadmap
1. Pengguna meminta roadmap.
2. Backend menyusun input dari career, hasil assessment, preferensi, dan katalog resource.
3. AI menghasilkan struktur terkontrol atau sistem menggunakan fallback.
4. Backend memvalidasi output.
5. Roadmap ditampilkan per tahap dan tugas.

Acceptance:
- Tidak ada resource ID/URL yang tidak dikenal.
- Tiap task memiliki tujuan dan completion criteria.
- Pengguna dapat memahami estimasi waktu.
- Error AI tidak membuat aplikasi crash.

## 6. Learning progress
1. Pengguna membuka task.
2. Membaca tujuan dan resource.
3. Melakukan aktivitas belajar.
4. Mengubah status progress.
5. Dashboard memperbarui ringkasan.

Acceptance:
- Status konsisten dan tersimpan.
- Progress hanya berubah berdasarkan tindakan yang tercatat.
- Pengguna dapat melanjutkan task yang belum selesai.

## 7. Portfolio evidence
1. Pengguna menambahkan item.
2. Menghubungkan item dengan skill.
3. Menambahkan deskripsi dan URL/file.
4. Memilih visibility.
5. Menyimpan item.

Acceptance:
- Privat secara default.
- Label "verified" hanya digunakan jika ada proses verifikasi nyata.

## 8. Job application tracker
1. Pengguna menambahkan perusahaan dan posisi.
2. Mengisi tanggal/status/next action jika tersedia.
3. Memperbarui status saat proses berjalan.
4. Melihat daftar dan filter lamaran.

Status awal yang diusulkan: `saved`, `applied`, `assessment`, `interview`, `offer`, `rejected`, `withdrawn`. Validasi transisi perlu ditetapkan di backend.

## 9. Navigation guidance
Gunakan navigasi utama yang ringkas. Usulan awal:
- Home
- Roadmap
- Portfolio
- Applications
- Profile

Career goal dan assessment dapat menjadi onboarding/entry flow atau bagian dari Home. Jangan menambahkan tab hanya untuk menampung fitur yang belum dibutuhkan.

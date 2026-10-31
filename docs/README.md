# SkillBridge — Project Documentation

**Product tagline:** Learn the Skills. Prove Them. Get Hired.

Dokumentasi ini adalah sumber acuan utama untuk AI coding agent (termasuk Codex) dan seluruh anggota tim. Baca dokumen yang relevan sebelum membuat atau mengubah kode.

## Tujuan dokumen
- Menjaga implementasi tetap sesuai tujuan produk.
- Menyamakan arsitektur Flutter, Laravel, database, dan AI.
- Menjaga konsistensi UI/UX.
- Mencegah agent membuat fitur, dependency, endpoint, atau desain yang tidak disepakati.
- Menjadi dasar acceptance criteria dan pengujian.

## Struktur repository yang dituju

```text
skillbridge/
├── docs/
│   ├── README.md
│   ├── CODEX_RULES.md
│   ├── PRODUCT_SPEC.md
│   ├── USER_FLOWS.md
│   ├── UI_DESIGN_SYSTEM.md
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── DATABASE_DESIGN.md
│   ├── API_CONTRACT.md
│   ├── AI_BEHAVIOR.md
│   ├── DEVELOPMENT_STANDARDS.md
│   ├── MVP_SCOPE.md
│   └── TESTING_AND_ACCEPTANCE.md
├── flutter_frontend/
├── laravel_backend/
└── README.md
```

Folder `flutter_frontend` dan `laravel_backend` merupakan direktori proyek aplikasi. Dokumentasi ini tidak mengasumsikan keduanya sudah dibuat atau sudah berisi kode.

## Urutan membaca untuk AI agent
1. `CODEX_RULES.md` — wajib dibaca sebelum bekerja.
2. `PRODUCT_SPEC.md` dan `MVP_SCOPE.md` — pahami tujuan dan batas fitur.
3. `UI_DESIGN_SYSTEM.md` dan `USER_FLOWS.md` — sebelum membuat UI.
4. `SYSTEM_ARCHITECTURE.md` — sebelum perubahan lintas frontend/backend.
5. `API_CONTRACT.md` dan `DATABASE_DESIGN.md` — sebelum integrasi atau perubahan data.
6. `AI_BEHAVIOR.md` — sebelum mengerjakan fitur AI.
7. `DEVELOPMENT_STANDARDS.md` dan `TESTING_AND_ACCEPTANCE.md` — selama implementasi dan sebelum menyatakan selesai.

## Aturan perubahan dokumen
Jika implementasi mengubah keputusan produk, endpoint, field, status, desain, atau alur:
1. Jangan diam-diam mengubah keputusan.
2. Jelaskan konflik atau kebutuhan perubahan.
3. Perbarui dokumen terkait setelah keputusan disetujui.
4. Pastikan frontend, backend, dan pengujian memakai kontrak terbaru.

## Status keputusan
Dokumen ini memisahkan:
- **Keputusan awal:** arahan yang sudah ditetapkan untuk proyek.
- **Usulan:** rekomendasi yang harus diperiksa terhadap repository dan disepakati sebelum implementasi.
- **Belum ditentukan:** agent tidak boleh mengarang; gunakan asumsi paling kecil dan tandai untuk konfirmasi jika berdampak besar.

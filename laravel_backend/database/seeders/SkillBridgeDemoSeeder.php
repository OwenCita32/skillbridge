<?php

namespace Database\Seeders;

use App\Models\Career;
use App\Models\CareerSkillRequirement;
use App\Models\LearningResource;
use App\Models\Skill;
use Illuminate\Database\Seeder;

class SkillBridgeDemoSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedUiUxDesigner();
        $this->seedCybersecurity();
    }

    private function seedUiUxDesigner(): void
    {
        $career = Career::updateOrCreate(
            ['slug' => 'ui-ux-designer'],
            [
                'title' => 'Freelance UI/UX Designer',
                'summary' => 'Merancang antarmuka aplikasi intuitif, wireframe, prototipe interaktif, dan sistem desain untuk klien.',
                'description' => 'Jalur ini menyiapkan kemampuan desain visual, prototyping Figma interaktif, dan riset UX praktis untuk kebutuhan proyek freelance.',
                'is_demo' => true,
            ],
        );

        $skillDefinitions = [
            'visual-design' => ['Visual Design', 'Fondasi tata letak visual, tipografi, warna, dan komponen UI siap pakai.', 'design', 4],
            'prototyping' => ['Prototyping Interaktif', 'Membuat prototipe alur aplikasi yang bisa diklik dan diuji langsung oleh klien.', 'prototyping', 4],
            'ux-research' => ['UX Research Praktis', 'Riset kebutuhan pengguna, usability testing sederhana, dan pemetaan alur persona.', 'research', 3],
            'design-systems' => ['Design System & Tokens', 'Menyusun komponen reusable, token warna/spasi, dan dokumentasi aset.', 'design_systems', 3],
            'client-pitching' => ['Portofolio & Pitching Klien', 'Menyusun studi kasus portofolio dan proposal penawaran proyek freelance.', 'freelance', 3],
        ];

        $skills = [];
        foreach ($skillDefinitions as $slug => [$name, $description, $category, $targetLevel]) {
            $skills[$slug] = Skill::updateOrCreate(
                ['slug' => $slug],
                ['name' => $name, 'description' => $description, 'category' => $category, 'is_demo' => true],
            );

            CareerSkillRequirement::updateOrCreate(
                ['career_id' => $career->id, 'skill_id' => $skills[$slug]->id],
                ['target_level' => $targetLevel],
            );
        }

        $resources = [
            [
                'skill' => 'visual-design',
                'title' => 'Figma Learn: Visual Design Foundations',
                'description' => 'Materi panduan dasar tata letak, warna, dan hierarki visual dalam Figma.',
                'category' => 'Visual Design',
                'type' => 'tutorial',
                'url' => 'https://help.figma.com/hc/en-us/categories/360002042553-Figma-design',
                'source' => 'Figma Learn',
            ],
            [
                'skill' => 'prototyping',
                'title' => 'Figma Prototyping Guide',
                'description' => 'Tutorial resmi membuat smart animate, interaksi komponen, dan transisi layar interaktif.',
                'category' => 'Prototyping',
                'type' => 'video',
                'url' => 'https://help.figma.com/hc/en-us/sections/360006651914-Prototypes',
                'source' => 'Figma Learn',
            ],
            [
                'skill' => 'ux-research',
                'title' => 'Practical UX Research Methods',
                'description' => 'Panduan cepat usability test dan wawancara pengguna untuk validasi ide desain.',
                'category' => 'UX Research',
                'type' => 'guide',
                'url' => 'https://www.nngroup.com/articles/which-ux-research-methods/',
                'source' => 'Nielsen Norman Group',
            ],
            [
                'skill' => 'design-systems',
                'title' => 'Building Design Systems in Figma',
                'description' => 'Praktik terbaik varian komponen, auto layout, dan variabel design token.',
                'category' => 'Design Systems',
                'type' => 'tutorial',
                'url' => 'https://help.figma.com/hc/en-us/articles/360040451373-Create-components-to-reuse-in-designs',
                'source' => 'Figma Learn',
            ],
            [
                'skill' => 'prototyping',
                'title' => 'Tonton: Figma Auto Layout',
                'description' => 'Konsep frame, auto layout, padding, gap, dan membuat tombol & card responsif.',
                'category' => 'Prototyping',
                'type' => 'video',
                'url' => 'https://help.figma.com/hc/en-us/articles/360040451373-Auto-layout',
                'source' => 'Figma Learn',
            ],
            [
                'skill' => 'client-pitching',
                'title' => 'Update case study portofolio',
                'description' => 'Perbarui case study Travel App dengan menambahkan bagian proses riset dan hasil usability test.',
                'category' => 'Portofolio',
                'type' => 'praktik',
                'url' => 'https://skillbridge.test/practice/case-study',
                'source' => 'SkillBridge Studio',
            ],
            [
                'skill' => 'client-pitching',
                'title' => 'Baca artikel pricing freelance',
                'description' => 'Cara Menentukan Harga Jasa Desain Pertamamu dan rumus menghitung rate proyek.',
                'category' => 'Freelance',
                'type' => 'bacaan',
                'url' => 'https://skillbridge.test/articles/freelance-pricing',
                'source' => 'Freelance Academy',
            ],
        ];

        foreach ($resources as $resource) {
            $skill = $skills[$resource['skill']];
            unset($resource['skill']);

            LearningResource::updateOrCreate(
                ['url' => $resource['url']],
                [
                    ...$resource,
                    'skill_id' => $skill->id,
                    'verified_at' => '2026-10-31',
                    'is_active' => true,
                    'is_demo' => true,
                ],
            );
        }
    }

    private function seedCybersecurity(): void
    {
        $career = Career::updateOrCreate(
            ['slug' => 'cybersecurity-analyst'],
            [
                'title' => 'Cybersecurity Analyst',
                'summary' => 'Contoh profil karier demo untuk mempelajari analisis keamanan.',
                'description' => 'Profil demonstrasi ini memetakan kompetensi awal untuk Cybersecurity Analyst. Target level merupakan data contoh yang perlu ditinjau, bukan standar universal atau jaminan kualifikasi kerja.',
                'is_demo' => true,
            ],
        );

        $skillDefinitions = [
            'networking-fundamentals' => ['Networking fundamentals', 'Memahami perangkat, protokol, alamat IP, dan aliran data jaringan.', 'networking', 3],
            'linux-fundamentals' => ['Linux fundamentals', 'Menggunakan terminal dan perintah dasar sistem Linux.', 'operating_systems', 3],
            'security-concepts' => ['Security concepts', 'Memahami risiko, kerentanan, kontrol keamanan, dan praktik aman.', 'security', 4],
            'log-analysis-siem' => ['Log analysis dan SIEM', 'Mencari, membaca, dan menghubungkan peristiwa log menggunakan SIEM.', 'security_operations', 3],
            'alert-triage' => ['Alert triage', 'Menilai prioritas dan ruang lingkup alert sebelum investigasi lanjutan.', 'security_operations', 3],
            'basic-scripting' => ['Basic scripting', 'Menggunakan skrip sederhana untuk membaca dan mengolah data.', 'scripting', 2],
            'technical-documentation' => ['Technical documentation', 'Mencatat temuan teknis secara jelas, terstruktur, dan dapat ditinjau.', 'communication', 3],
        ];

        $skills = [];

        foreach ($skillDefinitions as $slug => [$name, $description, $category, $targetLevel]) {
            $skills[$slug] = Skill::updateOrCreate(
                ['slug' => $slug],
                ['name' => $name, 'description' => $description, 'category' => $category, 'is_demo' => true],
            );

            CareerSkillRequirement::updateOrCreate(
                ['career_id' => $career->id, 'skill_id' => $skills[$slug]->id],
                ['target_level' => $targetLevel],
            );
        }

        $resources = [
            [
                'skill' => 'networking-fundamentals',
                'title' => 'Networking Basics',
                'description' => 'Kursus mandiri Cisco Networking Academy tentang dasar jaringan, perangkat, media, dan protokol.',
                'category' => 'Networking',
                'type' => 'course',
                'url' => 'https://www.netacad.com/courses/networking-basics/how-routers-work',
                'source' => 'Cisco Networking Academy',
            ],
            [
                'skill' => 'linux-fundamentals',
                'title' => 'The Linux command line for beginners',
                'description' => 'Tutorial resmi Ubuntu dengan latihan untuk navigasi terminal dan manipulasi file dasar.',
                'category' => 'Linux',
                'type' => 'tutorial',
                'url' => 'https://ubuntu.com/desktop/docs/en/latest/tutorial/the-linux-command-line-for-beginners/',
                'source' => 'Ubuntu Documentation',
            ],
            [
                'skill' => 'security-concepts',
                'title' => 'OWASP Top 10:2025',
                'description' => 'Dokumen awareness OWASP tentang risiko keamanan aplikasi web yang umum.',
                'category' => 'Security concepts',
                'type' => 'reference',
                'url' => 'https://top10.owasp.org/',
                'source' => 'OWASP Foundation',
            ],
            [
                'skill' => 'log-analysis-siem',
                'title' => 'Free Splunk training courses',
                'description' => 'Katalog pelatihan resmi yang mencakup kursus pengantar Splunk, event, pencarian, dan dashboard.',
                'category' => 'SIEM and log analysis',
                'type' => 'course_catalog',
                'url' => 'https://www.splunk.com/en_us/training/free-courses/overview.html',
                'source' => 'Splunk Education',
            ],
            [
                'skill' => 'alert-triage',
                'title' => 'Navigate, triage, and manage Microsoft Sentinel incidents',
                'description' => 'Panduan resmi untuk memfilter insiden, menilai severity, menetapkan owner, dan mengelola triage.',
                'category' => 'Incident response',
                'type' => 'guide',
                'url' => 'https://learn.microsoft.com/en-us/azure/sentinel/incident-navigate-triage',
                'source' => 'Microsoft Learn',
            ],
            [
                'skill' => 'basic-scripting',
                'title' => 'The Python Tutorial',
                'description' => 'Tutorial resmi Python untuk mempelajari dasar bahasa dan menulis program kecil.',
                'category' => 'Scripting',
                'type' => 'tutorial',
                'url' => 'https://docs.python.org/3/tutorial/',
                'source' => 'Python Software Foundation',
            ],
        ];

        foreach ($resources as $resource) {
            $skill = $skills[$resource['skill']];
            unset($resource['skill']);

            LearningResource::updateOrCreate(
                ['url' => $resource['url']],
                [
                    ...$resource,
                    'skill_id' => $skill->id,
                    'verified_at' => '2026-10-31',
                    'is_active' => true,
                    'is_demo' => true,
                ],
            );
        }
    }
}

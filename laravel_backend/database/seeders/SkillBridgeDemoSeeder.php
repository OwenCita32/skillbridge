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
                'description' => 'Kursus mandiri Cisco Networking Academy tentang dasar jaringan, perangkat, media, dan protokol. Pendaftaran mungkin diperlukan.',
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
                'description' => 'Dokumen awareness OWASP tentang risiko keamanan aplikasi web yang umum; materi pengantar, bukan daftar lengkap keamanan.',
                'category' => 'Security concepts',
                'type' => 'reference',
                'url' => 'https://top10.owasp.org/',
                'source' => 'OWASP Foundation',
            ],
            [
                'skill' => 'log-analysis-siem',
                'title' => 'Free Splunk training courses',
                'description' => 'Katalog pelatihan resmi yang mencakup kursus pengantar Splunk, event, pencarian, dan dashboard. Akses kursus dapat meminta pendaftaran.',
                'category' => 'SIEM and log analysis',
                'type' => 'course_catalog',
                'url' => 'https://www.splunk.com/en_us/training/free-courses/overview.html',
                'source' => 'Splunk Education',
            ],
            [
                'skill' => 'alert-triage',
                'title' => 'Navigate, triage, and manage Microsoft Sentinel incidents',
                'description' => 'Panduan resmi untuk memfilter insiden, menilai severity, menetapkan owner, dan mengelola triage. Akses portal memerlukan akun dan peran yang sesuai.',
                'category' => 'Incident response',
                'type' => 'guide',
                'url' => 'https://learn.microsoft.com/en-us/azure/sentinel/incident-navigate-triage',
                'source' => 'Microsoft Learn',
            ],
            [
                'skill' => 'basic-scripting',
                'title' => 'The Python Tutorial',
                'description' => 'Tutorial resmi Python untuk mempelajari dasar bahasa dan menulis program kecil; mengasumsikan pembaca sudah mengenal pemrograman dasar.',
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

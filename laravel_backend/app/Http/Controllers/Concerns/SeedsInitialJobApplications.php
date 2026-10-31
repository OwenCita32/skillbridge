<?php

namespace App\Http\Controllers\Concerns;

trait SeedsInitialJobApplications
{
    private function seedInitialApplications($user): void
    {
        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();
        $days2Ago = now()->subDays(2)->toDateString();
        $days3Ago = now()->subDays(3)->toDateString();
        $days4Ago = now()->subDays(4)->toDateString();
        $days5Ago = now()->subDays(5)->toDateString();
        $days6Ago = now()->subDays(6)->toDateString();
        $days7Ago = now()->subDays(7)->toDateString();

        $items = [
            ['title' => 'Redesign landing page kopi', 'client_name' => 'Kopi Senja', 'budget' => 'Rp1.500.000', 'platform' => 'Sribulancer', 'status' => 'Menunggu', 'applied_date' => $today],
            ['title' => 'UI aplikasi kasir UMKM', 'client_name' => 'PT Niaga Kecil', 'budget' => 'Rp3.500.000', 'platform' => 'Projects.co.id', 'status' => 'Menunggu', 'applied_date' => $today],
            ['title' => 'Mobile app booking futsal', 'client_name' => 'Andi S.', 'budget' => 'Rp4.200.000', 'platform' => 'Upwork', 'status' => 'Menunggu', 'applied_date' => $today],
            ['title' => 'Dashboard analitik fintech', 'client_name' => 'FinSmart Labs', 'budget' => 'Rp6.000.000', 'platform' => 'Upwork', 'status' => 'Interview', 'applied_date' => $yesterday],
            ['title' => 'Design system e-commerce', 'client_name' => 'TokoRetail ID', 'budget' => 'Rp5.500.000', 'platform' => 'LinkedIn', 'status' => 'Interview', 'applied_date' => $days2Ago],
            ['title' => 'E-learning micro-learning UI', 'client_name' => 'EduTech Indo', 'budget' => 'Rp3.000.000', 'platform' => 'Projects.co.id', 'status' => 'Diterima', 'applied_date' => $days3Ago],
            ['title' => 'Icon set & banner marketing', 'client_name' => 'Agency Kreatif', 'budget' => 'Rp800.000', 'platform' => 'Fiverr', 'status' => 'Ditolak', 'applied_date' => $days4Ago],
            ['title' => 'Website profil arsitek', 'client_name' => 'Studio Rancang', 'budget' => 'Rp2.800.000', 'platform' => 'Sribulancer', 'status' => 'Ditolak', 'applied_date' => $days5Ago],
            ['title' => 'App fitness workout planner', 'client_name' => 'FitLife Global', 'budget' => 'Rp4.500.000', 'platform' => 'Upwork', 'status' => 'Ditolak', 'applied_date' => $days6Ago],
            ['title' => 'Landing page travel agency', 'client_name' => 'Liburan Yuk', 'budget' => 'Rp2.000.000', 'platform' => 'Projects.co.id', 'status' => 'Menunggu', 'applied_date' => $days7Ago],
            ['title' => 'Redesign website logistik', 'client_name' => 'Kargo Nusantara', 'budget' => 'Rp3.800.000', 'platform' => 'LinkedIn', 'status' => 'Menunggu', 'applied_date' => $days7Ago],
            ['title' => 'Mobile UI resto & cafe POS', 'client_name' => 'Bistro Harmoni', 'budget' => 'Rp2.500.000', 'platform' => 'Sribulancer', 'status' => 'Menunggu', 'applied_date' => $days7Ago],
        ];

        foreach ($items as $item) {
            $user->jobApplications()->create($item);
        }
    }
}


<?php

namespace App\Http\Controllers;

use App\Models\JobApplication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class JobApplicationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Seed initial demo applications if user has none
        if ($user->jobApplications()->count() === 0) {
            $this->seedInitialApplications($user);
        }

        $query = $user->jobApplications()->orderByDesc('applied_date')->orderByDesc('id');

        if ($request->filled('status') && $request->input('status') !== 'Semua') {
            $query->where('status', $request->input('status'));
        }

        $allApplications = $user->jobApplications()->get();
        $total = $allApplications->count();
        $todayStr = now()->toDateString();
        $todayCount = $allApplications->filter(function ($app) use ($todayStr) {
            return $app->applied_date?->toDateString() === $todayStr;
        })->count();

        $countMenunggu = $allApplications->where('status', 'Menunggu')->count();
        $countInterview = $allApplications->where('status', 'Interview')->count();
        $countDiterima = $allApplications->where('status', 'Diterima')->count();
        $countDitolak = $allApplications->where('status', 'Ditolak')->count();

        $respondedCount = $countInterview + $countDiterima + $countDitolak;
        $responseRate = $total > 0 ? (int) round(($respondedCount / $total) * 100) : 0;

        return response()->json([
            'summary' => [
                'today_count' => $todayCount,
                'today_target' => 5,
                'total_count' => $total,
                'count_menunggu' => $countMenunggu,
                'count_interview' => $countInterview,
                'count_diterima' => $countDiterima,
                'count_ditolak' => $countDitolak,
                'response_rate' => $responseRate,
            ],
            'applications' => $query->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'client_name' => ['nullable', 'string', 'max:255'],
            'platform' => ['required', 'string', 'max:100'],
            'budget' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'in:Menunggu,Interview,Diterima,Ditolak'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'applied_date' => ['nullable', 'date'],
        ]);

        $application = $request->user()->jobApplications()->create([
            'title' => $validated['title'],
            'client_name' => $validated['client_name'] ?? 'Klien Baru',
            'platform' => $validated['platform'],
            'budget' => $validated['budget'] ?? 'Fleksibel',
            'status' => $validated['status'] ?? 'Menunggu',
            'notes' => $validated['notes'] ?? null,
            'applied_date' => $validated['applied_date'] ?? now()->toDateString(),
        ]);

        return response()->json([
            'message' => 'Lamaran berhasil dicatat.',
            'application' => $application,
        ], 201);
    }

    public function updateStatus(Request $request, JobApplication $jobApplication): JsonResponse
    {
        if ($jobApplication->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:Menunggu,Interview,Diterima,Ditolak'],
        ]);

        $jobApplication->update(['status' => $validated['status']]);

        return response()->json([
            'message' => 'Status lamaran berhasil diperbarui.',
            'application' => $jobApplication,
        ]);
    }

    public function destroy(Request $request, JobApplication $jobApplication): JsonResponse
    {
        if ($jobApplication->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $jobApplication->delete();

        return response()->json(['message' => 'Lamaran berhasil dihapus.']);
    }

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

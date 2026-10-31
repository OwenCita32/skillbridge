<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\SeedsInitialJobApplications;
use App\Models\JobApplication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class JobApplicationController extends Controller
{
    use SeedsInitialJobApplications;

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
}

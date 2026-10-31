<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\SeedsInitialNotifications;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    use SeedsInitialNotifications;

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->notifications()->count() === 0) {
            $this->seedInitialNotifications($user);
        }

        $notifications = $user->notifications()
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        $unreadCount = $user->notifications()->unread()->count();

        $formatted = $notifications->map(function (UserNotification $item) {
            return [
                'id' => $item->id,
                'title' => $item->title,
                'message' => $item->message,
                'type' => $item->type,
                'action_type' => $item->action_type,
                'action_payload' => $item->action_payload,
                'read' => $item->isRead(),
                'read_at' => $item->read_at?->toISOString(),
                'created_at' => $item->created_at?->toISOString(),
                'created_at_human' => $item->created_at?->diffForHumans() ?? 'Baru saja',
            ];
        });

        return response()->json([
            'data' => $formatted,
            'unread_count' => $unreadCount,
        ]);
    }

    public function markAsRead(Request $request, UserNotification $notification): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $notification->markAsRead();

        $unreadCount = $request->user()->notifications()->unread()->count();

        return response()->json([
            'message' => 'Notifikasi ditandai telah dibaca',
            'unread_count' => $unreadCount,
        ]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $request->user()->notifications()->whereNull('read_at')->update(['read_at' => now()]);

        return response()->json([
            'message' => 'Semua notifikasi ditandai telah dibaca',
            'unread_count' => 0,
        ]);
    }

    public function destroy(Request $request, UserNotification $notification): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $notification->delete();

        $unreadCount = $request->user()->notifications()->unread()->count();

        return response()->json([
            'message' => 'Notifikasi berhasil dihapus',
            'unread_count' => $unreadCount,
        ]);
    }
}

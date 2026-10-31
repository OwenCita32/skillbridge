<?php

namespace App\Enums;

enum RoadmapItemStatus: string
{
    case NotStarted = 'not_started';
    case InProgress = 'in_progress';
    case Completed = 'completed';
    case Skipped = 'skipped';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(fn (self $status): string => $status->value, self::cases());
    }
}

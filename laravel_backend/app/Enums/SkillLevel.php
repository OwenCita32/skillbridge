<?php

namespace App\Enums;

enum SkillLevel: int
{
    case NotKnown = 0;
    case Beginner = 1;
    case Basic = 2;
    case Assisted = 3;
    case Independent = 4;
    case Proficient = 5;

    public function label(): string
    {
        return match ($this) {
            self::NotKnown => 'Belum mengenal',
            self::Beginner => 'Pemula',
            self::Basic => 'Memahami dasar',
            self::Assisted => 'Mampu mengerjakan dengan sedikit bantuan',
            self::Independent => 'Mampu mengerjakan secara mandiri',
            self::Proficient => 'Mahir',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::NotKnown => 'Belum pernah mempelajari atau berhadapan dengan konsep ini.',
            self::Beginner => 'Mulai mengenali istilah dan konsep, tetapi belum dapat menyelesaikan tugas dasar sendiri.',
            self::Basic => 'Memahami konsep dasar dan dapat menjelaskan istilah penting dengan contoh sederhana.',
            self::Assisted => 'Dapat menyelesaikan tugas umum dengan arahan atau bantuan sesekali.',
            self::Independent => 'Dapat merencanakan dan menyelesaikan tugas umum secara mandiri.',
            self::Proficient => 'Mampu menangani kasus kompleks, memilih pendekatan yang tepat, dan membimbing orang lain.',
        };
    }

    /** @return list<array{level: int, label: string, description: string}> */
    public static function definitions(): array
    {
        return array_map(fn (self $level): array => [
            'level' => $level->value,
            'label' => $level->label(),
            'description' => $level->description(),
        ], self::cases());
    }

    public static function gap(?int $currentLevel, int $targetLevel): ?int
    {
        return $currentLevel === null ? null : max(0, $targetLevel - $currentLevel);
    }
}

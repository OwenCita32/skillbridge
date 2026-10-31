<?php

namespace App\Services;

use App\Models\LearningResource;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class RoadmapRecommendationValidator
{
    /**
     * @param  array<string, mixed>  $candidate
     * @param  list<array<string, mixed>>  $eligibleSkillGaps
     * @param  Collection<int, LearningResource>  $approvedResources
     * @return array{summary: string, priorities: list<array<string, mixed>>}|null
     */
    public function validate(array $candidate, array $eligibleSkillGaps, Collection $approvedResources): ?array
    {
        if (! $this->hasOnlyKeys($candidate, ['summary', 'priorities'])) {
            return null;
        }

        $summary = $candidate['summary'] ?? null;
        $candidatePriorities = $candidate['priorities'] ?? null;
        if (! is_string($summary)
            || Str::length(trim($summary)) < 20
            || Str::length($summary) > 500
            || $this->containsGeneratedScore($summary)
            || ! is_array($candidatePriorities)
            || ! array_is_list($candidatePriorities)
            || count($candidatePriorities) !== count($eligibleSkillGaps)) {
            return null;
        }

        $eligibleSkills = collect($eligibleSkillGaps)->keyBy(fn (array $gap): int => (int) $gap['skill']->id);
        $resourceById = $approvedResources->keyBy('id');
        $validatedBySkill = [];
        $taskCount = 0;
        $totalHours = 0;

        foreach ($candidatePriorities as $priority) {
            if (! is_array($priority)
                || ! $this->hasOnlyKeys($priority, ['skill_id', 'reason', 'tasks'])
                || ! is_int($priority['skill_id'] ?? null)
                || ! $eligibleSkills->has($priority['skill_id'])
                || isset($validatedBySkill[$priority['skill_id']])) {
                return null;
            }

            $reason = $priority['reason'] ?? null;
            $tasks = $priority['tasks'] ?? null;
            if (! is_string($reason)
                || Str::length(trim($reason)) < 8
                || Str::length($reason) > 400
                || $this->containsGeneratedScore($reason)
                || ! is_array($tasks)
                || ! array_is_list($tasks)
                || count($tasks) < 1
                || count($tasks) > 3) {
                return null;
            }

            $validatedTasks = [];
            foreach ($tasks as $task) {
                if (! is_array($task)
                    || ! $this->hasOnlyKeys($task, ['title', 'description', 'estimated_hours', 'resource_ids', 'completion_criteria'])) {
                    return null;
                }

                $title = $task['title'] ?? null;
                $description = $task['description'] ?? null;
                $estimatedHours = $task['estimated_hours'] ?? null;
                $resourceIds = $task['resource_ids'] ?? null;
                $completionCriteria = $task['completion_criteria'] ?? null;

                if (! is_string($title)
                    || Str::length(trim($title)) < 3
                    || Str::length($title) > 120
                    || ! is_string($description)
                    || Str::length(trim($description)) < 8
                    || Str::length($description) > 700
                    || ! is_int($estimatedHours)
                    || $estimatedHours < 1
                    || $estimatedHours > 12
                    || ! is_array($resourceIds)
                    || ! array_is_list($resourceIds)
                    || count($resourceIds) > 3
                    || count(array_filter($resourceIds, 'is_int')) !== count($resourceIds)
                    || ! is_string($completionCriteria)
                    || Str::length(trim($completionCriteria)) < 8
                    || Str::length($completionCriteria) > 500
                    || $this->containsGeneratedScore($title.' '.$description.' '.$completionCriteria)) {
                    return null;
                }

                if (count($resourceIds) !== count(array_unique($resourceIds, SORT_REGULAR))) {
                    return null;
                }

                foreach ($resourceIds as $resourceId) {
                    $resource = is_int($resourceId) ? $resourceById->get($resourceId) : null;
                    if ($resource === null || (int) $resource->skill_id !== $priority['skill_id']) {
                        return null;
                    }
                }

                $validatedTasks[] = [
                    'title' => trim($title),
                    'description' => trim($description),
                    'estimated_hours' => $estimatedHours,
                    'resource_ids' => array_values($resourceIds),
                    'completion_criteria' => trim($completionCriteria),
                ];
                $taskCount++;
                $totalHours += $estimatedHours;
            }

            $validatedBySkill[$priority['skill_id']] = [
                'skill_id' => $priority['skill_id'],
                'reason' => trim($reason),
                'tasks' => $validatedTasks,
            ];
        }

        if (count($validatedBySkill) !== $eligibleSkills->count() || $taskCount > 20 || $totalHours > 60) {
            return null;
        }

        $orderedPriorities = [];
        foreach ($eligibleSkillGaps as $skillGap) {
            $orderedPriorities[] = $validatedBySkill[(int) $skillGap['skill']->id];
        }

        return ['summary' => trim($summary), 'priorities' => $orderedPriorities];
    }

    /** @param array<string, mixed> $value
     * @param  list<string>  $expected
     */
    private function hasOnlyKeys(array $value, array $expected): bool
    {
        $keys = array_keys($value);
        sort($keys);
        sort($expected);

        return $keys === $expected;
    }

    private function containsGeneratedScore(string $text): bool
    {
        return preg_match('/\d/u', $text) === 1;
    }
}

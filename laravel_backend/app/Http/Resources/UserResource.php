<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'headline' => $this->headline,
            'github_username' => $this->github_username,
            'github_repos' => $this->github_repos,
            'linkedin_url' => $this->linkedin_url,
            'bio' => $this->bio,
            'avatar_url' => $this->avatar_url,
            'career_goal' => $this->whenLoaded('careerGoal', fn (): ?array => $this->careerGoal === null
                ? null
                : [
                    'career_id' => $this->careerGoal->career_id,
                    'career_title' => $this->careerGoal->career->title,
                ]),
        ];
    }
}

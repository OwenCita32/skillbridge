<?php

namespace App\Http\Controllers;

use App\Http\Resources\SkillResource;
use App\Models\Skill;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class SkillController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return SkillResource::collection(Skill::query()->orderBy('name')->paginate(100))
            ->additional(['message' => 'Daftar skill berhasil dimuat.']);
    }
}

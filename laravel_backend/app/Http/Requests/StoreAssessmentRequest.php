<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAssessmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'answers' => ['required', 'array', 'min:1'],
            'answers.*.skill_id' => ['required', 'integer', 'distinct', 'exists:skills,id'],
            'answers.*.level' => ['required', 'integer', Rule::in(range(0, 5))],
        ];
    }

    /** @return array<string, string> */
    public function messages(): array
    {
        return [
            'answers.required' => 'Nilai setiap skill wajib dikirim.',
            'answers.*.skill_id.required' => 'Setiap jawaban harus memilih skill.',
            'answers.*.skill_id.exists' => 'Skill yang dipilih tidak tersedia.',
            'answers.*.skill_id.distinct' => 'Setiap skill hanya boleh dinilai satu kali.',
            'answers.*.level.required' => 'Pilih level kemampuan untuk setiap skill.',
            'answers.*.level.integer' => 'Level harus berupa angka.',
            'answers.*.level.in' => 'Pilih level kemampuan dari 0 sampai 5.',
        ];
    }
}

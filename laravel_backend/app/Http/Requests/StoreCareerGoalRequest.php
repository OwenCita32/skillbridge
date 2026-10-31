<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreCareerGoalRequest extends FormRequest
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
            'career_id' => ['required_without:career_title', 'nullable', 'integer', 'exists:careers,id'],
            'career_title' => ['required_without:career_id', 'nullable', 'string', 'min:2', 'max:100'],
        ];
    }

    /** @return array<string, string> */
    public function messages(): array
    {
        return [
            'career_id.required_without' => 'Pilih dari daftar atau ketik target karier impianmu.',
            'career_title.required_without' => 'Pilih dari daftar atau ketik target karier impianmu.',
            'career_id.exists' => 'Karier yang dipilih tidak tersedia.',
            'career_title.min' => 'Nama target karier minimal 2 karakter.',
            'career_title.max' => 'Nama target karier maksimal 100 karakter.',
        ];
    }
}

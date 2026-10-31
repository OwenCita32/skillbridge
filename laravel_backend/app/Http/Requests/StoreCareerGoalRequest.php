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
            'career_id' => ['required', 'integer', 'exists:careers,id'],
        ];
    }

    /** @return array<string, string> */
    public function messages(): array
    {
        return [
            'career_id.required' => 'Pilih target karier.',
            'career_id.exists' => 'Karier yang dipilih tidak tersedia.',
        ];
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('job_applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('client_name')->default('Klien');
            $table->string('platform')->default('Upwork');
            $table->string('budget')->default('Rp0');
            $table->enum('status', ['Menunggu', 'Interview', 'Diterima', 'Ditolak'])->default('Menunggu');
            $table->text('notes')->nullable();
            $table->date('applied_date')->default(now()->toDateString());
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index(['user_id', 'applied_date']);
        });

        Schema::create('portfolio_submissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('roadmap_item_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->string('submission_link')->nullable();
            $table->json('checklist_completed')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'roadmap_item_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('portfolio_submissions');
        Schema::dropIfExists('job_applications');
    }
};


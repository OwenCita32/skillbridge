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
        Schema::create('learning_resource_roadmap_item', function (Blueprint $table) {
            $table->foreignId('roadmap_item_id')->constrained()->cascadeOnDelete();
            $table->foreignId('learning_resource_id')->constrained()->restrictOnDelete();
            $table->primary(['roadmap_item_id', 'learning_resource_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('learning_resource_roadmap_item');
    }
};

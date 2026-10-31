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
        Schema::table('users', function (Blueprint $table) {
            $table->string('headline')->nullable()->after('name');
            $table->string('github_username')->nullable()->after('headline');
            $table->json('github_repos')->nullable()->after('github_username');
            $table->string('linkedin_url')->nullable()->after('github_repos');
            $table->text('bio')->nullable()->after('linkedin_url');
            $table->string('avatar_url')->nullable()->after('bio');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'headline',
                'github_username',
                'github_repos',
                'linkedin_url',
                'bio',
                'avatar_url',
            ]);
        });
    }
};


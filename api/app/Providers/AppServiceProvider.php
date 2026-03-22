<?php

namespace App\Providers;

use App\Policies\TaskPolicy;
use App\Models\Task;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        $this->gate();
    }

    protected function gate(): void
    {
        //
    }
}

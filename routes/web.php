<?php

use App\Http\Livewire\CrudFixture;
use App\Http\Livewire\CrudGame;
use App\Http\Livewire\CrudPlayer;
use App\Http\Livewire\CrudTeam;
use App\Http\Livewire\StatLivewire;
use App\Http\Livewire\Web\PositionsLivewire;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Health check endpoint for load balancer
Route::get('/health', function () {
    return response()->json(['status' => 'healthy'], 200);
});

Route::middleware([
    'auth:sanctum',
    config('jetstream.auth_session'),
    'verified'
])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');
    Route::get('/games',CrudGame::class)->name('games');
    Route::get('/teams',CrudTeam::class)->name('teams');
    Route::get('/fixtures',CrudFixture::class)->name('fixtures');
    Route::get('/players',CrudPlayer::class)->name('players');
    Route::get('/stats',StatLivewire::class)->name('stats');
    Route::get('/stats-create/{id}/type',[StatLivewire::class,'create'])->name('stats-create');
});

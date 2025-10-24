<?php

use App\Http\Controllers\PhotoController;
use Illuminate\Support\Facades\Route;

Route::controller(PhotoController::class)->group(function () {
    Route::get('/', 'index');
    Route::post('/upload', 'store')->name('upload');
});
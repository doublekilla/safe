<?php

use App\Http\Controllers\BookingController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CustomerDashboardController;
use App\Http\Controllers\FaqController;
use App\Http\Controllers\MidtransWebhookController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RescheduleController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\VenueController;
use App\Http\Controllers\Admin;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::get('/', function () {
    $featuredVenues = \App\Models\Venue::active()
        ->withCount(['reviews' => function ($query) {
            $query->where('is_visible', true);
        }])
        ->withAvg(['reviews' => function ($query) {
            $query->where('is_visible', true);
        }], 'rating')
        ->take(6)
        ->get()
        ->map(function (\App\Models\Venue $venue) {
            $venue->average_rating = round($venue->reviews_avg_rating ?? 0, 1);
            $venue->review_count = $venue->reviews_count ?? 0;
            return $venue;
        });

    $faqs = \App\Models\Faq::active()->ordered()->take(6)->get();

    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'featuredVenues' => $featuredVenues,
        'faqs' => $faqs,
    ]);
})->name('home');

// Public venue browsing
Route::get('/venues', [VenueController::class, 'index'])->name('venues.index');
Route::get('/venues/{venue}', [VenueController::class, 'show'])->name('venues.show');
Route::get('/faq', [FaqController::class, 'index'])->name('faq.index');

// API routes (public)
Route::get('/api/schedules/available', [ScheduleController::class, 'getAvailable'])->name('schedules.available');
Route::get('/api/schedules/field/{venueField}', [ScheduleController::class, 'getFieldSchedules'])->name('schedules.field');
Route::get('/api/venues/{venue}/reviews', [ReviewController::class, 'venueReviews'])->name('venues.reviews');

// Midtrans webhook (public, no auth, no CSRF)
Route::post('/midtrans/notification', [MidtransWebhookController::class, 'handle'])->name('midtrans.notification');

/*
|--------------------------------------------------------------------------
| Customer Routes (authenticated)
|--------------------------------------------------------------------------
*/
Route::middleware('auth')->group(function () {
    // Customer Dashboard
    Route::get('/dashboard', [CustomerDashboardController::class, 'index'])->name('customer.dashboard');

    // Legacy dashboard route
    Route::get('/dashboard-legacy', function () {
        return redirect()->route('customer.dashboard');
    })->name('dashboard');

    // Cart
    Route::get('/cart', [CartController::class, 'index'])->name('cart.index');
    Route::post('/cart/add', [CartController::class, 'add'])->name('cart.add');
    Route::delete('/cart/{cartItem}', [CartController::class, 'remove'])->name('cart.remove');
    Route::delete('/cart', [CartController::class, 'clear'])->name('cart.clear');
    Route::get('/api/cart/count', [CartController::class, 'count'])->name('cart.count');

    // Checkout & Bookings
    Route::get('/checkout', [BookingController::class, 'checkout'])->name('checkout.index');
    Route::post('/bookings', [BookingController::class, 'store'])->name('bookings.store');
    Route::get('/bookings', [BookingController::class, 'index'])->name('bookings.index');
    Route::get('/bookings/{booking}', [BookingController::class, 'show'])->name('bookings.show');
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancel'])->name('bookings.cancel');

    // Reschedule
    Route::get('/bookings/{booking}/reschedule', [RescheduleController::class, 'show'])->name('reschedule.show');
    Route::post('/bookings/{booking}/reschedule', [RescheduleController::class, 'store'])->name('reschedule.store');

    // Payment
    Route::get('/payments/{booking}', [PaymentController::class, 'show'])->name('payments.show');
    Route::post('/payments/{booking}/pay', [PaymentController::class, 'pay'])->name('payments.pay');
    Route::post('/payments/{booking}/confirm-snap', [PaymentController::class, 'confirmFromSnap'])->name('payments.confirm-snap');
    Route::get('/api/payments/{payment}/status', [PaymentController::class, 'checkStatus'])->name('payments.status');

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store'])->name('reviews.store');

    // Profile
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

/*
|--------------------------------------------------------------------------
| Admin Routes (authenticated + admin role)
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    // Dashboard
    Route::get('/dashboard', [Admin\DashboardController::class, 'index'])->name('dashboard');

    // Venues
    Route::resource('venues', Admin\VenueController::class);
    Route::get('/venues/{venue}/fields', [Admin\VenueController::class, 'fields'])->name('venues.fields');
    Route::post('/venues/{venue}/fields', [Admin\VenueController::class, 'storeField'])->name('venues.fields.store');
    Route::put('/fields/{field}', [Admin\VenueController::class, 'updateField'])->name('fields.update');
    Route::delete('/fields/{field}', [Admin\VenueController::class, 'destroyField'])->name('fields.destroy');

    // Schedules
    Route::get('/schedules', [Admin\ScheduleController::class, 'index'])->name('schedules.index');
    Route::post('/schedules/generate', [Admin\ScheduleController::class, 'generate'])->name('schedules.generate');
    Route::put('/schedules/{schedule}/status', [Admin\ScheduleController::class, 'updateStatus'])->name('schedules.update-status');
    Route::post('/schedules/bulk-update', [Admin\ScheduleController::class, 'bulkUpdate'])->name('schedules.bulk-update');
    Route::post('/schedules/open-all', [Admin\ScheduleController::class, 'openAll'])->name('schedules.open-all');
    Route::post('/schedules/block-all', [Admin\ScheduleController::class, 'blockAll'])->name('schedules.block-all');
    Route::post('/schedules/block-range', [Admin\ScheduleController::class, 'blockRange'])->name('schedules.block-range');
    Route::delete('/schedules/{schedule}', [Admin\ScheduleController::class, 'destroy'])->name('schedules.destroy');

    // Bookings
    Route::get('/bookings', [Admin\BookingController::class, 'index'])->name('bookings.index');
    Route::get('/bookings/manual-create', [Admin\BookingController::class, 'manualCreate'])->name('bookings.manual-create');
    Route::post('/bookings/manual-store', [Admin\BookingController::class, 'manualStore'])->name('bookings.manual-store');
    Route::get('/bookings/{booking}', [Admin\BookingController::class, 'show'])->name('bookings.show');
    Route::put('/bookings/{booking}/status', [Admin\BookingController::class, 'updateStatus'])->name('bookings.update-status');

    // Payments
    Route::get('/payments', [Admin\PaymentController::class, 'index'])->name('payments.index');
    Route::get('/payments/{payment}', [Admin\PaymentController::class, 'show'])->name('payments.show');
    Route::post('/payments/{payment}/verify', [Admin\PaymentController::class, 'verify'])->name('payments.verify');
    Route::post('/payments/{payment}/reject', [Admin\PaymentController::class, 'reject'])->name('payments.reject');
    Route::post('/payments/{payment}/refund', [Admin\PaymentController::class, 'refund'])->name('payments.refund');

    // Reviews
    Route::get('/reviews', [Admin\ReviewController::class, 'index'])->name('reviews.index');
    Route::post('/reviews/{review}/reply', [Admin\ReviewController::class, 'reply'])->name('reviews.reply');
    Route::put('/reviews/{review}/toggle-visibility', [Admin\ReviewController::class, 'toggleVisibility'])->name('reviews.toggle-visibility');

    // CMS
    Route::get('/cms', [Admin\CmsController::class, 'index'])->name('cms.index');
    Route::post('/cms/content', [Admin\CmsController::class, 'storeContent'])->name('cms.content.store');
    Route::put('/cms/content/{content}', [Admin\CmsController::class, 'updateContent'])->name('cms.content.update');
    Route::delete('/cms/content/{content}', [Admin\CmsController::class, 'destroyContent'])->name('cms.content.destroy');
    Route::get('/cms/faqs', [Admin\CmsController::class, 'faqs'])->name('cms.faqs');
    Route::post('/cms/faqs', [Admin\CmsController::class, 'storeFaq'])->name('cms.faqs.store');
    Route::put('/cms/faqs/{faq}', [Admin\CmsController::class, 'updateFaq'])->name('cms.faqs.update');
    Route::delete('/cms/faqs/{faq}', [Admin\CmsController::class, 'destroyFaq'])->name('cms.faqs.destroy');

    // Settings
    Route::get('/settings', [Admin\SettingsController::class, 'index'])->name('settings.index');
    Route::post('/settings', [Admin\SettingsController::class, 'update'])->name('settings.update');

    // Reports
    Route::get('/reports', [Admin\ReportController::class, 'index'])->name('reports.index');
    Route::get('/reports/download-excel', [Admin\ReportController::class, 'downloadExcel'])->name('reports.download-excel');
    Route::get('/reports/download-pdf', [Admin\ReportController::class, 'downloadPdf'])->name('reports.download-pdf');
});

require __DIR__.'/auth.php';

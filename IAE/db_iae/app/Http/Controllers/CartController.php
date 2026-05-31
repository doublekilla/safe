<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Schedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class CartController extends Controller
{
    public function index()
    {
        $cart = $this->getOrCreateCart();
        $cart->load(['items.schedule', 'items.venueField.venue']);

        return Inertia::render('Cart/Index', [
            'cart' => $cart,
            'cartItems' => $cart->items,
            'total' => $cart->total,
        ]);
    }

    public function add(Request $request)
    {
        $request->validate([
            'schedule_id' => 'required|exists:schedules,id',
        ]);

        $schedule = Schedule::with('venueField')->findOrFail($request->schedule_id);

        if ($schedule->status !== 'available') {
            return back()->withErrors(['schedule' => 'Slot ini sudah tidak tersedia.']);
        }

        // Reject if the slot's time has already passed
        $slotDateTime = \Carbon\Carbon::parse(\Carbon\Carbon::parse($schedule->date)->toDateString() . ' ' . $schedule->start_time);
        if ($slotDateTime->lte(now())) {
            return back()->withErrors(['schedule' => 'Slot ini sudah melewati waktu dan tidak bisa dipesan.']);
        }

        $cart = $this->getOrCreateCart();

        // Check if already in cart
        $exists = $cart->items()->where('schedule_id', $schedule->id)->exists();
        if ($exists) {
            return back()->withErrors(['schedule' => 'Slot ini sudah ada di keranjang.']);
        }

        $cart->items()->create([
            'schedule_id' => $schedule->id,
            'venue_field_id' => $schedule->venue_field_id,
            'date' => $schedule->date,
            'start_time' => $schedule->start_time,
            'end_time' => $schedule->end_time,
            'price' => $schedule->price,
        ]);

        // Mark schedule as pending
        $schedule->update(['status' => 'pending']);

        $cart->load('items');

        return back()->with('success', 'Slot berhasil ditambahkan ke keranjang.');
    }

    public function remove(Request $request, CartItem $cartItem)
    {
        $cart = $this->getOrCreateCart();

        if ($cartItem->cart_id !== $cart->id) {
            return back()->withErrors(['error' => 'Item tidak ditemukan.']);
        }

        // Release the schedule back to available
        $schedule = Schedule::find($cartItem->schedule_id);
        if ($schedule && $schedule->status === 'pending') {
            $schedule->update(['status' => 'available']);
        }

        $cartItem->delete();

        return back()->with('success', 'Item berhasil dihapus dari keranjang.');
    }

    public function clear()
    {
        $cart = $this->getOrCreateCart();

        // Release all schedules back to available
        foreach ($cart->items as $item) {
            $schedule = Schedule::find($item->schedule_id);
            if ($schedule && $schedule->status === 'pending') {
                $schedule->update(['status' => 'available']);
            }
        }

        $cart->items()->delete();

        return back()->with('success', 'Keranjang berhasil dikosongkan.');
    }

    public function count()
    {
        $cart = Cart::where('user_id', Auth::id())->first();
        return response()->json([
            'count' => $cart ? $cart->items()->count() : 0,
        ]);
    }

    private function getOrCreateCart()
    {
        return Cart::firstOrCreate(['user_id' => Auth::id()]);
    }
}

<?php

namespace App\Http\Controllers;

use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MidtransWebhookController extends Controller
{
    /**
     * Handle Midtrans payment notification webhook.
     *
     * This endpoint receives POST requests from Midtrans servers
     * when a transaction status changes. It must NOT be behind
     * authentication middleware.
     */
    public function handle(Request $request)
    {
        $payload = $request->all();

        Log::info('Midtrans webhook received', [
            'order_id' => $payload['order_id'] ?? 'unknown',
            'transaction_status' => $payload['transaction_status'] ?? 'unknown',
        ]);

        try {
            $service = new MidtransService();
            $service->handleNotification($payload);

            return response()->json(['status' => 'ok'], 200);
        } catch (\Exception $e) {
            Log::error('Midtrans webhook error: ' . $e->getMessage(), [
                'payload' => $payload,
            ]);

            // Still return 200 to prevent Midtrans from retrying endlessly
            // for known issues like invalid signature or missing payment
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 200);
        }
    }
}

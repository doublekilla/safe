import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';
import { useState, useEffect, useRef, useCallback } from 'react';


export default function PaymentShow({ booking, payment, midtransClientKey, snapUrl }) {
    const [timeLeft, setTimeLeft] = useState('');
    const [paymentStatus, setPaymentStatus] = useState(payment?.status || 'pending');
    const [bookingStatus, setBookingStatus] = useState(booking?.status || 'pending');
    const [paidMethod, setPaidMethod] = useState(payment?.method || null);
    const [paidAt, setPaidAt] = useState(payment?.paid_at || null);
    const [isSnapLoaded, setIsSnapLoaded] = useState(false);
    const [isSnapOpen, setIsSnapOpen] = useState(false);
    const [snapError, setSnapError] = useState(null);
    const pollingRef = useRef(null);
    const snapTriggered = useRef(false);

    const methodLabels = {
        credit_card: 'Kartu Kredit',
        bank_transfer: 'Transfer Bank',
        echannel: 'Mandiri Bill',
        bca_va: 'BCA Virtual Account',
        bni_va: 'BNI Virtual Account',
        bri_va: 'BRI Virtual Account',
        permata_va: 'Permata Virtual Account',
        gopay: 'GoPay',
        shopeepay: 'ShopeePay',
        qris: 'QRIS',
        cstore: 'Convenience Store',
    };

    // Load Snap.js script
    useEffect(() => {
        if (!midtransClientKey || !snapUrl) return;

        if (window.snap) {
            setIsSnapLoaded(true);
            return;
        }

        const existingScript = document.querySelector(`script[src*="snap.js"]`);
        if (existingScript) {
            existingScript.addEventListener('load', () => setIsSnapLoaded(true));
            if (window.snap) setIsSnapLoaded(true);
            return;
        }

        const script = document.createElement('script');
        script.src = snapUrl;
        script.setAttribute('data-client-key', midtransClientKey);
        script.async = true;
        script.onload = () => setIsSnapLoaded(true);
        script.onerror = () => setSnapError('Gagal memuat payment gateway. Silakan refresh halaman.');
        document.head.appendChild(script);

        return () => {};
    }, [midtransClientKey, snapUrl]);

    // Countdown timer
    useEffect(() => {
        if (paymentStatus !== 'pending' || !payment?.expired_at) return;

        const timer = setInterval(() => {
            const diff = new Date(payment.expired_at) - new Date();
            if (diff <= 0) {
                setTimeLeft('Expired');
                setPaymentStatus('expired');
                clearInterval(timer);
                return;
            }
            const h = Math.floor(diff / 3600000);
            const m = Math.floor((diff % 3600000) / 60000);
            const s = Math.floor((diff % 60000) / 1000);
            setTimeLeft(`${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`);
        }, 1000);

        return () => clearInterval(timer);
    }, [payment, paymentStatus]);

    // Poll payment status
    const startPolling = useCallback(() => {
        if (pollingRef.current) return;

        pollingRef.current = setInterval(async () => {
            try {
                const res = await fetch(route('payments.status', payment.id));
                const data = await res.json();

                if (data.status !== paymentStatus) {
                    setPaymentStatus(data.status);
                    setBookingStatus(data.booking_status);
                    if (data.method) setPaidMethod(data.method);
                    if (data.paid_at) setPaidAt(data.paid_at);

                    if (['paid', 'failed', 'expired'].includes(data.status)) {
                        clearInterval(pollingRef.current);
                        pollingRef.current = null;
                    }
                }
            } catch (e) {}
        }, 3000);
    }, [payment?.id, paymentStatus]);

    useEffect(() => {
        if (paymentStatus === 'pending') {
            startPolling();
        }
        return () => {
            if (pollingRef.current) {
                clearInterval(pollingRef.current);
                pollingRef.current = null;
            }
        };
    }, [paymentStatus, startPolling]);

    // Auto-trigger Snap popup on first load if token exists
    useEffect(() => {
        if (isSnapLoaded && payment?.snap_token && paymentStatus === 'pending' && !snapTriggered.current) {
            snapTriggered.current = true;
            setTimeout(() => openSnapPopup(), 800);
        }
    }, [isSnapLoaded, payment?.snap_token, paymentStatus]);

    const confirmOnServer = async (result, status) => {
        try {
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
            await fetch(route('payments.confirm-snap', booking.id), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json',
                },
                body: JSON.stringify({
                    transaction_status: result.transaction_status || status,
                    payment_type: result.payment_type || 'unknown',
                    order_id: result.order_id,
                    transaction_id: result.transaction_id,
                }),
            });
        } catch (e) {
            console.error('Failed to confirm on server:', e);
        }
    };

    const openSnapPopup = () => {
        if (!window.snap || !payment?.snap_token) {
            setSnapError('Token pembayaran tidak tersedia. Klik "Buat Token" untuk generate ulang.');
            return;
        }

        setSnapError(null);
        setIsSnapOpen(true);

        window.snap.pay(payment.snap_token, {
            onSuccess: async function (result) {
                setIsSnapOpen(false);
                setPaymentStatus('paid');
                setBookingStatus('confirmed');
                setPaidMethod(result.payment_type);
                setPaidAt(result.transaction_time);
                await confirmOnServer(result, 'settlement');
            },
            onPending: async function (result) {
                setIsSnapOpen(false);
                await confirmOnServer(result, 'pending');
                startPolling();
            },
            onError: function (result) {
                setIsSnapOpen(false);
                setSnapError('Pembayaran gagal. Silakan coba lagi.');
            },
            onClose: function () {
                setIsSnapOpen(false);
                startPolling();
            },
        });
    };

    const handleRetryToken = () => {
        router.post(route('payments.pay', booking.id), {}, {
            onSuccess: () => {
                snapTriggered.current = false;
            },
        });
    };

    if (!payment) return null;

    return (
        <CustomerLayout>
            <Head title="Pembayaran" />
            <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8">
                {/* Breadcrumb */}
                <div className="flex items-center gap-2 text-sm text-gray-500 mb-6">
                    <Link href={route('bookings.index')} className="hover:text-gray-700">Booking Saya</Link>
                    <span>›</span>
                    <span className="text-gray-900 font-medium">Pembayaran</span>
                </div>

                <h1 className="text-2xl font-bold text-gray-900 mb-6">Pembayaran</h1>

                {/* ===== STATUS BANNERS ===== */}
                {paymentStatus === 'paid' && (
                    <div className="rounded-2xl p-6 mb-6 text-center border-2 border-emerald-200 bg-gradient-to-b from-emerald-50 to-white">
                        <div className="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-3 ring-4 ring-emerald-50">
                            <svg className="w-8 h-8 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" /></svg>
                        </div>
                        <h2 className="text-xl font-bold text-emerald-800">Pembayaran Berhasil!</h2>
                        <p className="text-sm text-emerald-600 mt-1">Booking Anda telah dikonfirmasi</p>
                        {paidMethod && (
                            <div className="mt-3 inline-flex items-center gap-2 bg-emerald-100 px-3 py-1.5 rounded-full">
                                <span className="w-2 h-2 bg-emerald-500 rounded-full" />
                                <span className="text-xs font-medium text-emerald-700">
                                    Dibayar via {methodLabels[paidMethod] || paidMethod}
                                    {paidAt && ` • ${new Date(paidAt).toLocaleString('id-ID')}`}
                                </span>
                            </div>
                        )}
                        <div className="mt-4">
                            <Link href={route('bookings.show', booking.id)} className="btn-accent inline-block">Lihat Detail Booking →</Link>
                        </div>
                    </div>
                )}

                {paymentStatus === 'pending' && (
                    <div className="rounded-2xl p-6 mb-6 text-center border-2 border-amber-200 bg-gradient-to-b from-amber-50 to-white">
                        <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-3 ring-4 ring-amber-50">
                            <svg className="w-8 h-8 text-amber-600 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                        </div>
                        <h2 className="text-xl font-bold text-amber-800">Menunggu Pembayaran</h2>
                        {timeLeft && timeLeft !== 'Expired' && (
                            <div className="mt-3">
                                <p className="text-xs text-amber-600 mb-1">Selesaikan pembayaran dalam</p>
                                <div className="inline-flex items-center gap-1 bg-amber-100 px-4 py-2 rounded-xl">
                                    {timeLeft.split(':').map((unit, i) => (
                                        <span key={i} className="flex items-center gap-1">
                                            <span className="text-2xl font-mono font-black text-amber-800 bg-amber-200/50 px-2 py-0.5 rounded-lg min-w-[2.5rem] text-center">{unit}</span>
                                            {i < 2 && <span className="text-amber-500 font-bold text-lg">:</span>}
                                        </span>
                                    ))}
                                </div>
                                <div className="flex justify-center gap-8 mt-1">
                                    <span className="text-[10px] text-amber-500">Jam</span>
                                    <span className="text-[10px] text-amber-500">Menit</span>
                                    <span className="text-[10px] text-amber-500">Detik</span>
                                </div>
                            </div>
                        )}
                    </div>
                )}

                {paymentStatus === 'expired' && (
                    <div className="rounded-2xl p-6 mb-6 text-center border-2 border-red-200 bg-gradient-to-b from-red-50 to-white">
                        <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3 ring-4 ring-red-50">
                            <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                        </div>
                        <h2 className="text-xl font-bold text-red-800">Pembayaran Kadaluarsa</h2>
                        <p className="text-sm text-red-600 mt-1">Batas waktu pembayaran telah habis. Silakan buat booking baru.</p>
                    </div>
                )}

                {paymentStatus === 'failed' && (
                    <div className="rounded-2xl p-6 mb-6 text-center border-2 border-red-200 bg-gradient-to-b from-red-50 to-white">
                        <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3 ring-4 ring-red-50">
                            <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" /></svg>
                        </div>
                        <h2 className="text-xl font-bold text-red-800">Pembayaran Gagal</h2>
                        <p className="text-sm text-red-600 mt-1">Transaksi pembayaran tidak berhasil</p>
                    </div>
                )}

                {/* Error Alert */}
                {snapError && (
                    <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start gap-3">
                        <svg className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
                        <p className="text-sm text-red-700">{snapError}</p>
                    </div>
                )}

                <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                    {/* ===== LEFT COLUMN ===== */}
                    <div className="lg:col-span-3 space-y-6">

                        {/* Amount Card */}
                        <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
                            <div className="text-center mb-5">
                                <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">Total Pembayaran</p>
                                <p className="text-3xl font-black text-gray-900 mt-1">
                                    Rp {parseInt(payment.amount).toLocaleString('id-ID')}
                                </p>
                            </div>
                            <div className="space-y-2.5 text-sm border-t border-gray-100 pt-4">
                                <div className="flex justify-between">
                                    <span className="text-gray-500">Kode Booking</span>
                                    <span className="font-mono font-bold text-gray-900 bg-gray-100 px-2 py-0.5 rounded text-xs">{booking.booking_code}</span>
                                </div>
                                {paidMethod && (
                                    <div className="flex justify-between items-center">
                                        <span className="text-gray-500">Metode Pembayaran</span>
                                        <span className="font-medium text-gray-900">{methodLabels[paidMethod] || paidMethod}</span>
                                    </div>
                                )}
                                <div className="flex justify-between items-center">
                                    <span className="text-gray-500">Status</span>
                                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold ${
                                        paymentStatus === 'paid' ? 'bg-emerald-100 text-emerald-800' :
                                        paymentStatus === 'pending' ? 'bg-amber-100 text-amber-800' :
                                        'bg-red-100 text-red-800'
                                    }`}>
                                        <span className={`w-1.5 h-1.5 rounded-full ${
                                            paymentStatus === 'paid' ? 'bg-emerald-500' :
                                            paymentStatus === 'pending' ? 'bg-amber-500 animate-pulse' :
                                            'bg-red-500'
                                        }`} />
                                        {paymentStatus === 'paid' ? 'Lunas' :
                                         paymentStatus === 'pending' ? 'Menunggu Pembayaran' :
                                         paymentStatus === 'expired' ? 'Kadaluarsa' : 'Gagal'}
                                    </span>
                                </div>
                            </div>
                        </div>

                        {/* Pay Button — Has snap token */}
                        {paymentStatus === 'pending' && payment?.snap_token && (
                            <button
                                onClick={openSnapPopup}
                                disabled={!isSnapLoaded || isSnapOpen}
                                className="w-full relative overflow-hidden rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-bold py-4 px-6 text-base transition-all duration-200 shadow-lg shadow-blue-500/20 hover:shadow-blue-500/30 disabled:opacity-60 disabled:cursor-not-allowed group"
                            >
                                {isSnapOpen ? (
                                    <span className="flex items-center justify-center gap-2">
                                        <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                                        Memproses Pembayaran...
                                    </span>
                                ) : !isSnapLoaded ? (
                                    <span className="flex items-center justify-center gap-2">
                                        <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                                        Memuat Payment Gateway...
                                    </span>
                                ) : (
                                    <span className="flex items-center justify-center gap-2">
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                                        Bayar Sekarang
                                        <svg className="w-4 h-4 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
                                    </span>
                                )}
                                <div className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/10 to-transparent" />
                            </button>
                        )}

                        {/* Retry Token — No snap token yet */}
                        {paymentStatus === 'pending' && !payment?.snap_token && (
                            <button
                                onClick={handleRetryToken}
                                className="w-full rounded-2xl bg-gray-900 hover:bg-gray-800 text-white font-bold py-4 px-6 text-base transition-all duration-200"
                            >
                                <span className="flex items-center justify-center gap-2">
                                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>
                                    Buat Token Pembayaran
                                </span>
                            </button>
                        )}

                        {/* Powered by Midtrans */}
                        {paymentStatus === 'pending' && (
                            <div className="flex items-center justify-center gap-2 text-xs text-gray-400">
                                <svg className="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                                <span>Pembayaran aman & terenkripsi melalui <span className="font-semibold text-gray-500">Midtrans</span></span>
                            </div>
                        )}
                    </div>

                    {/* ===== RIGHT COLUMN — Booking Summary ===== */}
                    <div className="lg:col-span-2 space-y-6">
                        {/* Booking Items */}
                        <div className="rounded-2xl border border-gray-200 bg-white shadow-sm overflow-hidden">
                            <div className="px-5 py-3.5 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="font-bold text-gray-900 text-sm">Detail Booking</h3>
                            </div>
                            <div className="p-4 space-y-2">
                                {booking.items?.map((item, i) => (
                                    <div key={i} className="flex items-start gap-3 p-3 bg-gray-50 rounded-xl">
                                        <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center flex-shrink-0 border border-gray-100 shadow-sm">
                                            <span className="text-sm">
                                                {(() => { const t = item.venue_field?.venue?.sport_type; const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[t] || '🏟️'; })()}
                                            </span>
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <p className="text-xs font-semibold text-gray-800 truncate">{item.venue_field?.venue?.name}</p>
                                            <p className="text-[11px] text-gray-500 truncate">{item.venue_field?.name}</p>
                                            <div className="flex items-center gap-2 mt-1">
                                                <span className="text-[10px] text-gray-400">
                                                    {new Date(item.date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })}
                                                </span>
                                                <span className="text-[10px] text-gray-300">•</span>
                                                <span className="text-[10px] text-gray-400">{item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}</span>
                                            </div>
                                        </div>
                                        <span className="text-xs font-bold text-gray-700 flex-shrink-0">
                                            Rp {parseInt(item.price).toLocaleString('id-ID')}
                                        </span>
                                    </div>
                                ))}
                            </div>

                            {/* Cost Breakdown */}
                            <div className="px-5 py-4 border-t border-gray-100 space-y-2 text-xs">
                                <div className="flex justify-between text-gray-500">
                                    <span>Subtotal ({booking.items?.length} slot)</span>
                                    <span>Rp {parseInt(booking.total_amount).toLocaleString('id-ID')}</span>
                                </div>
                                {parseFloat(booking.service_fee) > 0 && (
                                    <div className="flex justify-between text-gray-500">
                                        <span>Biaya Layanan</span>
                                        <span>Rp {parseInt(booking.service_fee).toLocaleString('id-ID')}</span>
                                    </div>
                                )}
                                {parseFloat(booking.tax) > 0 && (
                                    <div className="flex justify-between text-gray-500">
                                        <span>Pajak (PPN)</span>
                                        <span>Rp {parseInt(booking.tax).toLocaleString('id-ID')}</span>
                                    </div>
                                )}
                                <div className="flex justify-between pt-2.5 mt-1 border-t border-gray-200 font-bold text-gray-900 text-sm">
                                    <span>Total</span>
                                    <span className="text-primary">Rp {parseInt(payment.amount).toLocaleString('id-ID')}</span>
                                </div>
                            </div>
                        </div>

                        {/* Security & Trust */}
                        <div className="rounded-2xl border border-gray-100 bg-gray-50/50 p-5">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-8 h-8 bg-emerald-100 rounded-lg flex items-center justify-center flex-shrink-0">
                                    <svg className="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                                </div>
                                <div>
                                    <p className="text-xs font-semibold text-gray-700">Pembayaran Aman</p>
                                    <p className="text-[10px] text-gray-400">Powered by Midtrans</p>
                                </div>
                            </div>
                            <div className="space-y-2.5">
                                {['Enkripsi SSL 256-bit', 'PCI DSS Certified', 'Otentikasi 3D Secure', 'Deteksi fraud otomatis'].map((item, i) => (
                                    <div key={i} className="flex items-center gap-2 text-[11px] text-gray-500">
                                        <svg className="w-3.5 h-3.5 text-emerald-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" /></svg>
                                        <span>{item}</span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Back Link */}
                        <Link
                            href={route('bookings.index')}
                            className="flex items-center justify-center gap-1.5 text-sm text-gray-500 hover:text-gray-700 transition-colors py-2"
                        >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
                            Kembali ke Riwayat Booking
                        </Link>
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}

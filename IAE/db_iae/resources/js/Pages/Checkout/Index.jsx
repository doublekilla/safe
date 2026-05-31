import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, router, useForm } from '@inertiajs/react';


export default function CheckoutIndex({ cart, cartItems, subtotal, serviceFee, tax, total, serviceFeePercent, taxPercent }) {
    const { data, setData, post, processing, errors } = useForm({
        notes: '',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        if (confirm('Konfirmasi booking ini? Anda akan diarahkan ke halaman pembayaran.')) {
            post(route('bookings.store'));
        }
    };

    return (
        <CustomerLayout>
            <Head title="Checkout" />
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Breadcrumb */}
                <div className="flex items-center gap-2 text-sm text-gray-500 mb-6">
                    <span>Keranjang</span>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                    <span className="text-gray-900 font-medium">Checkout</span>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                    <span className="text-gray-400">Pembayaran</span>
                </div>

                <h1 className="text-2xl font-bold text-gray-900 mb-6">Checkout</h1>

                {errors.cart && (
                    <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700">
                        {errors.cart}
                    </div>
                )}
                {errors.schedule && (
                    <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700">
                        {errors.schedule}
                    </div>
                )}

                <form onSubmit={handleSubmit}>
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div className="lg:col-span-2 space-y-6">
                            {/* Items Summary */}
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 mb-4">Detail Booking</h3>
                                <div className="space-y-3">
                                    {cartItems?.map(item => (
                                        <div key={item.id} className="flex justify-between items-center py-3 border-b border-surface-border last:border-0">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 bg-accent/10 rounded-lg flex items-center justify-center flex-shrink-0">
                                                    <span className="text-lg">
                                                        {(() => { const t = item.venue_field?.venue?.sport_type; const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[t] || '🏟️'; })()}
                                                    </span>
                                                </div>
                                                <div>
                                                    <p className="text-sm font-medium text-gray-900">{item.venue_field?.venue?.name} — {item.venue_field?.name}</p>
                                                    <p className="text-xs text-gray-500">
                                                        📅 {new Date(item.date).toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' })} &bull; ⏰ {item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}
                                                    </p>
                                                </div>
                                            </div>
                                            <span className="font-semibold text-sm text-primary">Rp {parseInt(item.price).toLocaleString('id-ID')}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>


                            {/* Notes */}
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 mb-4">Catatan (Opsional)</h3>
                                <textarea
                                    value={data.notes}
                                    onChange={e => setData('notes', e.target.value)}
                                    placeholder="Tambahkan catatan untuk booking ini..."
                                    className="input h-24 resize-none"
                                    maxLength={500}
                                />
                                <p className="text-xs text-gray-400 mt-1">{data.notes.length}/500 karakter</p>
                            </div>
                        </div>

                        {/* Order Summary Sidebar */}
                        <div className="card p-6 h-fit sticky top-20">
                            <h3 className="font-bold text-gray-900 mb-4">Ringkasan Pesanan</h3>
                            <div className="space-y-2 text-sm">
                                <div className="flex justify-between">
                                    <span className="text-gray-500">Subtotal ({cartItems?.length} slot)</span>
                                    <span>Rp {parseInt(subtotal).toLocaleString('id-ID')}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-gray-500">Biaya Layanan ({serviceFeePercent}%)</span>
                                    <span>Rp {parseInt(serviceFee).toLocaleString('id-ID')}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-gray-500">PPN ({taxPercent}%)</span>
                                    <span>Rp {parseInt(tax).toLocaleString('id-ID')}</span>
                                </div>
                                <div className="flex justify-between pt-3 mt-3 border-t-2 border-surface-border">
                                    <span className="font-bold text-gray-900">Total</span>
                                    <span className="font-black text-xl text-primary">Rp {parseInt(total).toLocaleString('id-ID')}</span>
                                </div>
                            </div>
                            <button
                                type="submit"
                                disabled={processing}
                                className="btn-accent w-full mt-6"
                            >
                                {processing ? (
                                    <span className="flex items-center justify-center gap-2">
                                        <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                                        </svg>
                                        Memproses...
                                    </span>
                                ) : 'Lanjut ke Pembayaran'}
                            </button>
                            <p className="text-[10px] text-gray-400 text-center mt-3">
                                Pembayaran diproses melalui gateway yang aman
                            </p>
                        </div>
                    </div>
                </form>
            </div>
        </CustomerLayout>
    );
}

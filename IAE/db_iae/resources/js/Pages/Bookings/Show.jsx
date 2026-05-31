import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router, useForm } from '@inertiajs/react';
import { useState } from 'react';


export default function BookingShow({ booking }) {
    const [showReviewModal, setShowReviewModal] = useState(false);
    const reviewForm = useForm({ booking_id: booking.id, venue_id: booking.items?.[0]?.venue_field?.venue?.id, rating: 5, comment: '' });

    const statusLabels = { pending: 'Menunggu Pembayaran', confirmed: 'Dikonfirmasi', completed: 'Selesai', cancelled: 'Dibatalkan', reschedule_requested: 'Minta Reschedule', rescheduled: 'Dijadwal Ulang' };
    const statusColors = { pending: 'bg-amber-50 border-amber-200 text-amber-800', confirmed: 'bg-blue-50 border-blue-200 text-blue-800', completed: 'bg-emerald-50 border-emerald-200 text-emerald-800', cancelled: 'bg-red-50 border-red-200 text-red-800', reschedule_requested: 'bg-amber-50 border-amber-200 text-amber-800', rescheduled: 'bg-blue-50 border-blue-200 text-blue-800' };
    const paymentLabels = { pending: 'Menunggu', paid: 'Lunas', failed: 'Gagal', expired: 'Kadaluarsa' };

    const handleCancel = () => {
        if (confirm('Apakah Anda yakin ingin membatalkan booking ini?')) {
            router.post(route('bookings.cancel', booking.id));
        }
    };

    const handleReviewSubmit = (e) => {
        e.preventDefault();
        reviewForm.post(route('reviews.store'), { onSuccess: () => setShowReviewModal(false) });
    };

    const grandTotal = parseFloat(booking.total_amount) + parseFloat(booking.service_fee || 0) + parseFloat(booking.tax || 0);

    return (
        <CustomerLayout>
            <Head title={`Booking ${booking.booking_code}`} />
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Status Banner */}
                <div className={`rounded-card border-2 p-4 mb-6 ${statusColors[booking.status]}`}>
                    <div className="flex items-center justify-between">
                        <div>
                            <h2 className="font-bold text-lg">{statusLabels[booking.status]}</h2>
                            <p className="text-sm opacity-75">Kode Booking: <span className="font-mono font-bold">{booking.booking_code}</span></p>
                        </div>
                        {booking.status === 'pending' && booking.payment?.status === 'pending' && (
                            <Link href={route('payments.show', booking.id)} className="btn-accent btn-sm">Bayar Sekarang</Link>
                        )}
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div className="lg:col-span-2 space-y-6">
                        {/* Booking Items */}
                        <div className="card p-6">
                            <h3 className="font-bold text-gray-900 mb-4">Detail Jadwal</h3>
                            <div className="space-y-3">
                                {booking.items?.map((item, i) => (
                                    <div key={i} className="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                                        <div className="w-10 h-10 bg-accent/10 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <span className="text-lg">{(() => { const t = item.venue_field?.venue?.sport_type; const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[t] || '🏟️'; })()}</span>
                                        </div>
                                        <div className="flex-1">
                                            <p className="font-medium text-sm text-gray-900">{item.venue_field?.venue?.name} — {item.venue_field?.name}</p>
                                            <p className="text-xs text-gray-500">📅 {new Date(item.date).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}</p>
                                            <p className="text-xs text-gray-500">⏰ {item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}</p>
                                        </div>
                                        <span className="font-semibold text-sm text-primary">Rp {parseInt(item.price).toLocaleString('id-ID')}</span>
                                    </div>
                                ))}
                            </div>
                        </div>
                        {/* Payment Info */}
                        {booking.payment && (
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 mb-4">Informasi Pembayaran</h3>
                                <div className="space-y-2 text-sm">
                                    <div className="flex justify-between"><span className="text-gray-500">Metode</span><span className="font-medium capitalize">{
                                        {credit_card:'Kartu Kredit',bank_transfer:'Transfer Bank',echannel:'Mandiri Bill',gopay:'GoPay',shopeepay:'ShopeePay',qris:'QRIS',bca_va:'BCA VA',bni_va:'BNI VA',bri_va:'BRI VA',cstore:'Minimarket',akulaku:'Akulaku'}[booking.payment.method] || booking.payment.method?.replace('_', ' ') || 'Belum dipilih'
                                    }</span></div>
                                    <div className="flex justify-between"><span className="text-gray-500">Status</span><span className={`badge ${booking.payment.status === 'paid' ? 'badge-success' : booking.payment.status === 'pending' ? 'badge-warning' : 'badge-danger'}`}>{paymentLabels[booking.payment.status]}</span></div>
                                    {booking.payment.paid_at && <div className="flex justify-between"><span className="text-gray-500">Dibayar</span><span>{new Date(booking.payment.paid_at).toLocaleString('id-ID')}</span></div>}
                                    {booking.payment.expired_at && booking.payment.status === 'pending' && <div className="flex justify-between"><span className="text-gray-500">Batas Bayar</span><span className="text-red-600 font-medium">{new Date(booking.payment.expired_at).toLocaleString('id-ID')}</span></div>}
                                </div>
                            </div>
                        )}
                        {booking.notes && (
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 mb-2">Catatan</h3>
                                <p className="text-sm text-gray-600">{booking.notes}</p>
                            </div>
                        )}
                    </div>
                    {/* Sidebar */}
                    <div className="space-y-4">
                        <div className="card p-6">
                            <h3 className="font-bold text-gray-900 mb-4">Ringkasan Biaya</h3>
                            <div className="space-y-2 text-sm">
                                <div className="flex justify-between"><span className="text-gray-500">Subtotal</span><span>Rp {parseInt(booking.total_amount).toLocaleString('id-ID')}</span></div>
                                {parseFloat(booking.service_fee) > 0 && <div className="flex justify-between"><span className="text-gray-500">Biaya Layanan</span><span>Rp {parseInt(booking.service_fee).toLocaleString('id-ID')}</span></div>}
                                {parseFloat(booking.tax) > 0 && <div className="flex justify-between"><span className="text-gray-500">Pajak</span><span>Rp {parseInt(booking.tax).toLocaleString('id-ID')}</span></div>}
                                <div className="flex justify-between pt-3 mt-3 border-t-2 border-surface-border">
                                    <span className="font-bold">Total</span>
                                    <span className="font-black text-lg text-primary">Rp {parseInt(grandTotal).toLocaleString('id-ID')}</span>
                                </div>
                            </div>
                        </div>
                        {/* Actions */}
                        <div className="card p-6 space-y-2">
                            <h3 className="font-bold text-gray-900 mb-3">Aksi</h3>
                            {booking.status === 'pending' && booking.payment?.status === 'pending' && (
                                <Link href={route('payments.show', booking.id)} className="btn-accent w-full">Bayar Sekarang</Link>
                            )}
                            {booking.status === 'confirmed' && (
                                <Link href={route('reschedule.show', booking.id)} className="btn-outline w-full">Reschedule</Link>
                            )}
                            {['pending', 'confirmed'].includes(booking.status) && (
                                <button onClick={handleCancel} className="btn-danger w-full">Batalkan Booking</button>
                            )}
                            {booking.status === 'completed' && !booking.review && (
                                <button onClick={() => setShowReviewModal(true)} className="btn-accent w-full">⭐ Beri Ulasan</button>
                            )}
                            {booking.review && (
                                <div className="p-3 bg-emerald-50 rounded-lg text-center">
                                    <p className="text-sm font-medium text-emerald-700">✓ Sudah diulas</p>
                                    <div className="flex justify-center gap-0.5 mt-1">{[1,2,3,4,5].map(s => <span key={s} className={`text-sm ${s <= booking.review.rating ? 'text-amber-400' : 'text-gray-300'}`}>★</span>)}</div>
                                </div>
                            )}
                            <Link href={route('bookings.index')} className="btn-ghost w-full text-sm">← Kembali ke Riwayat</Link>
                        </div>
                    </div>
                </div>
            </div>

            {/* Review Modal */}
            {showReviewModal && (
                <div className="overlay flex items-center justify-center p-4 z-50">
                    <div className="modal animate-scale-in" onClick={e => e.stopPropagation()}>
                        <h3 className="text-lg font-bold text-gray-900 mb-4">⭐ Berikan Ulasan</h3>
                        <form onSubmit={handleReviewSubmit}>
                            <div className="mb-4">
                                <label className="input-label">Rating</label>
                                <div className="flex gap-2 mt-1">
                                    {[1,2,3,4,5].map(s => (
                                        <button key={s} type="button" onClick={() => reviewForm.setData('rating', s)}
                                            className={`text-3xl transition-transform hover:scale-110 ${s <= reviewForm.data.rating ? 'text-amber-400' : 'text-gray-300'}`}>★</button>
                                    ))}
                                </div>
                            </div>
                            <div className="mb-4">
                                <label className="input-label">Komentar</label>
                                <textarea value={reviewForm.data.comment} onChange={e => reviewForm.setData('comment', e.target.value)} className="input h-24 resize-none" placeholder="Bagaimana pengalaman bermain Anda?" />
                            </div>
                            <div className="flex gap-2">
                                <button type="submit" disabled={reviewForm.processing} className="btn-accent flex-1">{reviewForm.processing ? 'Mengirim...' : 'Kirim Ulasan'}</button>
                                <button type="button" onClick={() => setShowReviewModal(false)} className="btn-ghost">Batal</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </CustomerLayout>
    );
}

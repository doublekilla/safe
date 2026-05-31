import AdminLayout from '@/Layouts/AdminLayout';
import { Head, Link, router } from '@inertiajs/react';


const methodLabels = {
    credit_card: '💳 Kartu Kredit',
    bank_transfer: '🏦 Transfer Bank',
    echannel: '🏦 Mandiri Bill',
    bca_va: '🏦 BCA VA',
    bni_va: '🏦 BNI VA',
    bri_va: '🏦 BRI VA',
    permata_va: '🏦 Permata VA',
    gopay: '📱 GoPay',
    shopeepay: '📱 ShopeePay',
    qris: '📱 QRIS',
    cstore: '🏪 Minimarket',
};

const getMethodLabel = (method) => {
    if (!method) return 'Belum dipilih';
    return methodLabels[method] || method.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

export default function BookingShow({ booking }) {
    const updateStatus = (status) => { if (confirm(`Ubah status ke ${status}?`)) router.put(route('admin.bookings.update-status', booking.id), { status }); };
    const statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
    const grandTotal = parseFloat(booking.total_amount) + parseFloat(booking.service_fee || 0) + parseFloat(booking.tax || 0);

    return (
        <AdminLayout title={`Booking ${booking.booking_code}`}>
            <Head title={`Booking ${booking.booking_code}`} />
            <Link href={route('admin.bookings.index')} className="text-sm text-gray-500 hover:text-gray-700">← Kembali</Link>
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-4">
                <div className="lg:col-span-2 space-y-6">
                    <div className="card p-6">
                        <div className="flex items-center justify-between mb-4">
                            <h2 className="text-lg font-bold text-gray-900">Detail Booking</h2>
                            <span className={`badge ${booking.status === 'confirmed' ? 'badge-info' : booking.status === 'completed' ? 'badge-success' : booking.status === 'cancelled' ? 'badge-danger' : 'badge-warning'}`}>{booking.status}</span>
                        </div>
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div><span className="text-gray-500">Kode</span><p className="font-mono font-bold">{booking.booking_code}</p></div>
                            <div><span className="text-gray-500">Customer</span><p className="font-medium">{booking.user?.name}</p><p className="text-xs text-gray-400">{booking.user?.email} | {booking.user?.phone}</p></div>
                            <div><span className="text-gray-500">Tanggal Order</span><p>{new Date(booking.created_at).toLocaleString('id-ID')}</p></div>
                            <div><span className="text-gray-500">Total</span><p className="font-bold text-primary text-lg">Rp {parseInt(grandTotal).toLocaleString('id-ID')}</p></div>
                        </div>
                    </div>
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-3">Jadwal</h3>
                        {booking.items?.map((item, i) => (
                            <div key={i} className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg mb-2">
                                <span className="text-xl">{(() => { const t = item.venue_field?.venue?.sport_type; const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[t] || '🏟️'; })()}</span>
                                <div className="flex-1"><p className="font-medium text-sm">{item.venue_field?.venue?.name} — {item.venue_field?.name}</p><p className="text-xs text-gray-500">{new Date(item.date).toLocaleDateString('id-ID')} | {item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}</p></div>
                                <span className="font-semibold text-sm">Rp {parseInt(item.price).toLocaleString('id-ID')}</span>
                            </div>
                        ))}
                    </div>
                    {booking.notes && (
                        <div className="card p-6">
                            <h3 className="font-semibold text-gray-900 mb-2">📝 Catatan Customer</h3>
                            <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3 leading-relaxed">{booking.notes}</p>
                        </div>
                    )}
                    {booking.payment && (
                        <div className="card p-6">
                            <h3 className="font-semibold text-gray-900 mb-3">Pembayaran</h3>
                            <div className="grid grid-cols-2 gap-3 text-sm">
                                <div><span className="text-gray-500">Metode</span><p className="font-medium">{getMethodLabel(booking.payment.method)}</p></div>
                                <div><span className="text-gray-500">Status</span><p><span className={`badge ${booking.payment.status === 'paid' ? 'badge-success' : booking.payment.status === 'pending' ? 'badge-warning' : 'badge-danger'}`}>{booking.payment.status}</span></p></div>
                                <div><span className="text-gray-500">Jumlah</span><p className="font-bold">Rp {parseInt(booking.payment.amount).toLocaleString('id-ID')}</p></div>
                                {booking.payment.paid_at && <div><span className="text-gray-500">Dibayar</span><p>{new Date(booking.payment.paid_at).toLocaleString('id-ID')}</p></div>}
                            </div>
                            {booking.payment.payment_proof && <div className="mt-3"><img src={`/storage/${booking.payment.payment_proof}`} alt="Bukti" className="max-w-xs rounded-lg border" /></div>}
                        </div>
                    )}
                </div>
                <div className="space-y-4">
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-3">Ubah Status</h3>
                        <div className="space-y-2">
                            {statuses.map(s => (
                                <button key={s} onClick={() => updateStatus(s)} disabled={booking.status === s}
                                    className={`w-full text-left px-3 py-2 text-sm rounded-lg transition-all capitalize ${booking.status === s ? 'bg-accent/10 text-accent font-bold cursor-default' : 'hover:bg-gray-50 text-gray-600'}`}>
                                    {s}
                                </button>
                            ))}
                        </div>
                    </div>
                    {booking.payment?.status === 'pending' && (
                        <div className="card p-6 space-y-3">
                            <h3 className="font-semibold text-gray-900 mb-1">Pembayaran Pending</h3>
                            <p className="text-xs text-gray-500 leading-relaxed">
                                Pembayaran akan otomatis terkonfirmasi setelah customer menyelesaikan pembayaran via Midtrans. Gunakan tombol di bawah hanya jika diperlukan.
                            </p>
                            <div className="space-y-2 pt-1">
                                <button onClick={() => { if (confirm('Verifikasi pembayaran ini secara manual? Status akan berubah ke Lunas.')) router.post(route('admin.payments.verify', booking.payment.id)); }} className="btn-success w-full btn-sm">✓ Verifikasi Manual</button>
                                <button onClick={() => { if (confirm('Tolak pembayaran ini? Booking akan dibatalkan dan jadwal dilepas.')) router.post(route('admin.payments.reject', booking.payment.id)); }} className="btn-danger w-full btn-sm">✕ Tolak Pembayaran</button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </AdminLayout>
    );
}

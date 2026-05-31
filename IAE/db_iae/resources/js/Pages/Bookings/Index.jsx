import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';


const statusBadge = (status) => {
    const map = { pending: 'badge-warning', confirmed: 'badge-info', completed: 'badge-success', cancelled: 'badge-danger', reschedule_requested: 'badge-warning', rescheduled: 'badge-info' };
    const labels = { pending: 'Menunggu', confirmed: 'Dikonfirmasi', completed: 'Selesai', cancelled: 'Dibatalkan', reschedule_requested: 'Minta Reschedule', rescheduled: 'Dijadwal Ulang' };
    return <span className={map[status] || 'badge-neutral'}>{labels[status] || status}</span>;
};

const paymentBadge = (status) => {
    const map = { pending: 'badge-warning', paid: 'badge-success', failed: 'badge-danger', expired: 'badge-danger' };
    const labels = { pending: 'Menunggu', paid: 'Lunas', failed: 'Gagal', expired: 'Kadaluarsa' };
    return <span className={map[status] || 'badge-neutral'}>{labels[status] || status}</span>;
};

export default function BookingsIndex({ bookings, filters, statuses }) {
    return (
        <CustomerLayout>
            <Head title="Riwayat Booking" />
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-2xl font-bold text-gray-900 mb-6">📋 Riwayat Booking</h1>
                {/* Filter tabs */}
                <div className="flex flex-wrap gap-2 mb-6">
                    <Link href={route('bookings.index')} className={`px-3 py-1.5 text-sm rounded-lg font-medium transition-all ${!filters.status ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                        Semua
                    </Link>
                    {statuses.map(s => {
                        const labels = { pending: 'Pending', confirmed: 'Confirmed', completed: 'Completed', cancelled: 'Cancelled', rescheduled: 'Reschedule' };
                        return (
                            <Link key={s} href={route('bookings.index', { status: s })} className={`px-3 py-1.5 text-sm rounded-lg font-medium transition-all ${filters.status === s ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                                {labels[s] || s}
                            </Link>
                        );
                    })}
                </div>

                {bookings?.data?.length > 0 ? (
                    <div className="space-y-4">
                        {bookings.data.map(booking => (
                            <Link key={booking.id} href={route('bookings.show', booking.id)} className="card-hover block p-5">
                                <div className="flex items-start justify-between mb-3">
                                    <div>
                                        <span className="font-mono text-sm font-bold text-primary">{booking.booking_code}</span>
                                        <p className="text-xs text-gray-400 mt-0.5">{new Date(booking.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</p>
                                    </div>
                                    <div className="flex gap-2">{statusBadge(booking.status)} {booking.payment && paymentBadge(booking.payment.status)}</div>
                                </div>
                                {booking.items?.map((item, i) => (
                                    <div key={i} className="flex items-center gap-3 text-sm text-gray-600 mb-1">
                                        <span>{(() => { const t = item.venue_field?.venue?.sport_type; const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[t] || '🏟️'; })()}</span>
                                        <span>{item.venue_field?.venue?.name} — {item.venue_field?.name}</span>
                                        <span className="text-gray-400">|</span>
                                        <span>{new Date(item.date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })} {item.start_time?.substring(0, 5)}-{item.end_time?.substring(0, 5)}</span>
                                    </div>
                                ))}
                                <div className="flex justify-between items-center mt-3 pt-3 border-t border-surface-border">
                                    <span className="font-bold text-primary">Rp {parseInt(booking.total_amount).toLocaleString('id-ID')}</span>
                                    <span className="text-xs text-accent font-medium">Lihat Detail →</span>
                                </div>
                            </Link>
                        ))}
                        {/* Pagination */}
                        {bookings.links?.length > 3 && (
                            <div className="flex justify-center gap-1 mt-6">
                                {bookings.links.map((link, i) => (
                                    <Link key={i} href={link.url || '#'} className={`px-3 py-2 text-sm rounded-lg ${link.active ? 'bg-primary text-white' : link.url ? 'text-gray-600 hover:bg-gray-100' : 'text-gray-300'}`} dangerouslySetInnerHTML={{ __html: link.label }} preserveState />
                                ))}
                            </div>
                        )}
                    </div>
                ) : (
                    <div className="card p-12 text-center">
                        <span className="text-5xl mb-4 block">📋</span>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">Belum Ada Booking</h3>
                        <p className="text-gray-500 mb-4">Mulai booking lapangan sekarang!</p>
                        <Link href={route('venues.index')} className="btn-accent">Lihat Lapangan</Link>
                    </div>
                )}
            </div>
        </CustomerLayout>
    );
}

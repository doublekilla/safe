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
    if (!method) return null;
    return methodLabels[method] || method.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

export default function BookingsIndex({ bookings, filters, statuses }) {
    const statusBadge = (s) => {
        const m = { pending: 'badge-warning', confirmed: 'badge-info', completed: 'badge-success', cancelled: 'badge-danger', reschedule_requested: 'badge-warning', rescheduled: 'badge-info' };
        const labels = { pending: 'Pending', confirmed: 'Dikonfirmasi', completed: 'Selesai', cancelled: 'Dibatalkan', reschedule_requested: 'Minta Reschedule', rescheduled: 'Dijadwalkan Ulang' };
        return <span className={m[s] || 'badge-neutral'}>{labels[s] || s}</span>;
    };

    const payBadge = (s) => {
        const m = { pending: 'badge-warning', paid: 'badge-success', failed: 'badge-danger', expired: 'badge-danger' };
        const labels = { pending: 'Menunggu', paid: 'Lunas', failed: 'Gagal', expired: 'Kadaluarsa' };
        return <span className={m[s] || 'badge-neutral'}>{labels[s] || s}</span>;
    };

    return (
        <AdminLayout title="Manajemen Booking">
            <Head title="Manajemen Booking" />
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-xl font-bold text-gray-900">Manajemen Booking</h1>
                <Link href={route('admin.bookings.manual-create')} className="btn-accent">+ Booking Manual</Link>
            </div>

            {/* Filters */}
            <div className="card p-4 mb-6">
                <div className="flex flex-wrap gap-3">
                    <input type="text" placeholder="Cari kode/nama..." defaultValue={filters?.search} onKeyDown={e => { if (e.key === 'Enter') router.get(route('admin.bookings.index'), { ...filters, search: e.target.value }, { preserveState: true }); }} className="input w-64" />
                    <select defaultValue={filters?.status || ''} onChange={e => router.get(route('admin.bookings.index'), { ...filters, status: e.target.value || undefined }, { preserveState: true })} className="input w-48">
                        <option value="">Semua Status</option>{statuses.map(s => <option key={s} value={s}>{s}</option>)}
                    </select>
                    <input type="date" defaultValue={filters?.date || ''} onChange={e => router.get(route('admin.bookings.index'), { ...filters, date: e.target.value || undefined }, { preserveState: true })} className="input w-48" />
                </div>
            </div>

            {/* Table */}
            <div className="table-container">
                <table className="table">
                    <thead>
                        <tr>
                            <th>Kode</th>
                            <th>Customer</th>
                            <th>Lapangan</th>
                            <th>Booking</th>
                            <th>Pembayaran</th>
                            <th>Metode</th>
                            <th>Total</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        {bookings?.data?.map(b => (
                            <tr key={b.id}>
                                <td>
                                    <Link href={route('admin.bookings.show', b.id)} className="font-mono text-sm font-bold text-accent hover:underline">{b.booking_code}</Link>
                                    <p className="text-xs text-gray-400">{new Date(b.created_at).toLocaleDateString('id-ID')}</p>
                                </td>
                                <td>
                                    <p className="text-sm font-medium">{b.user?.name}</p>
                                    <p className="text-xs text-gray-400">{b.user?.phone}</p>
                                </td>
                                <td className="text-sm">
                                    {b.items?.[0]?.venue_field?.venue?.name}
                                    <br/><span className="text-xs text-gray-400">{b.items?.length} slot</span>
                                </td>
                                <td>{statusBadge(b.status)}</td>
                                <td>{b.payment && payBadge(b.payment.status)}</td>
                                <td className="text-sm">
                                    {b.payment?.method ? (
                                        <span className="font-medium">{getMethodLabel(b.payment.method)}</span>
                                    ) : (
                                        <span className="text-xs text-gray-300">—</span>
                                    )}
                                </td>
                                <td className="font-semibold text-sm">Rp {parseInt(b.total_amount).toLocaleString('id-ID')}</td>
                                <td><Link href={route('admin.bookings.show', b.id)} className="btn-ghost btn-sm text-xs">Detail</Link></td>
                            </tr>
                        ))}
                        {(!bookings?.data || bookings.data.length === 0) && <tr><td colSpan="8" className="text-center py-8 text-gray-400">Belum ada booking</td></tr>}
                    </tbody>
                </table>
            </div>
            {bookings?.links?.length > 3 && <div className="flex justify-center gap-1 mt-4">{bookings.links.map((l, i) => <Link key={i} href={l.url || '#'} className={`px-3 py-2 text-sm rounded-lg ${l.active ? 'bg-primary text-white' : l.url ? 'text-gray-600 hover:bg-gray-100' : 'text-gray-300'}`} dangerouslySetInnerHTML={{ __html: l.label }} preserveState />)}</div>}
        </AdminLayout>
    );
}

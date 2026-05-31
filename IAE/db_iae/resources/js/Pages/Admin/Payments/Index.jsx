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
    other_va: '🏦 Virtual Account',
};

const getMethodLabel = (method) => {
    if (!method) return '—';
    return methodLabels[method] || method.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

export default function PaymentsIndex({ payments, filters, stats }) {
    const payBadge = (s) => {
        const m = {
            pending: 'badge-warning',
            paid: 'badge-success',
            failed: 'badge-danger',
            expired: 'badge-danger',
            refunded: 'badge-neutral',
        };
        const labels = {
            pending: 'Menunggu',
            paid: 'Lunas',
            failed: 'Gagal',
            expired: 'Kadaluarsa',
            refunded: 'Refund',
        };
        return <span className={m[s] || 'badge-neutral'}>{labels[s] || s}</span>;
    };

    return (
        <AdminLayout title="Manajemen Pembayaran">
            <Head title="Manajemen Pembayaran" />
            <h1 className="text-xl font-bold text-gray-900 mb-6">Manajemen Pembayaran</h1>

            {/* Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                <div className="card p-4">
                    <p className="text-2xl font-bold text-emerald-600">Rp {parseInt(stats.total_paid).toLocaleString('id-ID')}</p>
                    <p className="text-xs text-gray-500">Total Diterima ({stats.count_paid})</p>
                </div>
                <div className="card p-4">
                    <p className="text-2xl font-bold text-amber-600">Rp {parseInt(stats.total_pending).toLocaleString('id-ID')}</p>
                    <p className="text-xs text-gray-500">Pending ({stats.count_pending})</p>
                </div>
            </div>

            {/* Filters */}
            <div className="card p-4 mb-6">
                <div className="flex flex-wrap gap-3">
                    <input type="text" placeholder="Cari..." defaultValue={filters?.search} onKeyDown={e => { if (e.key === 'Enter') router.get(route('admin.payments.index'), { ...filters, search: e.target.value }, { preserveState: true }); }} className="input w-64" />
                    <select defaultValue={filters?.status || ''} onChange={e => router.get(route('admin.payments.index'), { ...filters, status: e.target.value || undefined }, { preserveState: true })} className="input w-48">
                        <option value="">Semua</option>
                        <option value="pending">Menunggu</option>
                        <option value="paid">Lunas</option>
                        <option value="refunded">Refund</option>
                        <option value="failed">Gagal</option>
                        <option value="expired">Kadaluarsa</option>
                    </select>
                </div>
            </div>

            {/* Info Banner */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm text-blue-700 mb-4 flex items-start gap-2">
                <svg className="w-4 h-4 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" /></svg>
                <span>Pembayaran otomatis diverifikasi setelah customer menyelesaikan pembayaran melalui Midtrans. Status akan berubah ke <strong>Lunas</strong> dan booking menjadi <strong>Confirmed</strong> secara otomatis.</span>
            </div>

            {/* Table */}
            <div className="table-container">
                <table className="table">
                    <thead>
                        <tr>
                            <th>Booking</th>
                            <th>Customer</th>
                            <th>Jumlah</th>
                            <th>Metode</th>
                            <th>Status</th>
                            <th>Waktu Bayar</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        {payments?.data?.map(p => (
                            <tr key={p.id}>
                                <td>
                                    <span className="font-mono text-sm font-bold">{p.booking?.booking_code}</span>
                                    <p className="text-xs text-gray-400">{new Date(p.created_at).toLocaleDateString('id-ID')}</p>
                                </td>
                                <td className="text-sm">{p.booking?.user?.name}</td>
                                <td className="font-semibold">Rp {parseInt(p.amount).toLocaleString('id-ID')}</td>
                                <td>
                                    {p.method ? (
                                        <span className="text-sm font-medium">{getMethodLabel(p.method)}</span>
                                    ) : (
                                        <span className="text-xs text-gray-400 italic">Belum dipilih</span>
                                    )}
                                </td>
                                <td>{payBadge(p.status)}</td>
                                <td className="text-xs text-gray-500">
                                    {p.paid_at ? (
                                        <>
                                            <span className="block">{new Date(p.paid_at).toLocaleDateString('id-ID')}</span>
                                            <span className="text-gray-400">{new Date(p.paid_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })}</span>
                                        </>
                                    ) : (
                                        <span className="text-gray-300">—</span>
                                    )}
                                </td>
                                <td>
                                    <div className="flex gap-1">
                                        {p.status === 'paid' && <button onClick={() => { if (confirm('Proses refund pembayaran ini?')) router.post(route('admin.payments.refund', p.id)); }} className="btn-ghost btn-sm text-xs text-amber-600">Refund</button>}
                                        {p.status === 'pending' && (
                                            <>
                                                <button onClick={() => { if (confirm('Verifikasi pembayaran ini secara manual?')) router.post(route('admin.payments.verify', p.id)); }} className="btn-ghost btn-sm text-xs text-emerald-600">Verify</button>
                                                <button onClick={() => { if (confirm('Tolak pembayaran ini?')) router.post(route('admin.payments.reject', p.id)); }} className="btn-ghost btn-sm text-xs text-red-600">Tolak</button>
                                            </>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                        {(!payments?.data || payments.data.length === 0) && (
                            <tr><td colSpan="7" className="text-center py-8 text-gray-400">Belum ada pembayaran</td></tr>
                        )}
                    </tbody>
                </table>
            </div>
            {payments?.links?.length > 3 && (
                <div className="flex justify-center gap-1 mt-4">
                    {payments.links.map((l, i) => (
                        <Link key={i} href={l.url || '#'} className={`px-3 py-2 text-sm rounded-lg ${l.active ? 'bg-primary text-white' : l.url ? 'text-gray-600 hover:bg-gray-100' : 'text-gray-300'}`} dangerouslySetInnerHTML={{ __html: l.label }} preserveState />
                    ))}
                </div>
            )}
        </AdminLayout>
    );
}

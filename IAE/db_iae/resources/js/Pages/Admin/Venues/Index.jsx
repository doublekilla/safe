import AdminLayout from '@/Layouts/AdminLayout';
import { Head, Link, router } from '@inertiajs/react';
import { getSportEmoji, getSportLabel, getSportBadge } from '@/utils/sportTypes';


export default function VenuesIndex({ venues, filters }) {
    return (
        <AdminLayout title="Manajemen Lapangan">
            <Head title="Manajemen Lapangan" />
            <div className="flex items-center justify-between mb-6">
                <div>
                    <h1 className="text-xl font-bold text-gray-900">Lapangan</h1>
                    <p className="text-sm text-gray-500">Kelola semua lapangan olahraga</p>
                </div>
                <Link href={route('admin.venues.create')} className="btn-accent">+ Tambah Lapangan</Link>
            </div>
            {/* Filters */}
            <div className="card p-4 mb-6">
                <div className="flex flex-wrap gap-3">
                    <input type="text" placeholder="Cari lapangan..." defaultValue={filters?.search} onKeyDown={e => { if (e.key === 'Enter') router.get(route('admin.venues.index'), { ...filters, search: e.target.value }, { preserveState: true }); }} className="input w-64" />
                    <select defaultValue={filters?.sport_type || ''} onChange={e => router.get(route('admin.venues.index'), { ...filters, sport_type: e.target.value || undefined }, { preserveState: true })} className="input w-48">
                        <option value="">Semua Jenis</option><option value="badminton">🏸 Badminton</option><option value="futsal">⚽ Futsal</option><option value="basketball">🏀 Basket</option><option value="padel">🎾 Padel</option><option value="volleyball">🏐 Voli</option>
                    </select>
                    <select defaultValue={filters?.status || ''} onChange={e => router.get(route('admin.venues.index'), { ...filters, status: e.target.value || undefined }, { preserveState: true })} className="input w-48">
                        <option value="">Semua Status</option><option value="active">Active</option><option value="inactive">Inactive</option><option value="maintenance">Maintenance</option>
                    </select>
                </div>
            </div>
            {/* Table */}
            <div className="table-container">
                <table className="table">
                    <thead><tr><th>Nama</th><th>Jenis</th><th>Lokasi</th><th>Harga/Jam</th><th>Lapangan</th><th>Status</th><th>Aksi</th></tr></thead>
                    <tbody>
                        {venues?.data?.length > 0 ? venues.data.map(venue => (
                            <tr key={venue.id}>
                                <td className="font-medium">{venue.name}</td>
                                <td><span className={`badge ${getSportBadge(venue.sport_type)}`}>{getSportEmoji(venue.sport_type)} {getSportLabel(venue.sport_type)}</span></td>
                                <td className="text-sm text-gray-500">{venue.location}</td>
                                <td className="font-semibold">Rp {parseInt(venue.price_per_hour).toLocaleString('id-ID')}</td>
                                <td>{venue.fields_count} unit</td>
                                <td><span className={`badge ${venue.status === 'active' ? 'badge-success' : venue.status === 'maintenance' ? 'badge-warning' : 'badge-danger'}`}>{venue.status}</span></td>
                                <td>
                                    <div className="flex gap-1">
                                        <Link href={route('admin.venues.edit', venue.id)} className="btn-ghost btn-sm text-xs">Edit</Link>
                                        <Link href={route('admin.venues.fields', venue.id)} className="btn-ghost btn-sm text-xs">Fields</Link>
                                        <button onClick={() => { if (confirm('Hapus lapangan ini?')) router.delete(route('admin.venues.destroy', venue.id)); }} className="btn-ghost btn-sm text-xs text-red-600">Hapus</button>
                                    </div>
                                </td>
                            </tr>
                        )) : <tr><td colSpan="7" className="text-center py-8 text-gray-400">Belum ada lapangan</td></tr>}
                    </tbody>
                </table>
            </div>
        </AdminLayout>
    );
}

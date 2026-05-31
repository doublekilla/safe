import AdminLayout from '@/Layouts/AdminLayout';
import { Head, Link, useForm, router } from '@inertiajs/react';


export default function VenueFields({ venue }) {
    const { data, setData, post, processing, errors, reset } = useForm({ name: '', status: 'active', photo: null });
    const handleSubmit = (e) => { e.preventDefault(); post(route('admin.venues.fields.store', venue.id), { forceFormData: true, onSuccess: () => reset() }); };

    return (
        <AdminLayout title={`Fields - ${venue.name}`}>
            <Head title={`Fields - ${venue.name}`} />
            <Link href={route('admin.venues.index')} className="text-sm text-gray-500 hover:text-gray-700">← Kembali ke Lapangan</Link>
            <h1 className="text-xl font-bold text-gray-900 mt-2 mb-6">{venue.name} — Kelola Lapangan/Court</h1>
            {/* Add Form */}
            <div className="card p-6 mb-6">
                <h3 className="font-semibold text-gray-900 mb-3">Tambah Lapangan Baru</h3>
                <form onSubmit={handleSubmit} className="flex flex-wrap gap-3 items-end">
                    <div className="flex-1 min-w-[200px]"><label className="input-label">Nama</label><input type="text" value={data.name} onChange={e => setData('name', e.target.value)} className="input" placeholder="Contoh: Court A" />{errors.name && <p className="input-error-msg">{errors.name}</p>}</div>
                    <div><label className="input-label">Status</label><select value={data.status} onChange={e => setData('status', e.target.value)} className="input"><option value="active">Active</option><option value="inactive">Inactive</option><option value="maintenance">Maintenance</option></select></div>
                    <button type="submit" disabled={processing} className="btn-accent">{processing ? '...' : 'Tambah'}</button>
                </form>
            </div>
            {/* Fields List */}
            <div className="table-container">
                <table className="table">
                    <thead><tr><th>Nama</th><th>Status</th><th>Aksi</th></tr></thead>
                    <tbody>
                        {venue.fields?.map(field => (
                            <tr key={field.id}>
                                <td className="font-medium">{field.name}</td>
                                <td><span className={`badge ${field.status === 'active' ? 'badge-success' : field.status === 'maintenance' ? 'badge-warning' : 'badge-danger'}`}>{field.status}</span></td>
                                <td><button onClick={() => { if (confirm('Hapus lapangan ini?')) router.delete(route('admin.fields.destroy', field.id)); }} className="btn-ghost btn-sm text-xs text-red-600">Hapus</button></td>
                            </tr>
                        ))}
                        {(!venue.fields || venue.fields.length === 0) && <tr><td colSpan="3" className="text-center py-6 text-gray-400">Belum ada lapangan</td></tr>}
                    </tbody>
                </table>
            </div>
        </AdminLayout>
    );
}

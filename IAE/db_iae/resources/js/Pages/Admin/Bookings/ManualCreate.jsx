import AdminLayout from '@/Layouts/AdminLayout';
import { Head, useForm } from '@inertiajs/react';
import { useState, useEffect } from 'react';
import axios from 'axios';


export default function ManualCreate({ venues }) {
    const { data, setData, post, processing, errors } = useForm({ customer_name: '', customer_phone: '', schedule_ids: [], payment_method: 'cash', notes: '' });
    const [selField, setSelField] = useState('');
    const toLocalDateStr = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    const [selDate, setSelDate] = useState(toLocalDateStr(new Date()));
    const [schedules, setSchedules] = useState([]);
    const [loading, setLoading] = useState(false);
    const allFields = venues?.flatMap(v => v.fields?.map(f => ({ ...f, venue_name: v.name })) || []) || [];

    useEffect(() => {
        if (selField && selDate) {
            setLoading(true);
            axios.get(route('schedules.available'), { params: { venue_field_id: selField, date: selDate } })
                .then(r => setSchedules(r.data.schedules?.filter(s => s.status === 'available') || []))
                .finally(() => setLoading(false));
        }
    }, [selField, selDate]);

    const toggleSlot = (id) => setData('schedule_ids', data.schedule_ids.includes(id) ? data.schedule_ids.filter(s => s !== id) : [...data.schedule_ids, id]);
    const handleSubmit = (e) => { e.preventDefault(); post(route('admin.bookings.manual-store')); };

    return (
        <AdminLayout title="Booking Manual">
            <Head title="Booking Manual" />
            <h1 className="text-xl font-bold text-gray-900 mb-6">Booking Manual (Walk-in / Telepon)</h1>
            <form onSubmit={handleSubmit} className="max-w-4xl space-y-6">
                <div className="card p-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div><label className="input-label">Nama Customer *</label><input type="text" value={data.customer_name} onChange={e => setData('customer_name', e.target.value)} className="input" /></div>
                    <div><label className="input-label">No. Telepon *</label><input type="tel" value={data.customer_phone} onChange={e => setData('customer_phone', e.target.value)} className="input" /></div>
                </div>
                <div className="card p-6">
                    <h3 className="font-semibold text-gray-900 mb-3">Pilih Jadwal</h3>
                    <div className="flex gap-3 mb-4">
                        <select value={selField} onChange={e => setSelField(e.target.value)} className="input flex-1"><option value="">Pilih lapangan</option>{allFields.map(f => <option key={f.id} value={f.id}>{f.venue_name} — {f.name}</option>)}</select>
                        <input type="date" value={selDate} onChange={e => setSelDate(e.target.value)} className="input w-48" />
                    </div>
                    {loading ? <div className="text-center py-4 text-gray-400">Loading...</div> :
                    schedules.length > 0 ? (
                        <div className="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-6 gap-2">
                            {schedules.map(s => (
                                <button key={s.id} type="button" onClick={() => toggleSlot(s.id)}
                                    className={`p-3 rounded-lg border-2 text-center text-sm transition-all ${data.schedule_ids.includes(s.id) ? 'border-accent bg-accent/10 text-accent-dark font-bold' : 'border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100'}`}>
                                    {s.start_time?.substring(0, 5)}-{s.end_time?.substring(0, 5)}<br/><span className="text-[10px]">Rp {parseInt(s.price).toLocaleString('id-ID')}</span>
                                </button>
                            ))}
                        </div>
                    ) : selField ? <p className="text-center text-gray-400 py-4">Tidak ada slot tersedia</p> : null}
                    {data.schedule_ids.length > 0 && <p className="mt-3 text-sm font-medium text-accent">{data.schedule_ids.length} slot dipilih</p>}
                </div>
                <div className="card p-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div><label className="input-label">Metode Bayar</label><select value={data.payment_method} onChange={e => setData('payment_method', e.target.value)} className="input"><option value="cash">Cash</option><option value="transfer_bank">Transfer Bank</option><option value="ewallet">E-Wallet</option></select></div>
                    <div><label className="input-label">Catatan</label><input type="text" value={data.notes} onChange={e => setData('notes', e.target.value)} className="input" placeholder="Opsional" /></div>
                </div>
                <button type="submit" disabled={processing || data.schedule_ids.length === 0} className="btn-accent">{processing ? 'Memproses...' : 'Buat Booking'}</button>
            </form>
        </AdminLayout>
    );
}

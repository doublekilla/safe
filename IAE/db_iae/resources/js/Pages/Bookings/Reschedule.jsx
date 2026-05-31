import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';
import { useState, useEffect } from 'react';
import axios from 'axios';


export default function Reschedule({ booking }) {
    const [selectedItem, setSelectedItem] = useState(null);
    // Helper to format date as YYYY-MM-DD in local timezone (avoids UTC shift from toISOString)
    const toLocalDateStr = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

    const [newSchedules, setNewSchedules] = useState([]);
    const [selectedDate, setSelectedDate] = useState(toLocalDateStr(new Date()));
    const [loading, setLoading] = useState(false);
    const [selections, setSelections] = useState({});

    const dates = Array.from({ length: 14 }, (_, i) => {
        const d = new Date(); d.setDate(d.getDate() + i);
        return { date: toLocalDateStr(d), label: d.toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' }) };
    });

    useEffect(() => {
        if (selectedItem) fetchSchedules();
    }, [selectedItem, selectedDate]);

    const fetchSchedules = async () => {
        setLoading(true);
        try {
            const res = await axios.get(route('schedules.available'), { params: { venue_field_id: selectedItem.venue_field_id, date: selectedDate } });
            setNewSchedules(res.data.schedules?.filter(s => s.status === 'available') || []);
        } catch { setNewSchedules([]); }
        setLoading(false);
    };

    const [processing, setProcessing] = useState(false);
    const handleSubmit = () => {
        const items = Object.entries(selections).map(([bookingItemId, scheduleId]) => ({ booking_item_id: parseInt(bookingItemId), new_schedule_id: scheduleId }));
        if (items.length === 0) return;
        setProcessing(true);
        router.post(route('reschedule.store', booking.id), { items }, {
            onFinish: () => setProcessing(false),
        });
    };

    return (
        <CustomerLayout>
            <Head title="Reschedule Booking" />
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-2xl font-bold text-gray-900 mb-6">🔄 Reschedule Booking</h1>
                <p className="text-gray-500 mb-6">Kode Booking: <span className="font-mono font-bold text-primary">{booking.booking_code}</span></p>

                <div className="space-y-4 mb-6">
                    <h3 className="font-bold text-gray-900">Pilih slot yang ingin diubah:</h3>
                    {booking.items?.map(item => (
                        <button key={item.id} onClick={() => setSelectedItem(item)}
                            className={`card p-4 w-full text-left transition-all ${selectedItem?.id === item.id ? 'border-2 border-accent bg-accent/5' : 'hover:shadow-card-hover'}`}>
                            <p className="font-medium text-sm">{item.venue_field?.venue?.name} — {item.venue_field?.name}</p>
                            <p className="text-xs text-gray-500">{new Date(item.date).toLocaleDateString('id-ID')} | {item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}</p>
                            {selections[item.id] && <span className="badge-success mt-1">Jadwal baru dipilih ✓</span>}
                        </button>
                    ))}
                </div>

                {selectedItem && (
                    <div className="card p-6 mb-6">
                        <h3 className="font-bold text-gray-900 mb-4">Pilih jadwal baru:</h3>
                        <div className="flex gap-2 overflow-x-auto pb-2 mb-4 scrollbar-thin">
                            {dates.map(d => (
                                <button key={d.date} onClick={() => setSelectedDate(d.date)}
                                    className={`flex-shrink-0 px-3 py-2 rounded-lg text-xs font-medium border-2 ${selectedDate === d.date ? 'border-primary bg-primary text-white' : 'border-gray-200 text-gray-600 hover:border-gray-300'}`}>
                                    {d.label}
                                </button>
                            ))}
                        </div>
                        {loading ? (
                            <div className="grid grid-cols-4 gap-2">{Array.from({ length: 8 }).map((_, i) => <div key={i} className="skeleton h-14 rounded-lg" />)}</div>
                        ) : newSchedules.length > 0 ? (
                            <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
                                {newSchedules.map(slot => (
                                    <button key={slot.id} onClick={() => setSelections(prev => ({ ...prev, [selectedItem.id]: slot.id }))}
                                        className={`p-3 rounded-lg border-2 text-center transition-all ${selections[selectedItem.id] === slot.id ? 'border-accent bg-accent/10 text-accent-dark' : 'border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100'}`}>
                                        <div className="text-sm font-semibold">{slot.start_time?.substring(0, 5)} - {slot.end_time?.substring(0, 5)}</div>
                                        <div className="text-[10px]">Rp {parseInt(slot.price).toLocaleString('id-ID')}</div>
                                    </button>
                                ))}
                            </div>
                        ) : (
                            <p className="text-center text-gray-400 py-4">Tidak ada slot tersedia untuk tanggal ini</p>
                        )}
                    </div>
                )}

                <div className="flex gap-3">
                    <button onClick={handleSubmit} disabled={Object.keys(selections).length === 0 || processing} className="btn-accent">
                        {processing ? 'Memproses...' : 'Konfirmasi Reschedule'}
                    </button>
                    <Link href={route('bookings.show', booking.id)} className="btn-ghost">Kembali</Link>
                </div>
            </div>
        </CustomerLayout>
    );
}

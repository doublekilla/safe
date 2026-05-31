import AdminLayout from '@/Layouts/AdminLayout';
import { Head, router, useForm, usePage } from '@inertiajs/react';
import { useState } from 'react';


const getLocalDate = (d = new Date()) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
};

export default function SchedulesIndex({ venues, schedules, filters }) {
    const { flash } = usePage().props;
    const [selectedFieldId, setSelectedFieldId] = useState(filters.venue_field_id || '');
    const [date, setDate] = useState(filters.date || getLocalDate());
    const [showGenerate, setShowGenerate] = useState(false);
    const [showBlockRange, setShowBlockRange] = useState(false);
    const [bulkProcessing, setBulkProcessing] = useState(null); // 'open' | 'block' | null

    const allFields = venues?.flatMap(v => v.fields?.map(f => ({ ...f, venue_name: v.name, sport_type: v.sport_type })) || []) || [];

    const loadSchedules = () => {
        if (selectedFieldId) router.get(route('admin.schedules.index'), { venue_field_id: selectedFieldId, date }, { preserveState: true });
    };

    // Available time slots (from schedules) for block range dropdown
    const uniqueTimeSlots = [...new Set(schedules?.map(s => `${s.start_time?.substring(0, 5)}-${s.end_time?.substring(0, 5)}`) || [])];

    // ===== GENERATE FORM =====
    const genForm = useForm({
        venue_field_id: '',
        start_date: getLocalDate(),
        end_date: '',
        start_hour: 8,
        end_hour: 22,
        slot_duration: 60,
        price: 75000,
    });

    const handleGenerate = (e) => {
        e.preventDefault();
        genForm.post(route('admin.schedules.generate'), {
            onSuccess: () => {
                setShowGenerate(false);
                if (selectedFieldId) {
                    router.get(route('admin.schedules.index'), { venue_field_id: selectedFieldId, date }, { preserveState: true });
                }
            },
            preserveScroll: true,
        });
    };

    // ===== BLOCK RANGE FORM =====
    const blockRangeForm = useForm({
        venue_field_id: selectedFieldId,
        start_date: getLocalDate(),
        end_date: '',
        start_time: '10:00',
        end_time: '11:00',
        action: 'block',
    });

    const handleBlockRange = (e) => {
        e.preventDefault();
        blockRangeForm.data.venue_field_id = selectedFieldId;
        const actionLabel = blockRangeForm.data.action === 'block' ? 'memblokir' : 'membuka';
        if (!confirm(`Yakin ingin ${actionLabel} jadwal ${blockRangeForm.data.start_time} - ${blockRangeForm.data.end_time} dari ${blockRangeForm.data.start_date} s/d ${blockRangeForm.data.end_date}?`)) return;

        blockRangeForm.post(route('admin.schedules.block-range'), {
            onSuccess: () => {
                setShowBlockRange(false);
                if (selectedFieldId) {
                    router.get(route('admin.schedules.index'), { venue_field_id: selectedFieldId, date }, { preserveState: true });
                }
            },
            preserveScroll: true,
        });
    };

    // ===== BULK ACTIONS =====
    const handleOpenAll = () => {
        if (!selectedFieldId || !date) return;
        if (!confirm('Buka semua jadwal pada tanggal ini? (kecuali yang sudah dipesan)')) return;
        setBulkProcessing('open');
        router.post(route('admin.schedules.open-all'), { venue_field_id: selectedFieldId, date }, {
            preserveScroll: true,
            onFinish: () => setBulkProcessing(null),
        });
    };

    const handleBlockAll = () => {
        if (!selectedFieldId || !date) return;
        if (!confirm('Blokir semua jadwal pada tanggal ini? (kecuali yang sudah dipesan)')) return;
        setBulkProcessing('block');
        router.post(route('admin.schedules.block-all'), { venue_field_id: selectedFieldId, date }, {
            preserveScroll: true,
            onFinish: () => setBulkProcessing(null),
        });
    };

    // ===== INDIVIDUAL ACTIONS =====
    const statusColors = {
        available: 'bg-emerald-100 text-emerald-700 border border-emerald-200',
        booked: 'bg-red-100 text-red-700 border border-red-200',
        pending: 'bg-amber-100 text-amber-700 border border-amber-200',
        blocked: 'bg-gray-100 text-gray-500 border border-gray-200',
        maintenance: 'bg-blue-100 text-blue-700 border border-blue-200',
    };

    const updateStatus = (id, status) => router.put(route('admin.schedules.update-status', id), { status }, { preserveScroll: true });
    const deleteSchedule = (id) => { if (confirm('Hapus slot ini?')) router.delete(route('admin.schedules.destroy', id), { preserveScroll: true }); };

    // Stats
    const availableCount = schedules?.filter(s => s.status === 'available').length || 0;
    const blockedCount = schedules?.filter(s => s.status === 'blocked').length || 0;
    const bookedCount = schedules?.filter(s => ['booked', 'pending'].includes(s.status)).length || 0;

    return (
        <AdminLayout title="Manajemen Jadwal">
            <Head title="Manajemen Jadwal" />
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-xl font-bold text-gray-900">Manajemen Jadwal</h1>
                <div className="flex gap-2">
                    <button onClick={() => { setShowBlockRange(!showBlockRange); setShowGenerate(false); }} className="btn-ghost text-sm">
                        {showBlockRange ? 'Tutup' : '🔒 Blokir Rentang'}
                    </button>
                    <button onClick={() => { setShowGenerate(!showGenerate); setShowBlockRange(false); }} className="btn-accent">
                        {showGenerate ? 'Tutup' : '+ Generate Jadwal'}
                    </button>
                </div>
            </div>

            {/* Flash Messages */}
            {flash?.success && (
                <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-lg text-sm text-emerald-700 flex items-center gap-2">
                    <svg className="w-4 h-4 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" /></svg>
                    {flash.success}
                </div>
            )}

            {/* ===== GENERATE FORM ===== */}
            {showGenerate && (
                <div className="card p-6 mb-6 animate-fade-in-down">
                    <h3 className="font-semibold text-gray-900 mb-4">Generate Slot Jadwal</h3>
                    <form onSubmit={handleGenerate} className="space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            <div>
                                <label className="input-label">Lapangan *</label>
                                <select value={genForm.data.venue_field_id} onChange={e => genForm.setData('venue_field_id', e.target.value)} className={`input ${genForm.errors.venue_field_id ? 'input-error' : ''}`}>
                                    <option value="">Pilih lapangan</option>
                                    {venues?.map(v => (
                                        <optgroup key={v.id} label={v.name}>
                                            {v.fields?.map(f => (
                                                <option key={f.id} value={f.id}>{f.name}</option>
                                            ))}
                                        </optgroup>
                                    ))}
                                </select>
                                {genForm.errors.venue_field_id && <p className="input-error-msg">{genForm.errors.venue_field_id}</p>}
                            </div>
                            <div>
                                <label className="input-label">Tanggal Mulai *</label>
                                <input type="date" value={genForm.data.start_date} onChange={e => genForm.setData('start_date', e.target.value)} className={`input ${genForm.errors.start_date ? 'input-error' : ''}`} />
                                {genForm.errors.start_date && <p className="input-error-msg">{genForm.errors.start_date}</p>}
                            </div>
                            <div>
                                <label className="input-label">Tanggal Selesai *</label>
                                <input type="date" value={genForm.data.end_date} onChange={e => genForm.setData('end_date', e.target.value)} className={`input ${genForm.errors.end_date ? 'input-error' : ''}`} />
                                {genForm.errors.end_date && <p className="input-error-msg">{genForm.errors.end_date}</p>}
                            </div>
                            <div>
                                <label className="input-label">Jam Mulai</label>
                                <select value={genForm.data.start_hour} onChange={e => genForm.setData('start_hour', parseInt(e.target.value))} className="input">
                                    {Array.from({ length: 24 }, (_, i) => (
                                        <option key={i} value={i}>{String(i).padStart(2, '0')}:00</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="input-label">Jam Selesai</label>
                                <select value={genForm.data.end_hour} onChange={e => genForm.setData('end_hour', parseInt(e.target.value))} className="input">
                                    {Array.from({ length: 24 }, (_, i) => i + 1).map(i => (
                                        <option key={i} value={i}>{String(i).padStart(2, '0')}:00</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="input-label">Durasi Slot</label>
                                <select value={genForm.data.slot_duration} onChange={e => genForm.setData('slot_duration', parseInt(e.target.value))} className="input">
                                    <option value={60}>1 Jam (60 menit)</option>
                                    <option value={90}>1.5 Jam (90 menit)</option>
                                    <option value={120}>2 Jam (120 menit)</option>
                                </select>
                            </div>
                            <div>
                                <label className="input-label">Harga per Slot (Rp) *</label>
                                <input type="number" value={genForm.data.price} onChange={e => genForm.setData('price', e.target.value)} className={`input ${genForm.errors.price ? 'input-error' : ''}`} placeholder="75000" />
                                {genForm.errors.price && <p className="input-error-msg">{genForm.errors.price}</p>}
                            </div>
                        </div>
                        <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm text-blue-700">
                            ℹ️ Slot yang sudah ada pada tanggal & jam yang sama akan <strong>dilewati</strong> (tidak ditimpa).
                        </div>
                        <div className="flex gap-3">
                            <button type="submit" disabled={genForm.processing} className="btn-accent">
                                {genForm.processing ? 'Generating...' : '⚡ Generate Jadwal'}
                            </button>
                            <button type="button" onClick={() => setShowGenerate(false)} className="btn-ghost">Batal</button>
                        </div>
                    </form>
                </div>
            )}

            {/* ===== BLOCK RANGE FORM ===== */}
            {showBlockRange && (
                <div className="card p-6 mb-6 animate-fade-in-down border-l-4 border-l-amber-400">
                    <h3 className="font-semibold text-gray-900 mb-1">Blokir / Buka Rentang Jadwal</h3>
                    <p className="text-sm text-gray-500 mb-4">Blokir atau buka jam tertentu secara massal dalam rentang tanggal.</p>
                    <form onSubmit={handleBlockRange} className="space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            <div>
                                <label className="input-label">Lapangan</label>
                                <select
                                    value={selectedFieldId}
                                    onChange={e => setSelectedFieldId(e.target.value)}
                                    className="input"
                                    disabled
                                >
                                    <option value="">Pilih lapangan di filter</option>
                                    {allFields.map(f => (
                                        <option key={f.id} value={f.id}>{f.venue_name} — {f.name}</option>
                                    ))}
                                </select>
                                {!selectedFieldId && <p className="input-error-msg">Pilih lapangan terlebih dahulu di filter atas</p>}
                            </div>
                            <div>
                                <label className="input-label">Tanggal Mulai *</label>
                                <input type="date" value={blockRangeForm.data.start_date} onChange={e => blockRangeForm.setData('start_date', e.target.value)} className={`input ${blockRangeForm.errors.start_date ? 'input-error' : ''}`} />
                                {blockRangeForm.errors.start_date && <p className="input-error-msg">{blockRangeForm.errors.start_date}</p>}
                            </div>
                            <div>
                                <label className="input-label">Tanggal Selesai *</label>
                                <input type="date" value={blockRangeForm.data.end_date} onChange={e => blockRangeForm.setData('end_date', e.target.value)} className={`input ${blockRangeForm.errors.end_date ? 'input-error' : ''}`} />
                                {blockRangeForm.errors.end_date && <p className="input-error-msg">{blockRangeForm.errors.end_date}</p>}
                            </div>
                            <div>
                                <label className="input-label">Jam Mulai *</label>
                                <select value={blockRangeForm.data.start_time} onChange={e => blockRangeForm.setData('start_time', e.target.value)} className="input">
                                    {Array.from({ length: 24 }, (_, i) => (
                                        <option key={i} value={`${String(i).padStart(2, '0')}:00`}>{String(i).padStart(2, '0')}:00</option>
                                    ))}
                                </select>
                                {blockRangeForm.errors.start_time && <p className="input-error-msg">{blockRangeForm.errors.start_time}</p>}
                            </div>
                            <div>
                                <label className="input-label">Jam Selesai *</label>
                                <select value={blockRangeForm.data.end_time} onChange={e => blockRangeForm.setData('end_time', e.target.value)} className="input">
                                    {Array.from({ length: 24 }, (_, i) => i + 1).map(i => (
                                        <option key={i} value={`${String(i).padStart(2, '0')}:00`}>{String(i).padStart(2, '0')}:00</option>
                                    ))}
                                </select>
                                {blockRangeForm.errors.end_time && <p className="input-error-msg">{blockRangeForm.errors.end_time}</p>}
                            </div>
                            <div>
                                <label className="input-label">Aksi</label>
                                <select value={blockRangeForm.data.action} onChange={e => blockRangeForm.setData('action', e.target.value)} className="input">
                                    <option value="block">🔒 Blokir</option>
                                    <option value="open">🔓 Buka</option>
                                </select>
                            </div>
                        </div>

                        {/* Preview info */}
                        <div className={`rounded-lg p-3 text-sm flex items-start gap-2 ${blockRangeForm.data.action === 'block' ? 'bg-red-50 border border-red-200 text-red-700' : 'bg-emerald-50 border border-emerald-200 text-emerald-700'}`}>
                            <span className="flex-shrink-0">{blockRangeForm.data.action === 'block' ? '⚠️' : '✅'}</span>
                            <span>
                                Akan <strong>{blockRangeForm.data.action === 'block' ? 'memblokir' : 'membuka'}</strong> jadwal&nbsp;
                                <strong>{blockRangeForm.data.start_time} - {blockRangeForm.data.end_time}</strong>&nbsp;
                                dari tanggal <strong>{blockRangeForm.data.start_date}</strong> s/d <strong>{blockRangeForm.data.end_date || '...'}</strong>.
                                &nbsp;Jadwal yang sudah dipesan tidak akan terpengaruh.
                            </span>
                        </div>

                        <div className="flex gap-3">
                            <button type="submit" disabled={blockRangeForm.processing || !selectedFieldId} className={blockRangeForm.data.action === 'block' ? 'bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-50' : 'bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-50'}>
                                {blockRangeForm.processing ? 'Memproses...' : blockRangeForm.data.action === 'block' ? '🔒 Blokir Rentang' : '🔓 Buka Rentang'}
                            </button>
                            <button type="button" onClick={() => setShowBlockRange(false)} className="btn-ghost">Batal</button>
                        </div>
                    </form>
                </div>
            )}

            {/* Filter */}
            <div className="card p-4 mb-6">
                <div className="flex flex-wrap gap-3 items-end">
                    <div>
                        <label className="input-label">Lapangan</label>
                        <select value={selectedFieldId} onChange={e => setSelectedFieldId(e.target.value)} className="input w-72">
                            <option value="">Pilih lapangan</option>
                            {venues?.map(v => (
                                <optgroup key={v.id} label={v.name}>
                                    {v.fields?.map(f => (
                                        <option key={f.id} value={f.id}>{f.name}</option>
                                    ))}
                                </optgroup>
                            ))}
                        </select>
                    </div>
                    <div>
                        <label className="input-label">Tanggal</label>
                        <input type="date" value={date} onChange={e => setDate(e.target.value)} className="input" />
                    </div>
                    <button onClick={loadSchedules} className="btn-accent">Tampilkan</button>
                </div>
            </div>

            {/* Schedule Grid */}
            {schedules && schedules.length > 0 ? (
                <>
                    {/* Stat Bar + Bulk Actions */}
                    <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
                        <div className="flex gap-3 text-xs">
                            <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-700 font-medium">
                                <span className="w-2 h-2 rounded-full bg-emerald-500" />
                                Tersedia: {availableCount}
                            </span>
                            <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-gray-100 text-gray-600 font-medium">
                                <span className="w-2 h-2 rounded-full bg-gray-400" />
                                Diblokir: {blockedCount}
                            </span>
                            {bookedCount > 0 && (
                                <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-red-100 text-red-700 font-medium">
                                    <span className="w-2 h-2 rounded-full bg-red-500" />
                                    Dipesan: {bookedCount}
                                </span>
                            )}
                        </div>

                        <div className="flex gap-2">
                            <button
                                onClick={handleOpenAll}
                                disabled={bulkProcessing !== null}
                                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white transition-colors disabled:opacity-50"
                            >
                                {bulkProcessing === 'open' ? (
                                    <svg className="animate-spin h-3.5 w-3.5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                                ) : (
                                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 11V7a4 4 0 118 0m-4 8v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" /></svg>
                                )}
                                Open All
                            </button>
                            <button
                                onClick={handleBlockAll}
                                disabled={bulkProcessing !== null}
                                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold bg-red-600 hover:bg-red-700 text-white transition-colors disabled:opacity-50"
                            >
                                {bulkProcessing === 'block' ? (
                                    <svg className="animate-spin h-3.5 w-3.5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                                ) : (
                                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                                )}
                                Block All
                            </button>
                        </div>
                    </div>

                    {/* Table */}
                    <div className="table-container">
                        <table className="table">
                            <thead>
                                <tr>
                                    <th>Waktu</th>
                                    <th>Harga</th>
                                    <th>Status</th>
                                    <th>Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                {schedules.map(s => (
                                    <tr key={s.id}>
                                        <td className="font-mono font-semibold">{s.start_time?.substring(0, 5)} - {s.end_time?.substring(0, 5)}</td>
                                        <td>Rp {parseInt(s.price).toLocaleString('id-ID')}</td>
                                        <td>
                                            <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-semibold ${statusColors[s.status] || 'bg-gray-100 text-gray-500'}`}>
                                                {s.status}
                                            </span>
                                        </td>
                                        <td>
                                            <div className="flex gap-1">
                                                {s.status === 'available' && <button onClick={() => updateStatus(s.id, 'blocked')} className="btn-ghost btn-sm text-xs">Block</button>}
                                                {s.status === 'blocked' && <button onClick={() => updateStatus(s.id, 'available')} className="btn-ghost btn-sm text-xs text-emerald-600">Open</button>}
                                                {!['booked', 'pending'].includes(s.status) && <button onClick={() => deleteSchedule(s.id)} className="btn-ghost btn-sm text-xs text-red-600">Hapus</button>}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </>
            ) : selectedFieldId ? (
                <div className="card p-8 text-center text-gray-400">Tidak ada jadwal untuk tanggal ini. Gunakan "Generate Jadwal" untuk membuat slot.</div>
            ) : (
                <div className="card p-8 text-center text-gray-400">Pilih lapangan dan tanggal untuk melihat jadwal.</div>
            )}
        </AdminLayout>
    );
}
